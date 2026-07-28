import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wecoop_app/services/maintenance_handler.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import '../config/api_config.dart';

/// Servizio HTTP centralizzato con gestione automatica del refresh token
class HttpClientService {
  static const String authUrl = ApiConfig.loginUrl;
  static final storage = SecureStorageService();

  /// Decodifica JSON dalla risposta HTTP mantenendo l'encoding UTF-8 corretto
  ///
  /// Usa utf8.decode(response.bodyBytes) invece di response.body per garantire
  /// che i caratteri accentati (é, à, ù, etc.) non vengano corrotti.
  ///
  /// Verifica anche l'header Content-Type per debug.
  static dynamic decodeJsonResponse(http.Response response) {
    // Verifica se il server invia charset corretto
    final contentType = response.headers['content-type'] ?? '';
    final hasCharset = contentType.toLowerCase().contains('charset=utf-8');

    if (!hasCharset) {
      print('⚠️ Header Warning: Content-Type non contiene charset=utf-8');
      print('   Content-Type riportato: $contentType');
    }

    try {
      // Metodo corretto: decodifica i byte come UTF-8 prima di fare jsonDecode
      final jsonString = utf8.decode(response.bodyBytes);
      final decoded = jsonDecode(jsonString);
      return decoded;
    } catch (e) {
      print('⚠️ Errore UTF-8 decode, fallback a response.body: $e');
      try {
        // Fallback se utf8.decode fallisce
        return jsonDecode(response.body);
      } catch (e2) {
        print('❌ Errore nel parsing JSON: $e2');
        rethrow;
      }
    }
  }

  /// Rinfresca il JWT token usando le credenziali salvate.
  /// Le chiamate concorrenti condividono lo stesso Future (nessun doppio refresh).
  static Future<bool>? _refreshFuture;

  static Future<bool> refreshToken() {
    // Se un refresh è già in corso, attendi lo stesso risultato.
    if (_refreshFuture != null) {
      print('⏳ Refresh già in corso, attendo il risultato condiviso...');
      return _refreshFuture!;
    }
    _refreshFuture = _doRefreshToken().whenComplete(() {
      _refreshFuture = null;
    });
    return _refreshFuture!;
  }

  static Future<bool> _doRefreshToken() async {
    try {
      final authUsername =
          await storage.read(key: 'auth_username') ??
          await storage.read(key: 'username') ??
          await storage.read(key: 'saved_phone');
      final authPassword =
          await storage.read(key: 'auth_password') ??
          await storage.read(key: 'password') ??
          await storage.read(key: 'saved_password');

      if (authUsername == null || authPassword == null) {
        print(
          '❌ Credenziali non salvate - impossibile fare refresh automatico',
        );
        return false;
      }

      print('🔄 === INIZIO TOKEN REFRESH ===');
      print('📱 Username: $authUsername');

      final response = await processResponse(await http
          .post(
            Uri.parse(authUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': authUsername,
              'password': authPassword,
            }),
          )
          .timeout(const Duration(seconds: 30)));

      print('📥 Refresh Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = decodeJsonResponse(response);

        if (data['token'] != null) {
          final newToken = data['token'];
          await storage.write(key: 'jwt_token', value: newToken);

          print('✅ Token rinfresco con successo!');
          print('🔑 Nuovo token salvato');
          return true;
        }
      }

      print('❌ Refresh fallito - Status: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Errore durante il refresh: $e');
      return false;
    }
  }

  /// Faz una richiesta GET con refresh token automatico
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    return _makeRequestWithRefresh(
      () async => http
          .get(url, headers: await _withFreshToken(headers))
          .timeout(const Duration(seconds: 30)),
      url.toString(),
    );
  }

  /// Faz una richiesta POST con refresh token automatico
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _makeRequestWithRefresh(
      () async => http
          .post(url, headers: await _withFreshToken(headers), body: body, encoding: encoding)
          .timeout(const Duration(seconds: 30)),
      url.toString(),
    );
  }

  /// Faz una richiesta PUT con refresh token automatico
  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _makeRequestWithRefresh(
      () async => http
          .put(url, headers: await _withFreshToken(headers), body: body, encoding: encoding)
          .timeout(const Duration(seconds: 30)),
      url.toString(),
    );
  }

  /// Faz una richiesta PATCH con refresh token automatico
  static Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _makeRequestWithRefresh(
      () async => http
          .patch(url, headers: await _withFreshToken(headers), body: body, encoding: encoding)
          .timeout(const Duration(seconds: 30)),
      url.toString(),
    );
  }

  /// Faz una richiesta DELETE con refresh token automatico
  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _makeRequestWithRefresh(
      () async => http
          .delete(url, headers: await _withFreshToken(headers), body: body, encoding: encoding)
          .timeout(const Duration(seconds: 30)),
      url.toString(),
    );
  }

  /// Se gli headers contengono un Authorization Bearer, lo rimpiazza con il
  /// token JWT attuale dallo storage (così i retry dopo il refresh usano il
  /// token nuovo invece di quello scaduto).
  static Future<Map<String, String>?> _withFreshToken(
    Map<String, String>? headers,
  ) async {
    if (headers == null) return null;
    final hasAuth = headers.keys.any((k) => k.toLowerCase() == 'authorization');
    if (!hasAuth) return headers;
    final token = await storage.read(key: 'jwt_token');
    if (token == null) return headers;
    final updated = Map<String, String>.from(headers);
    updated.removeWhere((k, v) => k.toLowerCase() == 'authorization');
    updated['Authorization'] = 'Bearer $token';
    return updated;
  }

  /// Mostra l'avviso di manutenzione e non espone mai il dettaglio tecnico
  /// restituito da un backend che risponde con HTTP 500.
  static Future<http.Response> processResponse(http.Response response) async {
    await MaintenanceHandler.handleHttpStatusCode(response.statusCode);

    if (!MaintenanceHandler.isPlatformUpdateStatusCode(response.statusCode)) {
      return response;
    }

    return http.Response(
      jsonEncode({'message': MaintenanceHandler.platformUpdateMessage}),
      response.statusCode,
      headers: response.headers,
      request: response.request,
      reasonPhrase: response.reasonPhrase,
    );
  }

  /// Wrapper HTTP che gestisce il refresh token automatico
  static Future<http.Response> _makeRequestWithRefresh(
    Future<http.Response> Function() request,
    String requestUrl,
  ) async {
    try {
      var response = await processResponse(await request());

      // Se il token è scaduto, tenta il refresh.
      // WordPress restituisce 403 con code 'jwt_auth_invalid_token';
      // il nuovo backend Node restituisce 401 con "Invalid or expired token".
      if (response.statusCode == 403 || response.statusCode == 401) {
        try {
          final body = decodeJsonResponse(response);
          final message = (body['message'] ?? '').toString().toLowerCase();
          final isTokenError =
              body['code'] == 'jwt_auth_invalid_token' ||
              message.contains('expired') ||
              message.contains('invalid') ||
              message.contains('token') ||
              message.contains('authorization') ||
              response.statusCode == 401;

          if (isTokenError) {
            print('⚠️ Token scaduto rilevato in: $requestUrl (status ${response.statusCode})');
            print('🔄 Tentativo di refresh...');

            final refreshSuccess = await refreshToken();

            if (refreshSuccess) {
              print('✅ Refresh completato - Ritentativo della richiesta...');
              response = await processResponse(await request());

              if (response.statusCode == 200) {
                print('✅ Richiesta riuscita dopo refresh!');
              }
            } else {
              print('❌ Refresh fallito - Mantengo la risposta originale');
            }
          }
        } catch (e) {
          print('⚠️ Errore nel parsing della risposta ${response.statusCode}: $e');
        }
      }

      return response;
    } catch (e) {
      final errorText = e.toString();
      final isDnsLookupError =
          errorText.contains('Failed host lookup') ||
          errorText.contains('No address associated with hostname');
      if (!isDnsLookupError) {
        print('❌ Errore durante la richiesta: $e');
      }
      rethrow;
    }
  }
}
