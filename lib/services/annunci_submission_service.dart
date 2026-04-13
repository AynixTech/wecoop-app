import 'dart:convert';
import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';

/// Servizio per gestire l'invio di annunci di lavoro proposti dagli utenti
class AnnunciSubmissionService {
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
      return body;
    }
    return {'success': false, 'message': 'Formato risposta non valido'};
  }

  /// Invia un nuovo annuncio proposto dall'utente
  /// 
  /// [submissionType]: Tipo di annuncio ('Lavoro' o 'Servizio')
  /// [titleOffer]: Titolo/mansione dell'annuncio
  /// [city]: Città
  /// [contactPhone]: Telefono di contatto
  /// [contactEmail]: Email di contatto (opzionale)
  /// [description]: Descrizione dettagliata
  /// [consentPrivacy]: Consenso al trattamento dei dati
  static Future<Map<String, dynamic>> submitJobAnnouncement({
    required String submissionType,
    required String titleOffer,
    required String city,
    required String contactPhone,
    String? contactEmail,
    required String description,
    required bool consentPrivacy,
    String? categoryScope,
    String? categoryDirection,
    String? categoryMacro,
    String? categorySlug,
  }) async {
    try {
      // Validazione base lato client
      if (submissionType.trim().isEmpty ||
          titleOffer.trim().isEmpty ||
          city.trim().isEmpty ||
          contactPhone.trim().isEmpty ||
          description.trim().length < 20) {
        return {
          'success': false,
          'message': 'Compila tutti i campi correttamente (descrizione min 20 caratteri)'
        };
      }

      if (!consentPrivacy) {
        return {
          'success': false,
          'message': 'Devi accettare il consenso sulla privacy'
        };
      }

      final payload = {
        'submission_type': submissionType.trim(),
        'title_offer': titleOffer.trim(),
        'city': city.trim(),
        'contact_phone': contactPhone.trim(),
        'contact_email': (contactEmail ?? '').trim(),
        'description': description.trim(),
        'consent_privacy': consentPrivacy,
        'category_scope': (categoryScope ?? '').trim(),
        'category_direction': (categoryDirection ?? '').trim(),
        'category_macro': (categoryMacro ?? '').trim(),
        'category_slug': (categorySlug ?? '').trim(),
      };

      final uri = Uri.parse('$baseUrl/annunci');
      final response = await HttpClientService.post(
        uri,
        headers: await _getHeaders(),
        body: jsonEncode(payload),
      );

      final body = _parseMapResponse(
        HttpClientService.decodeJsonResponse(response),
      );

      if (response.statusCode == 201 && body['success'] == true) {
        return {
          'success': true,
          'message': (body['message'] ?? 'Annuncio inviato con successo').toString(),
          'data': body['data'] ?? const <String, dynamic>{},
        };
      }

      // Gestisci errori specifici da server
      if (response.statusCode == 429) {
        return {
          'success': false,
          'message':
              'Hai inviato troppi annunci oggi. Riprova domani.'
        };
      }

      if (response.statusCode == 400) {
        return {
          'success': false,
          'message': (body['message'] ?? 'Dati non validi').toString(),
        };
      }

      if (response.statusCode == 500) {
        final data = body['data'];
        final details =
            data is Map<String, dynamic> ? (data['details'] ?? '').toString() : '';
        return {
          'success': false,
          'message': details.isNotEmpty
              ? 'Errore server: $details'
              : (body['message'] ?? 'Servizio annunci temporaneamente non disponibile')
                    .toString(),
        };
      }

      return {
        'success': false,
        'message': (body['message'] ?? 'Errore nell\'invio dell\'annuncio').toString(),
      };
    } catch (e) {
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }
}
