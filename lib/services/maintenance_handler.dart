import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';

class MaintenanceHandler {
  static GlobalKey<NavigatorState>? _navigatorKey;
  static bool _isDialogVisible = false;

  static void bindNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  static Future<void> showMaintenanceModal() async {
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
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.translate('maintenanceTitle')),
          content: Text(l10n.translate('maintenanceMessage')),
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

  static Future<void> handleHttpStatusCode(int statusCode) async {
    if (statusCode == 500) {
      await showMaintenanceModal();
    }
  }
}
