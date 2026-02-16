import 'package:flutter/material.dart';
import '../../services/app_localizations.dart';
import 'richiesta_form_screen.dart';

class SupportoContabileScreen extends StatelessWidget {
  const SupportoContabileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountingSupport)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.vatManagementAccounting,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _OptionCard(
                icon: Icons.add_business,
                title: l10n.openVatNumber,
                description: l10n.openingNewVat,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.accountingSupport,
                            categoria: l10n.openVatNumber,
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
                                'label': l10n.businessType,
                                'type': 'select',
                                'options': [
                                  l10n.trade,
                                  l10n.servicesActivity,
                                  l10n.craftsmanship,
                                  l10n.freelance,
                                  l10n.other,
                                ],
                                'required': true,
                              },
                              {
                                'label': l10n.businessDescription,
                                'type': 'textarea',
                                'required': true,
                              },
                              {
                                'label': l10n.expectedTaxRegime,
                                'type': 'select',
                                'options': [
                                  l10n.flatRate,
                                  l10n.simplified,
                                  l10n.ordinary,
                                  l10n.dontKnow,
                                ],
                                'required': true,
                              },
                              {
                                'label': l10n.expectedAnnualRevenue,
                                'type': 'number',
                                'required': false,
                              },
                            ],
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _OptionCard(
                icon: Icons.settings,
                title: l10n.manageVatNumber,
                description: l10n.ordinaryAccountingInvoicing,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.accountingSupport,
                            categoria: l10n.manageVatNumber,
                            campi: [
                              {
                                'label': l10n.companyName,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.vatNumber,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.supportTypeRequired,
                                'type': 'select',
                                'options': [
                                  l10n.electronicInvoicing,
                                  l10n.invoiceRegistration,
                                  l10n.journalManagement,
                                  l10n.annualBalance,
                                  l10n.generalConsulting,
                                ],
                                'required': true,
                              },
                              {
                                'label': l10n.currentTaxRegime,
                                'type': 'select',
                                'options': [
                                  l10n.flatRate,
                                  l10n.simplified,
                                  l10n.ordinary,
                                ],
                                'required': true,
                              },
                              {
                                'label': l10n.describeYourNeed,
                                'type': 'textarea',
                                'required': true,
                              },
                            ],
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _OptionCard(
                icon: Icons.close_fullscreen,
                title: l10n.closeChangeActivity,
                description: l10n.businessTerminationModification,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.accountingSupport,
                            categoria: l10n.closeChangeActivity,
                            campi: [
                              {
                                'label': l10n.companyName,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.vatNumber,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.whatDoYouWantToDo,
                                'type': 'select',
                                'options': [
                                  l10n.closeVatNumber,
                                  l10n.changeActivity,
                                  l10n.changeTaxRegime,
                                ],
                                'required': true,
                              },
                              {
                                'label': l10n.expectedDate,
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': l10n.reason,
                                'type': 'textarea',
                                'required': true,
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

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _OptionCard({
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
