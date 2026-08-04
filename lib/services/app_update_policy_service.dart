import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wecoop_app/config/api_config.dart';

/// Verifica se l'aggiornamento dell'app è obbligatorio interrogando il backend
/// WeCoop (fonte unica gestita dagli amministratori dal portale).
///
/// L'endpoint pubblico `GET /api/app-version/:platform?current=<versione>`
/// restituisce già il calcolo `update_required` (versione minima non
/// soddisfatta oppure flag "aggiornamento obbligatorio" attivo) e l'URL dello
/// store dove aggiornare. Vale sia per iOS sia per Android.
class AppUpdatePolicyService {
  static Future<AppUpdateRequirement> checkForMandatoryUpdate() async {
    if (kIsWeb) {
      return const AppUpdateRequirement.notRequired();
    }

    final platform = _platformKey();
    if (platform == null) {
      return const AppUpdateRequirement.notRequired();
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final current = packageInfo.version;

      final uri = Uri.parse('${ApiConfig.baseUrl}/app-version/$platform')
          .replace(queryParameters: {'current': current});

      final response = await http
          .get(
            uri,
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return const AppUpdateRequirement.notRequired();
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        return const AppUpdateRequirement.notRequired();
      }

      final updateRequired = decoded['update_required'] == true;
      final requiredVersion =
          decoded['latest_version']?.toString() ?? '';
      final storeUrl = decoded['store_url']?.toString() ?? '';

      // Non forziamo l'update se manca l'URL dello store (l'utente resterebbe
      // bloccato senza via d'uscita). L'admin deve compilarlo dal portale.
      if (updateRequired && storeUrl.isEmpty) {
        return const AppUpdateRequirement.notRequired();
      }

      return AppUpdateRequirement(
        isRequired: updateRequired,
        requiredVersion: requiredVersion,
        storeUrl: storeUrl,
      );
    } catch (error) {
      debugPrint('AppUpdatePolicyService: backend non disponibile: $error');
      // La verifica non può bloccare chi è offline o quando il backend non è
      // raggiungibile; al prossimo avvio/rientro nell'app verrà rieseguita.
      return const AppUpdateRequirement.notRequired();
    }
  }

  /// Chiave piattaforma attesa dal backend ('ios' | 'android'), null altrove.
  static String? _platformKey() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return null;
  }
}

class AppUpdateRequirement {
  const AppUpdateRequirement({
    required this.isRequired,
    this.requiredVersion = '',
    this.storeUrl = '',
  });

  const AppUpdateRequirement.notRequired() : this(isRequired: false);

  final bool isRequired;
  final String requiredVersion;
  final String storeUrl;
}
