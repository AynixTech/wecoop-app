import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
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
  final _storage = SecureStorageService();
  bool _isSubmitting = false;
  bool _isLoading = true;
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
    setState(() => _isLoading = true);

    try {
      final userData = await SocioService.getMeData();
      if (userData != null && userData['success'] == true) {
        final data = userData['data'];
        if (mounted) {
          setState(() {
            _emailController.text = data['email'] ?? '';
            _codiceFiscaleController.text = data['codice_fiscale'] ?? '';

            // Converti data da YYYY-MM-DD a DD/MM/YYYY se presente
            final dataNascita = data['data_nascita'] ?? '';
            if (dataNascita.isNotEmpty && dataNascita.contains('-')) {
              final parts = dataNascita.split('-');
              if (parts.length == 3) {
                _dataNascitaController.text =
                    '${parts[2]}/${parts[1]}/${parts[0]}';
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
    } catch (e) {
      print('Errore caricamento dati: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        email:
            _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
        codiceFiscale:
            _codiceFiscaleController.text.trim().isEmpty
                ? null
                : _codiceFiscaleController.text.trim(),
        dataNascita: dataNascitaApi,
        luogoNascita:
            _luogoNascitaController.text.trim().isEmpty
                ? null
                : _luogoNascitaController.text.trim(),
        indirizzo:
            _indirizzoController.text.trim().isEmpty
                ? null
                : _indirizzoController.text.trim(),
        citta:
            _cittaController.text.trim().isEmpty
                ? null
                : _cittaController.text.trim(),
        cap:
            _capController.text.trim().isEmpty
                ? null
                : _capController.text.trim(),
        provincia:
            _provinciaController.text.trim().isEmpty
                ? null
                : _provinciaController.text.trim(),
        professione:
            _professioneController.text.trim().isEmpty
                ? null
                : _professioneController.text.trim(),
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

        Navigator.pop(
          context,
          true,
        ); // Ritorna true per aggiornare la schermata precedente
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
        SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      // Valida solo i campi dello step corrente
      bool isValid = true;
      if (_currentStep == 0) {
        // Valida email e codice fiscale
        if (_emailController.text.trim().isEmpty ||
            !_emailController.text.contains('@')) {
          isValid = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.invalidEmail),
              backgroundColor: Colors.orange,
            ),
          );
        }
        if (_codiceFiscaleController.text.trim().length != 16) {
          isValid = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.fiscalCodeMustBe16Chars,
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      if (isValid) {
        setState(() => _currentStep++);
      }
    } else {
      _completaProfilo();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(l10n.completeProfile),
        elevation: 0,
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Caricamento dati...'),
                  ],
                ),
              )
              : Column(
                children: [
                  // Progress Indicator
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildStepIndicator(
                              0,
                              l10n.personalData,
                              Icons.person,
                            ),
                            _buildStepConnector(0),
                            _buildStepIndicator(1, l10n.address, Icons.home),
                            _buildStepConnector(1),
                            _buildStepIndicator(
                              2,
                              l10n.documents,
                              Icons.description,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (_currentStep + 1) / 3,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF2196F3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildStepContent(_currentStep, l10n),
                        ),
                      ),
                    ),
                  ),

                  // Navigation Buttons
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: SafeArea(
                      child: Row(
                        children: [
                          if (_currentStep > 0)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isSubmitting ? null : _previousStep,
                                icon: const Icon(Icons.arrow_back),
                                label: Text(l10n.back),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFF2196F3),
                                  ),
                                  foregroundColor: const Color(0xFF2196F3),
                                ),
                              ),
                            ),
                          if (_currentStep > 0) const SizedBox(width: 12),
                          Expanded(
                            flex: _currentStep == 0 ? 1 : 1,
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting ? null : _nextStep,
                              icon:
                                  _isSubmitting
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : Icon(
                                        _currentStep == 2
                                            ? Icons.check
                                            : Icons.arrow_forward,
                                      ),
                              label: Text(
                                _currentStep == 2 ? l10n.complete : l10n.next,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  isCompleted
                      ? Colors.green
                      : isActive
                      ? const Color(0xFF2196F3)
                      : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isCompleted || isActive ? Colors.white : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? const Color(0xFF2196F3) : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = _currentStep > step;

    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 40),
        color: isCompleted ? Colors.green : Colors.grey[300],
      ),
    );
  }

  Widget _buildStepContent(int step, AppLocalizations l10n) {
    switch (step) {
      case 0:
        return _buildPersonalDataStep(l10n);
      case 1:
        return _buildAddressStep(l10n);
      case 2:
        return _buildDocumentsStep(l10n);
      default:
        return Container();
    }
  }

  Widget _buildPersonalDataStep(AppLocalizations l10n) {
    return Card(
      key: const ValueKey(0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person, color: Color(0xFF2196F3)),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.personalData,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '${l10n.email} *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.email),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codiceFiscaleController,
              decoration: InputDecoration(
                labelText: '${l10n.fiscalCode} *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.badge),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLength: 16,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dataNascitaController,
              decoration: InputDecoration(
                labelText: l10n.birthDate,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
                hintText: 'DD/MM/YYYY',
                helperText: 'Es: 13/07/1994',
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                LengthLimitingTextInputFormatter(10),
                _DateInputFormatter(),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _luogoNascitaController,
              decoration: InputDecoration(
                labelText: l10n.birthPlace,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.location_city),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressStep(AppLocalizations l10n) {
    return Card(
      key: const ValueKey(1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.home, color: Color(0xFF2196F3)),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.address,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _indirizzoController,
              decoration: InputDecoration(
                labelText: l10n.address,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.location_on),
                filled: true,
                fillColor: Colors.grey[50],
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _capController,
                    decoration: InputDecoration(
                      labelText: l10n.postalCode,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsStep(AppLocalizations l10n) {
    return Card(
      key: const ValueKey(2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.documents,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.uploadDocumentsOptional,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            _buildDocumentPicker(
              label: l10n.identityCard,
              file: _cartaIdentita,
              onTap: () => _pickFile('carta_identita'),
            ),
            const SizedBox(height: 16),
            _buildDocumentPicker(
              label: l10n.fiscalCodeDocument,
              file: _documentoCodiceFiscale,
              onTap: () => _pickFile('codice_fiscale'),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: file != null ? Colors.green : Colors.grey[300]!,
            width: file != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color:
              file != null ? Colors.green.withOpacity(0.05) : Colors.grey[50],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    file != null
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                file != null ? Icons.check_circle : Icons.upload_file,
                color: file != null ? Colors.green : Colors.grey[600],
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (file != null)
                    Text(
                      file.path.split('/').last,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      'PDF, JPG, PNG (max 5MB)',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
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
