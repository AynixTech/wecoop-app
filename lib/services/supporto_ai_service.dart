import 'dart:convert';

import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';

class SupportoAiService {
  static const String _endpoint =
      'https://www.wecoop.org/wp-json/wecoop/v1/supporto/assistant';

  static final SecureStorageService _storage = SecureStorageService();

  static Future<Map<String, String>> _headers() async {
    final languageCode = await _storage.read(key: 'language_code') ?? 'it';
    final token = await _storage.read(key: 'jwt_token');

    return {
      'Content-Type': 'application/json',
      'Accept-Language': languageCode,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> askAssistant({
    required String message,
    required String language,
  }) async {
    try {
      final response = await HttpClientService.post(
        Uri.parse(_endpoint),
        headers: await _headers(),
        body: jsonEncode({
          'message': message,
          'language': language,
          'source': 'app_sportello_chat',
        }),
      );

      final body = HttpClientService.decodeJsonResponse(response);
      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          return {
            'success': body['success'] == true,
            'reply': (data['reply'] ?? '').toString(),
            'action_key': (data['action_key'] ?? '').toString(),
            'action_label': (data['action_label'] ?? '').toString(),
          };
        }
      }

      return {
        'success': false,
        'message': 'Risposta assistant non valida',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Errore assistant: $e',
      };
    }
  }
}
