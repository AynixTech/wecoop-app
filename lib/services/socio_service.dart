import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'dart:async';
import 'dart:io';
import '../utils/html_utils.dart';

class SocioService {
  static const String baseUrl = 'https://www.wecoop.org/wp-json/wecoop/v1';
  static final storage = SecureStorageService();

  /// Ottiene gli headers comuni per tutte le richieste
  static Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final languageCode = await storage.read(key: 'language_code') ?? 'it';
    final headers = {
      'Content-Type': 'application/json',
      'Accept-Language': languageCode,
    };
    
    if (includeAuth) {
      final token = await storage.read(key: 'jwt_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }

  /// Verifica se l'utente è un socio attivo (PUBBLICO)
  /// GET /soci/verifica/{email}
  static Future<bool> isSocio() async {
    try {
      final email = await storage.read(key: 'user_email');

      if (email == null) {
        print('Nessuna email trovata');
        return false;
      }

      final encodedEmail = Uri.encodeComponent(email);
      final url = '$baseUrl/soci/verifica/$encodedEmail';
      print('Verifico socio su: $url');

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        final data = decodeHtmlInMap(rawData);
        // Nuova API ritorna: {"success": true, "is_socio": true, "status": "attivo", "data_adesione": "2024-01-10"}
        return data['is_socio'] == true && data['status'] == 'attivo';
      }
      return false;
    } catch (e) {
      print('Errore verifica socio: $e');
      return false;
    }
  }

  /// Verifica se c'è una richiesta di adesione in attesa (PUBBLICO)
  /// GET /soci/verifica/{email}
  /// Ritorna true se is_socio è false (richiesta non ancora approvata ma presente)
  static Future<bool> hasRichiestaInAttesa() async {
    try {
      final email = await storage.read(key: 'user_email');

      if (email == null) return false;

      final encodedEmail = Uri.encodeComponent(email);
      final url = '$baseUrl/soci/verifica/$encodedEmail';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        final data = decodeHtmlInMap(rawData);
        // Se success è true ma is_socio è false, significa che c'è una richiesta pending
        // Quando approvata: is_socio=true, status=attivo
        return data['success'] == true && data['is_socio'] == false;
      }
      return false;
    } catch (e) {
      print('Errore verifica richiesta: $e');
      return false;
    }
  }

  /// Invia richiesta di adesione come socio (PUBBLICO - no auth richiesta)
  /// POST /soci/richiesta
  /// CAMPI OBBLIGATORI (7): nome, cognome, prefix, telefono, nazionalita, email, privacy_accepted
  /// CAMPI OPZIONALI: tutti gli altri
  /// Username generato: prefix + telefono (solo numeri, es: +39 3331234567 → 393331234567)
  static Future<Map<String, dynamic>> richiestaAdesioneSocio({
    required String nome,
    required String cognome,
    required String prefix,
    required String telefono,
    required String nazionalita,
    required String email,
    required bool privacyAccepted,
    String? codiceFiscale,
    String? dataNascita,
    String? luogoNascita,
    String? indirizzo,
    String? citta,
    String? cap,
    String? provincia,
    String? professione,
  }) async {
    try {
      final url = '$baseUrl/soci/richiesta';

      print('=== INVIANDO RICHIESTA ADESIONE SOCIO ===');
      print('URL: $url');

      final Map<String, dynamic> bodyData = {
        'nome': nome,
        'cognome': cognome,
        'prefix': prefix,
        'telefono': telefono,
        'nazionalita': nazionalita.toUpperCase(), // Assicura maiuscolo ISO (IT, EC, ES)
        'email': email,
        'privacy_accepted': privacyAccepted,
      };

      // Aggiungi campi opzionali solo se valorizzati
      if (codiceFiscale != null && codiceFiscale.isNotEmpty) bodyData['codice_fiscale'] = codiceFiscale;
      if (dataNascita != null && dataNascita.isNotEmpty) bodyData['data_nascita'] = dataNascita;
      if (luogoNascita != null && luogoNascita.isNotEmpty) bodyData['luogo_nascita'] = luogoNascita;
      if (indirizzo != null && indirizzo.isNotEmpty) bodyData['indirizzo'] = indirizzo;
      if (citta != null && citta.isNotEmpty) bodyData['citta'] = citta;
      if (cap != null && cap.isNotEmpty) bodyData['cap'] = cap;
      if (provincia != null && provincia.isNotEmpty) bodyData['provincia'] = provincia;
      if (professione != null && professione.isNotEmpty) bodyData['professione'] = professione;

      final body = jsonEncode(bodyData);
      print('Body: $body');

      final headers = await _getHeaders(includeAuth: false);
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final rawData = jsonDecode(response.body);
        final data = decodeHtmlInMap(rawData);
        // Nuova API ritorna: {"success": true, "message": "...", "data": {"username": "socio_123", "password": "abc123", "tessera_url": "..."}}
        return {
          'success': data['success'] ?? true,
          'message':
              data['message'] ?? 'Registrazione completata con successo',
          'username': data['data']?['username'],
          'password': data['data']?['password'],
          'tessera_url': data['data']?['tessera_url'],
        };
      } else if (response.statusCode == 400) {
        final rawData = jsonDecode(response.body);
        final errorData = decodeHtmlInMap(rawData);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Parametro mancante o non valido',
        };
      } else if (response.statusCode == 409) {
        final rawData = jsonDecode(response.body);
        final errorData = decodeHtmlInMap(rawData);
        return {
          'success': false,
          'message':
              errorData['message'] ??
              'Esiste già una registrazione con questo telefono o email',
        };
      } else {
        final rawData = jsonDecode(response.body);
        final errorData = decodeHtmlInMap(rawData);
        return {
          'success': false,
          'message':
              errorData['message'] ?? 'Errore durante l\'invio della richiesta',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Timeout: il server non risponde. Riprova più tardi.',
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Nessuna connessione internet. Verifica la connessione.',
      };
    } catch (e) {
      print('Errore generico: $e');
      return {
        'success': false,
        'message': 'Errore imprevisto: ${e.toString()}',
      };
    }
  }

  /// Invia richiesta servizio (SOLO SOCI ATTIVI)
  /// POST /richiesta-servizio
  static Future<Map<String, dynamic>> inviaRichiestaServizio({
    required String servizio,
    required String categoria,
    required Map<String, dynamic> dati,
  }) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      final url = '$baseUrl/richiesta-servizio';

      print('=== INVIANDO RICHIESTA SERVIZIO ===');
      print('URL: $url');
      print('Token presente: ${token != null}');

      final body = jsonEncode({
        'servizio': servizio,
        'categoria': categoria,
        'dati': dati,
      });

      print('Body: $body');

      final headers = <String, String>{'Content-Type': 'application/json'};

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .post(Uri.parse(url), headers: headers, body: body)
          .timeout(const Duration(seconds: 30));

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Nuova API ritorna: {"success": true, "message": "Richiesta ricevuta con successo", "id": 789, "numero_pratica": "WECOOP-2025-00001", "data_richiesta": "..."}
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Richiesta ricevuta con successo',
          'id': data['id'],
          'numero_pratica': data['numero_pratica'],
          'data_richiesta': data['data_richiesta'],
        };
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Campo obbligatorio mancante',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Devi essere autenticato. Effettua il login.',
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message':
              'Non hai i permessi. Solo i soci possono richiedere servizi.',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              errorData['message'] ?? 'Errore durante l\'invio della richiesta',
        };
      }
    } on TimeoutException {
      return {'success': false, 'message': 'Timeout: il server non risponde'};
    } on SocketException {
      return {'success': false, 'message': 'Nessuna connessione internet'};
    } catch (e) {
      print('Errore: $e');
      return {'success': false, 'message': 'Errore: ${e.toString()}'};
    }
  }

  /// Ottieni i dati completi dell'utente socio corrente (AUTENTICATO)
  /// GET /soci/me
  static Future<Map<String, dynamic>?> getMe() async {
    try {
      final token = await storage.read(key: 'jwt_token');

      if (token == null) {
        print('Token JWT mancante');
        return null;
      }

      final url = '$baseUrl/soci/me';
      print('🔄 Chiamata GET /soci/me...');

      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      print('📥 GET /soci/me status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        final responseData = decodeHtmlInMap(rawData);
        // API ritorna: {"success": true, "data": {...tutti i campi socio...}}
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'] as Map<String, dynamic>;
        }
      } else if (response.statusCode == 401) {
        print('⚠️ Token scaduto o non valido');
        return null;
      }

      return null;
    } catch (e) {
      print('❌ Errore durante GET /soci/me: $e');
      return null;
    }
  }

  /// Ottieni lista dei soci (AUTENTICATO - solo admin)
  /// GET /soci
  /// Restituisce array con: id, nome, cognome, email, telefono, username, status, etc.
  /// NOTA: username = numero di telefono completo (es: +393331234567)
  static Future<List<Map<String, dynamic>>> getSoci({
    String status = 'attivo',
    int perPage = 50,
    int page = 1,
    String? search,
  }) async {
    try {
      final token = await storage.read(key: 'jwt_token');

      if (token == null) {
        print('Token JWT mancante');
        return [];
      }

      final queryParams = <String, String>{
        'status': status,
        'per_page': perPage.toString(),
        'page': page.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse(
        '$baseUrl/soci',
      ).replace(queryParameters: queryParams);
      print('🔄 Chiamata GET /soci...');

      final headers = await _getHeaders();
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      print('📥 GET /soci status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        final responseData = decodeHtmlInMap(rawData);
        if (responseData['success'] == true && responseData['data'] != null) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        }
      }

      return [];
    } catch (e) {
      print('❌ Errore durante GET /soci: $e');
      return [];
    }
  }

  /// Ottieni lista richieste servizi dell'utente corrente (AUTENTICATO)
  /// GET /mie-richieste
  static Future<Map<String, dynamic>> getRichiesteUtente({
    int page = 1,
    int perPage = 20,
    String? stato,
  }) async {
    try {
      final token = await storage.read(key: 'jwt_token');

      if (token == null) {
        print('Token JWT mancante');
        return {'success': false, 'data': [], 'pagination': {}};
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (stato != null && stato.isNotEmpty) {
        queryParams['stato'] = stato;
      }

      final uri = Uri.parse(
        '$baseUrl/mie-richieste',
      ).replace(queryParameters: queryParams);
      print('🔄 Chiamata GET /mie-richieste...');

      final headers = await _getHeaders();
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      print('📥 GET /mie-richieste status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        final responseData = decodeHtmlInMap(rawData);
        if (responseData['success'] == true) {
          return {
            'success': true,
            'data':
                responseData['richieste'] ??
                [], // Backend usa 'richieste' non 'data'
            'pagination': responseData['pagination'] ?? {},
          };
        }
      } else if (response.statusCode == 401) {
        print('⚠️ Token scaduto o non valido');
        return {'success': false, 'message': 'Token scaduto', 'data': []};
      }

      return {'success': false, 'data': [], 'pagination': {}};
    } catch (e) {
      print('❌ Errore durante GET /richieste-utente: $e');
      return {'success': false, 'data': [], 'pagination': {}};
    }
  }

  /// Ottieni dettaglio singola richiesta (AUTENTICATO)
  /// GET /richiesta-servizio/{id}
  static Future<Map<String, dynamic>?> getDettaglioRichiesta(int id) async {
    try {
      final token = await storage.read(key: 'jwt_token');

      if (token == null) {
        print('Token JWT mancante');
        return null;
      }

      final url = '$baseUrl/richiesta-servizio/$id';
      print('🔄 Chiamata GET /richiesta-servizio/$id...');

      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      print('📥 GET /richiesta-servizio/$id status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        final responseData = decodeHtmlInMap(rawData);
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'] as Map<String, dynamic>;
        }
      } else if (response.statusCode == 404) {
        print('⚠️ Richiesta non trovata');
        return null;
      } else if (response.statusCode == 403) {
        print('⚠️ Non hai i permessi per visualizzare questa richiesta');
        return null;
      }

      return null;
    } catch (e) {
      print('❌ Errore durante GET /richiesta-servizio/$id: $e');
      return null;
    }
  }

  /// Completa il profilo dell'utente loggato
  /// POST /soci/me/completa-profilo
  /// Tutti i campi sono opzionali
  /// Campi obbligatori per profilo completo (9): nome, cognome, email, telefono, 
  /// citta, indirizzo, codice_fiscale, data_nascita, nazionalita
  static Future<Map<String, dynamic>> completaProfilo({
    String? nome,
    String? cognome,
    String? email,
    String? telefono,
    String? prefix,
    String? codiceFiscale,
    String? dataNascita,
    String? luogoNascita,
    String? indirizzo,
    String? citta,
    String? cap,
    String? provincia,
    String? professione,
    String? paeseProvenienza,
    String? nazionalita,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: true);
      final url = '$baseUrl/soci/me/completa-profilo';

      final body = <String, dynamic>{};
      if (nome != null) body['nome'] = nome;
      if (cognome != null) body['cognome'] = cognome;
      if (email != null) body['email'] = email;
      if (telefono != null) body['telefono'] = telefono;
      if (prefix != null) body['prefix'] = prefix;
      if (codiceFiscale != null) body['codice_fiscale'] = codiceFiscale;
      if (dataNascita != null) body['data_nascita'] = dataNascita;
      if (luogoNascita != null) body['luogo_nascita'] = luogoNascita;
      if (indirizzo != null) body['indirizzo'] = indirizzo;
      if (citta != null) body['citta'] = citta;
      if (cap != null) body['cap'] = cap;
      if (provincia != null) body['provincia'] = provincia;
      if (professione != null) body['professione'] = professione;
      if (paeseProvenienza != null) body['paese_provenienza'] = paeseProvenienza;
      if (nazionalita != null) body['nazionalita'] = nazionalita;

      print('📤 Completamento profilo su: $url');
      print('📝 Dati: ${body.keys.join(", ")}');

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');
      final responseData = jsonDecode(response.body);

      // Salva dati aggiornati in storage se successo
      if (response.statusCode == 200) {
        if (nome != null || cognome != null) {
          await storage.write(key: 'full_name', value: '${nome ?? ''} ${cognome ?? ''}'.trim());
        }
        if (email != null) await storage.write(key: 'user_email', value: email);
        if (telefono != null) await storage.write(key: 'telefono', value: telefono);
        if (citta != null) await storage.write(key: 'citta', value: citta);
        if (indirizzo != null) await storage.write(key: 'indirizzo', value: indirizzo);
        if (cap != null) await storage.write(key: 'cap', value: cap);
        if (provincia != null) await storage.write(key: 'provincia', value: provincia);
        if (codiceFiscale != null) await storage.write(key: 'codice_fiscale', value: codiceFiscale);
        if (dataNascita != null) await storage.write(key: 'data_nascita', value: dataNascita);
        if (luogoNascita != null) await storage.write(key: 'luogo_nascita', value: luogoNascita);
        if (professione != null) await storage.write(key: 'professione', value: professione);
        if (paeseProvenienza != null) await storage.write(key: 'paese_origine', value: paeseProvenienza);
        if (nazionalita != null) await storage.write(key: 'nazionalita', value: nazionalita);
      }

      return responseData;
    } catch (e) {
      print('❌ Errore completamento profilo: $e');
      return {
        'success': false,
        'message': 'Errore di connessione: $e',
      };
    }
  }

  /// Ottiene i dati dell'utente loggato
  /// GET /soci/me
  static Future<Map<String, dynamic>?> getMeData() async {
    try {
      final headers = await _getHeaders(includeAuth: true);
      final url = '$baseUrl/soci/me';

      print('📤 GET /soci/me');

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print('❌ Errore GET /soci/me: $e');
      return null;
    }
  }

  /// Upload documento
  /// POST /soci/me/upload-documento
  static Future<Map<String, dynamic>> uploadDocumento({
    required File file,
    String tipoDocumento = 'carta_identita',
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: true);
      headers.remove('Content-Type'); // MultipartRequest gestisce il Content-Type

      final url = '$baseUrl/soci/me/upload-documento';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Aggiungi headers
      headers.forEach((key, value) {
        request.headers[key] = value;
      });

      // Aggiungi file
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      // Aggiungi tipo documento
      request.fields['tipo_documento'] = tipoDocumento;

      print('📤 Upload documento: ${file.path.split('/').last}');
      print('📝 Tipo: $tipoDocumento');

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Errore upload: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Errore upload documento: $e');
      return {
        'success': false,
        'message': 'Errore di connessione: $e',
      };
    }
  }

  /// Verifica se un username esiste
  /// GET /soci/check-username?username={username}
  static Future<Map<String, dynamic>> checkUsername(String username) async {
    try {
      final cleanUsername = username.trim().replaceAll(RegExp(r'[^\d]'), '');
      final url = '$baseUrl/soci/check-username?username=$cleanUsername';
      
      print('📤 GET /soci/check-username?username=$cleanUsername');

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'esiste': false,
          'error': 'Errore verifica username: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Errore verifica username: $e');
      return {
        'esiste': false,
        'error': 'Errore di connessione: $e',
      };
    }
  }

  /// Reset password (password dimenticata)
  /// POST /soci/reset-password
  /// Body: {"telefono": "3891733185"} oppure {"email": "user@example.com"}
  static Future<Map<String, dynamic>> resetPassword({
    String? telefono,
    String? email,
  }) async {
    try {
      if (telefono == null && email == null) {
        return {
          'success': false,
          'message': 'Fornisci almeno telefono o email',
        };
      }

      final url = '$baseUrl/soci/reset-password';
      final headers = await _getHeaders(includeAuth: false);
      
      final body = <String, dynamic>{};
      if (telefono != null) {
        // Pulisci il telefono da simboli
        body['telefono'] = telefono.trim().replaceAll(RegExp(r'[^\d]'), '');
      }
      if (email != null) {
        body['email'] = email.trim();
      }

      print('📤 POST /soci/reset-password');
      print('📤 Body: $body');

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password resettata. Controlla la tua email.',
          'email_sent_to': data['email_sent_to'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Errore reset password',
          'code': data['code'],
        };
      }
    } catch (e) {
      print('❌ Errore reset password: $e');
      return {
        'success': false,
        'message': 'Errore di connessione: $e',
      };
    }
  }

  /// Cambia password (utente autenticato)
  /// POST /soci/me/change-password
  /// Body: {"old_password": "xxx", "new_password": "yyy"}
  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final url = '$baseUrl/soci/me/change-password';
      final headers = await _getHeaders(includeAuth: true);
      
      final body = {
        'old_password': oldPassword,
        'new_password': newPassword,
      };

      print('📤 POST /soci/me/change-password');
      // Non logghiamo le password per sicurezza
      print('📤 Body: {old_password: ***, new_password: ***}');

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password cambiata con successo',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Errore cambio password',
          'code': data['code'],
        };
      }
    } catch (e) {
      print('❌ Errore cambio password: $e');
      return {
        'success': false,
        'message': 'Errore di connessione: $e',
      };
    }
  }

  /// Ottieni profilo completo utente corrente con tutti i dettagli
  /// GET /soci/me
  /// Ritorna: profilo_completo, campi_mancanti, percentuale_completamento, documenti, ecc.
  static Future<Map<String, dynamic>> getProfiloCompleto() async {
    try {
      final url = '$baseUrl/soci/me';
      final headers = await _getHeaders(includeAuth: true);

      print('📤 GET $url');

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        final data = decodeHtmlInMap(rawData);
        
        if (data['success'] == true && data['data'] != null) {
          return {
            'success': true,
            'data': data['data'],
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Non autenticato. Effettua il login.',
          'code': 'not_logged_in',
        };
      }

      final data = jsonDecode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Errore recupero profilo',
        'code': data['code'],
      };
    } catch (e) {
      print('❌ Errore get profilo: $e');
      return {
        'success': false,
        'message': 'Errore di connessione: $e',
      };
    }
  }
}
