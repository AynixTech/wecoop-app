import 'package:flutter/material.dart';
import '../../services/app_localizations.dart';
import '../../models/documento.dart';
import 'richiesta_form_screen.dart';

class PermessoSoggiornoScreen extends StatelessWidget {
  const PermessoSoggiornoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.residencePermit)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.selectType,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _OptionCard(
                title: l10n.forEmployment,
                description: l10n.forEmploymentDesc,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.residencePermit,
                            categoria: l10n.forEmployment,
                            campi: [
                              {
                                'label': l10n.fullName,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.dateOfBirth,
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': l10n.countryOfOrigin,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.contractType,
                                'type': 'select',
                                'options': [l10n.fixedTerm, l10n.permanentContract],
                                'required': true,
                              },
                              {
                                'label': l10n.companyName,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.contractDuration,
                                'type': 'number',
                                'required': true,
                              },
                              {
                                'label': l10n.additionalNotes,
                                'type': 'textarea',
                                'required': false,
                              },
                            ],
                            documentiRichiesti: const [
                              TipoDocumento.permessoSoggiorno,
                              TipoDocumento.passaporto,
                              TipoDocumento.codiceFiscale,
                              TipoDocumento.cartaIdentita,
                            ],
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _OptionCard(
                title: l10n.forSelfEmployment,
                description: l10n.forSelfEmploymentDesc,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.residencePermit,
                            categoria: l10n.forSelfEmployment,
                            campi: [
                              {
                                'label': l10n.fullName,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.dateOfBirth,
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': l10n.countryOfOrigin,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.activityType,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.haveVatNumber,
                                'type': 'select',
                                'options': [l10n.yes, l10n.no],
                                'required': true,
                              },
                              {
                                'label': l10n.activityDescription,
                                'type': 'textarea',
                                'required': true,
                              },
                            ],
                            documentiRichiesti: const [
                              TipoDocumento.permessoSoggiorno,
                              TipoDocumento.passaporto,
                              TipoDocumento.codiceFiscale,
                              TipoDocumento.cartaIdentita,
                            ],
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _OptionCard(
                title: l10n.forFamilyReasons,
                description: l10n.forFamilyReasonsDesc,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.residencePermit,
                            categoria: l10n.forFamilyReasons,
                            campi: [
                              {
                                'label': l10n.fullName,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.dateOfBirth,
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': l10n.countryOfOrigin,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.relationshipWithFamily,
                                'type': 'select',
                                'options': [
                                  l10n.spouse,
                                  l10n.son,
                                  l10n.parent,
                                  l10n.other,
                                ],
                                'required': true,
                              },
                              {
                                'label': l10n.familyNameInItaly,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.familyIdDocument,
                                'type': 'text',
                                'required': true,
                              },
                            ],
                            documentiRichiesti: const [
                              TipoDocumento.permessoSoggiorno,
                              TipoDocumento.passaporto,
                              TipoDocumento.codiceFiscale,
                              TipoDocumento.cartaIdentita,
                            ],
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _OptionCard(
                title: l10n.forStudy,
                description: l10n.forStudyDesc,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.residencePermit,
                            categoria: l10n.forStudy,
                            campi: [
                              {
                                'label': l10n.fullName,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.dateOfBirth,
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': l10n.countryOfOrigin,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.institutionName,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.courseType,
                                'type': 'select',
                                'options': [
                                  l10n.bachelorDegree,
                                  l10n.masterDegree,
                                  l10n.master,
                                  l10n.doctorate,
                                  l10n.other,
                                ],
                                'required': true,
                              },
                              {
                                'label': l10n.enrollmentYear,
                                'type': 'text',
                                'required': true,
                              },
                            ],
                            documentiRichiesti: const [
                              TipoDocumento.permessoSoggiorno,
                              TipoDocumento.passaporto,
                              TipoDocumento.codiceFiscale,
                              TipoDocumento.cartaIdentita,
                            ],
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _OptionCard(
                title: l10n.translate('waitingEmployment'),
                description: l10n.translate('waitingEmploymentDesc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.residencePermit,
                            categoria: l10n.translate('waitingEmployment'),
                            campi: [
                              {
                                'label': l10n.fullName,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.email,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.phone,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.dateOfBirth,
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': l10n.countryOfOrigin,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.translate('currentPermitType'),
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.translate('permitExpiryDate'),
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': l10n.additionalNotes,
                                'type': 'textarea',
                                'required': false,
                              },
                            ],
                            documentiRichiesti: const [
                              TipoDocumento.permessoSoggiorno,
                              TipoDocumento.passaporto,
                              TipoDocumento.codiceFiscale,
                              TipoDocumento.cartaIdentita,
                            ],
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _OptionCard(
                title: l10n.translate('familyReunificationPermit'),
                description: l10n.translate('familyReunificationPermitDesc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.residencePermit,
                            categoria: l10n.translate('familyReunificationPermit'),
                            campi: [
                              {
                                'label': l10n.fullName,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.email,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.phone,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.dateOfBirth,
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': l10n.countryOfOrigin,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.relationshipWithFamily,
                                'type': 'select',
                                'options': [l10n.spouse, l10n.son, l10n.parent, l10n.other],
                                'required': true,
                              },
                              {
                                'label': l10n.familyNameInItaly,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.additionalNotes,
                                'type': 'textarea',
                                'required': false,
                              },
                            ],
                            documentiRichiesti: const [
                              TipoDocumento.permessoSoggiorno,
                              TipoDocumento.passaporto,
                              TipoDocumento.codiceFiscale,
                              TipoDocumento.cartaIdentita,
                            ],
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _OptionCard(
                title: l10n.translate('duplicatePermit'),
                description: l10n.translate('duplicatePermitDesc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.residencePermit,
                            categoria: l10n.translate('duplicatePermit'),
                            campi: [
                              {
                                'label': l10n.fullName,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.email,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.phone,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.dateOfBirth,
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': l10n.countryOfOrigin,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.translate('currentPermitNumber'),
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.translate('reasonDuplicate'),
                                'type': 'select',
                                'options': [
                                  l10n.translate('lost'),
                                  l10n.translate('stolen'),
                                  l10n.translate('damaged'),
                                ],
                                'required': true,
                              },
                              {
                                'label': l10n.additionalNotes,
                                'type': 'textarea',
                                'required': false,
                              },
                            ],
                            documentiRichiesti: const [
                              TipoDocumento.permessoSoggiorno,
                              TipoDocumento.passaporto,
                              TipoDocumento.codiceFiscale,
                              TipoDocumento.cartaIdentita,
                            ],
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _OptionCard(
                title: l10n.translate('longTermPermitUpdate'),
                description: l10n.translate('longTermPermitUpdateDesc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RichiestaFormScreen(
                            servizio: l10n.residencePermit,
                            categoria: l10n.translate('longTermPermitUpdate'),
                            campi: [
                              {
                                'label': l10n.fullName,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.email,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.phone,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.dateOfBirth,
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': l10n.countryOfOrigin,
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.translate('currentPermitNumber'),
                                'type': 'text',
                                'required': true,
                              },
                              {
                                'label': l10n.translate('permitIssueDate'),
                                'type': 'date',
                                'required': true,
                              },
                              {
                                'label': l10n.translate('updateReason'),
                                'type': 'textarea',
                                'required': true,
                              },
                              {
                                'label': l10n.additionalNotes,
                                'type': 'textarea',
                                'required': false,
                              },
                            ],
                            documentiRichiesti: const [
                              TipoDocumento.permessoSoggiorno,
                              TipoDocumento.passaporto,
                              TipoDocumento.codiceFiscale,
                              TipoDocumento.cartaIdentita,
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
  final String title;
  final String description;
  final VoidCallback onTap;

  const _OptionCard({
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
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Row(
          children: [
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
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.amber.shade700,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
