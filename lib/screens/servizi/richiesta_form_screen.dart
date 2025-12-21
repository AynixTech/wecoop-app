import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/socio_service.dart';

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
  final _storage = const FlutterSecureStorage();
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

      print('=== DEBUG PRECOMPILAZIONE ===');
      print('fullName: $fullName');
      print('email: $email');
      print('telefono: $telefono');
      print('citta: $citta');
      print('indirizzo: $indirizzo');
      print('cap: $cap');
      print('codice_fiscale: $codiceFiscale');

      // Mappa i dati ai campi del form
      final prefilledData = <String, String>{};

      // Nome completo
      if (fullName != null && fullName.isNotEmpty) {
        prefilledData['Nome completo'] = fullName;
        prefilledData['Nome e Cognome'] = fullName;
        prefilledData['Nome richiedente'] = fullName;
      }

      // Email
      if (email != null) {
        prefilledData['Email'] = email;
        prefilledData['Email richiedente'] = email;
      }

      // Telefono
      if (telefono != null) {
        prefilledData['Telefono'] = telefono;
        prefilledData['Telefono richiedente'] = telefono;
        prefilledData['Numero di telefono'] = telefono;
      }

      // Città
      if (citta != null) {
        prefilledData['Città'] = citta;
        prefilledData['Città di residenza'] = citta;
      }

      // Indirizzo
      if (indirizzo != null) {
        prefilledData['Indirizzo'] = indirizzo;
        prefilledData['Indirizzo di residenza'] = indirizzo;
      }

      // CAP
      if (cap != null) {
        prefilledData['CAP'] = cap;
      }

      // Provincia
      if (provincia != null) {
        prefilledData['Provincia'] = provincia;
      }

      // Codice Fiscale
      if (codiceFiscale != null) {
        prefilledData['Codice Fiscale'] = codiceFiscale;
        prefilledData['Codice fiscale'] = codiceFiscale;
      }

      // Data di nascita
      if (dataNascita != null) {
        prefilledData['Data di nascita'] = dataNascita;
      }

      // Luogo di nascita
      if (luogoNascita != null) {
        prefilledData['Luogo di nascita'] = luogoNascita;
      }

      // Professione
      if (professione != null) {
        prefilledData['Professione'] = professione;
      }

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
                              const Text(
                                'Compila i seguenti campi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                  : const Text(
                                    'Invia richiesta',
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
                      value?.isEmpty ?? true ? 'Campo obbligatorio' : null
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
                      value?.isEmpty ?? true ? 'Campo obbligatorio' : null
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
                      value?.isEmpty ?? true ? 'Campo obbligatorio' : null
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
                      value?.isEmpty ?? true ? 'Campo obbligatorio' : null
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
                  ? (value) => value == null ? 'Campo obbligatorio' : null
                  : null,
          onChanged: (value) => _formData[label] = value,
        );
        break;
      default:
        field = const SizedBox();
    }

    return Padding(padding: const EdgeInsets.only(bottom: 16), child: field);
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
      // Usa il nuovo endpoint API
      final result = await SocioService.inviaRichiestaServizio(
        servizio: widget.servizio,
        categoria: widget.categoria,
        dati: _formData,
      );

      setState(() {
        _isSubmitting = false;
      });

      if (!mounted) return;

      if (result['success'] == true) {
        final numeroPratica = result['numero_pratica'];
        final message =
            numeroPratica != null
                ? 'Richiesta inviata con successo!\n\nNumero pratica: $numeroPratica'
                : result['message'] ?? 'Richiesta inviata con successo';

        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 32),
                    SizedBox(width: 12),
                    Text('Richiesta inviata!'),
                  ],
                ),
                content: Text(
                  message +
                      '\n\nSarai contattato via email per i prossimi passi.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Chiudi dialog
                      Navigator.of(context).pop(); // Torna indietro
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } else {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('❌ Errore'),
                content: Text(result['message'] ?? 'Errore durante l\'invio'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
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

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('❌ Errore'),
              content: Text('Errore di connessione: ${e.toString()}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }
}
