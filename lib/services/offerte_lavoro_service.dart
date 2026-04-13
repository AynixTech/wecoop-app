import 'dart:convert';

import 'package:wecoop_app/models/offerta_lavoro_model.dart';
import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/utils/html_utils.dart';

class OfferteLavoroService {
  static const String baseUrl = 'https://www.wecoop.org/wp-json/wecoop/v1/lavoro';
  static final SecureStorageService _storage = SecureStorageService();

  static Future<Map<String, String>> _getHeaders() async {
    final languageCode = await _storage.read(key: 'language_code') ?? 'it';
    return {
      'Content-Type': 'application/json',
      'Accept-Language': languageCode,
    };
  }

  static Map<String, dynamic> _parseMapResponse(dynamic body) {
    if (body is Map<String, dynamic>) {
      return decodeHtmlInMap(body);
    }
    return {'success': false, 'message': 'Formato risposta non valido'};
  }

  static Future<Map<String, dynamic>> getOfferte({
    int page = 1,
    int perPage = 10,
    String? search,
    String? categoria,
    String? categoryScope,
    String? categoryDirection,
    String? city,
    String? region,
    String? contractType,
    String? workMode,
    String? language,
  }) async {
    try {
      final query = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (categoria != null && categoria.trim().isNotEmpty)
          'categoria': categoria.trim(),
        if (categoryScope != null && categoryScope.trim().isNotEmpty)
          'category_scope': categoryScope.trim(),
        if (categoryDirection != null && categoryDirection.trim().isNotEmpty)
          'category_direction': categoryDirection.trim(),
        if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
        if (region != null && region.trim().isNotEmpty) 'region': region.trim(),
        if (contractType != null && contractType.trim().isNotEmpty)
          'contract_type': contractType.trim(),
        if (workMode != null && workMode.trim().isNotEmpty)
          'work_mode': workMode.trim(),
        if (language != null && language.trim().isNotEmpty)
          'language': language.trim(),
      };

      final uri = Uri.parse('$baseUrl/offerte').replace(queryParameters: query);
      final response = await HttpClientService.get(uri, headers: await _getHeaders());
      final body = _parseMapResponse(HttpClientService.decodeJsonResponse(response));

      if (response.statusCode == 200 && body['success'] == true) {
        final itemsRaw = body['data'];
        final items = <OffertaLavoro>[];

        if (itemsRaw is List) {
          for (final item in itemsRaw) {
            if (item is Map<String, dynamic>) {
              items.add(OffertaLavoro.fromJson(item));
            }
          }
        }

        return {
          'success': true,
          'offerte': items,
          'pagination': body['pagination'] ?? const <String, dynamic>{},
        };
      }

      return {
        'success': false,
        'message': (body['message'] ?? 'Errore caricamento offerte').toString(),
      };
    } catch (e) {
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOfferta(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/offerte/$id');
      final response = await HttpClientService.get(uri, headers: await _getHeaders());
      final body = _parseMapResponse(HttpClientService.decodeJsonResponse(response));

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          return {'success': true, 'offerta': OffertaLavoro.fromJson(data)};
        }
      }

      return {
        'success': false,
        'message': (body['message'] ?? 'Offerta non trovata').toString(),
      };
    } catch (e) {
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCategorie() async {
    try {
      final uri = Uri.parse('$baseUrl/categorie');
      final response = await HttpClientService.get(uri, headers: await _getHeaders());
      final body = _parseMapResponse(HttpClientService.decodeJsonResponse(response));

      if (response.statusCode == 200 && body['success'] == true) {
        final itemsRaw = body['data'];
        final categories = <OffertaCategoria>[];

        if (itemsRaw is List) {
          for (final item in itemsRaw) {
            if (item is Map<String, dynamic>) {
              categories.add(OffertaCategoria.fromJson(item));
            }
          }
        }

        return {'success': true, 'categorie': categories};
      }

      return {
        'success': false,
        'message': (body['message'] ?? 'Errore caricamento categorie').toString(),
      };
    } catch (e) {
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }

  static Future<Map<String, dynamic>> inviaCandidatura({
    required int offerId,
    required String name,
    required String phone,
    String? email,
    String? city,
    String? note,
    String origin = 'Latinoamerica',
    required bool consentPrivacy,
  }) async {
    try {
      final payload = {
        'offer_id': offerId,
        'name': name.trim(),
        'phone': phone.trim(),
        'email': (email ?? '').trim(),
        'city': (city ?? '').trim(),
        'note': (note ?? '').trim(),
        'origin': origin,
        'consent_privacy': consentPrivacy,
      };

      final uri = Uri.parse('$baseUrl/candidature');
      final response = await HttpClientService.post(
        uri,
        headers: await _getHeaders(),
        body: jsonEncode(payload),
      );

      final body = _parseMapResponse(HttpClientService.decodeJsonResponse(response));

      if (response.statusCode == 201 && body['success'] == true) {
        return {
          'success': true,
          'message': (body['message'] ?? 'Candidatura inviata').toString(),
          'data': body['data'] ?? const <String, dynamic>{},
        };
      }

      return {
        'success': false,
        'message': (body['message'] ?? 'Invio candidatura fallito').toString(),
      };
    } catch (e) {
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }
}
