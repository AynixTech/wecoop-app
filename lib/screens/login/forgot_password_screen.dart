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
  bool _usePhone = true;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Password resettata! Controlla la tua email.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('forgotPassword')),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [scheme.surfaceContainerLowest, scheme.surface],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoBanner(context),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            scheme.primary,
                            Color.alphaBlend(
                              scheme.secondary.withOpacity(0.28),
                              scheme.primary,
                            ),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withOpacity(0.24),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lock_reset,
                        size: 46,
                        color: scheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.translate('resetPasswordTitle'),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate('resetPasswordDescription'),
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: scheme.onSurface.withOpacity(0.72),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SegmentedButton<bool>(
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return scheme.primary;
                        }
                        return scheme.surfaceContainerLowest;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return scheme.onPrimary;
                        }
                        return scheme.onSurface.withOpacity(0.78);
                      }),
                      side: WidgetStatePropertyAll(
                        BorderSide(color: scheme.primary.withOpacity(0.18)),
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
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
                        _phoneController.clear();
                        _emailController.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_usePhone)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final useVerticalLayout = constraints.maxWidth < 360;
                        final prefixField = SizedBox(
                          width: useVerticalLayout ? double.infinity : 108,
                          child: TextFormField(
                            controller: _prefixController,
                            keyboardType: TextInputType.phone,
                            decoration: _buildFieldDecoration(
                              context,
                              labelText: l10n.translate('prefix'),
                              hintText: '+39',
                              icon: Icons.flag,
                            ),
                          ),
                        );

                        final phoneField = TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _buildFieldDecoration(
                            context,
                            labelText: l10n.translate('phoneNumber'),
                            hintText: '3891733185',
                            helperText: 'Es: 3891733185',
                            icon: Icons.phone,
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
                        );

                        if (useVerticalLayout) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              prefixField,
                              const SizedBox(height: 12),
                              phoneField,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            prefixField,
                            const SizedBox(width: 12),
                            Expanded(child: phoneField),
                          ],
                        );
                      },
                    )
                  else
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildFieldDecoration(
                        context,
                        labelText: l10n.email,
                        hintText: l10n.translate('enterEmail'),
                        icon: Icons.email,
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
                  ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      elevation: 0,
                      shadowColor: scheme.primary.withOpacity(0.24),
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      l10n.translate('backToLogin'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        scheme.primary.withOpacity(0.08),
                        Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: scheme.primary.withOpacity(0.18)),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: scheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.translate('helpTitle'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.translate('resetPasswordHelp'),
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: scheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildFieldDecoration(
    BuildContext context, {
    required String labelText,
    String? hintText,
    String? helperText,
    required IconData icon,
  }) {
    final scheme = Theme.of(context).colorScheme;

    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      helperStyle: TextStyle(
        fontSize: 11,
        color: scheme.onSurface.withOpacity(0.5),
      ),
      filled: true,
      fillColor: scheme.surfaceContainerLowest,
      prefixIcon: Icon(icon, color: scheme.primary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: border(Colors.black.withOpacity(0.08)),
      enabledBorder: border(Colors.black.withOpacity(0.08)),
      focusedBorder: border(scheme.primary.withOpacity(0.75), width: 1.4),
      errorBorder: border(Colors.red.withOpacity(0.45)),
      focusedErrorBorder: border(Colors.red.withOpacity(0.7), width: 1.4),
      labelStyle: TextStyle(color: scheme.onSurface.withOpacity(0.72)),
      hintStyle: TextStyle(color: scheme.onSurface.withOpacity(0.38)),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.alphaBlend(
              scheme.secondary.withOpacity(0.28),
              scheme.primary,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.onPrimary.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: scheme.onPrimary.withOpacity(0.25),
              ),
            ),
            child: Icon(Icons.key_outlined, color: scheme.onPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.translate('resetPasswordDescription'),
              style: TextStyle(
                color: scheme.onPrimary,
                fontSize: 15,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
