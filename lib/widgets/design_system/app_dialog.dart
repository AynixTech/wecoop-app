/// WeCoop Design System — Dialog di conferma
library;

import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import 'app_button.dart';

enum AppDialogVariant { info, success, warning, destructive }

/// Dialog standard WeCoop: header (icona + titolo), messaggio, azioni.
///
/// Uso rapido:
/// ```dart
/// final ok = await AppDialog.show(
///   context,
///   title: l10n.deleteAccountTitle,
///   message: l10n.deleteAccountConfirmMsg,
///   confirmLabel: l10n.deleteAccountAction,
///   cancelLabel: l10n.cancel,
///   variant: AppDialogVariant.destructive,
/// );
/// ```
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.variant = AppDialogVariant.info,
    this.content,
  });

  final String title;
  final String? message;
  final String? confirmLabel;
  final String? cancelLabel;
  final AppDialogVariant variant;
  final Widget? content;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    String? message,
    String? confirmLabel,
    String? cancelLabel,
    AppDialogVariant variant = AppDialogVariant.info,
    Widget? content,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AppDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        variant: variant,
        content: content,
      ),
    );
  }

  ({IconData icon, Color color}) get _style => switch (variant) {
        AppDialogVariant.info => (icon: Icons.info_outline, color: AppColors.info),
        AppDialogVariant.success => (icon: Icons.check_circle, color: AppColors.success),
        AppDialogVariant.warning => (icon: Icons.warning_amber_rounded, color: AppColors.warning),
        AppDialogVariant.destructive => (icon: Icons.error_outline, color: AppColors.error),
      };

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.heroCard),
      ),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(s.icon, color: s.color),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(title, style: AppTypography.headingS)),
              ],
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                message!,
                style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
              ),
            ],
            if (content != null) ...[
              const SizedBox(height: AppSpacing.md),
              content!,
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (cancelLabel != null)
                  AppButton(
                    label: cancelLabel!,
                    variant: AppButtonVariant.text,
                    expanded: false,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                if (confirmLabel != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(
                    label: confirmLabel!,
                    expanded: false,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
