import 'package:flutter/material.dart';
import 'package:wecoop_app/models/project_opportunity_catalog.dart';
import 'package:wecoop_app/services/interessati_service.dart';

import '../servizi/accoglienza_screen.dart';
import '../servizi/cv_ai_screen.dart';
import '../servizi/educazione_finanziaria_credito_screen.dart';
import '../servizi/lavoro_orientamento_screen.dart';
import 'project_detail_screen.dart';

class ProjectCategoryDetailScreen extends StatelessWidget {
    String _slugify(String value) {
      final lower = value.toLowerCase();
      final safe = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
      return safe.replaceAll(RegExp(r'^-+|-+$'), '');
    }

    String _resolveItemType(ProjectOpportunityItem item) {
      switch (item.actionKey) {
        case 'training':
          return 'corso';
        case 'inclusion':
          return 'evento';
        default:
          return 'opportunita';
      }
    }

    Future<void> _trackInterest(ProjectOpportunityItem item) async {
      final itemKey = '${category.key}-${item.actionKey}-${_slugify(item.title)}';

      await InteressatiService.registerInterest(
        itemKey: itemKey,
        itemTitle: item.title,
        itemType: _resolveItemType(item),
        source: 'app_project_cta',
      );
    }

  final ProjectOpportunityCategory category;

  const ProjectCategoryDetailScreen({super.key, required this.category});

  void _openDetail(BuildContext context, ProjectOpportunityItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ProjectDetailScreen(
              categoryKey: category.key,
              categoryTitle: category.title,
              item: item,
              categoryColor: category.color,
            ),
      ),
    );
  }

  void _handleCta(BuildContext context, ProjectOpportunityItem item) {
    _trackInterest(item);

    Widget destination;

    switch (item.actionKey) {
      case 'training':
      case 'work':
        destination = const LavoroOrientamentoScreen();
        break;
      case 'credit':
        destination = const EducazioneFinanziariaCreditoScreen();
        break;
      case 'inclusion':
        destination = const AccoglienzaScreen();
        break;
      case 'cv':
        destination = const CvAiScreen();
        break;
      default:
        destination = const AccoglienzaScreen();
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
        backgroundColor: category.color,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              category.summary,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: scheme.onSurface.withOpacity(0.84),
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final item in category.items) ...[
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: InkWell(
                onTap: () => _openDetail(context, item),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: category.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item.icon,
                              color: category.color,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: category.color.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    item.contentTypeLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: category.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurface.withOpacity(0.74),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final tag in item.tags)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurface.withOpacity(0.72),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleCta(context, item),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: Text(item.ctaLabel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: category.color,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
