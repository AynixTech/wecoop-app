import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wecoop_app/services/secure_storage_service.dart';

/// Servizio HTTP centralizzato con gestione automatica del refresh token
class HttpClientService {
  static const String authUrl =
      'https://www.wecoop.org/wp-json/jwt-auth/v1/token';
  static final storage = SecureStorageService();
  static bool _isRefreshing = false;

  /// Decodifica JSON dalla risposta HTTP mantenendo l'encoding UTF-8 corretto
  /// 
  /// Usa utf8.decode(response.bodyBytes) invece di response.body per garantire
  /// che i caratteri accentati (é, à, ù, etc.) non vengano corrotti.
  /// 
  /// Verifica anche l'header Content-Type per debug.
  static dynamic decodeJsonResponse(http.Response response) {
    // Verifica se il server invia charset corretto
    final contentType = response.headers['content-type'] ?? '';
    final hasCharset = contentType.contains('charset=utf-8');
    
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

  /// Rinfresca il JWT token usando le credenziali salvate
  static Future<bool> refreshToken() async {
    // Evita refresh multipli simultanei
    if (_isRefreshing) {
      print('⏳ Refresh già in corso...');
      return false;
    }

    try {
      _isRefreshing = true;

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

      final response = await http
          .post(
            Uri.parse(authUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': authUsername,
              'password': authPassword,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Refresh Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = decodeJsonResponse(response);

        if (data['token'] != null) {
          final newToken = data['token'];
          await storage.write(key: 'jwt_token', value: newToken);

          print('✅ Token rinfresco con successo!');
          print('🔑 Nuovo token salvato');

          _isRefreshing = false;
          return true;
        }
      }

      print('❌ Refresh fallito - Status: ${response.statusCode}');

      _isRefreshing = false;
      return false;
    } catch (e) {
      print('❌ Errore durante il refresh: $e');
      _isRefreshing = false;
      return false;
    }
  }

  /// Faz una richiesta GET con refresh token automatico
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    return _makeRequestWithRefresh(
      () =>
          http.get(url, headers: headers).timeout(const Duration(seconds: 30)),
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
      () => http
          .post(url, headers: headers, body: body, encoding: encoding)
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
      () => http
          .put(url, headers: headers, body: body, encoding: encoding)
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
      () => http
          .delete(url, headers: headers, body: body, encoding: encoding)
          .timeout(const Duration(seconds: 30)),
      url.toString(),
    );
  }

  /// Wrapper HTTP che gestisce il refresh token automatico
  static Future<http.Response> _makeRequestWithRefresh(
    Future<http.Response> Function() request,
    String requestUrl,
  ) async {
    try {
      var response = await request();

      // Se il token è scaduto, tenta il refresh
      if (response.statusCode == 403) {
        try {
          final body = decodeJsonResponse(response);
          if (body['code'] == 'jwt_auth_invalid_token' ||
              body['message']?.contains('Expired') == true) {
            print('⚠️ Token scaduto rilevato in: $requestUrl');
            print('🔄 Tentativo di refresh...');

            final refreshSuccess = await refreshToken();

            if (refreshSuccess) {
              print('✅ Refresh completato - Ritentativo della richiesta...');
              response = await request();

              if (response.statusCode == 200) {
                print('✅ Richiesta riuscita dopo refresh!');
              }
            } else {
              print('❌ Refresh fallito - Mantengo la risposta 403 originale');
            }
          }
        } catch (e) {
          print('⚠️ Errore nel parsing della risposta 403: $e');
        }
      }

      return response;
    } catch (e) {
      print('❌ Errore durante la richiesta: $e');
      rethrow;
    }
  }
}
