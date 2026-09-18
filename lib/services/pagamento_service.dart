import 'dart:convert';
import 'package:wecoop_app/utils/app_logger.dart';
import 'package:wecoop_app/utils/response_utils.dart';
import 'secure_storage_service.dart';
import 'http_client_service.dart';
import 'error_reporter.dart';
import '../models/pagamento_model.dart';
import '../config/api_config.dart';

class PagamentoService {
  static const String baseUrl = ApiConfig.baseUrl;
  static final storage = SecureStorageService();

  static void _reportPaymentFail({
    required String message,
    int? paymentId,
    int? richiestaId,
    String? step,
    String? endpoint,
    int? statusCode,
    Object? detail,
  }) {
    ErrorReporter.instance.reportPayment(
      message: message,
      paymentId: paymentId,
      richiestaId: richiestaId,
      step: step,
      endpoint: endpoint,
      statusCode: statusCode,
      detail: detail,
    );
  }

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
        _reportPaymentFail(
          message: 'GET pagamento: JWT mancante',
          paymentId: paymentId,
          step: 'load',
          endpoint: '/payment/$paymentId',
        );
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
        _reportPaymentFail(
          message: 'GET pagamento: non autorizzato (403)',
          paymentId: paymentId,
          step: 'load',
          endpoint: '/payment/$paymentId',
          statusCode: 403,
        );
        return null;
      }

      _reportPaymentFail(
        message: 'GET pagamento fallito (HTTP ${response.statusCode})',
        paymentId: paymentId,
        step: 'load',
        endpoint: '/payment/$paymentId',
        statusCode: response.statusCode,
        detail: response.body.length > 400
            ? response.body.substring(0, 400)
            : response.body,
      );
      return null;
    } catch (e) {
      AppLogger.d('❌ Errore durante GET /payment/$paymentId: $e');
      _reportPaymentFail(
        message: 'GET pagamento: eccezione',
        paymentId: paymentId,
        step: 'load',
        endpoint: '/payment/$paymentId',
        detail: e,
      );
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

      if (response.statusCode >= 500) {
        _reportPaymentFail(
          message: 'Lista pagamenti utente fallita (HTTP ${response.statusCode})',
          step: 'list_user',
          endpoint: '/payments/user/$userId',
          statusCode: response.statusCode,
          detail: response.body.length > 400
              ? response.body.substring(0, 400)
              : response.body,
        );
      }
      return [];
    } catch (e) {
      AppLogger.d('❌ Errore durante GET /payments/user: $e');
      _reportPaymentFail(
        message: 'Lista pagamenti utente: eccezione',
        step: 'list_user',
        endpoint: '/payments/user',
        detail: e,
      );
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
        _reportPaymentFail(
          message: 'GET pagamento per richiesta: JWT mancante',
          richiestaId: richiestaId,
          step: 'load_by_richiesta',
          endpoint: '/payment/richiesta/$richiestaId',
        );
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
        _reportPaymentFail(
          message:
              'GET pagamento per richiesta fallito (HTTP ${response.statusCode})',
          richiestaId: richiestaId,
          step: 'load_by_richiesta',
          endpoint: '/payment/richiesta/$richiestaId',
          statusCode: response.statusCode,
          detail: response.body.length > 400
              ? response.body.substring(0, 400)
              : response.body,
        );
      }

      return null;
    } catch (e) {
      AppLogger.d('❌ Errore durante GET /payment/richiesta/$richiestaId: $e');
      _reportPaymentFail(
        message: 'GET pagamento per richiesta: eccezione',
        richiestaId: richiestaId,
        step: 'load_by_richiesta',
        endpoint: '/payment/richiesta/$richiestaId',
        detail: e,
      );
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
        _reportPaymentFail(
          message: 'Conferma pagamento: JWT mancante (carta forse già addebitata)',
          paymentId: paymentId,
          step: 'confirm',
          endpoint: '/payment/$paymentId/confirm',
          detail: 'transactionId=$transactionId metodo=$metodoPagamento',
        );
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
        _reportPaymentFail(
          message: 'Conferma pagamento: pagamento non trovato (404)',
          paymentId: paymentId,
          step: 'confirm',
          endpoint: '/payment/$paymentId/confirm',
          statusCode: 404,
          detail: 'transactionId=$transactionId',
        );
        return {'success': false, 'message': 'Pagamento non trovato'};
      } else if (response.statusCode == 403) {
        _reportPaymentFail(
          message: 'Conferma pagamento: non autorizzato (403)',
          paymentId: paymentId,
          step: 'confirm',
          endpoint: '/payment/$paymentId/confirm',
          statusCode: 403,
          detail: 'transactionId=$transactionId',
        );
        return {'success': false, 'message': 'Non autorizzato'};
      } else {
        final errorData = ResponseUtils.decodeJson(response);
        final msg = errorData['message'] ?? 'Errore durante la conferma';
        _reportPaymentFail(
          message:
              'Conferma pagamento fallita dopo Stripe (HTTP ${response.statusCode})',
          paymentId: paymentId,
          step: 'confirm',
          endpoint: '/payment/$paymentId/confirm',
          statusCode: response.statusCode,
          detail:
              'transactionId=$transactionId msg=$msg body=${response.body.length > 300 ? response.body.substring(0, 300) : response.body}',
        );
        return {
          'success': false,
          'message': msg,
        };
      }
    } catch (e) {
      AppLogger.d('❌ Errore durante POST /payment/$paymentId/confirm: $e');
      _reportPaymentFail(
        message: 'Conferma pagamento: eccezione (carta forse già addebitata)',
        paymentId: paymentId,
        step: 'confirm',
        endpoint: '/payment/$paymentId/confirm',
        detail: 'transactionId=$transactionId error=$e',
      );
      return {'success': false, 'message': 'Errore di connessione'};
    }
  }

  /// Crea Payment Intent Stripe (backend).
  /// POST /create-payment-intent — l'importo lo decide solo il server.
  /// Ritorna clientSecret + paymentIntentId (mai salvare il secret come transaction_id).
  static Future<({String clientSecret, String? paymentIntentId})?>
      creaStripePaymentIntent({
    required int paymentId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/create-payment-intent');
      AppLogger.d(
        '🔄 Chiamata POST /create-payment-intent (paymentId: $paymentId)...',
      );

      final headers = await _getHeaders();
      final body = {
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
        final clientSecret =
            (data['clientSecret'] ?? data['client_secret']) as String?;
        final paymentIntentId = data['payment_intent_id'] as String?;

        if (clientSecret != null) {
          AppLogger.d('✅ Client Secret ricevuto');
          return (clientSecret: clientSecret, paymentIntentId: paymentIntentId);
        } else {
          AppLogger.d('⚠️ Client Secret non presente nella risposta');
          _reportPaymentFail(
            message:
                'create-payment-intent: clientSecret assente nella risposta 200',
            paymentId: paymentId,
            step: 'create_intent',
            endpoint: '/create-payment-intent',
            statusCode: 200,
            detail: response.body.length > 400
                ? response.body.substring(0, 400)
                : response.body,
          );
        }
      } else {
        AppLogger.d('❌ Errore HTTP ${response.statusCode}: ${response.body}');
        _reportPaymentFail(
          message: 'create-payment-intent fallito (HTTP ${response.statusCode})',
          paymentId: paymentId,
          step: 'create_intent',
          endpoint: '/create-payment-intent',
          statusCode: response.statusCode,
          detail: response.body.length > 400
              ? response.body.substring(0, 400)
              : response.body,
        );
      }

      return null;
    } catch (e) {
      AppLogger.d('❌ Errore durante creazione Payment Intent: $e');
      _reportPaymentFail(
        message: 'create-payment-intent: eccezione',
        paymentId: paymentId,
        step: 'create_intent',
        endpoint: '/create-payment-intent',
        detail: e,
      );
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
        AppLogger.d(
            '⚠️ Stripe non configurato sul backend (publishable_key vuota)');
        _reportPaymentFail(
          message: 'Stripe publishable key non configurata sul backend',
          step: 'stripe_config',
          endpoint: '/stripe-config',
          statusCode: 200,
        );
      } else {
        _reportPaymentFail(
          message: 'GET stripe-config fallito (HTTP ${response.statusCode})',
          step: 'stripe_config',
          endpoint: '/stripe-config',
          statusCode: response.statusCode,
          detail: response.body.length > 300
              ? response.body.substring(0, 300)
              : response.body,
        );
      }

      return null;
    } catch (e) {
      AppLogger.d('❌ Errore durante GET /stripe-config: $e');
      _reportPaymentFail(
        message: 'GET stripe-config: eccezione',
        step: 'stripe_config',
        endpoint: '/stripe-config',
        detail: e,
      );
      return null;
    }
  }
}
