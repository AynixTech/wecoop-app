/// WeCoop Design System — Bottom navigation
///
/// Barra di navigazione curva con bottone Home centrale rialzato (dal Figma).
/// Accetta una lista di item; l'item marcato `isCenter` viene reso come
/// bottone circolare flottante al centro.
library;

import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.label,
    this.isCenter = false,
  });

  final IconData icon;
  final String label;
  final bool isCenter;
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.centerChild,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Contenuto opzionale del bottone centrale (es. logo app).
  final Widget? centerChild;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 94,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Barra
          Positioned(
            left: 0,
            right: 0,
            top: 24,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.navBar),
                ),
                border: Border(top: BorderSide(color: AppColors.border)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0D1F2933),
                    offset: Offset(0, -2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0; i < items.length; i++)
                    items[i].isCenter
                        ? const SizedBox(width: 72)
                        : _Tab(
                            item: items[i],
                            selected: i == currentIndex,
                            onTap: () => onTap(i),
                          ),
                ],
              ),
            ),
          ),
          // Bottone centrale
          for (int i = 0; i < items.length; i++)
            if (items[i].isCenter)
              Align(
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () => onTap(i),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: i == currentIndex
                            ? AppColors.primary
                            : AppColors.border,
                        width: 3,
                      ),
                      boxShadow: AppShadows.centerButton,
                    ),
                    child: Center(
                      child: centerChild ??
                          Icon(
                            items[i].icon,
                            color: AppColors.primary,
                            size: 28,
                          ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.item, required this.selected, required this.onTap});

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.iconInactive;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 22, color: color),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.overline.copyWith(
                fontSize: 10,
                fontWeight: selected ? AppTypography.semiBold : AppTypography.medium,
                letterSpacing: 0,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
