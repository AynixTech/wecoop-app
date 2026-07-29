/// WeCoop Design System — Selection card
///
/// Unifica le ~10 card di selezione quasi identiche presenti nei servizi
/// (icona in box tinto + titolo + sottotitolo + chevron).
library;

import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import 'app_card.dart';

class SelectionCard extends StatelessWidget {
  const SelectionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyL.copyWith(
                    fontWeight: AppTypography.semiBold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.label.copyWith(
                      fontWeight: AppTypography.regular,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.chevron_right,
            size: 16,
            color: AppColors.iconInactive,
          ),
        ],
      ),
    );
  }
}
