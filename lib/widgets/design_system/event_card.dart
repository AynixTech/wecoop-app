/// WeCoop Design System — EventCard
///
/// Card evento a tutta larghezza: cover immagine + titolo + righe info
/// (data, luogo, posti). Dal Figma screen-eventi.
library;

import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Riga informativa con icona (data/luogo/posti).
class EventInfoRow {
  const EventInfoRow(this.icon, this.text);
  final IconData icon;
  final String text;
}

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.title,
    required this.info,
    this.cover,
    this.onTap,
    this.coverHeight = 180,
  });

  final String title;
  final List<EventInfoRow> info;
  final Widget? cover;
  final VoidCallback? onTap;
  final double coverHeight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardBr,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: coverHeight,
              width: double.infinity,
              child: cover ?? const ColoredBox(color: AppColors.bgSubtle),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.headingM.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final row in info) ...[
                    Row(
                      children: [
                        Icon(row.icon, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            row.text,
                            style: AppTypography.bodyM,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (row != info.last) const SizedBox(height: AppSpacing.xs),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
