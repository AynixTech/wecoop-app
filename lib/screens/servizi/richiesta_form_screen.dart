import 'package:flutter/material.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import '../../services/socio_service.dart';
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
  
  // Supporto Contabile
  'Supporto Contabile': 'accounting_support',
  'Accounting Support': 'accounting_support',
  'Soporte Contable': 'accounting_support',
  
  // Mediazione Fiscale
  'Mediazione Fiscale': 'tax_mediation',
  'Tax Mediation': 'tax_mediation',
  'Mediación Fiscal': 'tax_mediation',
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
  'VAT Number Opening': 'vat_number_opening',
  'Apertura de Partita IVA': 'vat_number_opening',
  
  // Contabilità - Gestione Contabilità
  'Gestione Contabilità': 'accounting_management',
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
  
  // Mediazione Fiscale - Gestione Debiti
  'Gestione Debiti Fiscali': 'tax_debt_management',
  'Tax Debt Management': 'tax_debt_management',
  'Gestión de Deudas Fiscales': 'tax_debt_management',
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

  const RichiestaFormScreen({
    super.key,
    required this.servizio,
    required this.categoria,
    required this.campi,
  });

  @override
  State<RichiestaFormScreen> createState() => _RichiestaFormScreenState();
}

class _RichiestaFormScreenState extends State<RichiestaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};
  final _storage = SecureStorageService();
  bool _isSubmitting = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    // Libera i controller
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Carica i dati dell'utente loggato e precompila i campi
  Future<void> _loadUserData() async {
    try {
      // Leggi tutti i dati dall'endpoint /soci/me
      final fullName = await _storage.read(key: 'full_name');
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

      print('=== DEBUG PRECOMPILAZIONE ===');
      print('fullName: $fullName');
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
      if (fullName != null && fullName.isNotEmpty) {
        prefilledData['Nome completo'] = fullName;
        prefilledData['Nome e Cognome'] = fullName;
        prefilledData['Nome richiedente'] = fullName;
        prefilledData['Full name'] = fullName;
        prefilledData['Nombre completo'] = fullName;
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

      // Crea i controller per ogni campo con i valori precompilati
      for (var campo in widget.campi) {
        final label = campo['label'] as String;
        final controller = TextEditingController(
          text: prefilledData[label] ?? '',
        );
        _controllers[label] = controller;
        if (prefilledData[label] != null) {
          _formData[label] = prefilledData[label];
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
      body:
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
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
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
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
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
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
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
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
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
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
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

    return Padding(padding: const EdgeInsets.only(bottom: 16), child: field);
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

    // Non serve più save() perché usiamo onChanged
    // Aggiungi i valori dei controller che potrebbero non essere in _formData
    for (var entry in _controllers.entries) {
      if (entry.value.text.isNotEmpty) {
        _formData[entry.key] = entry.value.text;
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
            ? '${l10n.requestSent}\n\n${l10n.error}: $numeroPratica'
            : result['message'] ?? l10n.requestSent;
        
        // Aggiungi info pagamento se richiesto
        if (requiresPayment && importo != null) {
          message += '\n\n💰 Pagamento richiesto: €${importo.toStringAsFixed(2)}';
          message += '\n\nPotrai completare il pagamento dalla sezione "Le Mie Richieste".';
        } else {
          message += '\n\nSarai contattato via email per i prossimi passi.';
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
                    requiresPayment ? 'Richiesta Inviata - Pagamento Richiesto' : l10n.requestSent,
                  ),
                ),
              ],
            ),
            content: Text(message),
            actions: [
              if (requiresPayment && paymentId != null)
                TextButton.icon(
                  icon: const Icon(Icons.credit_card),
                  label: const Text('Paga Ora'),
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
                child: Text(requiresPayment ? 'Paga Dopo' : l10n.ok),
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
}
