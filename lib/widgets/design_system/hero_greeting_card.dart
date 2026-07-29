/// WeCoop Design System — Hero greeting card
///
/// Card di saluto in home: gradiente teal→verde, avatar, badge stato socio.
library;

import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class HeroGreetingCard extends StatelessWidget {
  const HeroGreetingCard({
    super.key,
    required this.greeting,
    this.subtitle,
    this.badgeLabel,
    this.avatar,
    this.initials,
  });

  /// Es. "Ciao, Marco".
  final String greeting;

  /// Es. "Socio dal 2024 · Codice #4489".
  final String? subtitle;

  /// Es. "Area Soci" / "Ospite".
  final String? badgeLabel;

  /// Widget avatar (immagine). Se null, mostra [initials] o un'icona.
  final Widget? avatar;
  final String? initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: AppRadius.heroBr,
      ),
      child: Row(
        children: [
          _Avatar(avatar: avatar, initials: initials),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: AppTypography.headingS.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onGradientMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (badgeLabel != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.glassBadge,
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Text(
                badgeLabel!,
                style: AppTypography.overline.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.avatar, this.initials});

  final Widget? avatar;
  final String? initials;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 48,
        height: 48,
        child: avatar ??
            ColoredBox(
              color: AppColors.glassBadge,
              child: Center(
                child: initials != null && initials!.isNotEmpty
                    ? Text(
                        initials!,
                        style: AppTypography.bodyL.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: AppTypography.bold,
                        ),
                      )
                    : const Icon(Icons.person, color: AppColors.onPrimary),
              ),
            ),
      ),
    );
  }
}
