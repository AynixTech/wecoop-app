import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/socio_service.dart';
import '../login/login_screen.dart';

class AdesioneSocioScreen extends StatefulWidget {
  const AdesioneSocioScreen({super.key});

  @override
  State<AdesioneSocioScreen> createState() => _AdesioneSocioScreenState();
}

class _AdesioneSocioScreenState extends State<AdesioneSocioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  bool _isSubmitting = false;

  // 🧪 FLAG DEBUG: Imposta a true per precompilare i campi con dati di test
  static const bool _useTestData = true;

  // Controllers per i campi del form
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _codiceFiscaleController = TextEditingController();
  final _dataNascitaController = TextEditingController();
  final _luogoNascitaController = TextEditingController();
  final _indirizzoController = TextEditingController();
  final _cittaController = TextEditingController();
  final _capController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _professioneController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_useTestData) {
      _loadTestData();
    }
  }

  void _loadTestData() {
    _nomeController.text = 'Jordan';
    _cognomeController.text = 'Avila';
    _codiceFiscaleController.text = 'VLGGGN94L13Z605E';
    _dataNascitaController.text = '13/07/1994';
    _luogoNascitaController.text = 'Roma';
    _indirizzoController.text = 'Via Roma 123';
    _cittaController.text = 'Milano';
    _capController.text = '20100';
    _telefonoController.text = '+39 3891733185';
    _emailController.text = 'jordanavila1394gmail.com';
    _professioneController.text = 'Ingegnere';
    _noteController.text = 'Voglio contribuire alla cooperativa sociale';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _codiceFiscaleController.dispose();
    _dataNascitaController.dispose();
    _luogoNascitaController.dispose();
    _indirizzoController.dispose();
    _cittaController.dispose();
    _capController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _professioneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitAdesione() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Prima controlla se l'email è già registrata
    final email = _emailController.text.trim();
    final emailExists = await _checkEmailExists(email);

    if (emailExists) {
      setState(() {
        _isSubmitting = false;
      });
      if (!mounted) return;
      _showEmailExistsDialog();
      return;
    }

    final result = await SocioService.richiestaAdesioneSocio(
      nome: _nomeController.text.trim(),
      cognome: _cognomeController.text.trim(),
      codiceFiscale: _codiceFiscaleController.text.trim().toUpperCase(),
      dataNascita: _dataNascitaController.text.trim(),
      luogoNascita: _luogoNascitaController.text.trim(),
      indirizzo: _indirizzoController.text.trim(),
      citta: _cittaController.text.trim(),
      cap: _capController.text.trim(),
      telefono: _telefonoController.text.trim(),
      email: _emailController.text.trim(),
      professione: _professioneController.text.trim(),
      motivazione: _noteController.text.trim(),
    );

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    final success = result['success'] == true;
    final message = result['message'] ?? 'Operazione completata';

    if (success) {
      // Salva l'email localmente per verifiche future
      final email = _emailController.text.trim();
      await _storage.write(key: 'pending_socio_email', value: email);

      if (!mounted) return;

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
                    '\n\nRiceverai una conferma via email entro 24-48 ore.\n\n'
                        'Una volta approvata, potrai accedere a tutti i servizi riservati ai soci.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Chiudi dialog
                    Navigator.of(
                      context,
                    ).pop(); // Torna alla schermata precedente
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
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 32),
                  SizedBox(width: 12),
                  Expanded(child: Text('Errore')),
                ],
              ),
              content: Text(message),
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

  /// Controlla se l'email esiste già nel sistema
  Future<bool> _checkEmailExists(String email) async {
    try {
      // Chiama direttamente l'endpoint di verifica
      final encodedEmail = Uri.encodeComponent(email);
      final url = '${SocioService.baseUrl}/soci/verifica/$encodedEmail';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Se is_socio è true, l'email esiste già
        return data['is_socio'] == true;
      }
      return false;
    } catch (e) {
      print('Errore controllo email: $e');
      return false;
    }
  }

  /// Mostra dialog quando l'email esiste già
  void _showEmailExistsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 32),
                SizedBox(width: 12),
                Expanded(child: Text('Email già registrata')),
              ],
            ),
            content: const Text(
              'Questa email è già registrata nel sistema.\n\n'
              'Sei già un socio WECOOP! Effettua il login per accedere ai servizi.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annulla'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Chiudi dialog
                  Navigator.of(context).pop(); // Chiudi form adesione
                  // Vai al login
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Vai al Login'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diventa Socio WECOOP')),
      body: SafeArea(
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
                      // Intestazione informativa
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.amber.shade700,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Perché diventare socio?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '• Accesso a tutti i servizi di assistenza\n'
                              '• Supporto dedicato per pratiche burocratiche\n'
                              '• Consulenza fiscale e contabile\n'
                              '• Partecipazione a eventi e progetti\n'
                              '• Rete di supporto e comunità',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Dati Personali',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome *',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Campo obbligatorio'
                                    : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _cognomeController,
                        decoration: const InputDecoration(
                          labelText: 'Cognome *',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Campo obbligatorio'
                                    : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _codiceFiscaleController,
                        decoration: const InputDecoration(
                          labelText: 'Codice Fiscale *',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Campo obbligatorio';
                          }
                          if (value!.length != 16) {
                            return 'Il codice fiscale deve essere di 16 caratteri';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _dataNascitaController,
                        decoration: const InputDecoration(
                          labelText: 'Data di Nascita *',
                          border: OutlineInputBorder(),
                          hintText: 'gg/mm/aaaa',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime(1990),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            _dataNascitaController.text =
                                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                          }
                        },
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Campo obbligatorio'
                                    : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _luogoNascitaController,
                        decoration: const InputDecoration(
                          labelText: 'Luogo di Nascita *',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Campo obbligatorio'
                                    : null,
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Residenza',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _indirizzoController,
                        decoration: const InputDecoration(
                          labelText: 'Indirizzo *',
                          border: OutlineInputBorder(),
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
                              controller: _cittaController,
                              decoration: const InputDecoration(
                                labelText: 'Città *',
                                border: OutlineInputBorder(),
                              ),
                              validator:
                                  (value) =>
                                      value?.isEmpty ?? true
                                          ? 'Obbligatorio'
                                          : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _capController,
                              decoration: const InputDecoration(
                                labelText: 'CAP *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Obbligatorio';
                                }
                                if (value!.length != 5) {
                                  return 'CAP non valido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Contatti',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _telefonoController,
                        decoration: const InputDecoration(
                          labelText: 'Telefono *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Campo obbligatorio'
                                    : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Campo obbligatorio';
                          }
                          if (!value!.contains('@')) {
                            return 'Email non valida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Informazioni Aggiuntive',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _professioneController,
                        decoration: const InputDecoration(
                          labelText: 'Professione (opzionale)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'Note (opzionale)',
                          border: OutlineInputBorder(),
                          hintText: 'Eventuali informazioni aggiuntive',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.privacy_tip_outlined,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'I tuoi dati saranno trattati secondo la normativa sulla privacy',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottone fisso in basso
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
                  onPressed: _isSubmitting ? null : _submitAdesione,
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
                            'Invia richiesta di adesione',
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
}
