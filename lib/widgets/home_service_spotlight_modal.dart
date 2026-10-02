import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/service_spotlight_service.dart';
import 'package:wecoop_app/theme/theme.dart';
import 'package:wecoop_app/utils/service_code_navigation.dart';

/// Modal promo servizio sulla home: overlay nero, X per chiudere, CTA verso il servizio.
Future<void> showHomeServiceSpotlightModal(
  BuildContext context,
  ServiceSpotlightItem item,
) async {
  if (!context.mounted) return;

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'spotlight',
    barrierColor: Colors.black.withOpacity(0.72),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, anim, secondary) {
      return SafeArea(
        child: _HomeServiceSpotlightDialog(item: item),
      );
    },
    transitionBuilder: (ctx, anim, secondary, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _HomeServiceSpotlightDialog extends StatelessWidget {
  final ServiceSpotlightItem item;

  const _HomeServiceSpotlightDialog({required this.item});

  Future<void> _close(BuildContext context) async {
    await ServiceSpotlightService.dismiss(item);
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _openService(BuildContext context) async {
    await ServiceSpotlightService.dismiss(item);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    if (!context.mounted) return;
    final opened = await openServiceByCatalog(
      context: context,
      code: item.code,
      macro: item.macro,
      fallbackLabel: item.label,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(item.label)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final desc = (item.description ?? '').trim();

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        if (desc.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            desc,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        FilledButton(
                          onPressed: () => _openService(context),
                          child: Text(l10n.translate('ctaStartNow')),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                      onPressed: () => _close(context),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
