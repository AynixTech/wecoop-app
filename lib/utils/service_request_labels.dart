import '../services/app_localizations.dart';

/// Traduce i codici `servizio` / `categoria` del backend (catalogo WeCoop)
/// usando le stringhe già presenti in tutti i locale dell'app.
class ServiceRequestLabels {
  ServiceRequestLabels._();

  static String servizio(AppLocalizations l10n, Object? raw) {
    return _label(l10n, raw);
  }

  static String categoria(AppLocalizations l10n, Object? raw) {
    return _label(l10n, raw);
  }

  static String _label(AppLocalizations l10n, Object? raw) {
    final code = _code(raw);
    if (code.isEmpty) return '';
    final key = _keys[code];
    if (key == null) return code;
    return l10n.translate(key);
  }

  static String _code(Object? raw) {
    if (raw == null) return '';
    if (raw is String) return raw.trim().toLowerCase();
    if (raw is Map) {
      final value =
          raw['code'] ??
          raw['servizio'] ??
          raw['categoria'] ??
          raw['slug'] ??
          raw['name'];
      return value?.toString().trim().toLowerCase() ?? '';
    }
    return raw.toString().trim().toLowerCase();
  }

  /// code snake_case → chiave in [AppLocalizations] (it/en/es/ar/zh).
  static const Map<String, String> _keys = {
    // Servizi
    'caf_tax_assistance': 'cafTaxAssistance',
    'immigration_desk': 'immigrationDesk',
    'residence_permit': 'residencePermit',
    'citizenship': 'citizenship',
    'family_reunification': 'familyReunification',
    'tax_mediation': 'taxMediation',
    'tax_guidance_clarifications': 'taxGuidanceAndClarifications',
    'accounting_support': 'accountingSupport',
    'work_orientation': 'workAndOrientation',
    'lavoro_orientamento': 'workAndOrientation',
    'financial_education_credit': 'financialEducationCredit',
    'linguistic_mediation': 'mediazioneLinguistica',
    'political_asylum': 'politicalAsylum',
    'study_italy_service': 'studiareItalia',
    'study_italy': 'forStudy',
    'welcome_orientation': 'welcomeOrientation',
    'lead_generico': 'serviceRequest',
    // Macro (a volte salvate come categoria)
    'vivere_in_italia': 'vivereItalia',
    'studiare_in_italia': 'studiareItalia',
    'servizi_fiscali': 'fiscalServices',
    'partita_iva_contabilita': 'accountingSupport',
    'accesso_al_lavoro': 'workAndOrientation',
    'educazione_finanziaria_credito': 'financialEducationCredit',
    // Categorie
    '730': 'taxReturn730',
    'tax_return_730': 'taxReturn730',
    'form_compilation': 'formCompilation',
    'residence_permit_employment': 'forEmployment',
    'residence_permit_self_employment': 'forSelfEmployment',
    'residence_permit_family': 'forFamilyReasons',
    'waiting_employment': 'waitingEmployment',
    'family_reunification_permit': 'familyReunificationPermit',
    'duplicate_permit': 'duplicatePermit',
    'long_term_permit_update': 'longTermPermitUpdate',
    'tourist_visa': 'touristVisa',
    'asylum_request': 'asylumRequest',
    'income_tax_return': 'incomeTaxReturn',
    'vat_number_opening': 'vatNumberOpening',
    'accounting_management': 'accountingManagement',
    'tax_compliance': 'taxCompliance',
    'tax_consultation': 'taxConsultation',
    'tax_debt_management': 'taxDebtManagement',
    'taxes_and_contributions': 'taxesAndContributions',
    'clarifications_consulting': 'clarificationsConsulting',
    'close_change_activity': 'closeChangeActivity',
    'spouse': 'spouse',
    'minor_children': 'minorChildren',
    'dependent_parents': 'dependentParents',
    'citizenship_residence': 'citizenshipResidence',
    'citizenship_marriage': 'citizenshipMarriage',
    'individual_person_model': 'individualPerson',
    'work_activation': 'activateWorkService',
    'work_guidance': 'workAndOrientation',
    'cv_creation': 'createCvService',
    'financial_basics': 'financialBasics',
    'credit_support': 'creditSupport',
    'small_business_financing': 'smallBusinessFinancing',
    'linguistic_accompaniment': 'mediazioneLinguisticaAccompagnamento',
    'document_translation': 'mediazioneLinguisticaTraduzioneDoc',
    'phone_support': 'mediazioneLinguisticaSupportoTel',
    'other': 'other',
    'international_protection': 'internationalProtection',
  };
}
