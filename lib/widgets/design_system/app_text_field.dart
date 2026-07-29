/// WeCoop Design System — Campo di testo
library;

import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Campo di input WeCoop con label sopra e marcatore obbligatorio.
///
/// Dal Figma: label 13/semibold muted + `*` magenta, campo bianco h48,
/// radius 12, bordo hairline, focus teal.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.required = false,
    this.obscureText = false,
    this.keyboardType,
    this.prefix,
    this.suffix,
    this.readOnly = false,
    this.maxLines = 1,
    this.onTap,
    this.validator,
    this.errorText,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final bool required;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final Widget? suffix;
  final bool readOnly;
  final int maxLines;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTypography.label),
            if (required)
              Text(
                ' *',
                style: AppTypography.label.copyWith(color: AppColors.error),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          maxLines: obscureText ? 1 : maxLines,
          onTap: onTap,
          validator: validator,
          onChanged: onChanged,
          style: AppTypography.bodyL,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyL.copyWith(color: AppColors.textMuted),
            errorText: errorText,
            filled: true,
            fillColor: AppColors.surface,
            prefixIcon: prefix,
            suffixIcon: suffix,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputBr,
              borderSide: const BorderSide(color: AppColors.borderInput),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputBr,
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputBr,
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputBr,
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
