import 'dart:convert';
import 'package:wecoop_app/utils/app_logger.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/maintenance_handler.dart';
import '../models/evento_model.dart';
import '../utils/html_utils.dart';
import '../config/api_config.dart';

class EventiService {
  static const String baseUrl = ApiConfig.baseUrl;
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

      final response = await HttpClientService.get(uri, headers: headers);

      AppLogger.d('GET $uri - Status: ${response.statusCode}');

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
      AppLogger.d('Errore getEventi: $e');
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }

  /// Get dettaglio evento
  static Future<Map<String, dynamic>> getEvento(int eventoId) async {
    try {
      final uri = Uri.parse('$baseUrl/eventi/$eventoId');
      final headers = await _getHeaders();

      final response = await HttpClientService.get(uri, headers: headers);

      AppLogger.d('GET $uri - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        final data = decodeHtmlInMap(rawData);

        // Log importante per verificare iscrizione
        if (data['sono_iscritto'] != null) {
          AppLogger.d('\n=== VERIFICA ISCRIZIONE EVENTO $eventoId ===');
          AppLogger.d('✓ sono_iscritto: ${data['sono_iscritto']}');
          AppLogger.d('✓ stato_iscrizione: ${data['stato_iscrizione'] ?? "N/A"}');
          AppLogger.d('✓ data_iscrizione: ${data['data_iscrizione'] ?? "N/A"}');
        }

        return {'success': true, 'evento': Evento.fromJson(data)};
      }

      return {'success': false, 'message': 'Evento non trovato'};
    } catch (e) {
      AppLogger.d('Errore getEvento: $e');
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

      AppLogger.d('\n=== ISCRIZIONE EVENTO ===');
      final timestamp = DateTime.now().toIso8601String();
      AppLogger.d('⏰ Timestamp: $timestamp');

      final uri = Uri.parse('$baseUrl/eventi/$eventoId/iscrizione');
      AppLogger.d('📍 POST $uri');

      final body = {
        if (nome != null) 'nome': nome,
        if (email != null) 'email': email,
        if (telefono != null) 'telefono': telefono,
        if (note != null) 'note': note,
      };

      AppLogger.d('📤 Body richiesta: ${jsonEncode(body)}');

      final headers = await _getHeaders();
      AppLogger.d('📋 Headers:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          AppLogger.d('   $key: Bearer ${value.substring(7, 57)}...');
        } else {
          AppLogger.d('   $key: $value');
        }
      });

      final response = await HttpClientService.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      AppLogger.d('📥 Status: ${response.statusCode}');
      AppLogger.d('📥 Response completa: ${response.body}');

      final rawData = jsonDecode(response.body);
      final data = decodeHtmlInMap(rawData);

      if (response.statusCode == 200 && data['success'] == true) {
        AppLogger.d('✅ Iscrizione completata con successo!');
        AppLogger.d('✅ Message: ${data['message']}');
        if (data['partecipante'] != null) {
          AppLogger.d('✅ Partecipante: ${data['partecipante']}');
        }
        AppLogger.d(
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
      AppLogger.d('Errore iscriviEvento: $e');
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

      final response = await HttpClientService.delete(uri, headers: headers);

      AppLogger.d('DELETE $uri - Status: ${response.statusCode}');

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
      AppLogger.d('Errore cancellaIscrizione: $e');
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

      AppLogger.d('\n=== CHIAMATA MIEI EVENTI ===');

      final uri = Uri.parse('$baseUrl/miei-eventi');
      AppLogger.d('📍 URL: $uri');

      final headers = await _getHeaders();
      AppLogger.d('📋 Headers:');
      headers.forEach((key, value) {
        if (key == 'Authorization') {
          AppLogger.d('   $key: Bearer ${value.substring(7, 57)}...');
        } else {
          AppLogger.d('   $key: $value');
        }
      });

      // Log JWT token (primi 50 caratteri)
      if (token.length > 50) {
        AppLogger.d('🔑 JWT Token (primi 50 char): ${token.substring(0, 50)}...');

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

            AppLogger.d('🔓 JWT Payload decodificato:');
            AppLogger.d(
              '   - User ID (data.user.id): ${payloadData['data']?['user']?['id']}',
            );
            AppLogger.d('   - Email: ${payloadData['data']?['user']?['email']}');
            AppLogger.d('   - Issued at: ${payloadData['iat']}');
            AppLogger.d('   - Expires: ${payloadData['exp']}');
          }
        } catch (e) {
          AppLogger.d('⚠️ Impossibile decodificare JWT: $e');
        }
      }

      final response = await HttpClientService.get(uri, headers: headers);

      AppLogger.d('GET $uri - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        final data = decodeHtmlInMap(rawData);

        AppLogger.d('✅ Success: ${data['success']}');
        AppLogger.d('✅ Totale eventi: ${data['totale']}');
        AppLogger.d('✅ Eventi array length: ${(data['eventi'] as List).length}');

        if ((data['eventi'] as List).isEmpty) {
          AppLogger.d('⚠️ ATTENZIONE: L\'array eventi è vuoto!');
          AppLogger.d('⚠️ Possibili cause:');
          AppLogger.d('   - Query SQL non trova iscrizioni');
          AppLogger.d('   - User ID non corrisponde');
          AppLogger.d('   - Iscrizioni salvate con formato diverso');
          AppLogger.d(
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
        AppLogger.d('❌ Errore server 500: ${response.body}');
        return {
          'success': false,
          'message': MaintenanceHandler.platformUpdateMessage,
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
      AppLogger.d('Errore getMieiEventi: $e');
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

      AppLogger.d('\n=== GET USER ID ===');

      final uri = Uri.parse('$baseUrl/soci/me');
      AppLogger.d('📍 URL: $uri');

      final headers = await _getHeaders();

      final response = await HttpClientService.get(uri, headers: headers);

      AppLogger.d('📥 Status: ${response.statusCode}');
      AppLogger.d('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.d('✅ User ID: ${data['id'] ?? data['user_id']}');
        AppLogger.d('✅ Email: ${data['email']}');
        AppLogger.d('✅ Nome: ${data['nome']} ${data['cognome']}');

        return {'success': true, 'data': data};
      }

      return {'success': false, 'message': 'Errore ${response.statusCode}'};
    } catch (e) {
      AppLogger.d('Errore getUserId: $e');
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }

  /// Debug endpoint per vedere tutti gli eventi e i loro meta
  static Future<Map<String, dynamic>> debugEventi() async {
    try {
      AppLogger.d('\n=== DEBUG EVENTI ===');

      final uri = Uri.parse(
        '$baseUrl/eventi/debug',
      );
      AppLogger.d('📍 URL: $uri');

      final headers = await _getHeaders();

      final response = await HttpClientService.get(uri, headers: headers);

      AppLogger.d('📥 Status: ${response.statusCode}');
      AppLogger.d('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      }

      return {
        'success': false,
        'message': 'Errore ${response.statusCode}: ${response.body}',
      };
    } catch (e) {
      AppLogger.d('Errore debugEventi: $e');
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }
}
