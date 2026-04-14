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

  bool get _isResetFlow =>
      widget.resetToken != null && widget.resetToken!.isNotEmpty;

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

    final l10n = AppLocalizations.of(context)!;

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
            content: Text(result['message'] ?? l10n.translate('passwordChangedSuccess')),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 3),
          ),
        );

        // Torna indietro dopo 1 secondo
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          if (_isResetFlow) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          } else {
            Navigator.pop(context, true);
          }
        }
      } else {
        // Errore
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? l10n.translate('changePasswordError')),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.connectionError}: $e'),
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
      appBar: AppBar(title: Text(l10n.translate('changePassword'))),
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
                        _isResetFlow ? Icons.lock_reset : Icons.security,
                        size: 46,
                        color: scheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.translate('changePasswordTitle'),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.translate('changePasswordDescription'),
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: scheme.onSurface.withOpacity(0.72),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (!_isResetFlow) ...[
                    TextFormField(
                      controller: _oldPasswordController,
                      obscureText: !_showOldPassword,
                      decoration: _buildFieldDecoration(
                        context,
                        labelText: l10n.translate('currentPassword'),
                        hintText: l10n.translate('enterCurrentPassword'),
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showOldPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: scheme.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _showOldPassword = !_showOldPassword;
                            });
                          },
                        ),
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
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: !_showNewPassword,
                    decoration: _buildFieldDecoration(
                      context,
                      labelText: l10n.translate('newPassword'),
                      hintText: l10n.translate('enterNewPassword'),
                      helperText: l10n.translate('passwordMinLength'),
                      icon: Icons.lock,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: scheme.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            _showNewPassword = !_showNewPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.translate('enterNewPassword');
                      }
                      if (value.length < 6) {
                        return l10n.translate('passwordTooShort');
                      }
                      if (!_isResetFlow &&
                          value == _oldPasswordController.text) {
                        return l10n.translate('passwordMustBeDifferent');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_showConfirmPassword,
                    decoration: _buildFieldDecoration(
                      context,
                      labelText: l10n.translate('confirmPassword'),
                      hintText: l10n.translate('confirmNewPassword'),
                      icon: Icons.lock,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: scheme.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword;
                          });
                        },
                      ),
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
                  ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
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
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              l10n.translate('changePassword'),
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
                      border: Border.all(
                        color: scheme.primary.withOpacity(0.18),
                      ),
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
                                l10n.translate('passwordTips'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.primary,
                                ),
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
    Widget? suffixIcon,
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
      suffixIcon: suffixIcon,
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
              border: Border.all(color: scheme.onPrimary.withOpacity(0.25)),
            ),
            child: Icon(
              _isResetFlow ? Icons.lock_reset_outlined : Icons.shield_outlined,
              color: scheme.onPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isResetFlow
                  ? l10n.translate('resetPasswordHelp')
                  : l10n.translate('changePasswordDescription'),
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

  Widget _buildTip(String text) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: scheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
