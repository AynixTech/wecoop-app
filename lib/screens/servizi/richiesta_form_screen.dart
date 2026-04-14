import 'package:flutter/material.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/widgets/help_button_widget.dart';
import '../../services/socio_service.dart';
import '../../services/documento_service.dart';
import '../../models/documento.dart';
import '../main_screen.dart';
import '../profilo/documenti_screen.dart';
import 'pagamento_screen.dart';

/// Mappa dei codici ISO paese -> nome completo
const Map<String, String> countryNames = {
  'IT': 'Italia',
  'EC': 'Ecuador',
  'ES': 'España',
  'CO': 'Colombia',
  'PE': 'Perú',
  'VE': 'Venezuela',
  'AR': 'Argentina',
  'BR': 'Brasil',
  'CL': 'Chile',
  'MX': 'México',
  'US': 'United States',
  'GB': 'United Kingdom',
  'FR': 'France',
  'DE': 'Germany',
  'RO': 'Romania',
  'PL': 'Polonia',
  'UA': 'Ucraina',
  'MA': 'Marocco',
  'EG': 'Egitto',
  'NG': 'Nigeria',
  'GH': 'Ghana',
  'SN': 'Senegal',
  'CN': 'China',
  'IN': 'India',
  'PH': 'Filippine',
  'BD': 'Bangladesh',
  'PK': 'Pakistan',
};

/// Convierte código ISO a nombre completo del país
String getCountryName(String? isoCode) {
  if (isoCode == null || isoCode.isEmpty) return '';
  return countryNames[isoCode.toUpperCase()] ?? isoCode;
}

/// Mappa servizi multilingua -> chiave standardizzata (inglese)
const Map<String, String> servizioStandardMap = {
  // CAF - Assistenza Fiscale
  'CAF - Assistenza Fiscale': 'caf_tax_assistance',
  'CAF - Tax Assistance': 'caf_tax_assistance',
  'CAF - Asistencia Fiscal': 'caf_tax_assistance',

  // Sportello Immigrazione
  'Sportello Immigrazione': 'immigration_desk',
  'Immigration Desk': 'immigration_desk',
  'Oficina de Inmigración': 'immigration_desk',

  // Supporto contabile per P.IVA forfettaria
  'Supporto contabile per P.IVA forfettaria': 'accounting_support',
  'Accounting Support': 'accounting_support',
  'Soporte Contable': 'accounting_support',

  // Mediazione Fiscale
  'Mediazione Fiscale': 'tax_mediation',
  'Tax Mediation': 'tax_mediation',
  'Mediación Fiscal': 'tax_mediation',

  // Orientamento e chiarimenti fiscali
  'Orientamento e chiarimenti fiscali': 'tax_guidance_clarifications',
  'Tax Guidance and Clarifications': 'tax_guidance_clarifications',
  'Orientación y aclaraciones fiscales': 'tax_guidance_clarifications',
  'Orientación y Aclaraciones Fiscales': 'tax_guidance_clarifications',

  // Ricongiungimento familiare
  'Ricongiungimento familiare': 'family_reunification',
  'Family Reunification': 'family_reunification',
  'Reagrupación Familiar': 'family_reunification',
};

/// Mappa categorie multilingua -> chiave standardizzata (inglese)
const Map<String, String> categoriaStandardMap = {
  // CAF - Dichiarazione dei Redditi
  'Dichiarazione dei Redditi (730)': 'tax_return_730',
  'Tax Return (730)': 'tax_return_730',
  'Declaración de la Renta (730)': 'tax_return_730',

  // CAF - Compilazione Modelli
  'Compilazione Modelli': 'form_compilation',
  'Form Compilation': 'form_compilation',
  'Compilación de Formularios': 'form_compilation',

  // Sportello - Permesso di Soggiorno
  'Permesso di Soggiorno': 'residence_permit',
  'Residence Permit': 'residence_permit',
  'Permiso de Residencia': 'residence_permit',

  // Permesso - Per studiare in Italia
  'Per Studiare in Italia': 'study_italy',
  'For Studying in Italy': 'study_italy',
  'Para Estudiar en Italia': 'study_italy',

  // Permesso - Per attesa occupazione
  'Per attesa occupazione': 'waiting_employment',
  'Waiting Employment': 'waiting_employment',
  'Waiting for employment': 'waiting_employment',
  'En espera de empleo': 'waiting_employment',

  // Permesso - Ricongiungimento
  'Ricongiungimento': 'family_reunification_permit',
  'Family Reunification Permit': 'family_reunification_permit',
  'Family reunification permit': 'family_reunification_permit',
  'Reagrupación familiar': 'family_reunification_permit',

  // Permesso - Duplicato permesso di soggiorno
  'Duplicato permesso di soggiorno': 'duplicate_permit',
  'Duplicate Residence Permit': 'duplicate_permit',
  'Duplicate residence permit': 'duplicate_permit',
  'Duplicado permiso de residencia': 'duplicate_permit',

  // Permesso - Aggiornamento permesso lungo periodo
  'Aggiornamento permesso lungo periodo': 'long_term_permit_update',
  'Long-term Permit Update': 'long_term_permit_update',
  'Long-term permit update': 'long_term_permit_update',
  'Actualización permiso largo período': 'long_term_permit_update',
  'Actualización permiso larga duración': 'long_term_permit_update',

  // Sportello - Cittadinanza
  'Cittadinanza': 'citizenship',
  'Citizenship': 'citizenship',
  'Ciudadanía': 'citizenship',

  // Sportello - Visto Turistico
  'Visto Turistico': 'tourist_visa',
  'Tourist Visa': 'tourist_visa',
  'Visa Turística': 'tourist_visa',

  // Sportello - Richiesta Asilo
  'Richiesta Asilo': 'asylum_request',
  'Asylum Request': 'asylum_request',
  'Solicitud de Asilo': 'asylum_request',

  // Contabilità - Dichiarazione Redditi
  'Dichiarazione Redditi': 'income_tax_return',
  'Income Tax Return': 'income_tax_return',
  'Declaración de Renta': 'income_tax_return',

  // Contabilità - Apertura Partita IVA
  'Apertura Partita IVA': 'vat_number_opening',
  'Apertura Partita IVA – Regime forfettario': 'vat_number_opening',
  'VAT Number Opening': 'vat_number_opening',
  'Apertura de Partita IVA': 'vat_number_opening',

  // Contabilità - Gestione Contabilità
  'Gestione Contabilità': 'accounting_management',
  'Gestione contabile – Partita IVA forfettaria': 'accounting_management',
  'Accounting Management': 'accounting_management',
  'Gestión de Contabilidad': 'accounting_management',

  // Contabilità - Adempimenti Fiscali
  'Adempimenti Fiscali': 'tax_compliance',
  'Tax Compliance': 'tax_compliance',
  'Cumplimientos Fiscales': 'tax_compliance',

  // Contabilità - Consulenza Fiscale
  'Consulenza Fiscale': 'tax_consultation',
  'Tax Consultation': 'tax_consultation',
  'Consultoría Fiscal': 'tax_consultation',

  // Contabilità - Chiusura/Variazione Attività
  'Chiudere o cambiare attività': 'close_change_activity',

  // Mediazione Fiscale - Gestione Debiti
  'Gestione Debiti Fiscali': 'tax_debt_management',
  'Tax Debt Management': 'tax_debt_management',
  'Gestión de Deudas Fiscales': 'tax_debt_management',

  // Orientamento fiscale - Tasse e Contributi
  'Tasse e Contributi': 'taxes_and_contributions',
  'Taxes and Contributions': 'taxes_and_contributions',
  'Impuestos y Contribuciones': 'taxes_and_contributions',

  // Orientamento fiscale - Chiarimenti e Consulenza
  'Chiarimenti e Consulenza': 'clarifications_consulting',
  'Clarifications and Consulting': 'clarifications_consulting',
  'Aclaraciones y Consultoría': 'clarifications_consulting',

  // Ricongiungimento familiare - Categorie
  'Coniuge': 'spouse',
  'Spouse': 'spouse',
  'Cónyuge': 'spouse',

  'Figli minori': 'minor_children',
  'Minor Children': 'minor_children',
  'Minor children': 'minor_children',
  'Hijos menores': 'minor_children',

  'Genitori a carico': 'dependent_parents',
  'Dependent Parents': 'dependent_parents',
  'Dependent parents': 'dependent_parents',
  'Padres dependientes': 'dependent_parents',
  'Padres a cargo': 'dependent_parents',
};

/// Converte servizio tradotto in chiave standard
String _getStandardServizio(String servizio) {
  return servizioStandardMap[servizio] ?? servizio;
}

/// Converte categoria tradotta in chiave standard
String _getStandardCategoria(String categoria) {
  return categoriaStandardMap[categoria] ?? categoria;
}

class RichiestaFormScreen extends StatefulWidget {
  final String servizio;
  final String categoria;
  final List<Map<String, dynamic>> campi;
  final List<String>? documentiRichiesti;
  final List<String>? modalitaConsegna;

  const RichiestaFormScreen({
    super.key,
    required this.servizio,
    required this.categoria,
    required this.campi,
    this.documentiRichiesti,
    this.modalitaConsegna,
  });

  @override
  State<RichiestaFormScreen> createState() => _RichiestaFormScreenState();
}

class _RichiestaFormScreenState extends State<RichiestaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};
  final _storage = SecureStorageService();
  final _documentoService = DocumentoService();
  bool _isSubmitting = false;
  bool _isLoading = true;
  List<String> _documentiMancanti = [];
  List<String> _documentiMancantiFamiliare = [];
  final Set<String> _modalitaConsegnaSelezionate = {};

  // Controller per campi modalità di consegna
  final _consegnaIndirizzoController = TextEditingController();
  final _consegnaCittaController = TextEditingController();
  final _consegnaCapController = TextEditingController();
  final _consegnaProvinciaController = TextEditingController();
  final _consegnaEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkDocumenti();
  }

  // Controlla quali documenti mancano
  Future<void> _checkDocumenti() async {
    if (widget.documentiRichiesti == null ||
        widget.documentiRichiesti!.isEmpty) {
      return;
    }

    await _documentoService.getDocumenti(); // Carica documenti
    final mancanti = _documentoService.getDocumentiMancanti(
      widget.documentiRichiesti!,
    );
    final mancantiFamiliare =
        _isMotiviFamiliariFlow()
            ? _documentoService.getDocumentiMancanti(
              widget.documentiRichiesti!,
              soggetto: DocumentoSoggetto.familiare,
            )
            : <String>[];
    setState(() {
      _documentiMancanti = mancanti;
      _documentiMancantiFamiliare = mancantiFamiliare;
    });
  }

  @override
  void dispose() {
    // Libera i controller
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _consegnaIndirizzoController.dispose();
    _consegnaCittaController.dispose();
    _consegnaCapController.dispose();
    _consegnaProvinciaController.dispose();
    _consegnaEmailController.dispose();
    super.dispose();
  }

  String _normalizeFieldLabel(String input) {
    return input
        .toLowerCase()
        .trim()
        .replaceAll('à', 'a')
        .replaceAll('á', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('è', 'e')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('ì', 'i')
        .replaceAll('í', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ò', 'o')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('ú', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _isFullNameFieldLabel(String label) {
    final normalized = _normalizeFieldLabel(label);
    final hasNome = normalized.contains('nome');
    final hasCognome = normalized.contains('cognome');
    final hasCompleto = normalized.contains('completo');
    final hasNominativo = normalized.contains('nominativo');
    final hasFullName = normalized.contains('full name');
    final hasNombreCompleto = normalized.contains('nombre completo');

    return (hasNome && hasCognome) ||
        (hasNome && hasCompleto) ||
        hasNominativo ||
        hasFullName ||
        hasNombreCompleto;
  }

  bool _matchesCurrentFlow(List<String> patterns) {
    final normalizedCategoria = _normalizeFieldLabel(widget.categoria);
    final normalizedServizio = _normalizeFieldLabel(widget.servizio);
    final normalizedCategoriaStandard = _normalizeFieldLabel(
      _getStandardCategoria(widget.categoria),
    );
    final normalizedServizioStandard = _normalizeFieldLabel(
      _getStandardServizio(widget.servizio),
    );

    for (final pattern in patterns) {
      final normalizedPattern = _normalizeFieldLabel(pattern);
      if (normalizedCategoria.contains(normalizedPattern) ||
          normalizedServizio.contains(normalizedPattern) ||
          normalizedCategoriaStandard.contains(normalizedPattern) ||
          normalizedServizioStandard.contains(normalizedPattern)) {
        return true;
      }
    }

    return false;
  }

  bool _isLavoroSubordinatoFlow() {
    return _matchesCurrentFlow([
      'lavoro subordinato',
      'per lavoro subordinato',
      'trabajo subordinado',
      'por trabajo subordinado',
      'subordinate work',
      'subordinate employment',
      'employment',
    ]);
  }

  bool _isLavoroAutonomoFlow() {
    return _matchesCurrentFlow([
      'lavoro autonomo',
      'per lavoro autonomo',
      'trabajo autonomo',
      'trabajo autónomo',
      'por trabajo autonomo',
      'por trabajo autónomo',
    ]);
  }

  bool _isMotiviFamiliariFlow() {
    return _matchesCurrentFlow([
      'motivi familiari',
      'per motivi familiari',
      'family reasons',
      'family reunification',
      'motivos familiares',
      'por motivos familiares',
    ]);
  }

  bool _isCittadinanzaFlow() {
    return _matchesCurrentFlow([
      'cittadinanza',
      'cittadinanza italiana',
      'citizenship',
      'ciudadania',
      'ciudadanía',
    ]);
  }

  bool _isVistoTuristicoFlow() {
    return _matchesCurrentFlow([
      'visto turistico',
      'tourist visa',
      'visa turistica',
      'visa turística',
    ]);
  }

  bool _isContractTypeFieldLabel(String label) {
    final normalized = _normalizeFieldLabel(label);
    final hasTypeWord =
        normalized.contains('tipo') ||
        normalized.contains('type') ||
        normalized.contains('tipologia') ||
        normalized.contains('clase');
    final hasContractWord =
        normalized.contains('contratto') ||
        normalized.contains('contrato') ||
        normalized.contains('contract') ||
        normalized.contains('employment') ||
        normalized.contains('trabajo') ||
        normalized.contains('empleo') ||
        normalized.contains('impiego');
    return hasTypeWord && hasContractWord;
  }

  String _extractStableFieldIdentifier(Map<String, dynamic> campo) {
    const candidateKeys = ['api_key', 'field_key', 'key', 'name', 'slug', 'id'];
    for (final key in candidateKeys) {
      final value = campo[key];
      if (value == null) continue;
      final parsed = value.toString().trim();
      if (parsed.isNotEmpty) {
        return _normalizeFieldLabel(parsed);
      }
    }

    final label = (campo['label'] ?? '').toString();
    return _normalizeFieldLabel(label);
  }

  bool _isContractTypeFieldIdentifier(String identifier) {
    return identifier.contains('tipo_contratto') ||
        identifier.contains('tipo_contrato') ||
        identifier.contains('contract_type') ||
        identifier.contains('employment_type') ||
        identifier.contains('tipo_empleo') ||
        identifier.contains('tipo_impiego');
  }

  bool _isContractDurationFieldIdentifier(String identifier) {
    return identifier.contains('durata_contratto') ||
        identifier.contains('duracion_contrato') ||
        identifier.contains('contract_duration') ||
        identifier.contains('employment_duration') ||
        identifier.contains('durata_impiego') ||
        identifier.contains('durata_lavoro') ||
        identifier.contains('duracion_empleo');
  }

  bool _isDocumentExpiryFieldIdentifier(String identifier) {
    return identifier.contains('data_scadenza') ||
        identifier.contains('documento_scadenza') ||
        identifier.contains('document_expiry') ||
        identifier.contains('expiry_date') ||
        identifier.contains('expiration_date') ||
        identifier.contains('fecha_caducidad') ||
        identifier.contains('caducidad_documento');
  }

  bool _isFamilyDocumentFieldIdentifier(String identifier) {
    return identifier.contains('documento_identita_familiare') ||
        identifier.contains('family_id_document') ||
        identifier.contains('documento_identidad_familiar') ||
        identifier.contains('permesso_familiare_tipo') ||
        identifier.contains('family_permit_type');
  }

  bool _isItalianLanguageCertificationFieldIdentifier(String identifier) {
    return identifier.contains('certificazione_lingua_italiana') ||
        identifier.contains('certificato_lingua_italiana') ||
        identifier.contains('italian_language_certification') ||
        identifier.contains('certificacion_idioma_italiano') ||
        identifier.contains('certificacion_lingua_italiana');
  }

  bool _isTouristVisaOptionalDateFieldIdentifier(String identifier) {
    return identifier.contains('data_arrivo_prevista') ||
        identifier.contains('data_partenza_prevista') ||
        identifier.contains('expected_arrival_date') ||
        identifier.contains('expected_departure_date') ||
        identifier.contains('fecha_llegada_prevista') ||
        identifier.contains('fecha_salida_prevista');
  }

  bool _isContractTypeCampo(Map<String, dynamic> campo) {
    final id = _extractStableFieldIdentifier(campo);
    final label = (campo['label'] ?? '').toString();
    return _isContractTypeFieldIdentifier(id) ||
        _isContractTypeFieldLabel(label);
  }

  bool _isContractDurationCampo(Map<String, dynamic> campo) {
    final id = _extractStableFieldIdentifier(campo);
    final label = (campo['label'] ?? '').toString();
    return _isContractDurationFieldIdentifier(id) ||
        _isContractDurationFieldLabel(label);
  }

  bool _isDocumentExpiryCampo(Map<String, dynamic> campo) {
    final id = _extractStableFieldIdentifier(campo);
    final label = (campo['label'] ?? '').toString();
    return _isDocumentExpiryFieldIdentifier(id) ||
        _isDocumentExpiryFieldLabel(label);
  }

  bool _isFamilyDocumentCampo(Map<String, dynamic> campo) {
    final id = _extractStableFieldIdentifier(campo);
    final label = (campo['label'] ?? '').toString();
    return _isFamilyDocumentFieldIdentifier(id) ||
        _isFamilyDocumentFieldLabel(label);
  }

  bool _isItalianLanguageCertificationCampo(Map<String, dynamic> campo) {
    final id = _extractStableFieldIdentifier(campo);
    final label = (campo['label'] ?? '').toString();
    return _isItalianLanguageCertificationFieldIdentifier(id) ||
        _isItalianLanguageCertificationFieldLabel(label);
  }

  bool _isTouristVisaOptionalDateCampo(Map<String, dynamic> campo) {
    final id = _extractStableFieldIdentifier(campo);
    final label = (campo['label'] ?? '').toString();
    return _isTouristVisaOptionalDateFieldIdentifier(id) ||
        _isTouristVisaOptionalDateFieldLabel(label);
  }

  bool _isContractDurationFieldLabel(String label) {
    final normalized = _normalizeFieldLabel(label);
    final hasDurationWord =
        normalized.contains('durata') ||
        normalized.contains('duration') ||
        normalized.contains('duracion') ||
        normalized.contains('term') ||
        normalized.contains('length') ||
        normalized.contains('plazo') ||
        normalized.contains('termino');
    final hasContractWord =
        normalized.contains('contratto') ||
        normalized.contains('contrato') ||
        normalized.contains('contract') ||
        normalized.contains('employment') ||
        normalized.contains('trabajo') ||
        normalized.contains('empleo') ||
        normalized.contains('impiego');
    return hasDurationWord && hasContractWord;
  }

  bool _isDocumentExpiryFieldLabel(String label) {
    final normalized = _normalizeFieldLabel(label);
    final isExpiryField =
        normalized.contains('scadenza') ||
        normalized.contains('caducidad') ||
        normalized.contains('expiry') ||
        normalized.contains('expiration');
    final isDocumentField =
        normalized.contains('document') ||
        normalized.contains('documento') ||
        normalized.contains('passaporto') ||
        normalized.contains('passport') ||
        normalized.contains('permesso') ||
        normalized.contains('carta identita') ||
        normalized.contains('carta identidad');
    return isExpiryField && isDocumentField;
  }

  bool _isFamilyDocumentFieldLabel(String label) {
    final normalized = _normalizeFieldLabel(label);
    return normalized.contains('documento identita familiare') ||
        normalized.contains('documento identita del familiare') ||
        normalized.contains('documento identidad familiar') ||
        normalized.contains('family id document');
  }

  bool _isItalianLanguageCertificationFieldLabel(String label) {
    final normalized = _normalizeFieldLabel(label);
    return normalized.contains('certificazione lingua italiana') ||
        normalized.contains('certificato lingua italiana') ||
        normalized.contains('italian language certification') ||
        normalized.contains('certificacion idioma italiano') ||
        normalized.contains('certificación idioma italiano');
  }

  bool _isTouristVisaOptionalDateFieldLabel(String label) {
    final normalized = _normalizeFieldLabel(label);
    return normalized.contains('data arrivo') ||
        normalized.contains('date of arrival') ||
        normalized.contains('fecha llegada') ||
        normalized.contains('partenza prevista') ||
        normalized.contains('departure date') ||
        normalized.contains('fecha salida');
  }

  bool _isPermanentContractSelected() {
    for (final campo in widget.campi) {
      if (!_isContractTypeCampo(campo)) continue;
      final label = (campo['label'] ?? '').toString();
      final value = _formData[label] ?? _controllers[label]?.text;
      if (value == null) continue;

      final normalizedValue = _normalizeFieldLabel('$value');
      if (normalizedValue.contains('tempo indeterminato') ||
          normalizedValue.contains('indeterminat') ||
          normalizedValue.contains('tiempo indeterminado') ||
          normalizedValue.contains('indefinid') ||
          normalizedValue.contains('indefinite') ||
          normalizedValue.contains('open ended') ||
          normalizedValue.contains('permanent') ||
          normalizedValue.contains('sin fecha de fin')) {
        return true;
      }
    }
    return false;
  }

  void _clearContractDurationData() {
    for (final campo in widget.campi) {
      if (!_isContractDurationCampo(campo)) continue;
      final label = (campo['label'] ?? '').toString();
      _formData.remove(label);
      _controllers[label]?.clear();
    }
  }

  bool _shouldHideField(Map<String, dynamic> campo) {
    if ((_isLavoroSubordinatoFlow() || _isLavoroAutonomoFlow()) &&
        _isDocumentExpiryCampo(campo)) {
      return true;
    }

    if (_isLavoroSubordinatoFlow() &&
        _isContractDurationCampo(campo) &&
        _isPermanentContractSelected()) {
      return true;
    }

    return false;
  }

  bool _isFieldRequired(Map<String, dynamic> campo, bool required) {
    if (!required) return false;
    if (_shouldHideField(campo)) return false;

    if (_isVistoTuristicoFlow() && _isTouristVisaOptionalDateCampo(campo)) {
      return false;
    }

    return true;
  }

  String _getDisplayedFieldLabel(Map<String, dynamic> campo) {
    final label = (campo['label'] ?? '').toString();
    if (_isMotiviFamiliariFlow() && _isFamilyDocumentCampo(campo)) {
      return AppLocalizations.of(context)!.familyResidencePermitType;
    }
    return label;
  }

  String _getRequiredDocumentLabel(String tipo) {
    return TipoDocumento.getDisplayName(tipo);
  }

  String _getInitialDocumentSoggetto() {
    if (_isMotiviFamiliariFlow() && _documentiMancantiFamiliare.isNotEmpty) {
      return DocumentoSoggetto.familiare;
    }
    return DocumentoSoggetto.richiedente;
  }

  Widget _buildDocumentStatusSummary({
    required String title,
    required List<String> documentiMancanti,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isComplete = documentiMancanti.isEmpty;
    final containerColor =
        isComplete ? scheme.secondaryContainer : scheme.tertiaryContainer;
    final contentColor =
        isComplete ? scheme.onSecondaryContainer : scheme.onTertiaryContainer;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isComplete ? scheme.secondary : scheme.tertiary,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isComplete ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: contentColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: contentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isComplete
                  ? AppLocalizations.of(context)!.documentsComplete
                  : AppLocalizations.of(
                    context,
                  )!.missingDocumentsCount(documentiMancanti.length),
              style: TextStyle(
                fontSize: 13,
                color: contentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentiBlock({
    required String title,
    String? subtitle,
    required List<String> documenti,
    required List<String> documentiMancanti,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 10),
          ...documenti.map((tipo) {
            final haDocumento = !documentiMancanti.contains(tipo);
            final showAsUploaded = haDocumento;
            final showAsMissing = !haDocumento;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    showAsUploaded
                        ? Icons.check_circle
                        : showAsMissing
                        ? Icons.radio_button_unchecked
                        : Icons.folder_shared_outlined,
                    color:
                        showAsUploaded
                            ? scheme.secondary
                            : showAsMissing
                            ? scheme.onSurfaceVariant
                            : scheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getRequiredDocumentLabel(tipo),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (showAsUploaded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: scheme.secondary),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 12, color: scheme.secondary),
                          const SizedBox(width: 4),
                          Text(
                            l10n.alreadyUploaded,
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _joinNameParts(String? first, String? last) {
    return '${first ?? ''} ${last ?? ''}'.trim();
  }

  String? _toNonEmptyString(dynamic value) {
    if (value == null) return null;
    final parsed = value.toString().trim();
    if (parsed.isEmpty || parsed.toLowerCase() == 'null') return null;
    return parsed;
  }

  String? _firstNonEmpty(List<dynamic> candidates) {
    for (final candidate in candidates) {
      final parsed = _toNonEmptyString(candidate);
      if (parsed != null) return parsed;
    }
    return null;
  }

  Map<String, dynamic> _asStringDynamicMap(dynamic value) {
    if (value is! Map) return <String, dynamic>{};
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }

  Map<String, String?> _extractNamePartsFromApiData(
    Map<String, dynamic> meData,
  ) {
    final userData = _asStringDynamicMap(meData['user']);
    final wpUserData = _asStringDynamicMap(meData['wp_user']);
    final profileData = _asStringDynamicMap(meData['profilo']);

    final apiFirstName = _firstNonEmpty([
      meData['nome'],
      meData['first_name'],
      meData['firstname'],
      meData['given_name'],
      userData['nome'],
      userData['first_name'],
      userData['firstname'],
      userData['given_name'],
      wpUserData['nome'],
      wpUserData['first_name'],
      wpUserData['given_name'],
      profileData['nome'],
      profileData['first_name'],
    ]);

    final apiLastName = _firstNonEmpty([
      meData['cognome'],
      meData['last_name'],
      meData['lastname'],
      meData['family_name'],
      userData['cognome'],
      userData['last_name'],
      userData['lastname'],
      userData['family_name'],
      wpUserData['cognome'],
      wpUserData['last_name'],
      wpUserData['family_name'],
      profileData['cognome'],
      profileData['last_name'],
    ]);

    final apiFullName = _firstNonEmpty([
      meData['full_name'],
      meData['nome_completo'],
      meData['display_name'],
      meData['name'],
      meData['nominativo'],
      userData['full_name'],
      userData['display_name'],
      userData['name'],
      wpUserData['full_name'],
      wpUserData['display_name'],
      wpUserData['name'],
      profileData['full_name'],
      profileData['nome_completo'],
      profileData['nominativo'],
    ]);

    final joined = _joinNameParts(apiFirstName, apiLastName);

    return {
      'first': apiFirstName,
      'last': apiLastName,
      'full': apiFullName ?? joined,
    };
  }

  /// Carica i dati dell'utente loggato e precompila i campi
  Future<void> _loadUserData() async {
    try {
      // Leggi tutti i dati dall'endpoint /soci/me
      final fullName = await _storage.read(key: 'full_name');
      String? firstName = await _storage.read(key: 'first_name');
      String? lastName = await _storage.read(key: 'last_name');
      String? nome = await _storage.read(key: 'nome');
      String? cognome = await _storage.read(key: 'cognome');
      final userDisplayName = await _storage.read(key: 'user_display_name');
      final email = await _storage.read(key: 'user_email');
      final telefono = await _storage.read(key: 'telefono');
      final citta = await _storage.read(key: 'citta');
      final indirizzo = await _storage.read(key: 'indirizzo');
      final cap = await _storage.read(key: 'cap');
      final provincia = await _storage.read(key: 'provincia');
      final codiceFiscale = await _storage.read(key: 'codice_fiscale');
      final dataNascita = await _storage.read(key: 'data_nascita');
      final luogoNascita = await _storage.read(key: 'luogo_nascita');
      final professione = await _storage.read(key: 'professione');
      final paeseOrigine = await _storage.read(key: 'paese_origine');
      final nazionalita = await _storage.read(key: 'nazionalita');

      var computedFullName = _joinNameParts(firstName, lastName);
      if (computedFullName.isEmpty) {
        computedFullName = _joinNameParts(nome, cognome);
      }

      var resolvedFullName =
          (fullName != null && fullName.trim().isNotEmpty)
              ? fullName.trim()
              : computedFullName;

      if (resolvedFullName.isEmpty &&
          userDisplayName != null &&
          userDisplayName.trim().isNotEmpty) {
        resolvedFullName = userDisplayName.trim();
        await _storage.write(key: 'full_name', value: resolvedFullName);
        print(
          '✅ [Prefill] Nome recuperato da storage user_display_name: $resolvedFullName',
        );
      }

      if (resolvedFullName.isEmpty) {
        print(
          '⚠️ [Prefill] Nome non trovato in storage, provo fallback API /soci/me...',
        );
        final meData = await SocioService.getMe();
        if (meData != null) {
          final extractedNameParts = _extractNamePartsFromApiData(meData);
          final apiNome = extractedNameParts['first'];
          final apiCognome = extractedNameParts['last'];
          final apiFullName = extractedNameParts['full'] ?? '';

          if (apiNome != null && apiNome.isNotEmpty) {
            firstName = apiNome;
            await _storage.write(key: 'first_name', value: apiNome);
            await _storage.write(key: 'nome', value: apiNome);
          }
          if (apiCognome != null && apiCognome.isNotEmpty) {
            lastName = apiCognome;
            await _storage.write(key: 'last_name', value: apiCognome);
            await _storage.write(key: 'cognome', value: apiCognome);
          }
          if (apiFullName.isNotEmpty) {
            resolvedFullName = apiFullName;
            await _storage.write(key: 'full_name', value: apiFullName);
            print(
              '✅ [Prefill] Nome recuperato da API /soci/me (alias-aware): $apiFullName',
            );
          } else {
            print(
              '⚠️ [Prefill] API /soci/me non contiene campi nome utilizzabili',
            );
          }
        } else {
          print('⚠️ [Prefill] Fallback API /soci/me non disponibile');
        }
      }

      print('=== DEBUG PRECOMPILAZIONE ===');
      print('fullName: $fullName');
      print('firstName: $firstName');
      print('lastName: $lastName');
      print('nome (legacy key): $nome');
      print('cognome (legacy key): $cognome');
      print('user_display_name: $userDisplayName');
      print('resolvedFullName (post-fallback): $resolvedFullName');
      print('email: $email');
      print('telefono: $telefono');
      print('citta: $citta');
      print('indirizzo: $indirizzo');
      print('cap: $cap');
      print('codice_fiscale: $codiceFiscale');
      print('data_nascita: $dataNascita');
      print('luogo_nascita: $luogoNascita');
      print('paese_origine: $paeseOrigine');
      print('nazionalita: $nazionalita');

      // Mappa i dati ai campi del form
      final prefilledData = <String, String>{};

      // Nome completo (italiano, inglese, spagnolo)
      if (resolvedFullName.isNotEmpty) {
        prefilledData['Nome completo'] = resolvedFullName;
        prefilledData['Nome e Cognome'] = resolvedFullName;
        prefilledData['Nome richiedente'] = resolvedFullName;
        prefilledData['Nome completo richiedente'] = resolvedFullName;
        prefilledData['Nominativo'] = resolvedFullName;
        prefilledData['Intestatario'] = resolvedFullName;
        prefilledData['Full name'] = resolvedFullName;
        prefilledData['Applicant full name'] = resolvedFullName;
        prefilledData['Nombre completo'] = resolvedFullName;
      }

      // Email (italiano, inglese, spagnolo)
      if (email != null) {
        prefilledData['Email'] = email;
        prefilledData['Email richiedente'] = email;
        prefilledData['Correo'] = email;
      }

      // Telefono (italiano, inglese, spagnolo)
      if (telefono != null) {
        prefilledData['Telefono'] = telefono;
        prefilledData['Telefono richiedente'] = telefono;
        prefilledData['Numero di telefono'] = telefono;
        prefilledData['Phone'] = telefono;
        prefilledData['Phone number'] = telefono;
        prefilledData['Teléfono'] = telefono;
        prefilledData['Número de teléfono'] = telefono;
      }

      // Città
      if (citta != null) {
        prefilledData['Città'] = citta;
        prefilledData['Città di residenza'] = citta;
        prefilledData['City'] = citta;
        prefilledData['Ciudad'] = citta;
      }

      // Indirizzo
      if (indirizzo != null) {
        prefilledData['Indirizzo'] = indirizzo;
        prefilledData['Indirizzo di residenza'] = indirizzo;
        prefilledData['Address'] = indirizzo;
        prefilledData['Dirección'] = indirizzo;
      }

      // CAP
      if (cap != null) {
        prefilledData['CAP'] = cap;
        prefilledData['Postal Code'] = cap;
        prefilledData['Código Postal'] = cap;
      }

      // Provincia
      if (provincia != null) {
        prefilledData['Provincia'] = provincia;
      }

      // Precompila i campi per modalità di consegna
      if (indirizzo != null) _consegnaIndirizzoController.text = indirizzo;
      if (citta != null) _consegnaCittaController.text = citta;
      if (cap != null) _consegnaCapController.text = cap;
      if (provincia != null) _consegnaProvinciaController.text = provincia;
      if (email != null) _consegnaEmailController.text = email;

      // Provincia
      if (provincia != null) {
        prefilledData['Provincia'] = provincia;
        prefilledData['Province'] = provincia;
      }

      // Codice Fiscale
      if (codiceFiscale != null) {
        prefilledData['Codice Fiscale'] = codiceFiscale;
        prefilledData['Codice fiscale'] = codiceFiscale;
        prefilledData['Tax Code'] = codiceFiscale;
        prefilledData['Código Fiscal'] = codiceFiscale;
      }

      // Data di nascita - Converti da YYYY-MM-DD a DD/MM/YYYY
      if (dataNascita != null && dataNascita.isNotEmpty) {
        String dataFormattata = dataNascita;
        if (dataNascita.contains('-')) {
          final parts = dataNascita.split('-');
          if (parts.length == 3) {
            dataFormattata = '${parts[2]}/${parts[1]}/${parts[0]}';
          }
        }
        prefilledData['Data di nascita'] = dataFormattata;
        prefilledData['Date of birth'] = dataFormattata;
        prefilledData['Fecha de nacimiento'] = dataFormattata;
      }

      // Luogo di nascita
      if (luogoNascita != null) {
        prefilledData['Luogo di nascita'] = luogoNascita;
        prefilledData['Place of birth'] = luogoNascita;
        prefilledData['Lugar de nacimiento'] = luogoNascita;
      }
      // Professione
      if (professione != null) {
        prefilledData['Professione'] = professione;
        prefilledData['Profession'] = professione;
        prefilledData['Profesión'] = professione;
      }

      // Paese di origine/provenienza (priorità a paese_origine)
      // Converte codice ISO a nome completo (EC -> Ecuador, IT -> Italia, ecc.)
      final paese = paeseOrigine ?? nazionalita;
      if (paese != null && !_isLavoroSubordinatoFlow()) {
        final countryFullName = getCountryName(paese);
        prefilledData['Paese di provenienza'] = countryFullName;
        prefilledData['Paese di origine'] = countryFullName;
        prefilledData['Country of origin'] = countryFullName;
        prefilledData['País de origen'] = countryFullName;
      }

      // Nazionalità
      if (nazionalita != null) {
        final nationalityFullName = getCountryName(nazionalita);
        prefilledData['Nazionalità'] = nationalityFullName;
        prefilledData['Nationality'] = nationalityFullName;
        prefilledData['Nacionalidad'] = nationalityFullName;
      }

      print('Dati precompilati: $prefilledData');
      print('Dati precompilati: $prefilledData');
      print(
        'Campi form ricevuti (${widget.campi.length}): ${widget.campi.map((c) => c['label']).toList()}',
      );

      final normalizedPrefilledData = <String, String>{
        for (final entry in prefilledData.entries)
          _normalizeFieldLabel(entry.key): entry.value,
      };

      // Crea i controller per ogni campo con i valori precompilati
      for (var campo in widget.campi) {
        final label = campo['label'] as String;
        final normalizedLabel = _normalizeFieldLabel(label);
        final matchedExact = prefilledData[label] != null;
        final matchedNormalized =
            normalizedPrefilledData[normalizedLabel] != null;
        final looksLikeFullName = _isFullNameFieldLabel(label);
        final fullNameFallbackValue =
            looksLikeFullName && resolvedFullName.isNotEmpty
                ? resolvedFullName
                : null;

        final prefilledValue =
            prefilledData[label] ??
            normalizedPrefilledData[normalizedLabel] ??
            fullNameFallbackValue;

        final source =
            matchedExact
                ? 'exact-label'
                : matchedNormalized
                ? 'normalized-label'
                : fullNameFallbackValue != null
                ? 'fullname-fallback'
                : 'none';

        final preview =
            (prefilledValue == null || prefilledValue.isEmpty)
                ? '<vuoto>'
                : (prefilledValue.length > 40
                    ? '${prefilledValue.substring(0, 40)}...'
                    : prefilledValue);

        print(
          '[PrefillField] label="$label" normalized="$normalizedLabel" '
          'looksLikeFullName=$looksLikeFullName matchedExact=$matchedExact '
          'matchedNormalized=$matchedNormalized source=$source value="$preview"',
        );

        final controller = TextEditingController(text: prefilledValue ?? '');
        _controllers[label] = controller;
        if (prefilledValue != null) {
          _formData[label] = prefilledValue;
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Errore caricamento dati utente: $e');
      // Crea controller vuoti in caso di errore
      for (var campo in widget.campi) {
        final label = campo['label'] as String;
        _controllers[label] = TextEditingController();
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.categoria)),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: scheme.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.servizio,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: scheme.onPrimaryContainer,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.categoria,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: scheme.onPrimaryContainer
                                            .withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Builder(
                                builder: (context) {
                                  final l10n = AppLocalizations.of(context)!;
                                  return Text(
                                    l10n.fillFollowingFields,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              ...widget.campi.map(
                                (campo) => _buildField(campo),
                              ),
                              // Sezione documenti richiesti
                              if (widget.documentiRichiesti != null &&
                                  widget.documentiRichiesti!.isNotEmpty)
                                _buildDocumentiRichiestiSection(),
                              // Sezione modalità di consegna
                              if (widget.modalitaConsegna != null &&
                                  widget.modalitaConsegna!.isNotEmpty)
                                _buildModalitaConsegnaSection(),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: scheme.shadow.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                            foregroundColor: scheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                          child:
                              _isSubmitting
                                  ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        scheme.onPrimary,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    AppLocalizations.of(context)!.sendRequest,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          HelpButtonWidget(
            serviceName: widget.servizio,
            serviceCategory: widget.categoria,
            currentScreen: 'RichiestaFormScreen',
            bottomOffset: MediaQuery.of(context).viewPadding.bottom + 84,
          ),
        ],
      ),
    );
  }

  Widget _buildField(Map<String, dynamic> campo) {
    final l10n = AppLocalizations.of(context)!;
    final label = campo['label'] as String;
    final type = campo['type'] as String;
    final required = _isFieldRequired(campo, campo['required'] as bool);
    final displayedLabel = _getDisplayedFieldLabel(campo);

    if (_shouldHideField(campo)) {
      return const SizedBox.shrink();
    }

    Widget field;

    switch (type) {
      case 'text':
        field = TextFormField(
          controller: _controllers[label],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          validator:
              required
                  ? (value) =>
                      value?.isEmpty ?? true ? l10n.fillAllFields : null
                  : null,
          onChanged: (value) => _formData[label] = value,
        );
        break;
      case 'textarea':
        field = TextFormField(
          controller: _controllers[label],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 4,
          validator:
              required
                  ? (value) =>
                      value?.isEmpty ?? true ? l10n.fillAllFields : null
                  : null,
          onChanged: (value) => _formData[label] = value,
        );
        break;
      case 'number':
        field = TextFormField(
          controller: _controllers[label],
          decoration: const InputDecoration(border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          validator:
              required
                  ? (value) =>
                      value?.isEmpty ?? true ? l10n.fillAllFields : null
                  : null,
          onChanged: (value) => _formData[label] = value,
        );
        break;
      case 'date':
        field = TextFormField(
          controller: _controllers[label],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              final formattedDate = '${date.day}/${date.month}/${date.year}';
              _controllers[label]?.text = formattedDate;
              _formData[label] = formattedDate;
            }
          },
          validator:
              required
                  ? (value) =>
                      value?.isEmpty ?? true ? l10n.fillAllFields : null
                  : null,
        );
        break;
      case 'select':
        final options =
            (campo['options'] as List<dynamic>)
                .map((option) => option.toString())
                .toList();

        if (_isCittadinanzaFlow() &&
            _isItalianLanguageCertificationCampo(campo) &&
            !options.any(
              (option) => _normalizeFieldLabel(
                option,
              ).contains('permesso di soggiorno a lungo periodo'),
            )) {
          options.add('Ho permesso di soggiorno a lungo periodo');
        }

        field = DropdownButtonFormField<String>(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items:
              options.map((option) {
                return DropdownMenuItem<String>(
                  value: option.toString(),
                  child: Text(option.toString()),
                );
              }).toList(),
          validator:
              required
                  ? (value) => value == null ? l10n.fillAllFields : null
                  : null,
          onChanged: (value) {
            setState(() {
              _formData[label] = value;
              if (_isContractTypeCampo(campo) &&
                  _isPermanentContractSelected()) {
                _clearContractDurationData();
              }
            });
          },
        );
        break;
      default:
        field = const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: displayedLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              children:
                  required
                      ? [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]
                      : [],
            ),
          ),
          const SizedBox(height: 8),
          field,
        ],
      ),
    );
  }

  /// Converte le label italiane dei campi in chiavi snake_case per l'API
  Map<String, dynamic> _convertToApiFormat(Map<String, dynamic> formData) {
    final apiData = <String, dynamic>{};

    // Mappa di conversione label -> chiave API
    final labelToApiKey = {
      'Nome completo': 'nome_completo',
      'Nome e Cognome': 'nome_completo',
      'Nome richiedente': 'nome_completo',
      'Email': 'email',
      'Email richiedente': 'email',
      'Telefono': 'telefono',
      'Telefono richiedente': 'telefono',
      'Numero di telefono': 'telefono',
      'Data di nascita': 'data_nascita',
      'Luogo di nascita': 'luogo_nascita',
      'Paese di provenienza': 'paese_provenienza',
      'Paese di nascita': 'paese_nascita',
      'Paese nascita': 'paese_nascita',
      'Paese di origine': 'paese_provenienza',
      'Paese origine': 'paese_provenienza',
      'Country of origin': 'paese_provenienza',
      'País de origen': 'paese_provenienza',
      'Tipo di contratto': 'tipo_contratto',
      'Tipo contratto': 'tipo_contratto',
      'Nome azienda': 'nome_azienda',
      'Tipo di attività': 'tipo_attivita',
      'Tipo attività': 'tipo_attivita',
      'Relazione familiare': 'relazione_familiare',
      'Nome istituto/università': 'nome_istituto_universita',
      'Nome istituto università': 'nome_istituto_universita',
      'Data arrivo in Italia': 'data_arrivo_italia',
      'Data di arrivo in Italia': 'data_arrivo_italia',
      'Indirizzo residenza attuale': 'indirizzo_residenza_attuale',
      'Indirizzo di residenza attuale': 'indirizzo_residenza_attuale',
      'Motivo richiesta': 'motivo_richiesta',
      'Motivo della richiesta': 'motivo_richiesta',
      'Nazionalità': 'nazionalita',
      'Numero passaporto': 'numero_passaporto',
      'Data arrivo prevista': 'data_arrivo_prevista',
      'Data di arrivo prevista': 'data_arrivo_prevista',
      'Codice Fiscale': 'codice_fiscale',
      'Codice fiscale': 'codice_fiscale',
      'Indirizzo': 'indirizzo',
      'Indirizzo residenza': 'indirizzo_residenza',
      'Indirizzo di residenza': 'indirizzo_residenza',
      'Anno fiscale': 'anno_fiscale',
      'Partita IVA': 'partita_iva',
      'Tipo supporto richiesto': 'tipo_supporto_richiesto',
      'Tipo di supporto richiesto': 'tipo_supporto_richiesto',
      'Tipo adempimento': 'tipo_adempimento',
      'Tipo di adempimento': 'tipo_adempimento',
      'Argomento consulenza': 'argomento_consulenza',
      'Argomento della consulenza': 'argomento_consulenza',
      'Cosa vuoi fare': 'cosa_vuoi_fare',
      'Città': 'citta',
      'Città di residenza': 'citta',
      'CAP': 'cap',
      'Provincia': 'provincia',
      'Professione': 'professione',
      'Note aggiuntive': 'note',
      'Note': 'note',
      'Durata contratto (mesi)': 'durata_contratto_mesi',
      'Durata soggiorno (giorni)': 'durata_soggiorno_giorni',
      'Documenti disponibili': 'documenti_disponibili',
    };

    // Campi data che devono essere convertiti da DD/MM/YYYY a YYYY-MM-DD
    final dateFields = {
      'data_nascita',
      'data_arrivo_italia',
      'data_arrivo_prevista',
    };

    for (var entry in formData.entries) {
      final apiKey =
          labelToApiKey[entry.key] ??
          entry.key.toLowerCase().replaceAll(' ', '_');
      var value = entry.value;

      // Converti date dal formato DD/MM/YYYY a YYYY-MM-DD
      if (dateFields.contains(apiKey) && value is String) {
        final datePattern = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
        final match = datePattern.firstMatch(value);
        if (match != null) {
          final day = match.group(1)!.padLeft(2, '0');
          final month = match.group(2)!.padLeft(2, '0');
          final year = match.group(3);
          value = '$year-$month-$day';
        }
      }

      apiData[apiKey] = value;
    }

    return apiData;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Controlla se ci sono documenti mancanti
    if (widget.documentiRichiesti != null &&
        widget.documentiRichiesti!.isNotEmpty) {
      await _checkDocumenti();
      if (_documentiMancanti.isNotEmpty ||
          _documentiMancantiFamiliare.isNotEmpty) {
        _showDocumentiMancantiDialog();
        return;
      }
    }

    // Non serve più save() perché usiamo onChanged
    // Aggiungi i valori dei controller che potrebbero non essere in _formData
    for (var entry in _controllers.entries) {
      if (entry.value.text.isNotEmpty) {
        _formData[entry.key] = entry.value.text;
      }
    }

    // Aggiungi modalità di consegna selezionate se presenti
    if (widget.modalitaConsegna != null &&
        widget.modalitaConsegna!.isNotEmpty) {
      if (_modalitaConsegnaSelezionate.isNotEmpty) {
        _formData['modalita_consegna'] = _modalitaConsegnaSelezionate.toList();

        // Aggiungi dati specifici per ogni modalità
        if (_modalitaConsegnaSelezionate.contains('courier')) {
          _formData['consegna_indirizzo'] = _consegnaIndirizzoController.text;
          _formData['consegna_citta'] = _consegnaCittaController.text;
          _formData['consegna_cap'] = _consegnaCapController.text;
          _formData['consegna_provincia'] = _consegnaProvinciaController.text;
        }
        if (_modalitaConsegnaSelezionate.contains('email')) {
          _formData['consegna_email'] = _consegnaEmailController.text;
        }
        if (_modalitaConsegnaSelezionate.contains('pickup')) {
          _formData['consegna_indirizzo_ritiro'] =
              'Via Populonia 8, 20159 Milano MI';
        }
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Converti i dati dal formato form al formato API
      final apiData = _convertToApiFormat(_formData);

      // Aggiungi l'ID del socio/user per collegare la richiesta all'utente WordPress
      final socioId = await _storage.read(key: 'socio_id');
      final userId = await _storage.read(key: 'user_id');

      // Usa socio_id se disponibile, altrimenti user_id
      if (socioId != null && socioId.isNotEmpty) {
        apiData['socio_id'] = socioId;
        print('📋 Aggiunto socio_id: $socioId');
      } else if (userId != null && userId.isNotEmpty) {
        apiData['user_id'] = userId;
        print('📋 Aggiunto user_id: $userId');
      }

      print('=== DATI FORM ORIGINALI ===');
      print(_formData);
      print('=== DATI CONVERTITI PER API ===');
      print(apiData);

      // Standardizza servizio e categoria (da tradotti a chiavi inglesi)
      final servizioStandard = _getStandardServizio(widget.servizio);
      final categoriaStandard = _getStandardCategoria(widget.categoria);

      print('=== STANDARDIZZAZIONE ===');
      print('Servizio originale: ${widget.servizio}');
      print('Servizio standard: $servizioStandard');
      print('Categoria originale: ${widget.categoria}');
      print('Categoria standard: $categoriaStandard');

      print('\n🔄 CHIAMATA API IN CORSO...');
      // Usa il nuovo endpoint API con valori standardizzati
      final result = await SocioService.inviaRichiestaServizio(
        servizio: servizioStandard,
        categoria: categoriaStandard,
        dati: apiData,
      );

      print('\n📨 RESULT RICEVUTO:');
      print('   success: ${result['success']}');
      print('   numero_pratica: ${result['numero_pratica']}');
      print('   requires_payment: ${result['requires_payment']}');
      print('   payment_id: ${result['payment_id']}');
      print('   importo: ${result['importo']}');

      setState(() {
        _isSubmitting = false;
      });

      if (!mounted) return;

      if (result['success'] == true) {
        final l10n = AppLocalizations.of(context)!;
        final numeroPratica = result['numero_pratica'];
        final requiresPayment = result['requires_payment'] == true;
        final importo = result['importo'];
        final paymentId = result['payment_id'];

        print('\n💬 PREPARAZIONE DIALOG:');
        print('   numeroPratica: $numeroPratica');
        print('   requiresPayment: $requiresPayment');
        print('   importo: $importo');
        print('   paymentId: $paymentId');

        String message =
            numeroPratica != null
                ? '${l10n.requestSent}\n\n${l10n.fileNumber}: $numeroPratica'
                : result['message'] ?? l10n.requestSent;

        // Aggiungi info pagamento se richiesto
        if (requiresPayment && importo != null) {
          message +=
              '\n\n💰 ${l10n.paymentRequiredAmount}: €${importo.toStringAsFixed(2)}';
          message += '\n\n${l10n.canCompletePaymentFromRequests}';
        } else {
          message += '\n\n${l10n.willBeContactedByEmail}';
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      requiresPayment ? Icons.payment : Icons.check_circle,
                      color:
                          requiresPayment
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.secondary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        requiresPayment
                            ? l10n.requestSentPaymentRequired
                            : l10n.requestSent,
                      ),
                    ),
                  ],
                ),
                content: Text(message),
                actions: [
                  if (requiresPayment && paymentId != null)
                    TextButton.icon(
                      icon: const Icon(Icons.credit_card),
                      label: Text(l10n.payNow),
                      onPressed: () {
                        Navigator.of(context).pop(); // Chiudi dialog
                        Navigator.of(context).pop(); // Torna indietro
                        // Naviga alla schermata pagamento
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PagamentoScreen(paymentId: paymentId),
                          ),
                        );
                      },
                    ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Chiudi dialog
                      Navigator.of(this.context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const MainScreen(initialIndex: 3),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text(requiresPayment ? l10n.payLater : l10n.ok),
                  ),
                ],
              ),
        );
      } else {
        final l10n = AppLocalizations.of(context)!;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('❌ ${l10n.error}'),
                content: Text(result['message'] ?? 'Errore durante l\'invio'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.ok),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('❌ ${l10n.error}'),
              content: Text('${l10n.connectionError}: ${e.toString()}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.ok),
                ),
              ],
            ),
      );
    }
  }

  // Costruisce la sezione documenti richiesti
  Widget _buildDocumentiRichiestiSection() {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final allUploaded =
        _documentiMancanti.isEmpty && _documentiMancantiFamiliare.isEmpty;
    final sectionTextColor =
        allUploaded ? scheme.onSecondaryContainer : scheme.onTertiaryContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            allUploaded ? scheme.secondaryContainer : scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: allUploaded ? scheme.secondary : scheme.tertiary,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                allUploaded ? Icons.check_circle : Icons.upload_file,
                color: sectionTextColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.requiredDocuments.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: sectionTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isMotiviFamiliariFlow())
            Text(
              l10n.documentsManagedSeparately,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: sectionTextColor,
              ),
            ),
          if (_isMotiviFamiliariFlow()) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDocumentStatusSummary(
                  title: l10n.applicant,
                  documentiMancanti: _documentiMancanti,
                ),
                const SizedBox(width: 12),
                _buildDocumentStatusSummary(
                  title: l10n.familyMember,
                  documentiMancanti: _documentiMancantiFamiliare,
                ),
              ],
            ),
          ],
          if (_isMotiviFamiliariFlow()) ...[
            _buildDocumentiBlock(
              title: l10n.documentsApplicantTitle,
              subtitle: l10n.documentsApplicantSubtitle,
              documenti: widget.documentiRichiesti!,
              documentiMancanti: _documentiMancanti,
            ),
            _buildDocumentiBlock(
              title: l10n.documentsFamilyTitle,
              subtitle: l10n.documentsFamilySubtitle,
              documenti: widget.documentiRichiesti!,
              documentiMancanti: _documentiMancantiFamiliare,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DocumentiScreen(
                            showFamilyDocuments: true,
                            initialSoggetto: DocumentoSoggetto.familiare,
                          ),
                    ),
                  );
                  await _checkDocumenti();
                },
                icon: const Icon(Icons.edit_document),
                label: Text(l10n.reloadFamilyDocuments),
                style: TextButton.styleFrom(foregroundColor: scheme.primary),
              ),
            ),
          ] else
            _buildDocumentiBlock(
              title: l10n.requiredDocuments,
              documenti: widget.documentiRichiesti!,
              documentiMancanti: _documentiMancanti,
            ),
          if (_documentiMancanti.isNotEmpty ||
              _documentiMancantiFamiliare.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DocumentiScreen(
                            showFamilyDocuments: _isMotiviFamiliariFlow(),
                            initialSoggetto: _getInitialDocumentSoggetto(),
                          ),
                    ),
                  );
                  await _checkDocumenti();
                },
                icon: const Icon(Icons.upload),
                label: Text(
                  AppLocalizations.of(context)!.uploadMissingDocuments,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.tertiary,
                  foregroundColor: scheme.onTertiary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Mostra dialog per documenti mancanti
  void _showDocumentiMancantiDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              '📄 ${AppLocalizations.of(context)!.missingDocumentsTitle}',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.missingDocumentsIntro),
                if (_isMotiviFamiliariFlow())
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      AppLocalizations.of(context)!.documentsSeparatedNotice,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                const SizedBox(height: 16),
                if (_isMotiviFamiliariFlow()) ...[
                  Text(
                    AppLocalizations.of(context)!.documentsApplicantTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._documentiMancanti.map(
                    (tipo) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.upload_file,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getRequiredDocumentLabel(tipo),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.documentsFamilyTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._documentiMancantiFamiliare.map(
                    (tipo) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_shared_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getRequiredDocumentLabel(tipo),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else
                  ..._documentiMancanti.map(
                    (tipo) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.upload_file,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getRequiredDocumentLabel(tipo),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.formDataPreserved,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  // Naviga allo screen documenti
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DocumentiScreen(
                            showFamilyDocuments: _isMotiviFamiliariFlow(),
                            initialSoggetto: _getInitialDocumentSoggetto(),
                          ),
                    ),
                  );
                  // Ricontrolla i documenti al ritorno
                  await _checkDocumenti();
                },
                icon: const Icon(Icons.upload),
                label: const Text('Carica documenti'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
    );
  }

  // Costruisce la sezione modalità di consegna
  Widget _buildModalitaConsegnaSection() {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary;

    final modalitaDisponibili = {
      'courier': l10n.courierShipping,
      'pickup': l10n.pickupAtOffice,
      'email': l10n.emailDelivery,
    };

    final modalitaPerServizio = <String, String>{};
    for (var modalita in widget.modalitaConsegna!) {
      if (modalitaDisponibili.containsKey(modalita)) {
        modalitaPerServizio[modalita] = modalitaDisponibili[modalita]!;
      }
    }

    InputDecoration inputDecoration(String label, {IconData? icon}) {
      OutlineInputBorder border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: color, width: 1.2),
      );

      return InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        prefixIcon:
            icon == null
                ? null
                : Icon(icon, color: scheme.primary.withOpacity(0.78)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: border(scheme.outlineVariant),
        enabledBorder: border(scheme.outlineVariant),
        focusedBorder: border(scheme.primary),
        errorBorder: border(scheme.error),
        focusedErrorBorder: border(scheme.error),
      );
    }

    Widget optionTile({
      required String label,
      required bool selected,
      required VoidCallback onTap,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color:
                    selected
                        ? Color.alphaBlend(
                          scheme.primary.withOpacity(0.08),
                          Colors.white,
                        )
                        : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? scheme.primary : scheme.outlineVariant,
                  width: selected ? 1.6 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadow.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: const Color(0xFF253744),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: selected ? scheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? scheme.primary : scheme.outline,
                        width: 2,
                      ),
                    ),
                    child:
                        selected
                            ? Icon(
                              Icons.check,
                              size: 18,
                              color: scheme.onPrimary,
                            )
                            : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget panel({required Widget child}) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(accent.withOpacity(0.16), Colors.white),
            Color.alphaBlend(accent.withOpacity(0.06), scheme.surface),
          ],
        ),
        border: Border.all(color: accent.withOpacity(0.20), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.24),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.deliveryMethodsTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF20303C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.selectDeliveryMethods,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Color(0xFF61717E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...modalitaPerServizio.entries.map((entry) {
            final key = entry.key;
            final label = entry.value;
            final isSelected = _modalitaConsegnaSelezionate.contains(key);

            return optionTile(
              label: label,
              selected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _modalitaConsegnaSelezionate.remove(key);
                  } else {
                    _modalitaConsegnaSelezionate.add(key);
                  }
                });
              },
            );
          }),

          if (_modalitaConsegnaSelezionate.contains('courier'))
            panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.home_work_rounded, color: accent),
                      const SizedBox(width: 8),
                      const Text(
                        'Indirizzo di consegna',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF20303C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _consegnaIndirizzoController,
                    decoration: inputDecoration(
                      'Indirizzo *',
                      icon: Icons.location_on_outlined,
                    ),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Campo obbligatorio'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _consegnaCittaController,
                          decoration: inputDecoration('Città *'),
                          validator:
                              (value) =>
                                  value?.isEmpty ?? true
                                      ? 'Obbligatorio'
                                      : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _consegnaCapController,
                          decoration: inputDecoration('CAP *'),
                          keyboardType: TextInputType.number,
                          validator:
                              (value) =>
                                  value?.isEmpty ?? true
                                      ? 'Obbligatorio'
                                      : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _consegnaProvinciaController,
                    decoration: inputDecoration('Provincia *'),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Campo obbligatorio'
                                : null,
                  ),
                ],
              ),
            ),

          if (_modalitaConsegnaSelezionate.contains('email'))
            panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.alternate_email_rounded, color: accent),
                      const SizedBox(width: 8),
                      const Text(
                        'Indirizzo email per la consegna',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF20303C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _consegnaEmailController,
                    decoration: inputDecoration(
                      'Email *',
                      icon: Icons.email_outlined,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Campo obbligatorio';
                      if (!value!.contains('@')) return 'Email non valida';
                      return null;
                    },
                  ),
                ],
              ),
            ),

          if (_modalitaConsegnaSelezionate.contains('pickup'))
            panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.storefront_rounded, color: accent),
                      const SizedBox(width: 8),
                      const Text(
                        'Indirizzo di ritiro',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF20303C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        accent.withOpacity(0.08),
                        Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: accent.withOpacity(0.18)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent,
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Via Populonia 8, 20159 Milano MI',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF20303C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
