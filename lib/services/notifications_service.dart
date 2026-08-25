import 'dart:convert';

import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import '../config/api_config.dart';
import '../models/app_notification.dart';

/// Client API per Centro Notifiche (`/api/notifications`).
class NotificationsService {
  static const String baseUrl = ApiConfig.baseUrl;
  static final storage = SecureStorageService();

  static Future<Map<String, String>> _headers() async {
    final languageCode = await storage.read(key: 'language_code') ?? 'it';
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept-Language': languageCode,
    };
    final token = await storage.read(key: 'jwt_token');
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// GET /notifications — lista paginata.
  static Future<Map<String, dynamic>> list({
    int page = 1,
    int perPage = 30,
    bool unreadOnly = false,
  }) async {
    try {
      final qs = <String, String>{
        'page': '$page',
        'per_page': '$perPage',
        if (unreadOnly) 'unread': 'true',
      };
      final uri = Uri.parse('$baseUrl/notifications').replace(queryParameters: qs);
      final response = await HttpClientService.get(uri, headers: await _headers());
      final data = HttpClientService.decodeJsonResponse(response);
      if (response.statusCode != 200 || data is! Map) {
        return {
          'success': false,
          'message': data is Map ? data['message'] : 'Errore caricamento notifiche',
        };
      }
      final list = <AppNotification>[];
      final raw = data['data'];
      if (raw is List) {
        for (final item in raw) {
          if (item is Map) {
            list.add(AppNotification.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }
      return {
        'success': true,
        'data': list,
        'unread_count': int.tryParse('${data['unread_count'] ?? 0}') ?? 0,
        'pagination': data['pagination'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// GET /notifications/unread-count
  static Future<int> unreadCount() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) return 0;
      final uri = Uri.parse('$baseUrl/notifications/unread-count');
      final response = await HttpClientService.get(uri, headers: await _headers());
      final data = HttpClientService.decodeJsonResponse(response);
      if (response.statusCode != 200 || data is! Map) return 0;
      return int.tryParse('${data['unread_count'] ?? 0}') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// PATCH /notifications/:id/read
  static Future<Map<String, dynamic>> markRead(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/notifications/$id/read');
      final response = await HttpClientService.patch(
        uri,
        headers: await _headers(),
        body: jsonEncode({}),
      );
      final data = HttpClientService.decodeJsonResponse(response);
      if (response.statusCode != 200 || data is! Map) {
        return {'success': false, 'message': data is Map ? data['message'] : 'Errore'};
      }
      return {
        'success': true,
        'unread_count': int.tryParse('${data['unread_count'] ?? 0}') ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// POST /notifications/read-all
  static Future<Map<String, dynamic>> markAllRead() async {
    try {
      final uri = Uri.parse('$baseUrl/notifications/read-all');
      final response = await HttpClientService.post(
        uri,
        headers: await _headers(),
        body: jsonEncode({}),
      );
      final data = HttpClientService.decodeJsonResponse(response);
      if (response.statusCode != 200 || data is! Map) {
        return {'success': false, 'message': data is Map ? data['message'] : 'Errore'};
      }
      return {
        'success': true,
        'unread_count': int.tryParse('${data['unread_count'] ?? 0}') ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
