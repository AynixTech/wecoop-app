import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wecoop_app/services/secure_storage_service.dart';

/// Suggerimento di indirizzo restituito dal servizio di autocomplete.
class AddressSuggestion {
  const AddressSuggestion({
    required this.displayName,
    required this.street,
    required this.city,
    required this.postcode,
    required this.province,
  });

  /// Etichetta completa mostrata nella lista.
  final String displayName;

  /// Via + civico (es. "Via dei Mille 12").
  final String street;
  final String city;
  final String postcode;

  /// Sigla provincia (2 lettere, es. "MI") quando disponibile.
  final String province;

  factory AddressSuggestion.fromNominatim(Map<String, dynamic> json) {
    final addr = (json['address'] as Map<String, dynamic>?) ?? const {};

    final road = (addr['road'] ?? addr['pedestrian'] ?? addr['footway'] ?? '')
        .toString()
        .trim();
    final houseNumber = (addr['house_number'] ?? '').toString().trim();
    final street = [road, houseNumber].where((s) => s.isNotEmpty).join(' ');

    final city = (addr['city'] ??
            addr['town'] ??
            addr['village'] ??
            addr['municipality'] ??
            addr['hamlet'] ??
            '')
        .toString()
        .trim();

    final postcode = (addr['postcode'] ?? '').toString().trim();

    // Nominatim espone la sigla provincia in ISO3166-2-lvl6 (es. "IT-MI").
    var province = '';
    final iso = (addr['ISO3166-2-lvl6'] ?? '').toString();
    if (iso.contains('-')) {
      province = iso.split('-').last.trim();
    } else {
      province = (addr['county'] ?? addr['state_district'] ?? '')
          .toString()
          .trim();
    }

    return AddressSuggestion(
      displayName: (json['display_name'] ?? '').toString(),
      street: street,
      city: city,
      postcode: postcode,
      province: province,
    );
  }
}

/// Servizio gratuito di autocompletamento indirizzi basato su
/// **Nominatim (OpenStreetMap)** — nessuna API key richiesta.
///
/// I risultati vengono localizzati nella lingua dell'app (salvata in secure
/// storage come `language_code`, fallback `it`), così i toponimi vengono
/// restituiti nella lingua corrente.
class AddressAutocompleteService {
  AddressAutocompleteService._();

  static const String _base = 'https://nominatim.openstreetmap.org/search';

  // Policy Nominatim: identificare l'applicazione tramite User-Agent.
  static const Map<String, String> _headers = {
    'User-Agent': 'WeCoopApp/1.5 (support@wecoop.org)',
    'Accept': 'application/json',
  };

  static final SecureStorageService _storage = SecureStorageService();

  /// Cerca indirizzi che corrispondono a [query].
  ///
  /// [languageCode] forza la lingua dei risultati; se null viene letta dallo
  /// storage. Restituisce lista vuota per query troppo corte o in caso di errore.
  static Future<List<AddressSuggestion>> search(
    String query, {
    String? languageCode,
  }) async {
    final q = query.trim();
    if (q.length < 3) return const [];

    final lang = languageCode ??
        (await _storage.read(key: 'language_code')) ??
        'it';

    final uri = Uri.parse(_base).replace(queryParameters: {
      'q': q,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': '6',
      'accept-language': lang,
    });

    try {
      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return const [];

      final decoded = jsonDecode(res.body);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(AddressSuggestion.fromNominatim)
          .toList(growable: false);
    } on TimeoutException {
      return const [];
    } catch (_) {
      return const [];
    }
  }
}
