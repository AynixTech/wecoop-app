import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'dart:io';

class SocioService {
  static const String baseUrl = 'https://www.wecoop.org/wp-json/wecoop/v1';
  static const storage = FlutterSecureStorage();

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
        final data = jsonDecode(response.body);
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
        final data = jsonDecode(response.body);
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
  static Future<Map<String, dynamic>> richiestaAdesioneSocio({
    required String nome,
    required String cognome,
    required String codiceFiscale,
    required String dataNascita,
    required String luogoNascita,
    required String indirizzo,
    required String citta,
    required String cap,
    required String telefono,
    required String email,
    String? professione,
    String? provincia,
    String? motivazione,
  }) async {
    try {
      final url = '$baseUrl/soci/richiesta';

      print('=== INVIANDO RICHIESTA ADESIONE SOCIO ===');
      print('URL: $url');

      final body = jsonEncode({
        'nome': nome,
        'cognome': cognome,
        'codice_fiscale': codiceFiscale,
        'data_nascita': dataNascita,
        'luogo_nascita': luogoNascita,
        'indirizzo': indirizzo,
        'citta': citta,
        'cap': cap,
        'provincia': provincia ?? '',
        'telefono': telefono,
        'email': email,
        'professione': professione ?? '',
        'motivazione': motivazione ?? 'Richiesta di adesione alla cooperativa',
      });

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
        final data = jsonDecode(response.body);
        // Nuova API ritorna: {"success": true, "message": "...", "data": {"richiesta_id": 123, "nome": "...", "email": "...", "status": "pending"}}
        return {
          'success': data['success'] ?? true,
          'message':
              data['message'] ?? 'Richiesta di adesione inviata con successo',
          'richiesta_id': data['data']?['richiesta_id'],
          'status': data['data']?['status'] ?? 'pending',
        };
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Parametro mancante o non valido',
        };
      } else if (response.statusCode == 409) {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              errorData['message'] ??
              'Esiste già una richiesta con questa email',
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
        final responseData = jsonDecode(response.body);
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
        final responseData = jsonDecode(response.body);
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
        final responseData = jsonDecode(response.body);
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
        final responseData = jsonDecode(response.body);
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
}
