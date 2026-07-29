import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import '../../theme/theme.dart';
import '../../widgets/design_system/design_system.dart';
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

    void go(Widget screen) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.welcomeOrientation)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.selectServiceYouNeed, style: AppTypography.headingS),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.guideStepByStep,
                style: AppTypography.bodyM.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SelectionCard(
                icon: Icons.translate,
                title: l10n.translate('mediazioneLinguistica'),
                subtitle: l10n.translate('mediazioneLinguisticaSubtitle'),
                onTap: () => go(const MediazioneLinguisticaScreen()),
              ),
              const SizedBox(height: AppSpacing.md),
              SelectionCard(
                icon: Icons.badge,
                title: l10n.residencePermit,
                subtitle: l10n.residencePermitDesc,
                onTap: () => go(const PermessoSoggiornoScreen()),
              ),
              const SizedBox(height: AppSpacing.md),
              SelectionCard(
                icon: Icons.flag,
                title: l10n.citizenship,
                subtitle: l10n.citizenshipDesc,
                onTap: () => go(const CittadinanzaScreen()),
              ),
              const SizedBox(height: AppSpacing.md),
              SelectionCard(
                icon: Icons.family_restroom,
                title: l10n.translate('familyReunification'),
                subtitle: l10n.translate('familyReunificationDesc'),
                onTap: () => go(const RicongiungimentoFamiliareScreen()),
              ),
              const SizedBox(height: AppSpacing.md),
              SelectionCard(
                icon: Icons.verified_user,
                title: l10n.politicalAsylum,
                subtitle: l10n.politicalAsylumDesc,
                onTap: () => go(const AsiloPoliticoScreen()),
              ),
              const SizedBox(height: AppSpacing.md),
              SelectionCard(
                icon: Icons.flight,
                title: l10n.touristVisa,
                subtitle: l10n.touristVisaDesc,
                onTap: () => go(const VisaTurismoScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
