import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import '../../services/socio_service.dart';
import '../login/login_screen.dart';

class AdesioneSocioScreen extends StatefulWidget {
  const AdesioneSocioScreen({super.key});

  @override
  State<AdesioneSocioScreen> createState() => _AdesioneSocioScreenState();
}

class _AdesioneSocioScreenState extends State<AdesioneSocioScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Controllers per i campi OBBLIGATORI
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _prefissoController = TextEditingController(text: '+39');
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedNazionalita;
  bool _privacyAccepted = false;
  
  // Controllers per i campi OPZIONALI
  final _codiceFiscaleController = TextEditingController();
  final _dataNascitaController = TextEditingController();
  final _luogoNascitaController = TextEditingController();
  final _indirizzoController = TextEditingController();
  final _cittaController = TextEditingController();
  final _capController = TextEditingController();
  final _provinciaController = TextEditingController();
  final _professioneController = TextEditingController();
  
  // Lista nazionalità (ISO 3166-1 alpha-2)
  static const List<Map<String, String>> _nazionalita = [
    {'code': 'EC', 'name': '🇪🇨 Ecuador'},
    {'code': 'PE', 'name': '🇵🇪 Perù'},
    {'code': 'IT', 'name': '🇮🇹 Italia'},
    {'code': 'ES', 'name': '🇪🇸 Spagna'},
    {'code': 'FR', 'name': '🇫🇷 Francia'},
    {'code': 'DE', 'name': '🇩🇪 Germania'},
    {'code': 'GB', 'name': '🇬🇧 Regno Unito'},
    {'code': 'US', 'name': '🇺🇸 Stati Uniti'},
    {'code': 'BR', 'name': '🇧🇷 Brasile'},
    {'code': 'AR', 'name': '🇦🇷 Argentina'},
    {'code': 'CO', 'name': '🇨🇴 Colombia'},
    {'code': 'VE', 'name': '🇻🇪 Venezuela'},
    {'code': 'RO', 'name': '🇷🇴 Romania'},
    {'code': 'PL', 'name': '🇵🇱 Polonia'},
    {'code': 'UA', 'name': '🇺🇦 Ucraina'},
    {'code': 'MA', 'name': '🇲🇦 Marocco'},
    {'code': 'AL', 'name': '🇦🇱 Albania'},
    {'code': 'PH', 'name': '🇵🇭 Filippine'},
    {'code': 'CN', 'name': '🇨🇳 Cina'},
    {'code': 'IN', 'name': '🇮🇳 India'},
  ];



  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _prefissoController.dispose();
    _telefonoController.dispose();
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

  Future<void> _submitAdesione() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedNazionalita == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.translate('selectNationality')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!_privacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.translate('privacyRequired')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await SocioService.richiestaAdesioneSocio(
      nome: _nomeController.text.trim(),
      cognome: _cognomeController.text.trim(),
      prefix: _prefissoController.text.trim(),
      telefono: _telefonoController.text.trim(),
      nazionalita: _selectedNazionalita!,
      email: _emailController.text.trim(),
      privacyAccepted: _privacyAccepted,
      // Campi opzionali
      codiceFiscale: _codiceFiscaleController.text.trim().isNotEmpty
          ? _codiceFiscaleController.text.trim().toUpperCase()
          : null,
      dataNascita: _dataNascitaController.text.trim().isNotEmpty
          ? _dataNascitaController.text.trim()
          : null,
      luogoNascita: _luogoNascitaController.text.trim().isNotEmpty
          ? _luogoNascitaController.text.trim()
          : null,
      indirizzo: _indirizzoController.text.trim().isNotEmpty
          ? _indirizzoController.text.trim()
          : null,
      citta: _cittaController.text.trim().isNotEmpty
          ? _cittaController.text.trim()
          : null,
      cap: _capController.text.trim().isNotEmpty
          ? _capController.text.trim()
          : null,
      provincia: _provinciaController.text.trim().isNotEmpty
          ? _provinciaController.text.trim()
          : null,
      professione: _professioneController.text.trim().isNotEmpty
          ? _professioneController.text.trim()
          : null,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    final success = result['success'] == true;
    final message = result['message'] ?? 'Operazione completata';

    if (success) {
      if (!mounted) return;
      
      // Mostra dialog con credenziali generate
      final username = result['username'] ?? 'N/A';
      final password = result['password'] ?? 'N/A';
      final email = _emailController.text.trim();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) {
              final l10n = AppLocalizations.of(context)!;
              return AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 32),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.registrationCompleted)),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.email, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              email.isNotEmpty 
                                ? '${l10n.translate('credentialsSentTo')} $email'
                                : l10n.translate('credentialsSentViaEmail'),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.saveTheseCredentials,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.translate('useTheseCredentials'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${l10n.username} (${l10n.translate('fullPhoneNumber')})',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  SelectableText(
                                    username,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.password,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  SelectableText(
                                    password,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Chiudi dialog
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.iHaveSaved),
                  ),
                ],
              );
            },
      );
    } else {
      final l10n = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 32),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.error)),
                ],
              ),
              content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.becomeMember)),
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
                                Text(
                                  l10n.whyBecomeMember,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '• ${l10n.translate('accessToAllServices')}\n'
                              '• ${l10n.translate('dedicatedSupport')}\n'
                              '• ${l10n.translate('fiscalConsultancy')}\n'
                              '• ${l10n.translate('eventsParticipation')}\n'
                              '• ${l10n.translate('supportNetwork')}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        '${l10n.personalInfo} *',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.translate('requiredFieldsForRegistration'),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nomeController,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: '${l10n.name} *',
                          border: const OutlineInputBorder(),
                        ),
                        validator:
                            (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.fillAllFields;
                              }
                              if (value.trim().length < 2) {
                                return l10n.translate('nameTooShort');
                              }
                              return null;
                            },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _cognomeController,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: '${l10n.surname} *',
                          border: const OutlineInputBorder(),
                        ),
                        validator:
                            (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.fillAllFields;
                              }
                              if (value.trim().length < 2) {
                                return l10n.translate('surnameTooShort');
                              }
                              return null;
                            },
                      ),
                      const SizedBox(height: 12),

                      // Telefono con prefisso
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              controller: _prefissoController,
                              decoration: InputDecoration(
                                labelText: '${l10n.translate('prefix')} *',
                                border: const OutlineInputBorder(),
                                hintText: '+39',
                                prefixIcon: const Icon(Icons.public),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.translate('required');
                                }
                                if (!value.startsWith('+')) {
                                  return '+?';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _telefonoController,
                              decoration: InputDecoration(
                                labelText: '${l10n.phone} *',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.phone),
                                hintText: '333 1234567',
                                helperStyle: const TextStyle(fontSize: 10),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.fillAllFields;
                                }
                                final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
                                if (cleaned.length < 8) {
                                  return l10n.translate('numberTooShort');
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: _selectedNazionalita,
                        decoration: InputDecoration(
                          labelText: '${l10n.translate('nationality')} *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.public),
                          helperText: l10n.translate('selectYourCountryOfOrigin'),
                        ),
                        items: _nazionalita.map((country) {
                          return DropdownMenuItem<String>(
                            value: country['code'],
                            child: Text(country['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedNazionalita = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.translate('selectNationality');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: '${l10n.email} *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.email),
                          hintText: 'esempio@email.com',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.fillAllFields;
                          }
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value)) {
                            return l10n.translate('invalidEmail');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Privacy Checkbox
                      CheckboxListTile(
                        value: _privacyAccepted,
                        onChanged: (value) {
                          setState(() {
                            _privacyAccepted = value ?? false;
                          });
                        },
                        title: Text(
                          l10n.translate('iAcceptDataProcessing'),
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          l10n.translate('dataWillBeProcessed'),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 24),

                      // Campi Opzionali
                      ExpansionTile(
                        title: Text(
                          '${l10n.additionalInfo} (opzionale)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          l10n.translate('fillToSpeedUp'),
                          style: const TextStyle(fontSize: 12),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _codiceFiscaleController,
                                  decoration: InputDecoration(
                                    labelText: l10n.fiscalCode,
                                    border: const OutlineInputBorder(),
                                  ),
                                  textCapitalization: TextCapitalization.characters,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty && value.length != 16) {
                                      return l10n.translate('fiscalCodeMustBe16Chars');
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _dataNascitaController,
                                  decoration: InputDecoration(
                                    labelText: l10n.birthDate,
                                    border: const OutlineInputBorder(),
                                    hintText: l10n.dateFormat,
                                    suffixIcon: const Icon(Icons.calendar_today),
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
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _luogoNascitaController,
                                  decoration: InputDecoration(
                                    labelText: l10n.translate('birthPlace'),
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _indirizzoController,
                                  decoration: InputDecoration(
                                    labelText: l10n.address,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
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
                                        validator: (value) {
                                          if (value != null && value.isNotEmpty && value.length != 5) {
                                            return l10n.translate('invalidPostalCode');
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _provinciaController,
                                  decoration: InputDecoration(
                                    labelText: l10n.translate('province'),
                                    border: const OutlineInputBorder(),
                                    hintText: l10n.translate('provinceExample'),
                                  ),
                                  textCapitalization: TextCapitalization.characters,
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _professioneController,
                                  decoration: InputDecoration(
                                    labelText: l10n.translate('profession'),
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pulsante per andare al login
                    // TextButton.icon(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => const LoginScreen(),
                    //       ),
                    //     );
                    //   },
                    //   icon: const Icon(Icons.login),
                    //   label: Text(
                    //     l10n.translate('alreadyRegisteredLogin'),
                    //     style: const TextStyle(fontSize: 14),
                    //   ),
                    //   style: TextButton.styleFrom(
                    //     foregroundColor: const Color(0xFF2196F3),
                    //   ),
                    // ),
                    const SizedBox(height: 12),
                    // Pulsante di invio richiesta
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitAdesione,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 0),
                      ),
                      child: _isSubmitting
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
                              l10n.sendRequest,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// TextInputFormatter che converte tutto il testo in maiuscolo
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
