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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      builder: (context) => RichiestaFormScreen(
                        servizio: l10n.taxMediation,
                        categoria: '730',
                        documentiRichiesti: const [
                          TipoDocumento.permessoSoggiorno,
                          TipoDocumento.passaporto,
                          TipoDocumento.codiceFiscale,
                          TipoDocumento.cartaIdentita,
                        ],
                        campi: [
                          {'label': l10n.fullName, 'type': 'text', 'required': true},
                          {'label': l10n.fiscalCode, 'type': 'text', 'required': true},
                          {'label': l10n.dateOfBirth, 'type': 'date', 'required': true},
                          {'label': l10n.address, 'type': 'text', 'required': true},
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
                          {'label': l10n.notesAndAdditionalInfo, 'type': 'textarea', 'required': false},
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
                      builder: (context) => RichiestaFormScreen(
                        servizio: l10n.taxMediation,
                        categoria: l10n.individualPerson,
                        documentiRichiesti: const [
                          TipoDocumento.permessoSoggiorno,
                          TipoDocumento.passaporto,
                          TipoDocumento.codiceFiscale,
                          TipoDocumento.cartaIdentita,
                        ],
                        campi: [
                          {'label': l10n.fullName, 'type': 'text', 'required': true},
                          {'label': l10n.fiscalCode, 'type': 'text', 'required': true},
                          {'label': l10n.dateOfBirth, 'type': 'date', 'required': true},
                          {'label': l10n.address, 'type': 'text', 'required': true},
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
                          {'label': l10n.notesAndAdditionalInfo, 'type': 'textarea', 'required': false},
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.amber.shade700, size: 28),
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
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
