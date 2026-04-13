import 'package:flutter/material.dart';

import '../../models/project_opportunity_catalog.dart';
import '../../services/app_localizations.dart';
import '../../services/interessati_service.dart';
import '../servizi/accoglienza_screen.dart';
import '../servizi/educazione_finanziaria_credito_screen.dart';
import '../servizi/lavoro_orientamento_screen.dart';
import '../servizi/supporto_contabile_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String categoryKey;
  final String categoryTitle;
  final ProjectOpportunityItem item;
  final Color categoryColor;

  const ProjectDetailScreen({
    super.key,
    required this.categoryKey,
    required this.categoryTitle,
    required this.item,
    required this.categoryColor,
  });

  String _slugify(String value) {
    final lower = value.toLowerCase();
    final safe = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return safe.replaceAll(RegExp(r'^-+|-+$'), '');
  }

  String _resolveItemType() {
    switch (item.actionKey) {
      case 'training':
        return 'corso';
      case 'inclusion':
        return 'evento';
      default:
        return 'opportunita';
    }
  }

  Future<void> _trackInterest() async {
    final itemKey = '$categoryKey-${item.actionKey}-${_slugify(item.title)}';

    await InteressatiService.registerInterest(
      itemKey: itemKey,
      itemTitle: item.title,
      itemType: _resolveItemType(),
      source: 'app_project_detail_cta',
    );
  }

  void _handleCta(BuildContext context) {
    switch (item.behaviorKey) {
      case 'open_credit_service':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EducazioneFinanziariaCreditoScreen(),
          ),
        );
        return;
      case 'open_accounting_service':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SupportoContabileScreen()),
        );
        return;
      case 'interest_only':
        _trackInterest();
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            content: const Text(
              'Grazie per il tuo interessamento, appena sara disponibile ti manderemo un messaggio.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      case 'open_welcome_service':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AccoglienzaScreen()),
        );
        return;
      default:
        break;
    }

    if (item.actionKey == 'work') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LavoroOrientamentoScreen()),
      );
      return;
    }

    _trackInterest();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text(
          'Grazie per il tuo interessamento, appena sara disponibile ti manderemo un messaggio.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        backgroundColor: categoryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [categoryColor, categoryColor.withOpacity(0.72)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.contentTypeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('opportunityTagsTitle'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final tag in item.tags)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface.withOpacity(0.74),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.translate('opportunityActionHint'),
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: scheme.onSurface.withOpacity(0.72),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleCta(context),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(item.ctaLabel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: categoryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
