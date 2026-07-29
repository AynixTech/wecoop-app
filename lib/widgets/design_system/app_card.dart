/// WeCoop Design System — Card base
library;

import 'package:flutter/material.dart';
import '../../theme/theme.dart';

/// Card contenitore standard: bianca, radius 16, bordo hairline, ombra soft.
/// Opzionalmente cliccabile (InkWell con lo stesso radius).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.onTap,
    this.radius = AppRadius.card,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final BorderRadius br = BorderRadius.circular(radius);
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: br,
        border: Border.all(color: AppColors.border),
        boxShadow: shadow ? AppShadows.card : null,
      ),
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: br,
                onTap: onTap,
                child: Padding(padding: padding, child: child),
              ),
            ),
    );
    return content;
  }
}
