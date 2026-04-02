import 'dart:convert';
import 'package:wecoop_app/utils/response_utils.dart';
import 'secure_storage_service.dart';
import 'http_client_service.dart';
import '../models/pagamento_model.dart';

class PagamentoService {
  static const String baseUrl = 'https://www.wecoop.org/wp-json/wecoop/v1';
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
        print('❌ Token JWT mancante');
        return null;
      }

      final url = Uri.parse('$baseUrl/payment/$paymentId');
      print('🔄 Chiamata GET /payment/$paymentId...');

      final headers = await _getHeaders();
      final response = await HttpClientService.get(url, headers: headers);

      print('📥 GET /payment/$paymentId status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = ResponseUtils.decodeJson(response) as Map<String, dynamic>;
        return Pagamento.fromJson(data);
      } else if (response.statusCode == 404) {
        print('⚠️ Pagamento non trovato');
        return null;
      } else if (response.statusCode == 403) {
        print('⚠️ Non hai i permessi per visualizzare questo pagamento');
        return null;
      }

      return null;
    } catch (e) {
      print('❌ Errore durante GET /payment/$paymentId: $e');
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
        print('❌ Token o User ID mancante');
        return [];
      }

      final url = Uri.parse('$baseUrl/payments/user/$userId');
      print('🔄 Chiamata GET /payments/user/$userId...');

      final headers = await _getHeaders();
      final response = await HttpClientService.get(url, headers: headers);

      print('📥 GET /payments/user/$userId status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = ResponseUtils.decodeJson(response);
        return data.map((json) => Pagamento.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('❌ Errore durante GET /payments/user: $e');
      return [];
    }
  }

  /// Ottieni pagamento associato a una richiesta
  /// GET /payment/richiesta/{richiesta_id}
  static Future<Pagamento?> getPagamentoPerRichiesta(int richiestaId) async {
    try {
      final token = await storage.read(key: 'jwt_token');

      if (token == null) {
        print('❌ Token JWT mancante');
        return null;
      }

      final url = Uri.parse('$baseUrl/payment/richiesta/$richiestaId');
      print('🔄 Chiamata GET /payment/richiesta/$richiestaId...');

      final headers = await _getHeaders();
      final response = await HttpClientService.get(url, headers: headers);

      print(
        '📥 GET /payment/richiesta/$richiestaId status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = ResponseUtils.decodeJson(response) as Map<String, dynamic>;
        print(
          '✅ Pagamento trovato per richiesta $richiestaId: ID ${data['id']}, Importo €${data['importo']}, Stato: ${data['stato']}',
        );
        return Pagamento.fromJson(data);
      } else if (response.statusCode == 404) {
        print('ℹ️ Nessun pagamento trovato per richiesta $richiestaId');
        print('📝 Response body: ${response.body}');
        return null;
      } else {
        print('⚠️ Status code inatteso: ${response.statusCode}');
        print('📝 Response body: ${response.body}');
      }

      return null;
    } catch (e) {
      print('❌ Errore durante GET /payment/richiesta/$richiestaId: $e');
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
        print('❌ Token JWT mancante');
        return {'success': false, 'message': 'Token JWT mancante'};
      }

      final url = Uri.parse('$baseUrl/payment/$paymentId/confirm');
      print('🔄 Chiamata POST /payment/$paymentId/confirm...');

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

      print(
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
      print('❌ Errore durante POST /payment/$paymentId/confirm: $e');
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
      final url = Uri.parse(
        'https://www.wecoop.org/wp-json/wecoop/v1/create-payment-intent',
      );
      print(
        '🔄 Chiamata POST /create-payment-intent (importo: €$importo, paymentId: $paymentId)...',
      );

      final headers = await _getHeaders();
      final body = {
        'amount': (importo * 100).toInt(), // Stripe usa centesimi
        'currency': 'eur',
        'payment_id': paymentId,
      };

      print('📤 Body richiesta: ${jsonEncode(body)}');

      final response = await HttpClientService.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('📥 POST /create-payment-intent status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = ResponseUtils.decodeJson(response);
        final clientSecret = data['clientSecret'] as String?;

        if (clientSecret != null) {
          print('✅ Client Secret ricevuto');
          return clientSecret;
        } else {
          print('⚠️ Client Secret non presente nella risposta');
        }
      } else {
        print('❌ Errore HTTP ${response.statusCode}: ${response.body}');
      }

      return null;
    } catch (e) {
      print('❌ Errore durante creazione Payment Intent: $e');
      return null;
    }
  }
}
