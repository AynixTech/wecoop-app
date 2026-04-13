import 'dart:convert';

import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';

class InteressatiService {
  static const String _baseUrl =
      'https://www.wecoop.org/wp-json/wecoop/v1/interessati';

  static final SecureStorageService _storage = SecureStorageService();

  static Future<Map<String, String>> _getHeaders() async {
    final languageCode = await _storage.read(key: 'language_code') ?? 'it';
    final token = await _storage.read(key: 'jwt_token');

    return {
      'Content-Type': 'application/json',
      'Accept-Language': languageCode,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> registerInterest({
    required String itemKey,
    required String itemTitle,
    required String itemType,
    String source = 'app',
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/register');
      final response = await HttpClientService.post(
        uri,
        headers: await _getHeaders(),
        body: jsonEncode({
          'item_key': itemKey,
          'item_title': itemTitle,
          'item_type': itemType,
          'source': source,
        }),
      );

      final body = HttpClientService.decodeJsonResponse(response);
      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        return {
          'success': body['success'] == true,
          'already_registered': body['already_registered'] == true,
          'count': body['count'] ?? 0,
          'item_key': body['item_key'] ?? itemKey,
        };
      }

      return {
        'success': false,
        'message': 'Risposta non valida dal server',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Errore connessione interessati: $e',
      };
    }
  }
}
