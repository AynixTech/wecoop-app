import 'package:flutter/material.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/widgets/help_button_widget.dart';
import '../../services/socio_service.dart';
import '../../services/documento_service.dart';
import '../../models/documento.dart';
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
    if (widget.documentiRichiesti == null || widget.documentiRichiesti!.isEmpty) {
      return;
    }

    await _documentoService.getDocumenti(); // Carica documenti
    final mancanti = _documentoService.getDocumentiMancanti(widget.documentiRichiesti!);
    setState(() {
      _documentiMancanti = mancanti;
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
    return value.map(
      (key, mapValue) => MapEntry(key.toString(), mapValue),
    );
  }

  Map<String, String?> _extractNamePartsFromApiData(Map<String, dynamic> meData) {
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
        print('⚠️ [Prefill] Nome non trovato in storage, provo fallback API /soci/me...');
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
            print('✅ [Prefill] Nome recuperato da API /soci/me (alias-aware): $apiFullName');
          } else {
            print('⚠️ [Prefill] API /soci/me non contiene campi nome utilizzabili');
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
      if (paese != null) {
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
      print('Campi form ricevuti (${widget.campi.length}): ${widget.campi.map((c) => c['label']).toList()}');

      final normalizedPrefilledData = <String, String>{
        for (final entry in prefilledData.entries)
          _normalizeFieldLabel(entry.key): entry.value,
      };

      // Crea i controller per ogni campo con i valori precompilati
      for (var campo in widget.campi) {
        final label = campo['label'] as String;
        final normalizedLabel = _normalizeFieldLabel(label);
        final matchedExact = prefilledData[label] != null;
        final matchedNormalized = normalizedPrefilledData[normalizedLabel] != null;
        final looksLikeFullName = _isFullNameFieldLabel(label);
        final fullNameFallbackValue =
            looksLikeFullName && resolvedFullName.isNotEmpty
                ? resolvedFullName
                : null;

        final prefilledValue =
            prefilledData[label] ??
            normalizedPrefilledData[normalizedLabel] ??
            fullNameFallbackValue;

        final source = matchedExact
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

        final controller = TextEditingController(
          text: prefilledValue ?? '',
        );
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
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.amber.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.servizio,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.categoria,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
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
                              if (widget.documentiRichiesti != null && widget.documentiRichiesti!.isNotEmpty)
                                _buildDocumentiRichiestiSection(),
                              // Sezione modalità di consegna
                              if (widget.modalitaConsegna != null && widget.modalitaConsegna!.isNotEmpty)
                                _buildModalitaConsegnaSection(),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                          child:
                              _isSubmitting
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black,
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
          ),
        ],
      ),
    );
  }

  Widget _buildField(Map<String, dynamic> campo) {
    final l10n = AppLocalizations.of(context)!;
    final label = campo['label'] as String;
    final type = campo['type'] as String;
    final required = campo['required'] as bool;

    Widget field;

    switch (type) {
      case 'text':
        field = TextFormField(
          controller: _controllers[label],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
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
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
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
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
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
        final options = campo['options'] as List<dynamic>;
        field = DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
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
          onChanged: (value) => _formData[label] = value,
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
              text: label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
              children: required
                  ? [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: Colors.red.shade700,
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
    if (widget.documentiRichiesti != null && widget.documentiRichiesti!.isNotEmpty) {
      await _checkDocumenti();
      if (_documentiMancanti.isNotEmpty) {
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
    if (widget.modalitaConsegna != null && widget.modalitaConsegna!.isNotEmpty) {
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
          _formData['consegna_indirizzo_ritiro'] = 'Via Populonia 8, 20159 Milano MI';
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
        
        String message = numeroPratica != null
            ? '${l10n.requestSent}\n\n${l10n.fileNumber}: $numeroPratica'
            : result['message'] ?? l10n.requestSent;
        
        // Aggiungi info pagamento se richiesto
        if (requiresPayment && importo != null) {
          message += '\n\n💰 ${l10n.paymentRequiredAmount}: €${importo.toStringAsFixed(2)}';
          message += '\n\n${l10n.canCompletePaymentFromRequests}';
        } else {
          message += '\n\n${l10n.willBeContactedByEmail}';
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  requiresPayment ? Icons.payment : Icons.check_circle,
                  color: requiresPayment ? Colors.orange : Colors.green,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    requiresPayment ? l10n.requestSentPaymentRequired : l10n.requestSent,
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
                        builder: (context) => PagamentoScreen(
                          paymentId: paymentId,
                        ),
                      ),
                    );
                  },
                ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Chiudi dialog
                  Navigator.of(context).pop(); // Torna indietro
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
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _documentiMancanti.isEmpty ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _documentiMancanti.isEmpty ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _documentiMancanti.isEmpty ? Icons.check_circle : Icons.upload_file,
                color: _documentiMancanti.isEmpty ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'DOCUMENTI RICHIESTI',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.documentiRichiesti!.map((tipo) {
            final haDocumento = !_documentiMancanti.contains(tipo);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    haDocumento ? Icons.check_circle : Icons.cancel,
                    color: haDocumento ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      TipoDocumento.getDisplayName(tipo),
                      style: TextStyle(
                        fontSize: 14,
                        decoration: haDocumento ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (_documentiMancanti.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DocumentiScreen(),
                    ),
                  );
                  await _checkDocumenti();
                },
                icon: const Icon(Icons.upload),
                label: const Text('Carica documenti mancanti'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
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
      builder: (context) => AlertDialog(
        title: const Text('📄 Documenti mancanti'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Per procedere con questa richiesta devi caricare i seguenti documenti:',
            ),
            const SizedBox(height: 16),
            ..._documentiMancanti.map(
              (tipo) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.upload_file, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        TipoDocumento.getDisplayName(tipo),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'I dati del form verranno conservati.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
                  builder: (context) => const DocumentiScreen(),
                ),
              );
              // Ricontrolla i documenti al ritorno
              await _checkDocumenti();
            },
            icon: const Icon(Icons.upload),
            label: const Text('Carica documenti'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Costruisce la sezione modalità di consegna
  Widget _buildModalitaConsegnaSection() {
    final l10n = AppLocalizations.of(context)!;
    
    // Mappa delle modalità disponibili con le loro chiavi e etichette localizzate
    final modalitaDisponibili = {
      'courier': l10n.courierShipping,
      'pickup': l10n.pickupAtOffice,
      'email': l10n.emailDelivery,
    };
    
    // Filtra solo le modalità disponibili per questo servizio
    final modalitaPerServizio = <String, String>{};
    for (var modalita in widget.modalitaConsegna!) {
      if (modalitaDisponibili.containsKey(modalita)) {
        modalitaPerServizio[modalita] = modalitaDisponibili[modalita]!;
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade300,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.deliveryMethodsTitle.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.selectDeliveryMethods,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          ...modalitaPerServizio.entries.map((entry) {
            final key = entry.key;
            final label = entry.value;
            final isSelected = _modalitaConsegnaSelezionate.contains(key);
            
            return CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _modalitaConsegnaSelezionate.add(key);
                  } else {
                    _modalitaConsegnaSelezionate.remove(key);
                  }
                });
              },
              activeColor: Colors.blue,
            );
          }),
          
          // Campi dinamici per Corriere
          if (_modalitaConsegnaSelezionate.contains('courier'))
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Indirizzo di consegna',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _consegnaIndirizzoController,
                  decoration: const InputDecoration(
                    labelText: 'Indirizzo *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Campo obbligatorio' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _consegnaCittaController,
                        decoration: const InputDecoration(
                          labelText: 'Città *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Obbligatorio' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _consegnaCapController,
                        decoration: const InputDecoration(
                          labelText: 'CAP *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true ? 'Obbligatorio' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _consegnaProvinciaController,
                  decoration: const InputDecoration(
                    labelText: 'Provincia *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Campo obbligatorio' : null,
                ),
              ],
            ),
          
          // Campi dinamici per Email
          if (_modalitaConsegnaSelezionate.contains('email'))
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Indirizzo email per la consegna',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _consegnaEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
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
          
          // Informazioni per Ritiro in sede
          if (_modalitaConsegnaSelezionate.contains('pickup'))
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Indirizzo di ritiro',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Via Populonia 8, 20159 Milano MI',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
