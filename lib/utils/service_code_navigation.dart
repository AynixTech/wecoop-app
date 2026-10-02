import 'package:flutter/material.dart';

import '../screens/servizi/accoglienza_screen.dart';
import '../screens/servizi/educazione_finanziaria_credito_screen.dart';
import '../screens/servizi/lavoro_orientamento_screen.dart';
import '../screens/servizi/mediazione_fiscale_screen.dart';
import '../screens/servizi/studiare_in_italia_screen.dart';
import '../screens/servizi/supporto_contabile_screen.dart';
import '../services/app_localizations.dart';
import 'member_service_navigation.dart';

/// Mapping codice/macro catalogo → schermata Flutter (allineato alla home).
class ServiceNavigationTarget {
  final Widget destination;
  final String serviceName;
  final bool requiresLogin;

  const ServiceNavigationTarget({
    required this.destination,
    required this.serviceName,
    this.requiresLogin = true,
  });
}

/// Risolve un target navigabile da `code` / `macro` del catalogo app.
ServiceNavigationTarget? resolveServiceNavigation({
  required AppLocalizations l10n,
  String? code,
  String? macro,
}) {
  final c = (code ?? '').trim().toLowerCase();
  final m = (macro ?? '').trim().toLowerCase();

  // Macro home tiles
  if (m == 'studiare_in_italia' || c == 'study_italy_service') {
    return ServiceNavigationTarget(
      destination: const StudiareInItaliaScreen(),
      serviceName: l10n.translate('studiareItalia'),
      requiresLogin: false,
    );
  }
  if (m == 'servizi_fiscali' ||
      c == 'tax_mediation' ||
      c == 'caf_tax_assistance' ||
      c == 'tax_guidance_clarifications') {
    return ServiceNavigationTarget(
      destination: const MediazioneFiscaleScreen(),
      serviceName: l10n.translate('fiscalServices'),
    );
  }
  if (m == 'partita_iva_contabilita' || c == 'accounting_support') {
    return ServiceNavigationTarget(
      destination: const SupportoContabileScreen(),
      serviceName: l10n.accountingSupport,
    );
  }
  if (m == 'accesso_al_lavoro' || c == 'work_orientation') {
    return ServiceNavigationTarget(
      destination: const LavoroOrientamentoScreen(),
      serviceName: l10n.translate('workAndOrientation'),
    );
  }
  if (m == 'educazione_finanziaria_credito' || c == 'financial_education_credit') {
    return ServiceNavigationTarget(
      destination: const EducazioneFinanziariaCreditoScreen(),
      serviceName: l10n.translate('financialEducationCredit'),
    );
  }
  if (m == 'vivere_in_italia' ||
      c == 'immigration_desk' ||
      c == 'welcome_orientation' ||
      c == 'residence_permit' ||
      c == 'citizenship' ||
      c == 'family_reunification' ||
      c == 'linguistic_mediation' ||
      c == 'political_asylum') {
    return ServiceNavigationTarget(
      destination: const AccoglienzaScreen(),
      serviceName: l10n.welcomeOrientation,
    );
  }

  return null;
}

/// Apre il servizio corrispondente al codice/macro catalogo.
Future<bool> openServiceByCatalog({
  required BuildContext context,
  String? code,
  String? macro,
  String? fallbackLabel,
}) async {
  if (!context.mounted) return false;
  final l10n = AppLocalizations.of(context)!;
  final target = resolveServiceNavigation(l10n: l10n, code: code, macro: macro);
  if (target == null) return false;
  if (!context.mounted) return false;

  if (!target.requiresLogin) {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => target.destination),
    );
    return true;
  }

  await openMemberService(
    context,
    destination: target.destination,
    serviceName: fallbackLabel?.trim().isNotEmpty == true
        ? fallbackLabel!.trim()
        : target.serviceName,
  );
  return true;
}
