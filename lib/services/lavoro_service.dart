import 'dart:convert';

import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/utils/html_utils.dart';

class LavoroService {
  static const String baseUrl = 'https://www.wecoop.org/wp-json/wecoop/v1';
  static final SecureStorageService _storage = SecureStorageService();
  static const Set<String> _activeStatuses = {
    'service_activated',
    'consent_signed',
    'in_review',
    'ready_to_send',
    'sent',
    'under_evaluation',
    'interview',
  };

  static void _log(String event, Map<String, dynamic> data) {
    print('[LAVORO_SERVICE] $event ${jsonEncode(data)}');
  }

  static Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    return {
      for (final entry in headers.entries)
        entry.key:
            entry.key.toLowerCase() == 'authorization'
                ? '[redacted]'
                : entry.value,
    };
  }

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

  static String? _extractProfileId(Map<String, dynamic> body) {
    final directCandidates = [
      body['id'],
      body['profileId'],
      body['profile_id'],
    ];

    for (final candidate in directCandidates) {
      final value = candidate?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final nestedCandidates = [
        data['id'],
        data['profileId'],
        data['profile_id'],
      ];
      for (final candidate in nestedCandidates) {
        final value = candidate?.toString().trim() ?? '';
        if (value.isNotEmpty) return value;
      }
    }

    return null;
  }

  static String? _extractErrorCode(Map<String, dynamic> body) {
    final candidates = [body['code'], body['error']];
    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
      if (candidate is Map<String, dynamic>) {
        final code = candidate['code']?.toString().trim() ?? '';
        if (code.isNotEmpty) return code;
      }
    }
    return null;
  }

  static String? _extractMessage(Map<String, dynamic> body) {
    final direct = body['message']?.toString().trim() ?? '';
    if (direct.isNotEmpty) return direct;

    final error = body['error'];
    if (error is Map<String, dynamic>) {
      final nested = error['message']?.toString().trim() ?? '';
      if (nested.isNotEmpty) return nested;
    }

    return null;
  }

  static String normalizeJobStatus(String raw) {
    final value = raw.trim().toLowerCase();
    const map = {
      'profile_created': 'profile_created',
      'profilo_creato': 'profile_created',
      'cv_generated': 'cv_generated',
      'cv_generato': 'cv_generated',
      'service_activated': 'service_activated',
      'servizio_attivato': 'service_activated',
      'consent_signed': 'consent_signed',
      'consenso_firmato': 'consent_signed',
      'in_review': 'in_review',
      'in_revisione': 'in_review',
      'ready_to_send': 'ready_to_send',
      'pronto_invio': 'ready_to_send',
      'sent': 'sent',
      'inviato': 'sent',
      'under_evaluation': 'under_evaluation',
      'in_valutazione': 'under_evaluation',
      'interview': 'interview',
      'colloquio': 'interview',
      'closed': 'closed',
      'chiuso': 'closed',
      'not_selected': 'not_selected',
      'non_selezionato': 'not_selected',
      'deactivated': 'deactivated',
      'disattivato': 'deactivated',
    };

    return map[value] ?? value;
  }

  static String? extractJobStatus(Map<String, dynamic> result) {
    final data = result['data'];
    if (data is! Map<String, dynamic>) {
      return null;
    }

    final job = data['job'];
    if (job is Map<String, dynamic>) {
      final status = (job['status'] ?? '').toString();
      if (status.trim().isNotEmpty) {
        return normalizeJobStatus(status);
      }
    }

    final directStatus =
        (data['currentStatus'] ?? data['status'] ?? data['state'] ?? '')
            .toString();
    if (directStatus.trim().isEmpty) {
      return null;
    }

    return normalizeJobStatus(directStatus);
  }

  static bool isJobServiceActiveStatus(String? status) {
    if (status == null || status.trim().isEmpty) {
      return false;
    }
    return _activeStatuses.contains(normalizeJobStatus(status));
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
      'message': _extractMessage(body),
      'errorCode': _extractErrorCode(body),
      'profileId': _extractProfileId(body),
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
      if (v.isNotEmpty) {
        _log('resolve_profile_id', {'resolvedProfileId': v});
        return v;
      }
    }
    _log('resolve_profile_id', {'resolvedProfileId': null});
    return null;
  }

  static Future<Map<String, dynamic>> createOrUpdateProfile({
    String? profileId,
    Map<String, dynamic>? payload,
  }) async {
    final headers = await _getHeaders();
    final effectivePayload = payload ?? <String, dynamic>{};

    if (profileId == null || profileId.trim().isEmpty) {
      final uri = Uri.parse('$baseUrl/lavoro/profile');
      _log('create_profile_request', {
        'method': 'POST',
        'url': uri.toString(),
        'headers': _sanitizeHeaders(headers),
        'payload': effectivePayload,
      });
      final response = await HttpClientService.post(
        uri,
        headers: headers,
        body: jsonEncode(effectivePayload),
      );
      final body = _parseResponseBody(response.body);
      final result = _wrapResult(response.statusCode, body);
      final id = result['profileId']?.toString();
      if (id != null && id.isNotEmpty) {
        await _storage.write(key: 'profilo_lavoro_id', value: id);
      }
      _log('create_profile_response', {
        'statusCode': response.statusCode,
        'result': result,
        'resolvedProfileId': id,
      });
      return result;
    }

    final uri = Uri.parse('$baseUrl/lavoro/profile/$profileId');
    _log('update_profile_request', {
      'method': 'PUT',
      'url': uri.toString(),
      'headers': _sanitizeHeaders(headers),
      'profileId': profileId,
      'payload': effectivePayload,
    });
    final response = await HttpClientService.put(
      uri,
      headers: headers,
      body: jsonEncode(effectivePayload),
    );
    final body = _parseResponseBody(response.body);
    final result = _wrapResult(response.statusCode, body);
    _log('update_profile_response', {
      'statusCode': response.statusCode,
      'result': result,
      'profileId': profileId,
    });

    if (response.statusCode == 404 &&
        result['errorCode'] == 'PROFILE_NOT_FOUND') {
      _log('update_profile_fallback_to_create', {
        'missingProfileId': profileId,
        'payload': effectivePayload,
      });
      await _storage.delete(key: 'profilo_lavoro_id');
      return createOrUpdateProfile(payload: effectivePayload);
    }

    return result;
  }

  static Future<Map<String, dynamic>> submitConsent({
    required String profileId,
    required bool gdpr,
    required bool shareCv,
    required bool whatsapp,
    required bool terms,
    required String digitalSignature,
  }) async {
    final headers = await _getHeaders();
    final signedAt = DateTime.now().toIso8601String();
    final payload = {
      'profileId': profileId,

      // Current backend contract
      'gdprAccepted': gdpr,
      'shareCvAccepted': shareCv,
      'whatsappAccepted': whatsapp,
      'termsAccepted': terms,
      'digitalSignature': digitalSignature,
      'signedAt': signedAt,

      // Backward compatibility with previous payload keys
      'gdpr': gdpr,
      'shareCv': shareCv,
      'whatsapp': whatsapp,
      'terms': terms,
      'consentSignedAt': signedAt,
    };

    final uri = Uri.parse('$baseUrl/lavoro/consent');
    _log('submit_consent_request', {
      'method': 'POST',
      'url': uri.toString(),
      'headers': _sanitizeHeaders(headers),
      'payload': payload,
    });

    final response = await HttpClientService.post(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    );
    final body = _parseResponseBody(response.body);
    final result = _wrapResult(response.statusCode, body);
    _log('submit_consent_response', {
      'statusCode': response.statusCode,
      'result': result,
    });
    return result;
  }

  static Future<Map<String, dynamic>> activateJobService({
    required String profileId,
  }) async {
    final headers = await _getHeaders();
    final payload = {
      'profileId': profileId,
      'activatedAt': DateTime.now().toIso8601String(),
    };

    final uri = Uri.parse('$baseUrl/lavoro/job/activate');
    _log('activate_job_service_request', {
      'method': 'POST',
      'url': uri.toString(),
      'headers': _sanitizeHeaders(headers),
      'payload': payload,
    });

    final response = await HttpClientService.post(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    );
    final body = _parseResponseBody(response.body);
    final result = _wrapResult(response.statusCode, body);
    _log('activate_job_service_response', {
      'statusCode': response.statusCode,
      'result': result,
    });
    return result;
  }

  static Future<Map<String, dynamic>> getJobStatus({
    required String profileId,
  }) async {
    final headers = await _getHeaders();

    final uri = Uri.parse('$baseUrl/lavoro/job/status/$profileId');
    _log('get_job_status_request', {
      'method': 'GET',
      'url': uri.toString(),
      'headers': _sanitizeHeaders(headers),
      'profileId': profileId,
    });

    final response = await HttpClientService.get(uri, headers: headers);
    final body = _parseResponseBody(response.body);
    final result = _wrapResult(response.statusCode, body);
    _log('get_job_status_response', {
      'statusCode': response.statusCode,
      'result': result,
      'profileId': profileId,
    });
    return result;
  }

  static Future<Map<String, dynamic>> updateJobStatus({
    required String profileId,
    required String status,
    String? note,
  }) async {
    final headers = await _getHeaders();
    final payload = <String, dynamic>{
      'status': status,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    };

    final uri = Uri.parse('$baseUrl/lavoro/job/status/$profileId');
    _log('update_job_status_request', {
      'method': 'PATCH',
      'url': uri.toString(),
      'headers': _sanitizeHeaders(headers),
      'profileId': profileId,
      'payload': payload,
    });

    final response = await HttpClientService.patch(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    );
    final body = _parseResponseBody(response.body);
    final result = _wrapResult(response.statusCode, body);
    _log('update_job_status_response', {
      'statusCode': response.statusCode,
      'result': result,
      'profileId': profileId,
    });
    return result;
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

    final uri = Uri.parse('$baseUrl/lavoro/wachatbot/trigger');
    _log('trigger_wachatbot_request', {
      'method': 'POST',
      'url': uri.toString(),
      'headers': _sanitizeHeaders(headers),
      'payload': payload,
    });

    final response = await HttpClientService.post(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    );
    final body = _parseResponseBody(response.body);
    final result = _wrapResult(response.statusCode, body);
    _log('trigger_wachatbot_response', {
      'statusCode': response.statusCode,
      'result': result,
    });
    return result;
  }
}
