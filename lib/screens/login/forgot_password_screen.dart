import 'package:flutter/material.dart';
import '../../services/app_localizations.dart';
import '../../services/socio_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prefixController = TextEditingController(text: '+39');
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _usePhone = true; // true = telefono, false = email

  @override
  void dispose() {
    _prefixController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? phoneToSend;
      if (_usePhone) {
        var phone = _phoneController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
        final prefix = _prefixController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
        
        // Si el número no empieza con el prefijo, lo agregamos
        if (prefix.isNotEmpty && !phone.startsWith(prefix)) {
          phone = prefix + phone;
        }
        phoneToSend = phone;
      }
      
      final result = await SocioService.resetPassword(
        telefono: phoneToSend,
        email: !_usePhone ? _emailController.text.trim() : null,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // Successo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Password resettata! Controlla la tua email.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );

        // Torna alla schermata di login dopo 2 secondi
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        // Errore
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Errore durante il reset della password'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore di connessione: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('forgotPassword')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              
              // Icona
              const Icon(
                Icons.lock_reset,
                size: 80,
                color: Colors.blue,
              ),
              
              const SizedBox(height: 24),
              
              // Titolo
              Text(
                l10n.translate('resetPasswordTitle'),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Descrizione
              Text(
                l10n.translate('resetPasswordDescription'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Toggle Telefono/Email
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment<bool>(
                    value: true,
                    label: Text(l10n.translate('phone')),
                    icon: const Icon(Icons.phone),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    label: Text(l10n.email),
                    icon: const Icon(Icons.email),
                  ),
                ],
                selected: {_usePhone},
                onSelectionChanged: (Set<bool> newSelection) {
                  setState(() {
                    _usePhone = newSelection.first;
                    // Pulisce i campi quando si cambia metodo
                    _phoneController.clear();
                    _emailController.clear();
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Campo Telefono o Email
              if (_usePhone)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        controller: _prefixController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: l10n.translate('prefix'),
                          hintText: '+39',
                          prefixIcon: const Icon(Icons.flag, size: 20),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: l10n.translate('phoneNumber'),
                          hintText: '3891733185',
                          helperText: 'Ej: 3891733185',
                          helperStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                          prefixIcon: const Icon(Icons.phone),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.translate('enterPhoneNumber');
                          }
                          final cleanPhone = value.trim().replaceAll(RegExp(r'[^\d]'), '');
                          if (cleanPhone.length < 8) {
                            return l10n.translate('phoneNumberTooShort');
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                )
              else
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    hintText: l10n.translate('enterEmail'),
                    prefixIcon: const Icon(Icons.email),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.translate('enterEmail');
                    }
                    if (!value.contains('@')) {
                      return l10n.translate('invalidEmail');
                    }
                    return null;
                  },
                ),
              
              const SizedBox(height: 32),
              
              // Pulsante Reset
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        l10n.translate('resetPassword'),
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // Link torna al login
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(l10n.translate('backToLogin')),
              ),
              
              const SizedBox(height: 24),
              
              // Informazioni
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          l10n.translate('helpTitle'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.translate('resetPasswordHelp'),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
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
