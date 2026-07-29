/// WeCoop Design System — Campo OTP
///
/// Campo singolo a 6 cifre (dal Figma firma-03): testo grande centrato,
/// letter-spacing ampio. Non boxed-cell, coerente con l'implementazione app.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';

class OtpField extends StatelessWidget {
  const OtpField({
    super.key,
    this.controller,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
  });

  final TextEditingController? controller;
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: length,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: AppTypography.display.copyWith(letterSpacing: 8),
      onChanged: (v) {
        onChanged?.call(v);
        if (v.length == length) onCompleted?.call(v);
      },
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBr,
          borderSide: const BorderSide(color: AppColors.borderInput),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputBr,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
