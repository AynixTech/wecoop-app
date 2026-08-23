import 'dart:convert';
import 'package:wecoop_app/utils/app_logger.dart';
import 'package:http/http.dart' as http;
import 'package:wecoop_app/services/maintenance_handler.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/error_reporter.dart';
import '../config/api_config.dart';

/// Servizio HTTP centralizzato con gestione automatica del refresh token
class HttpClientService {
  static const String authUrl = ApiConfig.loginUrl;
  static const String refreshUrl = '${ApiConfig.baseUrl}/auth/refresh';
  static final storage = SecureStorageService();

  /// Callback invocato quando il refresh fallisce definitivamente (sessione
  /// scaduta): l'app dovrebbe pulire lo stato e riportare l'utente al login.
  /// Impostato una volta all'avvio (es. da main/AuthGate).
  static Future<void> Function()? onSessionExpired;

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
      AppLogger.d('⚠️ Header Warning: Content-Type non contiene charset=utf-8');
      AppLogger.d('   Content-Type riportato: $contentType');
    }

    try {
      // Metodo corretto: decodifica i byte come UTF-8 prima di fare jsonDecode
      final jsonString = utf8.decode(response.bodyBytes);
      final decoded = jsonDecode(jsonString);
      return decoded;
    } catch (e) {
      AppLogger.d('⚠️ Errore UTF-8 decode, fallback a response.body: $e');
      try {
        // Fallback se utf8.decode fallisce
        return jsonDecode(response.body);
      } catch (e2) {
        AppLogger.d('❌ Errore nel parsing JSON: $e2');
        // Segnala al backend: risposta non-JSON (spesso pagina HTML di errore).
        final preview = response.body.length > 300
            ? response.body.substring(0, 300)
            : response.body;
        ErrorReporter.instance.reportHttp(
          endpoint: response.request?.url.toString() ?? 'unknown',
          statusCode: response.statusCode,
          message: 'Risposta non-JSON dal server (parse fallito)',
          bodyPreview: preview,
        );
        rethrow;
      }
    }
  }

  /// Rinnova il JWT usando il refresh token opaco.
  /// Le chiamate concorrenti condividono lo stesso Future (nessun doppio refresh).
  static Future<bool>? _refreshFuture;

  /// Pulisce i token di sessione (logout locale).
  static Future<void> _clearSession() async {
    await storage.delete(key: 'jwt_token');
    await storage.delete(key: 'refresh_token');
  }

  static Future<bool> refreshToken() {
    // Se un refresh è già in corso, attendi lo stesso risultato.
    if (_refreshFuture != null) {
      AppLogger.d('⏳ Refresh già in corso, attendo il risultato condiviso...');
      return _refreshFuture!;
    }
    _refreshFuture = _doRefreshToken().whenComplete(() {
      _refreshFuture = null;
    });
    return _refreshFuture!;
  }

  static Future<bool> _doRefreshToken() async {
    try {
      final refreshToken = await storage.read(key: 'refresh_token');

      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.d('❌ Nessun refresh token salvato - impossibile rinnovare');
        return false;
      }

      AppLogger.d('🔄 === INIZIO TOKEN REFRESH ===');

      final response = await processResponse(await http
          .post(
            Uri.parse(refreshUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(const Duration(seconds: 30)));

      AppLogger.d('📥 Refresh Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = decodeJsonResponse(response);
        if (data['token'] != null) {
          await storage.write(key: 'jwt_token', value: data['token']);
          // Rotazione: il backend emette un nuovo refresh token ad ogni uso.
          if (data['refresh_token'] != null) {
            await storage.write(key: 'refresh_token', value: data['refresh_token']);
          }
          AppLogger.d('✅ Token rinnovato con successo');
          return true;
        }
      }

      AppLogger.d('❌ Refresh fallito - Status: ${response.statusCode}');
      return false;
    } catch (e) {
      AppLogger.d('❌ Errore durante il refresh: $e');
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

      // Non tentare il refresh sugli endpoint di autenticazione:
      // un 401 sul login significa "credenziali errate", non "token scaduto".
      final isAuthEndpoint =
          requestUrl.contains('/auth/login') ||
          requestUrl.contains('/auth/primo-accesso') ||
          requestUrl.contains('/auth/refresh') ||
          requestUrl.contains('jwt-auth/v1/token');

      // Se il token è scaduto, tenta il refresh.
      // WordPress restituisce 403 con code 'jwt_auth_invalid_token';
      // il nuovo backend Node restituisce 401 con "Invalid or expired token".
      if (!isAuthEndpoint && (response.statusCode == 403 || response.statusCode == 401)) {
        try {
          final body = decodeJsonResponse(response);
          final message = (body['message'] ?? '').toString().toLowerCase();
          // Non trattare i 401 di API key come sessione scaduta: altrimenti
          // l'utente loggato vede "Devi essere autenticato" su endpoint
          // protetti solo da x-api-key (es. POST /service-requests).
          final isApiKeyError =
              message.contains('api key') || message.contains('api-key');
          final isTokenError =
              !isApiKeyError &&
              (body['code'] == 'jwt_auth_invalid_token' ||
                  message.contains('expired') ||
                  message.contains('invalid token') ||
                  message.contains('authorization') ||
                  (response.statusCode == 401 &&
                      (message.contains('token') ||
                          message.contains('authenticated') ||
                          message.contains('authorization'))));

          if (isTokenError) {
            AppLogger.d('⚠️ Token scaduto rilevato in: $requestUrl (status ${response.statusCode})');
            AppLogger.d('🔄 Tentativo di refresh...');

            final refreshSuccess = await refreshToken();

            if (refreshSuccess) {
              AppLogger.d('✅ Refresh completato - Ritentativo della richiesta...');
              response = await processResponse(await request());

              if (response.statusCode == 200) {
                AppLogger.d('✅ Richiesta riuscita dopo refresh!');
              }
            } else {
              // Refresh fallito definitivamente: sessione scaduta. Pulisci i
              // token e notifica l'app per riportare l'utente al login.
              AppLogger.d('❌ Refresh fallito - sessione scaduta, logout');
              await _clearSession();
              if (onSessionExpired != null) {
                try {
                  await onSessionExpired!();
                } catch (_) {
                  // il logout non deve propagare errori
                }
              }
            }
          }
        } catch (e) {
          AppLogger.d('⚠️ Errore nel parsing della risposta ${response.statusCode}: $e');
        }
      }

      return response;
    } catch (e) {
      final errorText = e.toString();
      final isDnsLookupError =
          errorText.contains('Failed host lookup') ||
          errorText.contains('No address associated with hostname');
      if (!isDnsLookupError) {
        AppLogger.d('❌ Errore durante la richiesta: $e');
      }
      rethrow;
    }
  }
}
