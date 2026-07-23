import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';

class MaintenanceHandler {
  static const String _platformUpdateFallback =
      'La piattaforma è in aggiornamento. Riprova tra un\'ora.';
  static GlobalKey<NavigatorState>? _navigatorKey;
  static bool _isDialogVisible = false;

  static String get platformUpdateMessage =>
      _platformUpdateMessageFor(_navigatorKey?.currentContext);

  static void bindNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  static Future<void> showMaintenanceModal() async {
    await _showModal(
      message:
          (context) =>
              AppLocalizations.of(context)!.translate('maintenanceMessage'),
    );
  }

  static Future<void> showPlatformUpdateModal() async {
    await _showModal(message: _platformUpdateMessageFor);
  }

  static String _platformUpdateMessageFor(BuildContext? context) {
    final activeContext = context ?? _navigatorKey?.currentContext;
    if (activeContext == null) {
      return _platformUpdateFallback;
    }
    return AppLocalizations.of(
          activeContext,
        )?.translate('platformUpdateMessage') ??
        _platformUpdateFallback;
  }

  static Future<void> _showModal({
    required String Function(BuildContext context) message,
  }) async {
    if (_isDialogVisible) return;

    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    _isDialogVisible = true;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder:
            (dialogContext) => AlertDialog(
              title: Text(l10n.translate('maintenanceTitle')),
              content: Text(message(dialogContext)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.translate('close')),
                ),
              ],
            ),
      );
    } finally {
      _isDialogVisible = false;
    }
  }

  static bool isPlatformUpdateStatusCode(int statusCode) => statusCode == 500;

  static Future<void> handleHttpStatusCode(int statusCode) async {
    if (isPlatformUpdateStatusCode(statusCode)) {
      await showPlatformUpdateModal();
    } else if (statusCode == 503) {
      await showMaintenanceModal();
    }
  }
}
