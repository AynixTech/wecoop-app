import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';

class ProgettoDettaglioScreen extends StatelessWidget {
  final Map<String, dynamic> progetto;

  const ProgettoDettaglioScreen({super.key, required this.progetto});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final services = progetto['services'] as List<Map<String, String>>;

    return Scaffold(
      appBar: AppBar(
        title: Text(progetto['title'] as String),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con icona e categoria
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (progetto['color'] as Color).withOpacity(0.2),
                    (progetto['color'] as Color).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (progetto['color'] as Color).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: progetto['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      progetto['icon'] as IconData,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          progetto['title'] as String,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: progetto['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          progetto['category'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Descrizione
            Text(
              l10n.translate('projectDescription'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              progetto['description'] as String,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Servizi offerti
            Text(
              l10n.translate('servicesOffered'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...services.map((service) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (progetto['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: progetto['color'] as Color,
                    ),
                  ),
                  title: Text(
                    service['name']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      service['description']!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
