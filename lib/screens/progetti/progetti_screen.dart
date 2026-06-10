import 'package:flutter/material.dart';
import 'package:wecoop_app/models/project_opportunity_catalog.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'project_category_detail_screen.dart';

class ProgettiScreen extends StatelessWidget {
  const ProgettiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = _getCategories(context);
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('projectsOpportunitySectionTitle')),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ProjectCategoryDetailScreen(category: category),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [category.color.withOpacity(0.75), category.color],
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 20,
                  vertical: isTablet ? 14 : 20,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isTablet ? 10 : 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        category.icon,
                        size: isTablet ? 28 : 32,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: isTablet ? 12 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.title,
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: isTablet ? 2 : 4),
                          Text(
                            '${category.items.length} ${l10n.translate('availableOpportunitiesLabel')}',
                            style: TextStyle(
                              fontSize: isTablet ? 13 : 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: isTablet ? 6 : 8),
                          Text(
                            category.summary,
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 13,
                              height: 1.35,
                              color: Colors.white.withOpacity(0.92),
                            ),
                            maxLines: isTablet ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: isTablet ? 18 : 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<ProjectOpportunityCategory> _getCategories(BuildContext context) {
    return buildProjectOpportunityCatalog(context);
  }
}
