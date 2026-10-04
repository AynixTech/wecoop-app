/// WeCoop Design System — InfoCard (orizzontale)
///
/// Card compatta usata negli slider orizzontali (post/eventi in home).
/// Dal Figma: width 208, immagine top 100px, titolo + sottotitolo + CTA.
library;

import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.image,
    this.ctaLabel,
    this.onTap,
    this.width = 208,
  });

  final String title;
  final String? subtitle;
  final Widget? image;
  final String? ctaLabel;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
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
            // Nessun placeholder se non c'è immagine: evita lo spazio bianco vuoto.
            if (image != null)
              SizedBox(
                height: 100,
                width: double.infinity,
                child: image,
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyM.copyWith(
                      fontWeight: AppTypography.bold,
                      height: 1.25,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(height: 1.3),
                    ),
                  ],
                  if (ctaLabel != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ctaLabel!,
                          style: AppTypography.overline.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        const Icon(
                          Icons.arrow_forward,
                          size: 12,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
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
