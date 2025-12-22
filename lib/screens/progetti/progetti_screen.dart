import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'project_category_detail_screen.dart';

class ProgettiScreen extends StatelessWidget {
  const ProgettiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = _getCategories(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n!.projects),

        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: ListView.builder(
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
                      builder: (context) => ProjectCategoryDetailScreen(
                        categoryKey: category['key'],
                        categoryName: category['name'],
                        categoryIcon: category['icon'],
                        categoryColor: category['color'],
                        projects: category['projects'],
                      ),
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
                      colors: [
                        category['color'].withOpacity(0.7),
                        category['color'],
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          category['icon'],
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${category['projects'].length} ${category['projects'].length == 1 ? 'progetto' : 'progetti'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getCategories(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return [
      {
        'key': 'giovani',
        'name': l10n.youthCategory,
        'icon': Icons.school,
        'color': Colors.blue,
        'projects': [
          {
            'name': 'MAFALDA',
            'description': l10n.mafaldaDescription,
            'services': [
              l10n.mafaldaService1,
              l10n.mafaldaService2,
              l10n.mafaldaService3,
              l10n.mafaldaService4,
            ],
          },
        ],
      },
      {
        'key': 'donne',
        'name': l10n.womenCategory,
        'icon': Icons.people,
        'color': Colors.purple,
        'projects': [
          {
            'name': 'WOMENTOR',
            'description': l10n.womentorDescription,
            'services': [
              l10n.womentorService1,
              l10n.womentorService2,
              l10n.womentorService3,
              l10n.womentorService4,
            ],
          },
        ],
      },
      {
        'key': 'sport',
        'name': l10n.sportsCategory,
        'icon': Icons.sports_soccer,
        'color': Colors.green,
        'projects': [
          {
            'name': 'SPORTUNITY',
            'description': l10n.sportunityDescription,
            'services': [
              l10n.sportunityService1,
              l10n.sportunityService2,
              l10n.sportunityService3,
              l10n.sportunityService4,
            ],
          },
        ],
      },
      {
        'key': 'migranti',
        'name': l10n.migrantsCategory,
        'icon': Icons.support_agent,
        'color': Colors.orange,
        'projects': [
          {
            'name': 'PASSAPAROLA',
            'description': l10n.passaparolaDescription,
            'services': [
              l10n.passaparolaService1,
              l10n.passaparolaService2,
              l10n.passaparolaService3,
              l10n.passaparolaService4,
            ],
          },
        ],
      },
    ];
  }
}
