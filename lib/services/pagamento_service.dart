import 'dart:convert';
import 'package:wecoop_app/utils/app_logger.dart';
import 'package:wecoop_app/utils/response_utils.dart';
import 'secure_storage_service.dart';
import 'http_client_service.dart';
import '../models/pagamento_model.dart';
import '../config/api_config.dart';

class PagamentoService {
  static const String baseUrl = ApiConfig.baseUrl;
  static final storage = SecureStorageService();

  /// Headers comuni per le richieste
  static Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'jwt_token');
    final languageCode = await storage.read(key: 'language_code') ?? 'it';

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
      'Accept-Language': languageCode,
    };
  }

  /// Ottieni singolo pagamento
  /// GET /payment/{id}
  static Future<Pagamento?> getPagamento(int paymentId) async {
    try {
      final token = await storage.read(key: 'jwt_token');

      if (token == null) {
        AppLogger.d('❌ Token JWT mancante');
        return null;
      }

      final url = Uri.parse('$baseUrl/payment/$paymentId');
      AppLogger.d('🔄 Chiamata GET /payment/$paymentId...');

      final headers = await _getHeaders();
      final response = await HttpClientService.get(url, headers: headers);

      AppLogger.d('📥 GET /payment/$paymentId status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = ResponseUtils.decodeJson(response) as Map<String, dynamic>;
        return Pagamento.fromJson(data);
      } else if (response.statusCode == 404) {
        AppLogger.d('⚠️ Pagamento non trovato');
        return null;
      } else if (response.statusCode == 403) {
        AppLogger.d('⚠️ Non hai i permessi per visualizzare questo pagamento');
        return null;
      }

      return null;
    } catch (e) {
      AppLogger.d('❌ Errore durante GET /payment/$paymentId: $e');
      return null;
    }
  }

  /// Ottieni tutti i pagamenti dell'utente
  /// GET /payments/user/{user_id}
  static Future<List<Pagamento>> getPagamentiUtente() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      final userId = await storage.read(key: 'user_id');

      if (token == null || userId == null) {
        AppLogger.d('❌ Token o User ID mancante');
        return [];
      }

      final url = Uri.parse('$baseUrl/payments/user/$userId');
      AppLogger.d('🔄 Chiamata GET /payments/user/$userId...');

      final headers = await _getHeaders();
      final response = await HttpClientService.get(url, headers: headers);

      AppLogger.d(
        '📥 GET /payments/user/$userId status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        // Il backend risponde con { payments: [...] }
        final decoded = ResponseUtils.decodeJson(response);
        final List<dynamic> data =
            decoded is Map
                ? (decoded['payments'] ?? [])
                : (decoded is List ? decoded : []);
        return data.map((json) => Pagamento.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      AppLogger.d('❌ Errore durante GET /payments/user: $e');
      return [];
    }
  }

  /// Ottieni pagamento associato a una richiesta
  /// GET /payment/richiesta/{richiesta_id}
  static Future<Pagamento?> getPagamentoPerRichiesta(int richiestaId) async {
    try {
      final token = await storage.read(key: 'jwt_token');

      if (token == null) {
        AppLogger.d('❌ Token JWT mancante');
        return null;
      }

      final url = Uri.parse('$baseUrl/payment/richiesta/$richiestaId');
      AppLogger.d('🔄 Chiamata GET /payment/richiesta/$richiestaId...');

      final headers = await _getHeaders();
      final response = await HttpClientService.get(url, headers: headers);

      AppLogger.d(
        '📥 GET /payment/richiesta/$richiestaId status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = ResponseUtils.decodeJson(response) as Map<String, dynamic>;
        AppLogger.d(
          '✅ Pagamento trovato per richiesta $richiestaId: ID ${data['id']}, Importo €${data['importo']}, Stato: ${data['stato']}',
        );
        return Pagamento.fromJson(data);
      } else if (response.statusCode == 404) {
        AppLogger.d('ℹ️ Nessun pagamento trovato per richiesta $richiestaId');
        AppLogger.d('📝 Response body: ${response.body}');
        return null;
      } else {
        AppLogger.d('⚠️ Status code inatteso: ${response.statusCode}');
        AppLogger.d('📝 Response body: ${response.body}');
      }

      return null;
    } catch (e) {
      AppLogger.d('❌ Errore durante GET /payment/richiesta/$richiestaId: $e');
      return null;
    }
  }

  /// Conferma pagamento
  /// POST /payment/{id}/confirm
  static Future<Map<String, dynamic>> confermaPagamento({
    required int paymentId,
    required String metodoPagamento,
    required String transactionId,
    String? note,
  }) async {
    try {
      final token = await storage.read(key: 'jwt_token');

      if (token == null) {
        AppLogger.d('❌ Token JWT mancante');
        return {'success': false, 'message': 'Token JWT mancante'};
      }

      final url = Uri.parse('$baseUrl/payment/$paymentId/confirm');
      AppLogger.d('🔄 Chiamata POST /payment/$paymentId/confirm...');

      final body = {
        'metodo_pagamento': metodoPagamento,
        'transaction_id': transactionId,
        if (note != null) 'note': note,
      };

      final headers = await _getHeaders();
      final response = await HttpClientService.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      AppLogger.d(
        '📥 POST /payment/$paymentId/confirm status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = ResponseUtils.decodeJson(response);
        return {
          'success': true,
          'message': data['message'] ?? 'Pagamento confermato',
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Pagamento non trovato'};
      } else if (response.statusCode == 403) {
        return {'success': false, 'message': 'Non autorizzato'};
      } else {
        final errorData = ResponseUtils.decodeJson(response);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Errore durante la conferma',
        };
      }
    } catch (e) {
      AppLogger.d('❌ Errore durante POST /payment/$paymentId/confirm: $e');
      return {'success': false, 'message': 'Errore di connessione'};
    }
  }

  /// Crea Payment Intent Stripe (backend)
  /// POST /create-payment-intent
  static Future<String?> creaStripePaymentIntent({
    required double importo,
    required int paymentId,
  }) async {
    try {
      // Nota: questo endpoint deve essere creato sul backend WordPress
      final url = Uri.parse('$baseUrl/create-payment-intent');
      AppLogger.d(
        '🔄 Chiamata POST /create-payment-intent (importo: €$importo, paymentId: $paymentId)...',
      );

      final headers = await _getHeaders();
      final body = {
        'amount': (importo * 100).toInt(), // Stripe usa centesimi
        'currency': 'eur',
        'payment_id': paymentId,
      };

      AppLogger.d('📤 Body richiesta: ${jsonEncode(body)}');

      final response = await HttpClientService.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      AppLogger.d(
        '📥 POST /create-payment-intent status: ${response.statusCode}',
      );
      AppLogger.d('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = ResponseUtils.decodeJson(response);
        final clientSecret = data['clientSecret'] as String?;

        if (clientSecret != null) {
          AppLogger.d('✅ Client Secret ricevuto');
          return clientSecret;
        } else {
          AppLogger.d('⚠️ Client Secret non presente nella risposta');
        }
      } else {
        AppLogger.d('❌ Errore HTTP ${response.statusCode}: ${response.body}');
      }

      return null;
    } catch (e) {
      AppLogger.d('❌ Errore durante creazione Payment Intent: $e');
      return null;
    }
  }

  /// Recupera la publishable key Stripe dal backend Node
  /// GET /stripe-config
  ///
  /// Ritorna null se la chiave non è configurata (pagamenti carta non disponibili).
  static Future<String?> getStripePublishableKey() async {
    try {
      final url = Uri.parse('$baseUrl/stripe-config');
      final headers = await _getHeaders();
      final response = await HttpClientService.get(url, headers: headers);

      AppLogger.d('📥 GET /stripe-config status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = ResponseUtils.decodeJson(response) as Map<String, dynamic>;
        final key = data['publishable_key'] as String?;
        final configured = data['configured'] == true ||
            (key != null && key.isNotEmpty);
        if (configured && key != null && key.isNotEmpty) {
          return key;
        }
        AppLogger.d('⚠️ Stripe non configurato sul backend (publishable_key vuota)');
      }

      return null;
    } catch (e) {
      AppLogger.d('❌ Errore durante GET /stripe-config: $e');
      return null;
    }
  }
}
