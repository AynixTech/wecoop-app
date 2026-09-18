import '../services/app_localizations.dart';
import 'operativo_service_labels.dart';

/// Traduce i codici `servizio` / `categoria` del backend (catalogo WeCoop)
/// usando le stringhe già presenti in tutti i locale dell'app + catalogo operativo.
class ServiceRequestLabels {
  ServiceRequestLabels._();

  static String servizio(AppLocalizations l10n, Object? raw) {
    return _label(l10n, raw);
  }

  static String categoria(AppLocalizations l10n, Object? raw) {
    return _label(l10n, raw);
  }

  /// Preferisce `servizio_label` / `categoria_label` dal payload API se presenti.
  static String servizioFromRecord(AppLocalizations l10n, Map? record) {
    final override = _overrideLabel(record, const [
      'servizio_label',
      'service_label',
    ]);
    if (override != null) return override;
    return servizio(l10n, record?['servizio'] ?? record?['service']);
  }

  static String categoriaFromRecord(AppLocalizations l10n, Map? record) {
    final override = _overrideLabel(record, const [
      'categoria_label',
      'category_label',
    ]);
    if (override != null) return override;
    return categoria(l10n, record?['categoria'] ?? record?['category']);
  }

  static String? _overrideLabel(Map? record, List<String> keys) {
    if (record == null) return null;
    for (final k in keys) {
      final v = record[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    final dati = record['dati'];
    if (dati is Map) {
      for (final k in keys) {
        final v = dati[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }
    return null;
  }

  static String _label(AppLocalizations l10n, Object? raw) {
    final code = _code(raw);
    if (code.isEmpty) return '';

    // Catalogo CAF operativo (label IT ufficiali).
    final op = kOperativoServiceLabels[code] ?? kOperativoCategoryLabels[code];
    if (op != null) {
      return _titleCaseIt(op.replaceAll('\\n', ' ').replaceAll('\n', ' '));
    }

    final key = _keys[code];
    if (key != null) {
      final translated = l10n.translate(key);
      // translate() a volte restituisce la chiave se manca: evita di mostrarla.
      if (translated.isNotEmpty && translated != key) return translated;
    }

    return _prettifyCode(code);
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

  /// `op_immigrazione__richiesta_rinnovo_...` → "Richiesta rinnovo ..."
  /// Fallback generico: snake_case → titolo leggibile.
  static String _prettifyCode(String code) {
    var s = code.trim();
    if (s.startsWith('op_') && s.contains('__')) {
      s = s.split('__').skip(1).join('__');
    } else if (s.startsWith('op_')) {
      // Variante senza doppio underscore: op_<categoria>_<slug...>
      final parts = s.substring(3).split('_');
      // tenta di togliere la prima "categoria" nota
      if (parts.length > 1) {
        final knownCats = kOperativoCategoryLabels.keys.toList()
          ..sort((a, b) => b.length.compareTo(a.length));
        final joined = parts.join('_');
        for (final cat in knownCats) {
          if (joined == cat) return _titleCaseIt(kOperativoCategoryLabels[cat]!);
          if (joined.startsWith('${cat}_')) {
            s = joined.substring(cat.length + 1);
            break;
          }
        }
      }
    }
    return _titleCaseIt(s.replaceAll(RegExp(r'[_-]+'), ' ').trim());
  }

  static String _titleCaseIt(String input) {
    final s = input.trim();
    if (s.isEmpty) return s;
    // Se è già tutto maiuscolo (catalogo operativo), lascia leggibile in Title Case.
    final words = s.toLowerCase().split(RegExp(r'\s+'));
    return words
        .map((w) {
          if (w.isEmpty) return w;
          // Acronimi comuni
          const upper = {
            'imu',
            'iva',
            'inps',
            'cu',
            'caf',
            'naspi',
            'isee',
            'red',
            'auu',
            'p.iva',
            'piva',
          };
          if (upper.contains(w.replaceAll('.', ''))) return w.toUpperCase();
          return '${w[0].toUpperCase()}${w.substring(1)}';
        })
        .join(' ');
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
