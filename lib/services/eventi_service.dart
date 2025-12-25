import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wecoop_app/services/secure_storage_service.dart';
import '../models/evento_model.dart';
import '../utils/html_utils.dart';

class EventiService {
  static const String baseUrl = 'https://www.wecoop.org/wp-json/wecoop/v1';
  static final storage = SecureStorageService();

  /// Ottiene gli headers comuni per tutte le richieste
  static Future<Map<String, String>> _getHeaders({
    bool includeAuth = true,
  }) async {
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

  /// Get lista eventi
  static Future<Map<String, dynamic>> getEventi({
    int page = 1,
    int perPage = 10,
    String? categoria,
    String? dataDa,
    String? dataA,
    String? stato,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (categoria != null) 'categoria': categoria,
        if (dataDa != null) 'data_da': dataDa,
        if (dataA != null) 'data_a': dataA,
        if (stato != null) 'stato': stato,
      };

      final uri = Uri.parse(
        '$baseUrl/eventi',
      ).replace(queryParameters: queryParams);
      final headers = await _getHeaders();

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      print('GET $uri - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        final data = decodeHtmlInMap(rawData);
        return {
          'success': true,
          'eventi':
              (data['eventi'] as List).map((e) => Evento.fromJson(e)).toList(),
          'pagination': data['pagination'],
        };
      }

      return {
        'success': false,
        'message': 'Errore nel caricamento degli eventi',
      };
    } catch (e) {
      print('Errore getEventi: $e');
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }

  /// Get dettaglio evento
  static Future<Map<String, dynamic>> getEvento(int eventoId) async {
    try {
      final uri = Uri.parse('$baseUrl/eventi/$eventoId');
      final headers = await _getHeaders();

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      print('GET $uri - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        final data = decodeHtmlInMap(rawData);

        // Log importante per verificare iscrizione
        if (data['sono_iscritto'] != null) {
          print('\n=== VERIFICA ISCRIZIONE EVENTO $eventoId ===');
          print('✓ sono_iscritto: ${data['sono_iscritto']}');
          print('✓ stato_iscrizione: ${data['stato_iscrizione'] ?? "N/A"}');
          print('✓ data_iscrizione: ${data['data_iscrizione'] ?? "N/A"}');
        }

        return {'success': true, 'evento': Evento.fromJson(data)};
      }

      return {'success': false, 'message': 'Evento non trovato'};
    } catch (e) {
      print('Errore getEvento: $e');
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }

  /// Iscrivi utente a evento
  static Future<Map<String, dynamic>> iscriviEvento({
    required int eventoId,
    String? nome,
    String? email,
    String? telefono,
    String? note,
  }) async {
    try {
      final token = await storage.read(key: 'jwt_token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Devi effettuare il login per iscriverti',
        };
      }

      print('\n=== ISCRIZIONE EVENTO ===');
      final timestamp = DateTime.now().toIso8601String();
      print('⏰ Timestamp: $timestamp');

      final uri = Uri.parse('$baseUrl/eventi/$eventoId/iscrizione');
      print('📍 POST $uri');

      final body = {
        if (nome != null) 'nome': nome,
        if (email != null) 'email': email,
        if (telefono != null) 'telefono': telefono,
        if (note != null) 'note': note,
      };

      print('📤 Body richiesta: ${jsonEncode(body)}');

      final headers = await _getHeaders();
      print('📋 Headers:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          print('   $key: Bearer ${value.substring(7, 57)}...');
        } else {
          print('   $key: $value');
        }
      });

      final response = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      print('📥 Status: ${response.statusCode}');
      print('📥 Response completa: ${response.body}');

      final rawData = jsonDecode(response.body);
      final data = decodeHtmlInMap(rawData);

      if (response.statusCode == 200 && data['success'] == true) {
        print('✅ Iscrizione completata con successo!');
        print('✅ Message: ${data['message']}');
        if (data['partecipante'] != null) {
          print('✅ Partecipante: ${data['partecipante']}');
        }
        print(
          '💡 Ora dovresti chiamare getEvento($eventoId) per verificare sono_iscritto = true',
        );

        return {
          'success': true,
          'message': data['message'] ?? 'Iscrizione completata!',
          'partecipante': data['partecipante'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Errore durante l\'iscrizione',
      };
    } catch (e) {
      print('Errore iscriviEvento: $e');
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }

  /// Cancella iscrizione
  static Future<Map<String, dynamic>> cancellaIscrizione(int eventoId) async {
    try {
      final token = await storage.read(key: 'jwt_token');

      if (token == null) {
        return {'success': false, 'message': 'Devi effettuare il login'};
      }

      final uri = Uri.parse('$baseUrl/eventi/$eventoId/iscrizione');

      final headers = await _getHeaders();

      final response = await http
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      print('DELETE $uri - Status: ${response.statusCode}');

      final rawData = jsonDecode(response.body);
      final data = decodeHtmlInMap(rawData);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Iscrizione cancellata',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Errore durante la cancellazione',
      };
    } catch (e) {
      print('Errore cancellaIscrizione: $e');
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }

  /// Get eventi dell'utente
  static Future<Map<String, dynamic>> getMieiEventi() async {
    try {
      final token = await storage.read(key: 'jwt_token');

      if (token == null) {
        return {'success': false, 'message': 'Devi effettuare il login'};
      }

      print('\n=== CHIAMATA MIEI EVENTI ===');

      final uri = Uri.parse('$baseUrl/miei-eventi');
      print('📍 URL: $uri');

      final headers = await _getHeaders();
      print('📋 Headers:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          print('   $key: Bearer ${value.substring(7, 57)}...');
        } else {
          print('   $key: $value');
        }
      });

      // Log JWT token (primi 50 caratteri)
      if (token.length > 50) {
        print('🔑 JWT Token (primi 50 char): ${token.substring(0, 50)}...');

        // Decodifica il payload del JWT per vedere user_id
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            // Decodifica il payload (seconda parte)
            final payload = parts[1];
            // Aggiungi padding se necessario
            String normalized = base64Url.normalize(payload);
            final decoded = utf8.decode(base64Url.decode(normalized));
            final payloadData = jsonDecode(decoded);

            print('🔓 JWT Payload decodificato:');
            print(
              '   - User ID (data.user.id): ${payloadData['data']?['user']?['id']}',
            );
            print('   - Email: ${payloadData['data']?['user']?['email']}');
            print('   - Issued at: ${payloadData['iat']}');
            print('   - Expires: ${payloadData['exp']}');
          }
        } catch (e) {
          print('⚠️ Impossibile decodificare JWT: $e');
        }
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      print('📥 Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        final data = decodeHtmlInMap(rawData);

        print('✅ Success: ${data['success']}');
        print('✅ Totale eventi: ${data['totale']}');
        print('✅ Eventi array length: ${(data['eventi'] as List).length}');

        if ((data['eventi'] as List).isEmpty) {
          print('⚠️ ATTENZIONE: L\'array eventi è vuoto!');
          print('⚠️ Possibili cause:');
          print('   - Query SQL non trova iscrizioni');
          print('   - User ID non corrisponde');
          print('   - Iscrizioni salvate con formato diverso');
          print(
            '   - Verifica che l\'iscrizione sia stata salvata correttamente',
          );
        }

        return {
          'success': true,
          'eventi':
              (data['eventi'] as List).map((e) => Evento.fromJson(e)).toList(),
          'totale': data['totale'],
        };
      } else if (response.statusCode == 500) {
        print('❌ Errore server 500: ${response.body}');
        return {
          'success': false,
          'message':
              'Errore del server. L\'endpoint /miei-eventi non è configurato correttamente.',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sessione scaduta, effettua nuovamente il login',
        };
      }

      return {
        'success': false,
        'message': 'Errore ${response.statusCode}: ${response.body}',
      };
    } catch (e) {
      print('Errore getMieiEventi: $e');
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }

  /// Get User ID corrente dal backend
  static Future<Map<String, dynamic>> getUserId() async {
    try {
      final token = await storage.read(key: 'jwt_token');

      if (token == null) {
        return {'success': false, 'message': 'Devi effettuare il login'};
      }

      print('\n=== GET USER ID ===');

      final uri = Uri.parse('https://www.wecoop.org/wp-json/wecoop/v1/soci/me');
      print('📍 URL: $uri');

      final headers = await _getHeaders();

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ User ID: ${data['id'] ?? data['user_id']}');
        print('✅ Email: ${data['email']}');
        print('✅ Nome: ${data['nome']} ${data['cognome']}');

        return {'success': true, 'data': data};
      }

      return {'success': false, 'message': 'Errore ${response.statusCode}'};
    } catch (e) {
      print('Errore getUserId: $e');
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }

  /// Debug endpoint per vedere tutti gli eventi e i loro meta
  static Future<Map<String, dynamic>> debugEventi() async {
    try {
      print('\n=== DEBUG EVENTI ===');

      final uri = Uri.parse(
        'https://www.wecoop.org/wp-json/wecoop/v1/eventi/debug',
      );
      print('📍 URL: $uri');

      final headers = await _getHeaders();

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      }

      return {
        'success': false,
        'message': 'Errore ${response.statusCode}: ${response.body}',
      };
    } catch (e) {
      print('Errore debugEventi: $e');
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }
}
