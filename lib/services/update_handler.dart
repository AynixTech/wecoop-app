import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/app_update_service.dart';

/// Mostra il dialogo di aggiornamento.
///
/// - Se [info.updateRequired] è true: dialogo NON chiudibile (blocco totale),
///   l'unica azione è andare allo store.
/// - Se solo [info.updateAvailable] è true: dialogo chiudibile con opzione
///   "più tardi".
class UpdateHandler {
  static GlobalKey<NavigatorState>? _navigatorKey;
  static bool _isDialogVisible = false;

  static void bindNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// Controlla l'aggiornamento e mostra il dialogo se necessario.
  static Future<void> checkAndPrompt() async {
    final info = await AppUpdateService.checkForUpdate();
    if (!info.updateRequired && !info.updateAvailable) return;
    await _showUpdateDialog(info);
  }

  static Future<void> _showUpdateDialog(AppUpdateInfo info) async {
    if (_isDialogVisible) return;

    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    _isDialogVisible = true;

    final bool forced = info.updateRequired;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: !forced,
        builder: (dialogContext) {
          return PopScope(
            // Se l'aggiornamento è obbligatorio, blocca il tasto indietro.
            canPop: !forced,
            child: AlertDialog(
              title: Text(
                forced
                    ? l10n.translate('updateRequiredTitle')
                    : l10n.translate('updateAvailableTitle'),
              ),
              content: Text(
                info.message?.isNotEmpty == true
                    ? info.message!
                    : (forced
                        ? l10n.translate('updateRequiredMessage')
                        : l10n.translate('updateAvailableMessage')),
              ),
              actions: [
                if (!forced)
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(l10n.translate('updateLater')),
                  ),
                ElevatedButton(
                  onPressed: () => _openStore(info.storeUrl),
                  child: Text(l10n.translate('updateNow')),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      _isDialogVisible = false;
    }
  }

  static Future<void> _openStore(String storeUrl) async {
    if (storeUrl.isEmpty) return;
    final uri = Uri.parse(storeUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('UpdateHandler: impossibile aprire lo store: $e');
    }
  }
}
