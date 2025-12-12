import 'package:flutter/material.dart';

class ProgettiScreen extends StatelessWidget {
  const ProgettiScreen({super.key});

  final List<Map<String, String>> mockProjects = const [
    {'title': 'MAFALDA', 'description': 'Progettazione europea per giovani.'},
    {
      'title': 'WOMENTOR',
      'description': 'Mentoring e networking intergenerazionale tra donne.',
    },
    {
      'title': 'SPORTUNITY',
      'description': 'Integrazione sociale tramite sport.',
    },
    {
      'title': 'PASSAPAROLA',
      'description': 'Sportello migranti e supporto documentale.',
    },
  ];

  void _showProposalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Proponi un corso o evento'),
            content: const Text('Funzionalità in sviluppo.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Chiudi'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          Text(
            'Progetti Attivi',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...mockProjects.map((project) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: Colors.amber.shade200,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 40,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project['title']!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            project['description']!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade700,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showProposalDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Proponi corso o evento'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.amber.shade700,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                elevation: 5,
                shadowColor: Colors.amber.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
