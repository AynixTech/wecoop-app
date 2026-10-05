import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'secure_storage_service.dart';

/// Helper leggero per verifiche di sessione (utente loggato).
abstract final class AuthHelper {
  static final SecureStorageService _storage = SecureStorageService();

  /// True se c'è un JWT valido (non scaduto) oppure un refresh token
  /// con cui si può rinnovare la sessione.
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null && token.isNotEmpty && !isJwtExpired(token)) {
      return true;
    }
    final refresh = await _storage.read(key: 'refresh_token');
    return refresh != null && refresh.isNotEmpty;
  }

  static Future<bool> hasJwtToken() => isLoggedIn();

  /// JWT scaduto (skew 30s). Se non parsabile, non forza logout.
  static bool isJwtExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return true;
      final payload = _decodeJwtPayload(parts[1]);
      final exp = payload['exp'];
      if (exp is! num) return false;
      final expiry = DateTime.fromMillisecondsSinceEpoch(
        exp.toInt() * 1000,
        isUtc: true,
      );
      return DateTime.now().toUtc().isAfter(
        expiry.subtract(const Duration(seconds: 30)),
      );
    } catch (_) {
      return false;
    }
  }

  static Map<String, dynamic> _decodeJwtPayload(String segment) {
    var normalized = segment.replaceAll('-', '+').replaceAll('_', '/');
    switch (normalized.length % 4) {
      case 2:
        normalized += '==';
        break;
      case 3:
        normalized += '=';
        break;
    }
    final decoded = utf8.decode(base64.decode(normalized));
    final json = jsonDecode(decoded);
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return Map<String, dynamic>.from(json);
    return {};
  }

  /// Pulisce token, biometriche e PII profilo. Mantiene `last_login_phone`.
  static Future<void> clearSessionForLogout({
    bool keepLastLoginPhone = true,
  }) async {
    final lastPhone =
        keepLastLoginPhone ? await _storage.read(key: 'last_login_phone') : null;

    const keys = <String>[
      'jwt_token',
      'refresh_token',
      'auth_username',
      'auth_password',
      'biometric_username',
      'biometric_password',
      'biometric_login_enabled',
      'user_email',
      'user_display_name',
      'user_nicename',
      'saved_phone',
      'saved_password',
      'carta_id',
      'socio_id',
      'user_id',
      'first_name',
      'last_name',
      'full_name',
      'codice_fiscale',
      'data_nascita',
      'luogo_nascita',
      'indirizzo',
      'citta',
      'cap',
      'provincia',
      'telefono',
      'professione',
      'stato_socio',
      'data_iscrizione',
      'tessera_numero',
      'tessera_url',
      'quota_pagata',
      'anni_socio',
      'avatar_url',
    ];

    for (final key in keys) {
      await _storage.delete(key: key);
    }

    // Primo accesso scriveva PII anche in SharedPreferences: pulisci al logout.
    try {
      final prefs = await SharedPreferences.getInstance();
      const prefsKeys = <String>[
        'user_id',
        'richiesta_id',
        'numero_pratica',
        'username',
        'nome',
        'cognome',
        'telefono_completo',
        'is_socio',
        'profilo_completo',
      ];
      for (final key in prefsKeys) {
        await prefs.remove(key);
      }
    } catch (_) {
      // ignore: prefs opzionale
    }

    if (keepLastLoginPhone && lastPhone != null && lastPhone.isNotEmpty) {
      await _storage.write(key: 'last_login_phone', value: lastPhone);
    }
  }
}
