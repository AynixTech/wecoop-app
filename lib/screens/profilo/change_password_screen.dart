import 'package:flutter/material.dart';
import '../../services/app_localizations.dart';
import '../../services/socio_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String? resetToken;

  const ChangePasswordScreen({super.key, this.resetToken});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  bool get _isResetFlow => widget.resetToken != null && widget.resetToken!.isNotEmpty;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result =
          _isResetFlow
              ? await SocioService.confirmPasswordReset(
                token: widget.resetToken!,
                newPassword: _newPasswordController.text,
              )
              : await SocioService.changePassword(
                oldPassword: _oldPasswordController.text,
                newPassword: _newPasswordController.text,
              );

      if (!mounted) return;

      if (result['success'] == true) {
        // Successo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Password cambiata con successo!',
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 3),
          ),
        );

        // Torna indietro dopo 1 secondo
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          if (_isResetFlow) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          } else {
            Navigator.pop(context, true);
          }
        }
      } else {
        // Errore
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Errore durante il cambio password',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore di connessione: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
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
        title: Text(l10n.translate('changePassword')),
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
              Icon(Icons.security, size: 80, color: scheme.primary),

              const SizedBox(height: 24),

              // Titolo
              Text(
                l10n.translate('changePasswordTitle'),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Descrizione
              Text(
                l10n.translate('changePasswordDescription'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              if (!_isResetFlow) ...[
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: !_showOldPassword,
                  decoration: InputDecoration(
                    labelText: l10n.translate('currentPassword'),
                    hintText: l10n.translate('enterCurrentPassword'),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showOldPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _showOldPassword = !_showOldPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.translate('enterCurrentPassword');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Nuova Password
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_showNewPassword,
                decoration: InputDecoration(
                  labelText: l10n.translate('newPassword'),
                  hintText: l10n.translate('enterNewPassword'),
                  helperText: l10n.translate('passwordMinLength'),
                  helperStyle: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _showNewPassword = !_showNewPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.translate('enterNewPassword');
                  }
                  if (value.length < 6) {
                    return l10n.translate('passwordTooShort');
                  }
                  if (!_isResetFlow && value == _oldPasswordController.text) {
                    return l10n.translate('passwordMustBeDifferent');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Conferma Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(
                  labelText: l10n.translate('confirmPassword'),
                  hintText: l10n.translate('confirmNewPassword'),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.translate('confirmNewPassword');
                  }
                  if (value != _newPasswordController.text) {
                    return l10n.translate('passwordsDoNotMatch');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Pulsante Cambia Password
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
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
                          l10n.translate('changePassword'),
                          style: const TextStyle(fontSize: 16),
                        ),
              ),

              const SizedBox(height: 24),

              // Consigli sicurezza
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: scheme.secondary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: scheme.secondary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.translate('passwordTips'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: scheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip(l10n.translate('passwordTip1')),
                    _buildTip(l10n.translate('passwordTip2')),
                    _buildTip(l10n.translate('passwordTip3')),
                    _buildTip(l10n.translate('passwordTip4')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: scheme.secondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
