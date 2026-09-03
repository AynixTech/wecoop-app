import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/api_config.dart';
import 'secure_storage_service.dart';
import '../utils/app_logger.dart';

/// Invia gli errori runtime dell'app (crash + risposte HTTP anomale) al backend
/// WeCoop, così l'admin li vede nella pagina "Errori App" del back-office.
///
/// Invio automatico, best-effort e non bloccante. Applica throttling per non
/// spammare (max 1 invio ogni 3s + dedup dello stesso messaggio per 60s).
class ErrorReporter {
  ErrorReporter._();
  static final ErrorReporter instance = ErrorReporter._();

  static const _endpoint = '${ApiConfig.baseUrl}/app-errors';
  final _storage = SecureStorageService();

  String? _appVersion;
  String? _deviceInfo;
  String? _platform;

  DateTime _lastSent = DateTime.fromMillisecondsSinceEpoch(0);
  final Map<String, DateTime> _recent = {};

  bool _installed = false;

  /// Installa gli handler globali per catturare crash e errori async non gestiti.
  /// Chiamare una sola volta all'avvio (dopo WidgetsFlutterBinding).
  void install() {
    if (_installed) return;
    _installed = true;

    // Errori del framework Flutter (build/layout/gesture).
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      previousOnError?.call(details);
      report(
        tipo: 'crash',
        message: details.exceptionAsString(),
        stack: details.stack?.toString(),
        screen: details.library,
      );
    };

    // Errori async non gestiti a livello di piattaforma.
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      report(tipo: 'crash', message: error.toString(), stack: stack.toString());
      return true;
    };
  }

  /// Segnala un errore HTTP anomalo (es. HTML invece di JSON, 5xx).
  void reportHttp({
    required String endpoint,
    required int statusCode,
    String? message,
    String? bodyPreview,
  }) {
    report(
      tipo: 'http',
      message: message ?? 'Risposta HTTP inattesa ($statusCode) su $endpoint',
      endpoint: endpoint,
      statusCode: statusCode,
      stack: bodyPreview,
    );
  }

  /// Invia l'errore in background (fire-and-forget). Non lancia mai eccezioni.
  Future<void> report({
    required String message,
    String tipo = 'error',
    String? stack,
    String? endpoint,
    int? statusCode,
    String? screen,
  }) async {
    try {
      // Throttling globale.
      final now = DateTime.now();
      if (now.difference(_lastSent).inMilliseconds < 3000) return;

      // Dedup: stesso messaggio entro 60s → ignora.
      final key = '$tipo|$message';
      final last = _recent[key];
      if (last != null && now.difference(last).inSeconds < 60) return;
      _recent[key] = now;
      // Pulisce voci vecchie (mantiene la mappa piccola).
      _recent.removeWhere((_, t) => now.difference(t).inMinutes > 5);
      _lastSent = now;

      await _ensureContext();

      final userId = await _storage.read(key: 'user_id');
      final userLabel = await _storage.read(key: 'user_display_name') ??
          await _storage.read(key: 'user_email');

      final body = jsonEncode({
        'tipo': tipo,
        'message': message,
        if (stack != null) 'stack': stack,
        if (endpoint != null) 'endpoint': endpoint,
        if (statusCode != null) 'status_code': statusCode,
        if (screen != null) 'screen': screen,
        'platform': _platform,
        'app_version': _appVersion,
        'device_info': _deviceInfo,
        if (userId != null) 'user_id': userId,
        if (userLabel != null) 'user_label': userLabel,
      });

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      final jwt = await _storage.read(key: 'jwt_token');
      if (jwt != null && jwt.isNotEmpty) {
        headers['Authorization'] = 'Bearer $jwt';
      }

      await http
          .post(
            Uri.parse(_endpoint),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      // L'error reporter non deve MAI far crashare l'app.
      AppLogger.d('ErrorReporter: invio fallito: $e');
    }
  }

  Future<void> _ensureContext() async {
    if (_appVersion != null) return;
    try {
      final pkg = await PackageInfo.fromPlatform();
      _appVersion = '${pkg.version}+${pkg.buildNumber}';
    } catch (_) {
      _appVersion = 'unknown';
    }
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        _platform = 'android';
        final a = await info.androidInfo;
        _deviceInfo = '${a.manufacturer} ${a.model} · Android ${a.version.release}';
      } else if (Platform.isIOS) {
        _platform = 'ios';
        final i = await info.iosInfo;
        _deviceInfo = '${i.model} · iOS ${i.systemVersion}';
      } else {
        _platform = 'other';
        _deviceInfo = 'unknown';
      }
    } catch (_) {
      _platform ??= 'unknown';
      _deviceInfo ??= 'unknown';
    }
  }
}
