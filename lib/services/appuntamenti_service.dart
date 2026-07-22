import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import '../models/appuntamento_model.dart';

/// Service per la prenotazione di appuntamenti fisici (stile Calendly).
///
/// Comunica con il plugin WordPress `wecoop-appuntamenti` sotto il namespace
/// REST `wecoop/v1`, usando lo stesso pattern degli altri service:
/// bearer JWT via [HttpClientService], risposte `{success, ...}`.
class AppuntamentiService {
  static const String baseUrl = 'https://www.wecoop.org/wp-json/wecoop/v1';
  static final storage = SecureStorageService();

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

  /// GET /appuntamenti/richiesta/{id}/slot
  /// Ritorna slot disponibili + eventuale appuntamento gia' confermato.
  static Future<Map<String, dynamic>> getSlot(int richiestaId) async {
    try {
      final uri = Uri.parse('$baseUrl/appuntamenti/richiesta/$richiestaId/slot');
      final headers = await _getHeaders();
      final response = await HttpClientService.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = HttpClientService.decodeJsonResponse(response);
        final slotsJson = (data['slots'] as List?) ?? [];
        final apptJson = data['appuntamento'];
        return {
          'success': true,
          'data': SlotDisponibilita(
            slots: slotsJson
                .map((e) => AppuntamentoSlot.fromJson(e as Map<String, dynamic>))
                .toList(),
            appuntamento: apptJson != null
                ? Appuntamento.fromJson(apptJson as Map<String, dynamic>)
                : null,
          ),
        };
      }
      return _errorFromResponse(response);
    } on TimeoutException {
      return {'success': false, 'message': 'Tempo di connessione scaduto'};
    } on SocketException {
      return {'success': false, 'message': 'Nessuna connessione internet'};
    } catch (e) {
      return {'success': false, 'message': 'Errore: $e'};
    }
  }

  /// POST /appuntamenti/prenota
  static Future<Map<String, dynamic>> prenota({
    required int richiestaId,
    required int slotId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/appuntamenti/prenota');
      final headers = await _getHeaders();
      final response = await HttpClientService.post(
        uri,
        headers: headers,
        body: jsonEncode({'richiesta_id': richiestaId, 'slot_id': slotId}),
      );

      final data = HttpClientService.decodeJsonResponse(response);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Appuntamento confermato',
          'appuntamento': data['appuntamento'] != null
              ? Appuntamento.fromJson(data['appuntamento'] as Map<String, dynamic>)
              : null,
        };
      }
      return {
        'success': false,
        'code': data['code'],
        'message': data['message'] ?? 'Errore ${response.statusCode}',
      };
    } on TimeoutException {
      return {'success': false, 'message': 'Tempo di connessione scaduto'};
    } on SocketException {
      return {'success': false, 'message': 'Nessuna connessione internet'};
    } catch (e) {
      return {'success': false, 'message': 'Errore: $e'};
    }
  }

  /// POST /appuntamenti/{id}/annulla
  static Future<Map<String, dynamic>> annulla(int appuntamentoId) async {
    return _simplePost('$baseUrl/appuntamenti/$appuntamentoId/annulla');
  }

  /// POST /appuntamenti/{id}/riprogramma
  static Future<Map<String, dynamic>> riprogramma({
    required int appuntamentoId,
    required int nuovoSlotId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/appuntamenti/$appuntamentoId/riprogramma');
      final headers = await _getHeaders();
      final response = await HttpClientService.post(
        uri,
        headers: headers,
        body: jsonEncode({'nuovo_slot_id': nuovoSlotId}),
      );
      final data = HttpClientService.decodeJsonResponse(response);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Appuntamento riprogrammato',
          'appuntamento': data['appuntamento'] != null
              ? Appuntamento.fromJson(data['appuntamento'] as Map<String, dynamic>)
              : null,
        };
      }
      return {
        'success': false,
        'code': data['code'],
        'message': data['message'] ?? 'Errore ${response.statusCode}',
      };
    } on TimeoutException {
      return {'success': false, 'message': 'Tempo di connessione scaduto'};
    } on SocketException {
      return {'success': false, 'message': 'Nessuna connessione internet'};
    } catch (e) {
      return {'success': false, 'message': 'Errore: $e'};
    }
  }

  static Future<Map<String, dynamic>> _simplePost(String url) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders();
      final response = await HttpClientService.post(uri, headers: headers);
      final data = HttpClientService.decodeJsonResponse(response);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Operazione completata'};
      }
      return {
        'success': false,
        'code': data['code'],
        'message': data['message'] ?? 'Errore ${response.statusCode}',
      };
    } on TimeoutException {
      return {'success': false, 'message': 'Tempo di connessione scaduto'};
    } on SocketException {
      return {'success': false, 'message': 'Nessuna connessione internet'};
    } catch (e) {
      return {'success': false, 'message': 'Errore: $e'};
    }
  }

  static Map<String, dynamic> _errorFromResponse(response) {
    try {
      final data = HttpClientService.decodeJsonResponse(response);
      return {
        'success': false,
        'code': data['code'],
        'message': data['message'] ?? 'Errore ${response.statusCode}',
      };
    } catch (_) {
      return {'success': false, 'message': 'Errore ${response.statusCode}'};
    }
  }
}
