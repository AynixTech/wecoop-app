import 'package:flutter/material.dart';
import '../../services/app_localizations.dart';
import 'richiesta_form_screen.dart';

class OrientamentoFiscaleScreen extends StatelessWidget {
  const OrientamentoFiscaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('taxGuidanceAndClarifications'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.translate('selectServiceCategory'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _ServiceCard(
                icon: Icons.account_balance,
                title: l10n.translate('taxesAndContributions'),
                description: l10n.translate('taxesAndContributionsDesc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RichiestaFormScreen(
                        servizio: l10n.translate('taxGuidanceAndClarifications'),
                        categoria: l10n.translate('taxesAndContributions'),
                        campi: [
                          {'label': l10n.fullName, 'type': 'text', 'required': true},
                          {'label': l10n.email, 'type': 'text', 'required': true},
                          {'label': l10n.phone, 'type': 'text', 'required': true},
                          {'label': l10n.fiscalCode, 'type': 'text', 'required': true},
                          {
                            'label': l10n.translate('taxType'),
                            'type': 'select',
                            'options': [
                              'IMU',
                              'TARI',
                              'TASI',
                              l10n.translate('incomeTax'),
                              'INPS',
                              'INAIL',
                              l10n.translate('other'),
                            ],
                            'required': true,
                          },
                          {
                            'label': l10n.translate('requestDescription'),
                            'type': 'textarea',
                            'required': true,
                          },
                          {'label': l10n.translate('additionalNotes'), 'type': 'textarea', 'required': false},
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ServiceCard(
                icon: Icons.question_answer,
                title: l10n.translate('clarificationsAndConsulting'),
                description: l10n.translate('clarificationsAndConsultingDesc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RichiestaFormScreen(
                        servizio: l10n.translate('taxGuidanceAndClarifications'),
                        categoria: l10n.translate('clarificationsAndConsulting'),
                        campi: [
                          {'label': l10n.fullName, 'type': 'text', 'required': true},
                          {'label': l10n.email, 'type': 'text', 'required': true},
                          {'label': l10n.phone, 'type': 'text', 'required': true},
                          {
                            'label': l10n.translate('consultingTopic'),
                            'type': 'select',
                            'options': [
                              l10n.translate('taxDeduction'),
                              l10n.translate('vatRefund'),
                              l10n.translate('fiscalRegime'),
                              l10n.translate('taxDeclaration'),
                              l10n.translate('other'),
                            ],
                            'required': true,
                          },
                          {
                            'label': l10n.translate('questionDetail'),
                            'type': 'textarea',
                            'required': true,
                          },
                          {'label': l10n.translate('additionalNotes'), 'type': 'textarea', 'required': false},
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.amber.shade700, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
