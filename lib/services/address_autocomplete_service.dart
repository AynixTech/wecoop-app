import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import '../config/api_config.dart';

/// Suggerimento di indirizzo restituito dal servizio di autocomplete.
class AddressSuggestion {
  const AddressSuggestion({
    required this.displayName,
    required this.street,
    required this.city,
    required this.postcode,
    required this.province,
    this.placeId,
  });

  /// Etichetta completa mostrata nella lista.
  final String displayName;

  /// Via + civico (es. "Via dei Mille 12").
  final String street;
  final String city;
  final String postcode;

  /// Sigla provincia (2 lettere, es. "MI") quando disponibile.
  final String province;

  /// Place ID Google (se proveniente da /api/geo). Usato per Place Details.
  final String? placeId;

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

  factory AddressSuggestion.fromGeoPlace(Map<String, dynamic> json) {
    return AddressSuggestion(
      displayName: (json['formatted_address'] ?? json['description'] ?? '')
          .toString(),
      street: (json['street'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      postcode: (json['postcode'] ?? '').toString(),
      province: (json['province'] ?? '').toString(),
      placeId: (json['place_id'] ?? json['placeId'])?.toString(),
    );
  }
}

/// Autocompletamento indirizzi: preferisce `GET /api/geo/*` (Google via
/// backend) quando configurato; fallback a Nominatim (OpenStreetMap).
class AddressAutocompleteService {
  AddressAutocompleteService._();

  static const String _nominatimBase =
      'https://nominatim.openstreetmap.org/search';

  static const Map<String, String> _nominatimHeaders = {
    'User-Agent': 'WeCoopApp/1.5 (support@wecoop.org)',
    'Accept': 'application/json',
  };

  static final SecureStorageService _storage = SecureStorageService();
  static bool? _geoConfigured;

  static Future<bool> _isGeoConfigured() async {
    if (_geoConfigured != null) return _geoConfigured!;
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/geo/status');
      final res = await HttpClientService.get(uri)
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _geoConfigured = data is Map && data['configured'] == true;
      } else {
        _geoConfigured = false;
      }
    } catch (_) {
      _geoConfigured = false;
    }
    return _geoConfigured!;
  }

  /// Cerca indirizzi che corrispondono a [query].
  static Future<List<AddressSuggestion>> search(
    String query, {
    String? languageCode,
  }) async {
    final q = query.trim();
    if (q.length < 3) return const [];

    if (await _isGeoConfigured()) {
      final geo = await _searchGeo(q);
      if (geo.isNotEmpty) return geo;
    }
    return _searchNominatim(q, languageCode: languageCode);
  }

  /// Risolve i campi strutturati per un suggerimento con [placeId].
  static Future<AddressSuggestion> resolve(AddressSuggestion suggestion) async {
    final placeId = suggestion.placeId;
    if (placeId == null || placeId.isEmpty) return suggestion;

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/geo/place').replace(
        queryParameters: {'place_id': placeId},
      );
      final res = await HttpClientService.get(uri)
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return suggestion;
      final data = jsonDecode(res.body);
      if (data is! Map<String, dynamic>) return suggestion;
      final resolved = AddressSuggestion.fromGeoPlace(data);
      // Se Place Details non ha la via, mantieni almeno la label.
      if (resolved.street.isEmpty && suggestion.displayName.isNotEmpty) {
        return AddressSuggestion(
          displayName: resolved.displayName.isNotEmpty
              ? resolved.displayName
              : suggestion.displayName,
          street: suggestion.street.isNotEmpty
              ? suggestion.street
              : suggestion.displayName.split(',').first.trim(),
          city: resolved.city,
          postcode: resolved.postcode,
          province: resolved.province,
          placeId: placeId,
        );
      }
      return resolved;
    } catch (_) {
      return suggestion;
    }
  }

  static Future<List<AddressSuggestion>> _searchGeo(String query) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/geo/autocomplete').replace(
        queryParameters: {'input': query},
      );
      final res = await HttpClientService.get(uri)
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return const [];
      final data = jsonDecode(res.body);
      final list = data is Map ? data['suggestions'] : null;
      if (list is! List) return const [];
      return list
          .whereType<Map>()
          .map((s) => AddressSuggestion(
                displayName: (s['description'] ?? '').toString(),
                street: '',
                city: '',
                postcode: '',
                province: '',
                placeId: (s['place_id'] ?? s['placeId'])?.toString(),
              ))
          .where((s) => s.displayName.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static Future<List<AddressSuggestion>> _searchNominatim(
    String query, {
    String? languageCode,
  }) async {
    final lang = languageCode ??
        (await _storage.read(key: 'language_code')) ??
        'it';

    final uri = Uri.parse(_nominatimBase).replace(queryParameters: {
      'q': query,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': '6',
      'accept-language': lang,
    });

    try {
      final res = await http
          .get(uri, headers: _nominatimHeaders)
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
