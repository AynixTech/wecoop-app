import 'package:flutter/material.dart';
import '../../services/app_localizations.dart';
import '../../models/documento.dart';
import 'richiesta_form_screen.dart';

class MediazioneFiscaleScreen extends StatelessWidget {
  const MediazioneFiscaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.taxMediation)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.selectFiscalService,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _ServiceCard(
                icon: Icons.description,
                title: l10n.tax730Declaration,
                description: l10n.tax730Description,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.taxMediation,
                            categoria: '730',
                            documentiRichiesti: const [
                              TipoDocumento.permessoSoggiorno,
                              TipoDocumento.passaporto,
                              TipoDocumento.codiceFiscale,
                              TipoDocumento.cartaIdentita,
                            ],
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
                                'label': l10n.dateOfBirth,
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': l10n.address,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.workType,
                                'type': 'select',
                                'options': [
                                  l10n.employee,
                                  l10n.housekeeper,
                                  l10n.caregiver,
                                  l10n.babysitter,
                                ],
                                'required': true,
                              },
                              {
                                'label': l10n.multipleContracts,
                                'type': 'select',
                                'options': [l10n.yes, l10n.no],
                                'required': true,
                              },
                              {
                                'label': l10n.homeMortgage,
                                'type': 'select',
                                'options': [l10n.yes, l10n.no],
                                'required': true,
                              },
                              {
                                'label': l10n.pensionIncome,
                                'type': 'select',
                                'options': [l10n.yes, l10n.no],
                                'required': true,
                              },
                              {
                                'label': l10n.fiscalYear,
                                'type': 'select',
                                'options': ['2024', '2023', '2022'],
                                'required': true,
                              },
                              {
                                'label': l10n.notesAndAdditionalInfo,
                                'type': 'textarea',
                                'required': false,
                              },
                            ],
                            modalitaConsegna: const [
                              'courier',
                              'pickup',
                              'email',
                            ],
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ServiceCard(
                icon: Icons.person,
                title: l10n.individualPerson,
                description: l10n.individualPersonDescription,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.taxMediation,
                            categoria: l10n.individualPerson,
                            documentiRichiesti: const [
                              TipoDocumento.permessoSoggiorno,
                              TipoDocumento.passaporto,
                              TipoDocumento.codiceFiscale,
                              TipoDocumento.cartaIdentita,
                            ],
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
                                'label': l10n.dateOfBirth,
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': l10n.address,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.workType,
                                'type': 'select',
                                'options': [
                                  l10n.selfEmployedForfettario,
                                  l10n.housekeeper,
                                  l10n.caregiver,
                                  l10n.babysitter,
                                ],
                                'required': true,
                              },
                              {
                                'label': l10n.missedTax730Deadline,
                                'type': 'select',
                                'options': [l10n.yes, l10n.no],
                                'required': true,
                              },
                              {
                                'label': l10n.multipleContracts,
                                'type': 'select',
                                'options': [l10n.yes, l10n.no],
                                'required': true,
                              },
                              {
                                'label': l10n.homeMortgage,
                                'type': 'select',
                                'options': [l10n.yes, l10n.no],
                                'required': true,
                              },
                              {
                                'label': l10n.fiscalYear,
                                'type': 'select',
                                'options': ['2024', '2023', '2022'],
                                'required': true,
                              },
                              {
                                'label': l10n.notesAndAdditionalInfo,
                                'type': 'textarea',
                                'required': false,
                              },
                            ],
                            modalitaConsegna: const [
                              'courier',
                              'pickup',
                              'email',
                            ],
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                l10n.translate('taxGuidanceAndClarifications'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _ServiceCard(
                icon: Icons.account_balance,
                title: l10n.translate('taxesAndContributions'),
                description: l10n.translate('taxesAndContributionsDesc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.taxMediation,
                            categoria: l10n.translate('taxesAndContributions'),
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
                                'label': l10n.dateOfBirth,
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': l10n.residenceAddress,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.clarifyTopic,
                                'type': 'select',
                                'options': [
                                  l10n.taxCalculation,
                                  l10n.depositsBalances,
                                  l10n.inpsContributionsTax,
                                  l10n.f24Payments,
                                ],
                                'required': true,
                              },
                              {
                                'label': l10n.workSituation,
                                'type': 'select',
                                'options': [
                                  l10n.employeeWorker,
                                  l10n.vatForfettario,
                                  l10n.otherActivity,
                                ],
                                'required': true,
                              },
                              {
                                'label': l10n.urgencyLevel,
                                'type': 'select',
                                'options': [
                                  l10n.informative,
                                  l10n.imminentDeadline,
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
                icon: Icons.question_answer,
                title: l10n.translate('clarificationsAndConsulting'),
                description: l10n.translate('clarificationsAndConsultingDesc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.taxMediation,
                            categoria: l10n.translate(
                              'clarificationsAndConsulting',
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
                                'label': l10n.dateOfBirth,
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': l10n.residenceAddress,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.howCanWeHelp,
                                'type': 'select',
                                'options': [
                                  l10n.personalizedExplanations,
                                  l10n.taxPositionVerification,
                                  l10n.taxRegimeChange,
                                  l10n.questionsNotSureWhereToStart,
                                ],
                                'required': true,
                              },
                              {
                                'label': l10n.workSituationQuestion,
                                'type': 'select',
                                'options': [
                                  l10n.employeeWorker,
                                  l10n.vatForfettario,
                                  l10n.notWorkingOther,
                                ],
                                'required': true,
                              },
                              {
                                'label': l10n.urgencyQuestion,
                                'type': 'select',
                                'options': [
                                  l10n.informative,
                                  l10n.closeDeadline,
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: scheme.onSurface.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: scheme.onPrimaryContainer, size: 28),
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
