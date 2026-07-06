import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Risultato del controllo versione.
class AppUpdateInfo {
  /// Se true, l'utente DEVE aggiornare (blocco totale).
  final bool updateRequired;

  /// Se true, esiste una versione più recente ma l'aggiornamento è opzionale.
  final bool updateAvailable;

  /// URL dello store (Play Store / App Store) verso cui inviare l'utente.
  final String storeUrl;

  /// Messaggio opzionale personalizzato dal backend (facoltativo).
  final String? message;

  const AppUpdateInfo({
    required this.updateRequired,
    required this.updateAvailable,
    required this.storeUrl,
    this.message,
  });

  static const AppUpdateInfo none = AppUpdateInfo(
    updateRequired: false,
    updateAvailable: false,
    storeUrl: '',
  );
}

/// Servizio che verifica se l'app installata è troppo vecchia rispetto
/// alla versione minima richiesta dal backend WECOOP.
///
/// Il backend (WordPress) espone un endpoint JSON con la configurazione
/// delle versioni. Vedi la documentazione PHP fornita separatamente.
class AppUpdateService {
  /// Endpoint sul backend WordPress che restituisce la config versioni.
  static const String _versionEndpoint =
      'https://www.wecoop.org/wp-json/wecoop/v1/app-version';

  /// Fallback store URL se il backend non ne fornisce uno.
  static const String _androidStoreUrl =
      'https://play.google.com/store/apps/details?id=org.wecoop.app';
  static const String _iosStoreUrl =
      'https://apps.apple.com/app/id0000000000'; // TODO: sostituire con l'Apple ID reale dell'app

  /// Controlla la versione contro il backend.
  ///
  /// Ritorna [AppUpdateInfo.none] in caso di errore di rete o risposta
  /// non valida: NON blocchiamo mai l'utente per un problema di rete.
  static Future<AppUpdateInfo> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // es. "1.4.0"
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0; // es. 17

      final response = await http
          .get(
            Uri.parse(_versionEndpoint),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('AppUpdateService: status ${response.statusCode}');
        return AppUpdateInfo.none;
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final platformKey = _platformKey();
      final config = data[platformKey] ?? data;

      // Versione minima richiesta (build number) sotto la quale si BLOCCA.
      final minBuild = _asInt(config['min_build']);
      // Ultima versione disponibile (build number), per update opzionale.
      final latestBuild = _asInt(config['latest_build']);

      final storeUrl = (config['store_url'] as String?)?.trim().isNotEmpty == true
          ? config['store_url'] as String
          : _defaultStoreUrl();

      final message = config['message'] as String?;

      final updateRequired = minBuild != null && currentBuild < minBuild;
      final updateAvailable =
          latestBuild != null && currentBuild < latestBuild;

      debugPrint(
        'AppUpdateService: current=$currentVersion+$currentBuild '
        'min=$minBuild latest=$latestBuild '
        'required=$updateRequired available=$updateAvailable',
      );

      return AppUpdateInfo(
        updateRequired: updateRequired,
        updateAvailable: updateAvailable,
        storeUrl: storeUrl,
        message: message,
      );
    } catch (e) {
      debugPrint('AppUpdateService: errore controllo versione: $e');
      return AppUpdateInfo.none;
    }
  }

  static String _platformKey() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    return 'android';
  }

  static String _defaultStoreUrl() {
    if (!kIsWeb && Platform.isIOS) return _iosStoreUrl;
    return _androidStoreUrl;
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }
}
