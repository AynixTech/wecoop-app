/// WeCoop Design System — Section header
///
/// Titolo di sezione con barretta verticale teal (dal Figma home).
library;

import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(title, style: AppTypography.headingS)),
        if (trailing != null) trailing!,
      ],
    );
  }
}
