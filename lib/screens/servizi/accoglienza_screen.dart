import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'permesso_soggiorno_screen.dart';
import 'cittadinanza_screen.dart';
import 'ricongiungimento_familiare_screen.dart';
import 'asilo_politico_screen.dart';
import 'visa_turismo_screen.dart';
import 'mediazione_linguistica_screen.dart';

class AccoglienzaScreen extends StatelessWidget {
  const AccoglienzaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.welcomeOrientation)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.selectServiceYouNeed,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.guideStepByStep,
                style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              _ServiceOptionCard(
                icon: Icons.translate,
                title: l10n.translate('mediazioneLinguistica'),
                description: l10n.translate('mediazioneLinguisticaSubtitle'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MediazioneLinguisticaScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ServiceOptionCard(
                icon: Icons.badge,
                title: l10n.residencePermit,
                description: l10n.residencePermitDesc,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PermessoSoggiornoScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ServiceOptionCard(
                icon: Icons.flag,
                title: l10n.citizenship,
                description: l10n.citizenshipDesc,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CittadinanzaScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ServiceOptionCard(
                icon: Icons.family_restroom,
                title: l10n.translate('familyReunification'),
                description: l10n.translate('familyReunificationDesc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const RicongiungimentoFamiliareScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ServiceOptionCard(
                icon: Icons.verified_user,
                title: l10n.politicalAsylum,
                description: l10n.politicalAsylumDesc,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AsiloPoliticoScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ServiceOptionCard(
                icon: Icons.flight,
                title: l10n.touristVisa,
                description: l10n.touristVisaDesc,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VisaTurismoScreen(),
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

class _ServiceOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ServiceOptionCard({
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
