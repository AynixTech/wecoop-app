import 'package:flutter/material.dart';
import 'package:wecoop_app/utils/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import '../../services/app_localizations.dart';
import '../../services/socio_service.dart';
import '../../services/address_autocomplete_service.dart';
import '../../utils/italian_validators.dart';
import '../../widgets/design_system/design_system.dart';
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
      AppLogger.d('Errore caricamento dati: $e');
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
    // Evita doppio invio (doppio tap sul bottone).
    if (_isSubmitting) return;
    if (!_validateStep1(showSnackBar: true)) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dataNascitaApi = ItalianValidators.birthDateToIso(
        _dataNascitaController.text.trim(),
      );

      final result = await SocioService.completaProfilo(
        email:
            _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
        codiceFiscale: ItalianValidators.normalizeCodiceFiscale(
          _codiceFiscaleController.text,
        ),
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

        // Aggiorna flag profilo_completo in storage.
        // `data` può essere assente/null nella response: accesso null-safe.
        final data = result['data'];
        final profiloCompleto = data is Map ? data['profilo_completo'] : null;
        if (profiloCompleto == true || profiloCompleto == null) {
          // Se il server non specifica il flag ma la chiamata ha avuto successo,
          // consideriamo il profilo completato.
          await _storage.write(key: 'profilo_completo', value: 'true');
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Profilo aggiornato'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
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
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _nextStep() {
    if (_currentStep < 1) {
      if (_currentStep == 0 && !_validateStep0(showSnackBar: true)) {
        return;
      }
      setState(() => _currentStep++);
    } else {
      _completaProfilo();
    }
  }

  String? _validateEmailField(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty || !ItalianValidators.isValidEmail(value)) {
      return l10n.invalidEmail;
    }
    return null;
  }

  String? _validateCodiceFiscaleField(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return l10n.fiscalCodeMustBe16Chars;
    if (trimmed.length != 16) return l10n.fiscalCodeMustBe16Chars;
    if (!ItalianValidators.isValidCodiceFiscale(trimmed)) {
      return l10n.translate('invalidFiscalCode');
    }
    return null;
  }

  String? _validateBirthDateField(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final errKey = ItalianValidators.validateBirthDate(value ?? '');
    if (errKey == null) return null;
    return l10n.translate(errKey);
  }

  String? _validateAddressField(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final errKey = ItalianValidators.validateAddress(value ?? '', required: true);
    if (errKey == null) return null;
    return l10n.translate(errKey);
  }

  String? _validateCityField(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final errKey = ItalianValidators.validateCity(value ?? '', required: true);
    if (errKey == null) return null;
    return l10n.translate(errKey);
  }

  String? _validateCapField(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return l10n.translate('invalidPostalCode');
    if (!ItalianValidators.isValidCap(trimmed)) return l10n.invalidPostalCode;
    return null;
  }

  String? _validateProvinceField(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return l10n.translate('invalidProvince');
    if (!ItalianValidators.isValidProvince(trimmed)) return l10n.translate('invalidProvince');
    return null;
  }

  bool _validateStep0({required bool showSnackBar}) {
    final errors = [
      _validateEmailField(_emailController.text),
      _validateCodiceFiscaleField(_codiceFiscaleController.text),
      _validateBirthDateField(_dataNascitaController.text),
    ].whereType<String>().toList();
    if (errors.isEmpty) return true;
    if (showSnackBar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errors.first),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
    }
    _formKey.currentState?.validate();
    return false;
  }

  bool _validateStep1({required bool showSnackBar}) {
    final errors = [
      _validateAddressField(_indirizzoController.text),
      _validateCityField(_cittaController.text),
      _validateCapField(_capController.text),
      _validateProvinceField(_provinciaController.text),
    ].whereType<String>().toList();
    if (errors.isEmpty) return true;
    if (showSnackBar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errors.first),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
    }
    _formKey.currentState?.validate();
    return false;
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.completeProfile),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.surfaceContainerLowest,
              Color.alphaBlend(scheme.primary.withOpacity(0.06), scheme.surface),
            ],
          ),
        ),
        child:
            _isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: scheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        l10n.translate('loadingData'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
                : Column(
                  children: [
                    _buildHeader(theme, scheme, l10n),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                        child: Form(
                          key: _formKey,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.06, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: _buildStepContent(_currentStep, l10n),
                          ),
                        ),
                      ),
                    ),

                    _buildNavigationBar(theme, scheme, l10n),
                  ],
                ),
      ),
    );
  }

  /// Header con gradiente: titolo, sottotitolo e stepper moderno.
  Widget _buildHeader(
    ThemeData theme,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 4, 20, 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, const Color(0xFF1496C1)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.20),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('completeProfileHeaderTitle'),
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.translate('completeProfileHeaderSubtitle'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.85),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _buildStepIndicator(0, l10n.personalData, Icons.person_rounded),
              _buildStepConnector(0),
              _buildStepIndicator(1, l10n.address, Icons.home_rounded),
            ],
          ),
        ],
      ),
    );
  }

  /// Barra inferiore con i pulsanti di navigazione.
  Widget _buildNavigationBar(
    ThemeData theme,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _previousStep,
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  label: Text(l10n.back),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: scheme.primary.withOpacity(0.5)),
                    foregroundColor: scheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _nextStep,
                icon:
                    _isSubmitting
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.onPrimary,
                          ),
                        )
                        : Icon(
                          _currentStep == 1
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: 20,
                        ),
                label: Text(
                  _currentStep == 1 ? l10n.complete : l10n.next,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;
    final isDone = isActive || isCompleted;

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isDone ? Colors.white : Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(isDone ? 1 : 0.4),
                width: 2,
              ),
              boxShadow:
                  isActive
                      ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : null,
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : icon,
              color: isDone ? const Color(0xFF1496C1) : Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: Colors.white.withOpacity(isDone ? 1 : 0.75),
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
        height: 3,
        margin: const EdgeInsets.only(bottom: 28),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isCompleted ? 1 : 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildStepContent(int step, AppLocalizations l10n) {
    switch (step) {
      case 0:
        return _buildPersonalDataStep(l10n);
      case 1:
        return _buildAddressStep(l10n);
      default:
        return Container();
    }
  }

  /// Card contenitore con stile morbido (usata dai singoli step).
  Widget _buildStepCard({required Key key, required List<Widget> children}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F2430),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// Intestazione di sezione con icona in badge, titolo e sottotitolo.
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: scheme.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Decorazione uniforme per i campi (bordi arrotondati, focus colorato).
  InputDecoration _fieldDecoration({
    required String label,
    IconData? icon,
    String? hint,
    String? helper,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      filled: true,
      fillColor: scheme.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
    );
  }

  Widget _buildPersonalDataStep(AppLocalizations l10n) {
    return _buildStepCard(
      key: const ValueKey(0),
      children: [
        _buildSectionHeader(
          icon: Icons.person_rounded,
          title: l10n.personalData,
          subtitle: l10n.translate('personalDataSubtitle'),
        ),
        const SizedBox(height: 22),
        TextFormField(
          controller: _emailController,
          decoration: _fieldDecoration(
            label: '${l10n.email} *',
            icon: Icons.email_outlined,
          ),
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmailField,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _codiceFiscaleController,
          decoration: _fieldDecoration(
            label: '${l10n.fiscalCode} *',
            icon: Icons.badge_outlined,
          ),
          maxLength: 16,
          textCapitalization: TextCapitalization.characters,
          validator: _validateCodiceFiscaleField,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dataNascitaController,
          decoration: _fieldDecoration(
            label: l10n.birthDate,
            icon: Icons.calendar_today_outlined,
            hint: 'DD/MM/YYYY',
            helper: 'Es: 13/07/1994',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
            LengthLimitingTextInputFormatter(10),
            _DateInputFormatter(),
          ],
          validator: _validateBirthDateField,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _luogoNascitaController,
          decoration: _fieldDecoration(
            label: l10n.birthPlace,
            icon: Icons.location_city_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressStep(AppLocalizations l10n) {
    return _buildStepCard(
      key: const ValueKey(1),
      children: [
        _buildSectionHeader(
          icon: Icons.home_rounded,
          title: l10n.address,
          subtitle: l10n.translate('addressSubtitle'),
        ),
        const SizedBox(height: 22),
        AddressAutocompleteField(
          controller: _indirizzoController,
          label: '${l10n.address} *',
          hint: l10n.searchAddress,
          onSelected: (AddressSuggestion s) {
            // Auto-compila i campi correlati dalla selezione (lingua app).
            if (s.city.isNotEmpty) _cittaController.text = s.city;
            if (s.postcode.isNotEmpty) _capController.text = s.postcode;
            if (s.province.isNotEmpty) {
              _provinciaController.text = s.province.toUpperCase();
            }
            setState(() {});
          },
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _cittaController,
                decoration: _fieldDecoration(label: '${l10n.city} *'),
                validator: _validateCityField,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _capController,
                decoration: _fieldDecoration(label: '${l10n.postalCode} *'),
                keyboardType: TextInputType.number,
                maxLength: 5,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _validateCapField,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _provinciaController,
                decoration: _fieldDecoration(label: '${l10n.province} *'),
                maxLength: 2,
                textCapitalization: TextCapitalization.characters,
                validator: _validateProvinceField,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _professioneController,
                decoration: _fieldDecoration(
                  label: l10n.profession,
                  icon: Icons.work_outline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildDocumentsStep(AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      key: const ValueKey(2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
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
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.description, color: scheme.primary),
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
              style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
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
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: file != null ? scheme.secondary : scheme.outlineVariant,
            width: file != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color:
              file != null
                  ? scheme.secondaryContainer.withOpacity(0.5)
                  : scheme.surfaceContainerLowest,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    file != null
                        ? scheme.secondaryContainer
                        : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                file != null ? Icons.check_circle : Icons.upload_file,
                color:
                    file != null ? scheme.secondary : scheme.onSurfaceVariant,
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
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      'PDF, JPG, PNG (max 5MB)',
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
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
