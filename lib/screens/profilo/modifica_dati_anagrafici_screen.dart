import 'package:flutter/material.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/socio_service.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/utils/app_logger.dart';
import 'package:wecoop_app/utils/phone_prefixes.dart';

/// Consente di correggere nome, cognome e telefono dopo il primo accesso.
class ModificaDatiAnagraficiScreen extends StatefulWidget {
  const ModificaDatiAnagraficiScreen({super.key});

  @override
  State<ModificaDatiAnagraficiScreen> createState() =>
      _ModificaDatiAnagraficiScreenState();
}

class _ModificaDatiAnagraficiScreenState
    extends State<ModificaDatiAnagraficiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = SecureStorageService();
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _telefonoController = TextEditingController();

  String _prefix = '+39';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final me = await SocioService.getMeData();
      final data =
          (me != null && me['success'] == true)
              ? (me['data'] as Map?)?.cast<String, dynamic>() ?? {}
              : <String, dynamic>{};

      var nome = (data['nome'] ?? '').toString().trim();
      var cognome = (data['cognome'] ?? '').toString().trim();
      var telefono = (data['telefono'] ?? '').toString().trim();
      var prefixRaw = (data['prefix'] ?? '').toString().trim();
      final phoneFull =
          (data['telefono_completo'] ?? data['phone'] ?? '').toString().trim();

      if (nome.isEmpty) {
        nome = (await _storage.read(key: 'first_name'))?.trim() ?? '';
      }
      if (cognome.isEmpty) {
        cognome = (await _storage.read(key: 'last_name'))?.trim() ?? '';
      }

      // Preferisci numero nazionale; se arriva solo il completo, togli il prefisso.
      var national = telefono.replaceAll(RegExp(r'[^\d]'), '');
      final fullDigits = phoneFull.replaceAll(RegExp(r'[^\d]'), '');
      var prefixDigits = prefixRaw.replaceAll(RegExp(r'[^\d]'), '');
      if (prefixDigits.isEmpty && fullDigits.length >= 10) {
        // Heuristica: +39 IT se inizia con 39 e ha 12 cifre.
        if (fullDigits.startsWith('39') && fullDigits.length >= 11) {
          prefixDigits = '39';
        }
      }
      if (national.isEmpty && fullDigits.isNotEmpty && prefixDigits.isNotEmpty) {
        national =
            fullDigits.startsWith(prefixDigits)
                ? fullDigits.substring(prefixDigits.length)
                : fullDigits;
      }
      national = national.replaceFirst(RegExp(r'^0+'), '');

      final prefixWithPlus =
          prefixDigits.isEmpty
              ? '+39'
              : (prefixDigits.startsWith('+') ? prefixDigits : '+$prefixDigits');
      final matched = PhonePrefixes.prefixes.contains(prefixWithPlus)
          ? prefixWithPlus
          : (PhonePrefixes.prefixes.contains('+$prefixDigits')
              ? '+$prefixDigits'
              : '+39');

      if (!mounted) return;
      setState(() {
        _nomeController.text = nome;
        _cognomeController.text = cognome;
        _telefonoController.text = national;
        _prefix = matched;
        _loading = false;
      });
    } catch (e) {
      AppLogger.d('❌ [ModificaDati] load: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final nome = _nomeController.text.trim();
      final cognome = _cognomeController.text.trim();
      final telefonoLocale = _telefonoController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );
      final loginPhone = PhonePrefixes.normalizeForLogin(
        prefix: _prefix,
        phone: telefonoLocale,
      );

      final result = await SocioService.completaProfilo(
        nome: nome,
        cognome: cognome,
        telefono: telefonoLocale,
        prefix: _prefix.replaceAll(RegExp(r'[^\d]'), ''),
      );

      if (!mounted) return;

      if (result['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (result['message'] ?? l10n.translate('genericError')).toString(),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final data =
          (result['data'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      final savedPhone =
          (data['telefono_completo'] ?? data['phone'] ?? loginPhone)
              .toString()
              .replaceAll(RegExp(r'[^\d]'), '');
      final savedNational =
          (data['telefono'] ?? telefonoLocale).toString().replaceAll(
            RegExp(r'[^\d]'),
            '',
          );

      await _storage.write(key: 'first_name', value: nome);
      await _storage.write(key: 'last_name', value: cognome);
      await _storage.write(key: 'full_name', value: '$nome $cognome'.trim());
      await _storage.write(key: 'nome', value: nome);
      await _storage.write(key: 'cognome', value: cognome);
      // Login / OTP: salva sempre il numero internazionale completo.
      await _storage.write(key: 'telefono', value: savedPhone);
      await _storage.write(key: 'user_phone', value: savedPhone);
      await _storage.write(key: 'telefono_completo', value: savedPhone);
      await _storage.write(key: 'telefono_locale', value: savedNational);
      await _storage.write(
        key: 'prefix',
        value: _prefix.replaceAll(RegExp(r'[^\d]'), ''),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('profileDataUpdated')),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      AppLogger.d('❌ [ModificaDati] save: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.personalData),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    children: [
                      Text(
                        l10n.translate('personalDataSubtitle'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.translate('editNamePhoneHint'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withOpacity(0.55),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nomeController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: l10n.nameRequired,
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().length < 2) {
                            return l10n.translate('nameIsMandatory');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cognomeController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: l10n.surnameRequired,
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().length < 2) {
                            return l10n.translate('surnameIsMandatory');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _prefix,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.prefixRequired,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              PhonePrefixes.flagFor(_prefix),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        items:
                            PhonePrefixes.prefixes
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _prefix = v);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telefonoController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: l10n.phoneRequired,
                          hintText: '3929795575',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.translate('phoneIsMandatory');
                          }
                          final clean = value.replaceAll(RegExp(r'[^\d]'), '');
                          if (_prefix == '+39' && clean.length != 10) {
                            return l10n.translate('phoneMust10Digits');
                          }
                          if (clean.length < 8) {
                            return l10n.translate('phoneInvalid');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child:
                              _saving
                                  ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(l10n.translate('save')),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
    );
  }
}
