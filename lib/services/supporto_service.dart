import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import '../models/supporto_ticket_model.dart';
import '../config/api_config.dart';

/// Service per le richieste di supporto (ticket).
///
/// Comunica con il backend Node/Express di WeCoop (`/api/supporto`), stesso
/// pattern degli altri service: bearer JWT via [HttpClientService] e risposte
/// nel formato `{success, ...}`. I ticket creati qui compaiono nel back-office
/// (pagina "Supporto" della piattaforma) e sono recuperabili dall'utente
/// tramite `mie-richieste`.
class SupportoService {
  static const String baseUrl = ApiConfig.baseUrl;
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

  /// POST /supporto/richiesta — crea un ticket di supporto.
  ///
  /// Ritorna `{success: true, numero_ticket, id, status}` in caso di successo.
  static Future<Map<String, dynamic>> creaRichiesta({
    required String serviceName,
    String serviceCategory = 'non_specificato',
    String currentScreen = 'non_specificato',
    String tipoRichiesta = 'aiuto_manuale',
    String priorita = 'media',
    String? messaggio,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/supporto/richiesta');
      final headers = await _getHeaders();

      // Dati utente da secure storage (arricchiscono il ticket lato back-office).
      final userId = await storage.read(key: 'user_id');
      final userEmail = await storage.read(key: 'user_email');
      final userName = await storage.read(key: 'user_display_name');
      final userPhone = await storage.read(key: 'telefono') ??
          await storage.read(key: 'last_login_phone');

      final body = {
        if (userId != null) 'user_id': userId,
        'service_name': serviceName,
        'service_category': serviceCategory,
        'current_screen': currentScreen,
        'user_email': userEmail ?? '',
        'user_name': userName ?? '',
        'user_phone': userPhone ?? '',
        'tipo_richiesta': tipoRichiesta,
        'priorita': priorita,
        'messaggio': messaggio ??
            'L\'utente ha richiesto aiuto dal servizio $serviceName',
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await HttpClientService.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      final data = HttpClientService.decodeJsonResponse(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final payload = (data['data'] as Map?)?.cast<String, dynamic>() ?? {};
        return {
          'success': true,
          'message': data['message'] ?? 'Richiesta di supporto creata',
          'numero_ticket': payload['numero_ticket'],
          'id': payload['id'],
          'status': payload['status'],
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

  /// GET /supporto/mie-richieste — elenco dei ticket dell'utente autenticato.
  static Future<Map<String, dynamic>> getMieRichieste() async {
    try {
      final uri = Uri.parse('$baseUrl/supporto/mie-richieste');
      final headers = await _getHeaders();
      final response = await HttpClientService.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = HttpClientService.decodeJsonResponse(response);
        final list = (data['data'] as List?) ?? [];
        final tickets = list
            .map((e) => SupportoTicket.fromJson(e as Map<String, dynamic>))
            .toList();
        return {'success': true, 'data': tickets, 'total': tickets.length};
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

  /// GET /supporto/richiesta/:id/messaggi — risposte operatore (socio) o
  /// conversazione completa (staff). Usato come fallback se `mie-richieste`
  /// non include ancora `risposte`.
  static Future<Map<String, dynamic>> getMessaggi(int ticketId) async {
    try {
      final uri = Uri.parse('$baseUrl/supporto/richiesta/$ticketId/messaggi');
      final headers = await _getHeaders();
      final response = await HttpClientService.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = HttpClientService.decodeJsonResponse(response);
        final list = (data['data'] as List?) ?? [];
        final messaggi = list
            .map((e) => SupportoMessaggio.fromJson(e as Map<String, dynamic>))
            .where((m) => m.isOperatore)
            .toList();
        return {'success': true, 'data': messaggi, 'total': messaggi.length};
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
