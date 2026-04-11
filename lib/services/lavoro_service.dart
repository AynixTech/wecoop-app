import 'dart:convert';

import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/utils/html_utils.dart';

class LavoroService {
  static const String baseUrl = 'https://www.wecoop.org/wp-json/wecoop/v1';
  static final SecureStorageService _storage = SecureStorageService();

  static Future<Map<String, String>> _getHeaders() async {
    final languageCode = await _storage.read(key: 'language_code') ?? 'it';
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept-Language': languageCode,
    };

    final token = await _storage.read(key: 'jwt_token');
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Map<String, dynamic> _parseResponseBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decodeHtmlInMap(decoded);
    }
    return {'ok': false, 'success': false, 'raw': decoded};
  }

  static Map<String, dynamic> _wrapResult(
    int statusCode,
    Map<String, dynamic> body,
  ) {
    final success =
        statusCode >= 200 &&
        statusCode < 300 &&
        (body['ok'] == true ||
            body['success'] == true ||
            !body.containsKey('ok'));
    return {
      'success': success,
      'statusCode': statusCode,
      'data': body['data'] ?? body,
      'raw': body,
      'message': body['message']?.toString(),
    };
  }

  static Future<String?> resolveProfileId() async {
    final candidates = [
      await _storage.read(key: 'profilo_lavoro_id'),
      await _storage.read(key: 'socio_id'),
      await _storage.read(key: 'user_id'),
      await _storage.read(key: 'member_id'),
    ];

    for (final value in candidates) {
      final v = value?.trim() ?? '';
      if (v.isNotEmpty) return v;
    }
    return null;
  }

  static Future<Map<String, dynamic>> createOrUpdateProfile({
    String? profileId,
    Map<String, dynamic>? payload,
  }) async {
    final headers = await _getHeaders();
    final effectivePayload = payload ?? <String, dynamic>{};

    if (profileId == null || profileId.trim().isEmpty) {
      final response = await HttpClientService.post(
        Uri.parse('$baseUrl/lavoro/profile'),
        headers: headers,
        body: jsonEncode(effectivePayload),
      );
      final body = _parseResponseBody(response.body);
      final result = _wrapResult(response.statusCode, body);
      final id =
          (body['id'] ?? body['profileId'] ?? body['data']?['id'])?.toString();
      if (id != null && id.isNotEmpty) {
        await _storage.write(key: 'profilo_lavoro_id', value: id);
      }
      return result;
    }

    final response = await HttpClientService.put(
      Uri.parse('$baseUrl/lavoro/profile/$profileId'),
      headers: headers,
      body: jsonEncode(effectivePayload),
    );
    final body = _parseResponseBody(response.body);
    return _wrapResult(response.statusCode, body);
  }

  static Future<Map<String, dynamic>> submitConsent({
    required String profileId,
    required bool gdpr,
    required bool shareCv,
    required bool whatsapp,
    required bool terms,
  }) async {
    final headers = await _getHeaders();
    final payload = {
      'profileId': profileId,
      'gdpr': gdpr,
      'shareCv': shareCv,
      'whatsapp': whatsapp,
      'terms': terms,
      'consentSignedAt': DateTime.now().toIso8601String(),
    };

    final response = await HttpClientService.post(
      Uri.parse('$baseUrl/lavoro/consent'),
      headers: headers,
      body: jsonEncode(payload),
    );
    final body = _parseResponseBody(response.body);
    return _wrapResult(response.statusCode, body);
  }

  static Future<Map<String, dynamic>> activateJobService({
    required String profileId,
  }) async {
    final headers = await _getHeaders();
    final payload = {
      'profileId': profileId,
      'activatedAt': DateTime.now().toIso8601String(),
    };

    final response = await HttpClientService.post(
      Uri.parse('$baseUrl/lavoro/job/activate'),
      headers: headers,
      body: jsonEncode(payload),
    );
    final body = _parseResponseBody(response.body);
    return _wrapResult(response.statusCode, body);
  }

  static Future<Map<String, dynamic>> getJobStatus({
    required String profileId,
  }) async {
    final headers = await _getHeaders();

    final response = await HttpClientService.get(
      Uri.parse('$baseUrl/lavoro/job/status/$profileId'),
      headers: headers,
    );
    final body = _parseResponseBody(response.body);
    return _wrapResult(response.statusCode, body);
  }

  static Future<Map<String, dynamic>> triggerWachatbot({
    required String profileId,
    required String message,
    String event = 'job_service_activated',
  }) async {
    final headers = await _getHeaders();
    final payload = {
      'profileId': profileId,
      'event': event,
      'message': message,
      'channel': 'whatsapp',
    };

    final response = await HttpClientService.post(
      Uri.parse('$baseUrl/lavoro/wachatbot/trigger'),
      headers: headers,
      body: jsonEncode(payload),
    );
    final body = _parseResponseBody(response.body);
    return _wrapResult(response.statusCode, body);
  }
}
