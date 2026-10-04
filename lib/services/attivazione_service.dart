import 'dart:convert';
import 'package:wecoop_app/config/api_config.dart';
import 'package:wecoop_app/models/attivazione_models.dart';
import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/utils/app_logger.dart';

/// Client per attivazione utente (Documento Unico + Privacy) a livello user.
class AttivazioneService {
  static const String baseUrl = ApiConfig.baseUrl;
  static final _storage = SecureStorageService();

  static Future<Map<String, String>> _headers() async {
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

  /// GET /attivazione/status
  static Future<AttivazioneStatus?> getStatus() async {
    try {
      final url = '$baseUrl/attivazione/status';
      AppLogger.d('🔄 [Attivazione] GET $url');
      final response = await HttpClientService.get(
        Uri.parse(url),
        headers: await _headers(),
      );
      AppLogger.d('📥 [Attivazione] status=${response.statusCode}');
      if (response.statusCode != 200) return null;
      final data = HttpClientService.decodeJsonResponse(response);
      if (data is! Map) return null;
      return AttivazioneStatus.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      AppLogger.d('❌ [Attivazione] getStatus error: $e');
      return null;
    }
  }

  /// POST /attivazione/privacy/viewed
  static Future<AttivazioneStatus?> markPrivacyViewed({
    String version = '1.0',
  }) async {
    try {
      final url = '$baseUrl/attivazione/privacy/viewed';
      final response = await HttpClientService.post(
        Uri.parse(url),
        headers: await _headers(),
        body: jsonEncode({'privacy_version': version}),
      );
      if (response.statusCode != 200) return null;
      final data = HttpClientService.decodeJsonResponse(response);
      if (data is! Map) return null;
      return AttivazioneStatus.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      AppLogger.d('❌ [Attivazione] markPrivacyViewed error: $e');
      return null;
    }
  }

  /// GET /documento-unico/download — PDF binario user-level.
  static Future<Map<String, dynamic>> downloadDocumentoUnicoPdf() async {
    try {
      final url = '$baseUrl/documento-unico/download';
      AppLogger.d('🔄 [Attivazione] GET $url');
      final response = await HttpClientService.get(
        Uri.parse(url),
        headers: await _headers(),
      );
      AppLogger.d('📥 [Attivazione] download status=${response.statusCode}');

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Download non disponibile (${response.statusCode})',
        };
      }

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/pdf')) {
        return {'success': false, 'message': 'Risposta non valida: atteso PDF'};
      }

      String filename = 'Documento_Unico_WECOOP.pdf';
      final disposition = response.headers['content-disposition'] ?? '';
      final match = RegExp(r'filename="(.+?)"').firstMatch(disposition);
      if (match != null) {
        filename = match.group(1) ?? filename;
      }

      return {
        'success': true,
        'pdf_bytes': response.bodyBytes,
        'filename': filename,
        'size': response.bodyBytes.length,
      };
    } catch (e) {
      AppLogger.d('❌ [Attivazione] downloadDocumentoUnicoPdf error: $e');
      return {'success': false, 'message': 'Errore: $e'};
    }
  }
}
