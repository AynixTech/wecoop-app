import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Verifica automaticamente la versione pubblicata sull'App Store.
///
/// Google Play offre gia' un controllo nativo su Android tramite
/// [InAppUpdateService]. Apple non offre un equivalente nativo: per iOS viene
/// usato il catalogo pubblico App Store, che restituisce sia la versione sia
/// l'URL della pagina dello store, senza configurazione manuale per release.
class AppUpdatePolicyService {
  static const _appStoreLookupUrl = 'https://itunes.apple.com/lookup';
  static const _bundleId = 'org.wecoop.app';

  static Future<AppUpdateRequirement> checkForMandatoryUpdate() async {
    if (kIsWeb || !Platform.isIOS) {
      return const AppUpdateRequirement.notRequired();
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final response = await http
          .get(
            Uri.parse(_appStoreLookupUrl).replace(
              queryParameters: const {'bundleId': _bundleId, 'country': 'IT'},
            ),
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

      final results = decoded['results'];
      if (results is! List || results.isEmpty || results.first is! Map) {
        return const AppUpdateRequirement.notRequired();
      }

      final storeEntry = Map<String, dynamic>.from(results.first as Map);
      final publishedVersion = storeEntry['version']?.toString() ?? '';
      final storeUrl = storeEntry['trackViewUrl']?.toString() ?? '';
      if (publishedVersion.isEmpty || storeUrl.isEmpty) {
        return const AppUpdateRequirement.notRequired();
      }

      return AppUpdateRequirement(
        isRequired: _isOlderVersion(packageInfo.version, publishedVersion),
        requiredVersion: publishedVersion,
        storeUrl: storeUrl,
      );
    } catch (error) {
      debugPrint('AppUpdatePolicyService: App Store non disponibile: $error');
      // La verifica non puo' bloccare chi e' offline o quando App Store non
      // e' raggiungibile; al prossimo avvio/rientro nell'app verra' rieseguita.
      return const AppUpdateRequirement.notRequired();
    }
  }

  static bool _isOlderVersion(String current, String required) {
    final currentParts = _numericVersionParts(current);
    final requiredParts = _numericVersionParts(required);
    if (currentParts == null || requiredParts == null) return false;

    final length =
        currentParts.length > requiredParts.length
            ? currentParts.length
            : requiredParts.length;
    for (var index = 0; index < length; index++) {
      final currentPart = index < currentParts.length ? currentParts[index] : 0;
      final requiredPart =
          index < requiredParts.length ? requiredParts[index] : 0;
      if (currentPart != requiredPart) return currentPart < requiredPart;
    }
    return false;
  }

  static List<int>? _numericVersionParts(String version) {
    final match = RegExp(r'^v?(\d+(?:\.\d+)*)').firstMatch(version.trim());
    if (match == null) return null;
    final parts = match.group(1)!.split('.');
    final parsed = parts.map(int.tryParse).toList();
    if (parsed.any((part) => part == null)) return null;
    return parsed.cast<int>();
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
