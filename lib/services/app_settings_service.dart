import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/utils/app_logger.dart';
import '../config/api_config.dart';

/// Contatto WhatsApp configurato lato backend (Integrazioni → Contatto WhatsApp).
class WhatsappContact {
  final String? number;
  final String? defaultMessage;

  const WhatsappContact({this.number, this.defaultMessage});

  bool get isConfigured => (number ?? '').trim().isNotEmpty;

  /// URL wa.me pronto per url_launcher (numero senza '+' e messaggio opzionale).
  Uri? get waUri {
    final digits = (number ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    final msg = (defaultMessage ?? '').trim();
    final query = msg.isNotEmpty ? '?text=${Uri.encodeComponent(msg)}' : '';
    return Uri.parse('https://wa.me/$digits$query');
  }
}

/// Legge la configurazione pubblica dell'app da GET /api/settings/public
/// (contatto WhatsApp + macro-categorie). Endpoint pubblico, senza auth.
class AppSettingsService {
  static final SecureStorageService _storage = SecureStorageService();

  /// Cache in memoria per evitare chiamate ripetute nella stessa sessione.
  static WhatsappContact? _cachedWhatsapp;

  /// Ritorna il contatto WhatsApp (da cache se disponibile). Mai lancia:
  /// in caso di errore ritorna un contatto non configurato.
  static Future<WhatsappContact> getWhatsappContact({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedWhatsapp != null) return _cachedWhatsapp!;
    try {
      final languageCode = await _storage.read(key: 'language_code') ?? 'it';
      final uri = Uri.parse('${ApiConfig.baseUrl}/settings/public');
      final response = await HttpClientService.get(
        uri,
        headers: {'Accept-Language': languageCode},
      );
      if (response.statusCode == 200) {
        final body = HttpClientService.decodeJsonResponse(response);
        if (body is Map && body['whatsapp'] is Map) {
          final wa = (body['whatsapp'] as Map).cast<String, dynamic>();
          final contact = WhatsappContact(
            number: (wa['number'] as String?)?.trim(),
            defaultMessage: (wa['defaultMessage'] as String?)?.trim(),
          );
          _cachedWhatsapp = contact;
          return contact;
        }
      }
    } catch (e) {
      AppLogger.d('⚠️ getWhatsappContact error: $e');
    }
    return const WhatsappContact();
  }
}
