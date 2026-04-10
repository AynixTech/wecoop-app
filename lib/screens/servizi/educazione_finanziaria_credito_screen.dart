import 'package:flutter/material.dart';
import '../../services/app_localizations.dart';
import 'richiesta_form_screen.dart';

class EducazioneFinanziariaCreditoScreen extends StatelessWidget {
  const EducazioneFinanziariaCreditoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('financialEducationCredit'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.translate('selectServiceCategory'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _ServiceCard(
                icon: Icons.school,
                title: l10n.translate('financialBasics'),
                description: l10n.translate('financialBasicsDesc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.translate(
                              'financialEducationCredit',
                            ),
                            categoria: l10n.translate('financialBasics'),
                            campi: [
                              {
                                'label': l10n.fullName,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.fiscalCode,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.phone,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.email,
                                'type': 'email',
                                'required': true,
                              },
                              {
                                'label': l10n.translate('clarifyTopic'),
                                'type': 'select',
                                'options': [
                                  l10n.translate('budgetPlanning'),
                                  l10n.translate('savingsManagement'),
                                  l10n.translate('debtManagement'),
                                ],
                                'required': true,
                              },
                              {
                                'label': l10n.notesAndAdditionalInfo,
                                'type': 'textarea',
                                'required': false,
                              },
                            ],
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ServiceCard(
                icon: Icons.credit_score,
                title: l10n.translate('creditSupport'),
                description: l10n.translate('creditSupportDesc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.translate(
                              'financialEducationCredit',
                            ),
                            categoria: l10n.translate('creditSupport'),
                            campi: [
                              {
                                'label': l10n.fullName,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.fiscalCode,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.phone,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.email,
                                'type': 'email',
                                'required': true,
                              },
                              {
                                'label': l10n.translate('howCanWeHelp'),
                                'type': 'select',
                                'options': [
                                  l10n.translate('creditScoreCheck'),
                                  l10n.translate('loanOrientation'),
                                  l10n.translate('microcreditInfo'),
                                ],
                                'required': true,
                              },
                              {
                                'label': l10n.notesAndAdditionalInfo,
                                'type': 'textarea',
                                'required': false,
                              },
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
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: scheme.onSurface.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: scheme.onPrimaryContainer, size: 32),
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
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: scheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
