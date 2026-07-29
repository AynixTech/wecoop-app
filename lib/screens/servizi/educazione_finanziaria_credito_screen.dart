import 'package:flutter/material.dart';
import '../../widgets/design_system/design_system.dart';
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
              const SizedBox(height: 12),
              _ServiceCard(
                icon: Icons.storefront,
                title: l10n.translate('smallBusinessFinancing'),
                description: l10n.translate('smallBusinessFinancingDesc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.translate(
                              'financialEducationCredit',
                            ),
                            categoria: l10n.translate(
                              'smallBusinessFinancing',
                            ),
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
                                  l10n.translate('startupFinancing'),
                                  l10n.translate('workingCapital'),
                                  l10n.translate('equipmentInvestment'),
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
    return SelectionCard(
      icon: icon,
      title: title,
      subtitle: description,
      onTap: onTap,
    );
  }
}
