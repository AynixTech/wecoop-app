import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'richiesta_form_screen.dart';

class RicongiungimentoFamiliareScreen extends StatelessWidget {
  const RicongiungimentoFamiliareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('familyReunification'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.translate('selectFamilyMember'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.translate('familyReunificationDesc'),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              _FamilyMemberCard(
                icon: Icons.favorite,
                title: l10n.translate('spouse'),
                description: l10n.translate('spouseDesc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RichiestaFormScreen(
                        servizio: l10n.translate('familyReunification'),
                        categoria: l10n.translate('spouse'),
                        campi: [
                          {'label': l10n.fullName, 'type': 'text', 'required': true},
                          {'label': l10n.email, 'type': 'text', 'required': true},
                          {'label': l10n.phone, 'type': 'text', 'required': true},
                          {'label': l10n.dateOfBirth, 'type': 'date', 'required': true},
                          {'label': l10n.translate('countryOfOrigin'), 'type': 'text', 'required': true},
                          {'label': l10n.translate('spouseFullName'), 'type': 'text', 'required': true},
                          {'label': l10n.translate('spouseDateOfBirth'), 'type': 'date', 'required': true},
                          {'label': l10n.translate('marriageDate'), 'type': 'date', 'required': true},
                          {'label': l10n.translate('marriageCountry'), 'type': 'text', 'required': true},
                          {
                            'label': l10n.translate('currentResidence'),
                            'type': 'text',
                            'required': true,
                          },
                          {
                            'label': l10n.translate('incomeProof'),
                            'type': 'select',
                            'options': [l10n.yes, l10n.no],
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
              _FamilyMemberCard(
                icon: Icons.child_care,
                title: l10n.translate('minorChildren'),
                description: l10n.translate('minorChildrenDesc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RichiestaFormScreen(
                        servizio: l10n.translate('familyReunification'),
                        categoria: l10n.translate('minorChildren'),
                        campi: [
                          {'label': l10n.fullName, 'type': 'text', 'required': true},
                          {'label': l10n.email, 'type': 'text', 'required': true},
                          {'label': l10n.phone, 'type': 'text', 'required': true},
                          {'label': l10n.translate('childFullName'), 'type': 'text', 'required': true},
                          {'label': l10n.translate('childDateOfBirth'), 'type': 'date', 'required': true},
                          {'label': l10n.translate('countryOfOrigin'), 'type': 'text', 'required': true},
                          {
                            'label': l10n.translate('relationshipType'),
                            'type': 'select',
                            'options': [
                              l10n.translate('biologicalChild'),
                              l10n.translate('adoptedChild'),
                            ],
                            'required': true,
                          },
                          {
                            'label': l10n.translate('currentResidence'),
                            'type': 'text',
                            'required': true,
                          },
                          {
                            'label': l10n.translate('incomeProof'),
                            'type': 'select',
                            'options': [l10n.yes, l10n.no],
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
              _FamilyMemberCard(
                icon: Icons.elderly,
                title: l10n.translate('dependentParents'),
                description: l10n.translate('dependentParentsDesc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RichiestaFormScreen(
                        servizio: l10n.translate('familyReunification'),
                        categoria: l10n.translate('dependentParents'),
                        campi: [
                          {'label': l10n.fullName, 'type': 'text', 'required': true},
                          {'label': l10n.email, 'type': 'text', 'required': true},
                          {'label': l10n.phone, 'type': 'text', 'required': true},
                          {'label': l10n.translate('parentFullName'), 'type': 'text', 'required': true},
                          {'label': l10n.translate('parentDateOfBirth'), 'type': 'date', 'required': true},
                          {'label': l10n.translate('countryOfOrigin'), 'type': 'text', 'required': true},
                          {
                            'label': l10n.translate('parentRelationship'),
                            'type': 'select',
                            'options': [l10n.translate('father'), l10n.translate('mother')],
                            'required': true,
                          },
                          {
                            'label': l10n.translate('currentResidence'),
                            'type': 'text',
                            'required': true,
                          },
                          {
                            'label': l10n.translate('dependencyProof'),
                            'type': 'select',
                            'options': [l10n.yes, l10n.no],
                            'required': true,
                          },
                          {
                            'label': l10n.translate('incomeProof'),
                            'type': 'select',
                            'options': [l10n.yes, l10n.no],
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

class _FamilyMemberCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FamilyMemberCard({
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
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.blue.shade700, size: 32),
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
