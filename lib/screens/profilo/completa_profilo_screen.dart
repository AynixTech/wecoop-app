import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/app_localizations.dart';
import '../../services/socio_service.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class CompletaProfiloScreen extends StatefulWidget {
  const CompletaProfiloScreen({super.key});

  @override
  State<CompletaProfiloScreen> createState() => _CompletaProfiloScreenState();
}

class _CompletaProfiloScreenState extends State<CompletaProfiloScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  bool _isSubmitting = false;
  int _currentStep = 0;

  // Controllers
  final _emailController = TextEditingController();
  final _codiceFiscaleController = TextEditingController();
  final _dataNascitaController = TextEditingController();
  final _luogoNascitaController = TextEditingController();
  final _indirizzoController = TextEditingController();
  final _cittaController = TextEditingController();
  final _capController = TextEditingController();
  final _provinciaController = TextEditingController();
  final _professioneController = TextEditingController();

  File? _cartaIdentita;
  File? _documentoCodiceFiscale;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final userData = await SocioService.getMeData();
    if (userData != null && userData['success'] == true) {
      final data = userData['data'];
      setState(() {
        _emailController.text = data['email'] ?? '';
        _codiceFiscaleController.text = data['codice_fiscale'] ?? '';
        
        // Converti data da YYYY-MM-DD a DD/MM/YYYY se presente
        final dataNascita = data['data_nascita'] ?? '';
        if (dataNascita.isNotEmpty && dataNascita.contains('-')) {
          final parts = dataNascita.split('-');
          if (parts.length == 3) {
            _dataNascitaController.text = '${parts[2]}/${parts[1]}/${parts[0]}';
          } else {
            _dataNascitaController.text = dataNascita;
          }
        } else {
          _dataNascitaController.text = dataNascita;
        }
        
        _luogoNascitaController.text = data['luogo_nascita'] ?? '';
        _indirizzoController.text = data['indirizzo'] ?? '';
        _cittaController.text = data['citta'] ?? '';
        _capController.text = data['cap'] ?? '';
        _provinciaController.text = data['provincia'] ?? '';
        _professioneController.text = data['professione'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codiceFiscaleController.dispose();
    _dataNascitaController.dispose();
    _luogoNascitaController.dispose();
    _indirizzoController.dispose();
    _cittaController.dispose();
    _capController.dispose();
    _provinciaController.dispose();
    _professioneController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String tipo) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        if (tipo == 'carta_identita') {
          _cartaIdentita = File(result.files.single.path!);
        } else {
          _documentoCodiceFiscale = File(result.files.single.path!);
        }
      });
    }
  }

  Future<void> _uploadDocumenti() async {
    if (_cartaIdentita != null) {
      await SocioService.uploadDocumento(
        file: _cartaIdentita!,
        tipoDocumento: 'carta_identita',
      );
    }
    if (_documentoCodiceFiscale != null) {
      await SocioService.uploadDocumento(
        file: _documentoCodiceFiscale!,
        tipoDocumento: 'codice_fiscale',
      );
    }
  }

  Future<void> _completaProfilo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Converti data da DD/MM/YYYY a YYYY-MM-DD per l'API
      String? dataNascitaApi;
      final dataInput = _dataNascitaController.text.trim();
      if (dataInput.isNotEmpty && dataInput.contains('/')) {
        final parts = dataInput.split('/');
        if (parts.length == 3) {
          dataNascitaApi = '${parts[2]}-${parts[1]}-${parts[0]}';
        } else {
          dataNascitaApi = dataInput;
        }
      } else if (dataInput.isNotEmpty) {
        dataNascitaApi = dataInput;
      }

      final result = await SocioService.completaProfilo(
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        codiceFiscale: _codiceFiscaleController.text.trim().isEmpty ? null : _codiceFiscaleController.text.trim(),
        dataNascita: dataNascitaApi,
        luogoNascita: _luogoNascitaController.text.trim().isEmpty ? null : _luogoNascitaController.text.trim(),
        indirizzo: _indirizzoController.text.trim().isEmpty ? null : _indirizzoController.text.trim(),
        citta: _cittaController.text.trim().isEmpty ? null : _cittaController.text.trim(),
        cap: _capController.text.trim().isEmpty ? null : _capController.text.trim(),
        provincia: _provinciaController.text.trim().isEmpty ? null : _provinciaController.text.trim(),
        professione: _professioneController.text.trim().isEmpty ? null : _professioneController.text.trim(),
      );

      if (result['success'] == true) {
        // Upload documenti se presenti
        await _uploadDocumenti();

        // Aggiorna flag profilo_completo in storage
        if (result['data']['profilo_completo'] == true) {
          await _storage.write(key: 'profilo_completo', value: 'true');
        }

        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Profilo aggiornato'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true); // Ritorna true per aggiornare la schermata precedente
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Errore'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.completeProfile),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _completaProfilo();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_currentStep == 2 ? l10n.complete : l10n.next),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: Text(l10n.back),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // Step 1: Dati Personali
            Step(
              title: Text(l10n.personalData),
              content: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: '${l10n.email} *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.requiredField;
                      }
                      if (!value.contains('@')) {
                        return l10n.invalidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _codiceFiscaleController,
                    decoration: InputDecoration(
                      labelText: '${l10n.fiscalCode} *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.badge),
                    ),
                    maxLength: 16,
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.requiredField;
                      }
                      if (value.length != 16) {
                        return l10n.fiscalCodeMustBe16Chars;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dataNascitaController,
                    decoration: InputDecoration(
                      labelText: l10n.birthDate,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                      hintText: 'DD/MM/YYYY',
                      helperText: 'Es: 13/07/1994',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                      LengthLimitingTextInputFormatter(10),
                      _DateInputFormatter(),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return null; // Campo opzionale
                      }
                      // Valida formato DD/MM/YYYY
                      if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                        return 'Formato non valido (DD/MM/YYYY)';
                      }
                      // Valida che sia una data reale
                      final parts = value.split('/');
                      final day = int.tryParse(parts[0]);
                      final month = int.tryParse(parts[1]);
                      final year = int.tryParse(parts[2]);
                      
                      if (day == null || month == null || year == null) {
                        return 'Data non valida';
                      }
                      if (day < 1 || day > 31) {
                        return 'Giorno non valido';
                      }
                      if (month < 1 || month > 12) {
                        return 'Mese non valido';
                      }
                      if (year < 1900 || year > DateTime.now().year) {
                        return 'Anno non valido';
                      }
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _luogoNascitaController,
                    decoration: InputDecoration(
                      labelText: l10n.birthPlace,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.location_city),
                    ),
                  ),
                ],
              ),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            
            // Step 2: Indirizzo
            Step(
              title: Text(l10n.address),
              content: Column(
                children: [
                  TextFormField(
                    controller: _indirizzoController,
                    decoration: InputDecoration(
                      labelText: l10n.address,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.home),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _cittaController,
                          decoration: InputDecoration(
                            labelText: l10n.city,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _capController,
                          decoration: InputDecoration(
                            labelText: l10n.postalCode,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _provinciaController,
                          decoration: InputDecoration(
                            labelText: l10n.province,
                            border: const OutlineInputBorder(),
                          ),
                          maxLength: 2,
                          textCapitalization: TextCapitalization.characters,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _professioneController,
                          decoration: InputDecoration(
                            labelText: l10n.profession,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            
            // Step 3: Documenti
            Step(
              title: Text(l10n.documents),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.uploadDocumentsOptional,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentPicker(
                    label: l10n.identityCard,
                    file: _cartaIdentita,
                    onTap: () => _pickFile('carta_identita'),
                  ),
                  const SizedBox(height: 12),
                  _buildDocumentPicker(
                    label: l10n.fiscalCodeDocument,
                    file: _documentoCodiceFiscale,
                    onTap: () => _pickFile('codice_fiscale'),
                  ),
                ],
              ),
              isActive: _currentStep >= 2,
              state: StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPicker({
    required String label,
    required File? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              file != null ? Icons.check_circle : Icons.upload_file,
              color: file != null ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (file != null)
                    Text(
                      file.path.split('/').last,
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    )
                  else
                    const Text(
                      'PDF, JPG, PNG (max 5MB)',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

// Formatter per input data DD/MM/YYYY
class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Rimuovi tutti i caratteri non numerici
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Formatta automaticamente con /
    String formatted = '';
    for (int i = 0; i < digitsOnly.length && i < 8; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      formatted += digitsOnly[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
