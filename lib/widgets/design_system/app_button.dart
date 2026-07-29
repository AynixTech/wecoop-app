/// WeCoop Design System — Bottone
library;

import 'package:flutter/material.dart';
import '../../theme/theme.dart';

enum AppButtonVariant { primary, secondary, text }

/// Bottone standard WeCoop.
///
/// - `primary`: pillola teal piena (default), ombra soft.
/// - `secondary`: pillola con bordo teal, testo teal scuro.
/// - `text`: solo testo teal.
///
/// Supporta stato `loading` (spinner + disabilitato) e larghezza piena.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expanded = true,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expanded;
  final double height;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = variant == AppButtonVariant.primary;
    final bool isSecondary = variant == AppButtonVariant.secondary;

    final Color fg = isPrimary ? AppColors.onPrimary : AppColors.primaryDark;
    final Color spinnerColor = isPrimary ? AppColors.onPrimary : AppColors.primary;

    final Widget child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: spinnerColor),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label, style: AppTypography.button.copyWith(color: fg)),
            ],
          );

    final Widget button = DecoratedBox(
      decoration: BoxDecoration(
        color: isPrimary
            ? (_enabled ? AppColors.primary : AppColors.disabled)
            : Colors.transparent,
        borderRadius: AppRadius.pillBr,
        border: isSecondary
            ? Border.all(color: AppColors.primary, width: 1.2)
            : null,
        boxShadow: isPrimary && _enabled ? AppShadows.buttonPrimary : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.pillBr,
          onTap: _enabled ? onPressed : null,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );

    if (variant == AppButtonVariant.text) {
      return TextButton(
        onPressed: _enabled ? onPressed : null,
        child: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: spinnerColor),
              )
            : Text(label, style: AppTypography.button.copyWith(color: AppColors.primary)),
      );
    }

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
