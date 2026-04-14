import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/app_localizations.dart';
import '../../services/lavoro_service.dart';
import '../../services/secure_storage_service.dart';
import 'cv_ai_screen.dart';

class LavoroOrientamentoScreen extends StatefulWidget {
  const LavoroOrientamentoScreen({super.key});

  @override
  State<LavoroOrientamentoScreen> createState() =>
      _LavoroOrientamentoScreenState();
}

class _LavoroOrientamentoScreenState extends State<LavoroOrientamentoScreen> {
  bool _isCheckingServiceStatus = true;
  bool _isServiceActive = false;

  static const String _jobServiceTrackingKey = 'job_service_tracking_v1';
  static const String _cvLocalCacheKey = 'cv_ai_local_cvs_v1';

  @override
  void initState() {
    super.initState();
    _refreshServiceStatus();
  }

  Future<bool> _hasGeneratedCv() async {
    final storage = SecureStorageService();
    final raw = await storage.read(key: _cvLocalCacheKey);
    if (raw == null || raw.trim().isEmpty) return false;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return false;

      for (final item in decoded) {
        if (item is! Map) continue;
        final status = (item['status'] ?? '').toString().toLowerCase();
        if (status == 'generated') return true;

        final files = item['files'];
        if (files is Map) {
          final pdfUrl = (files['pdfUrl'] ?? '').toString().trim();
          final docxUrl = (files['docxUrl'] ?? '').toString().trim();
          if (pdfUrl.isNotEmpty || docxUrl.isNotEmpty) return true;
        }
      }
    } catch (_) {
      return false;
    }

    return false;
  }

  Future<void> _refreshServiceStatus() async {
    final profileId = await LavoroService.resolveProfileId();
    var isActive = false;

    if (profileId != null && profileId.isNotEmpty) {
      try {
        final statusResult = await LavoroService.getJobStatus(profileId: profileId);
        final status = LavoroService.extractJobStatus(statusResult);
        isActive = LavoroService.isJobServiceActiveStatus(status);
      } catch (_) {
        isActive = false;
      }
    }

    if (!mounted) return;
    setState(() {
      _isServiceActive = isActive;
      _isCheckingServiceStatus = false;
    });
  }

  Future<void> _handleActivateWorkServiceTap(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    if (_isServiceActive) {
      final refreshed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder:
              (context) => AttivazioneServizioLavoroScreen(
                trackingKey: _jobServiceTrackingKey,
                serviceAlreadyActive: true,
              ),
        ),
      );
      if (refreshed == true && mounted) {
        await _refreshServiceStatus();
      }
      return;
    }

    final hasGeneratedCv = await _hasGeneratedCv();
    if (!context.mounted) return;

    if (!hasGeneratedCv) {
      await showDialog<void>(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: Text(l10n.translate('activateWorkService')),
              content: const Text(
                'Per attivare il servizio lavoro devi prima generare un Curriculum CV.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CvAiScreen(),
                      ),
                    );
                  },
                  child: Text(l10n.translate('createCvService')),
                ),
              ],
            ),
      );
      return;
    }

    final refreshed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (context) => AttivazioneServizioLavoroScreen(
              trackingKey: _jobServiceTrackingKey,
            ),
      ),
    );
    if (refreshed == true && mounted) {
      await _refreshServiceStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activateTitle =
        _isServiceActive
            ? l10n.translate('deactivateServiceCta')
            : l10n.translate('activateWorkService');
    final activateDescription =
        _isServiceActive
            ? l10n.translate('activateWorkServiceActiveDesc')
            : l10n.translate('activateWorkServiceDesc');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('workAndOrientation'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.translate('selectServiceCategory'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _ServiceCard(
              icon: Icons.description_outlined,
              title: l10n.translate('createCvService'),
              description: l10n.translate('createCvServiceDesc'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CvAiScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _ServiceCard(
              icon: Icons.work_outline,
              title: activateTitle,
              description:
                  _isCheckingServiceStatus
                      ? 'Controlliamo lo stato del servizio lavoro...'
                      : activateDescription,
              onTap:
                  _isCheckingServiceStatus
                      ? () {}
                      : () {
                        _handleActivateWorkServiceTap(context);
                      },
            ),
          ],
        ),
      ),
    );
  }
}

class AttivazioneServizioLavoroScreen extends StatefulWidget {
  final String trackingKey;
  final bool serviceAlreadyActive;

  const AttivazioneServizioLavoroScreen({
    super.key,
    required this.trackingKey,
    this.serviceAlreadyActive = false,
  });

  @override
  State<AttivazioneServizioLavoroScreen> createState() =>
      _AttivazioneServizioLavoroScreenState();
}

class _AttivazioneServizioLavoroScreenState
    extends State<AttivazioneServizioLavoroScreen> {
  final _storage = SecureStorageService();

  void _log(String event, Map<String, dynamic> data) {
    print('[LAVORO_UI] $event ${jsonEncode(data)}');
  }

  bool _gdprConsent = false;
  bool _shareCvConsent = false;
  bool _whatsappConsent = false;
  bool _termsConsent = false;
  bool _saving = false;
  bool _isCheckingStatus = true;
  bool _isServiceActive = false;

  bool get _allChecked =>
      _gdprConsent && _shareCvConsent && _whatsappConsent && _termsConsent;

  @override
  void initState() {
    super.initState();
    _isServiceActive = widget.serviceAlreadyActive;
    _loadCurrentStatus();
  }

  Future<void> _loadCurrentStatus() async {
    final profileId = await LavoroService.resolveProfileId();
    var isActive = widget.serviceAlreadyActive;

    if (profileId != null && profileId.isNotEmpty) {
      try {
        final result = await LavoroService.getJobStatus(profileId: profileId);
        final status = LavoroService.extractJobStatus(result);
        isActive = LavoroService.isJobServiceActiveStatus(status);
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _isServiceActive = isActive;
      _isCheckingStatus = false;
    });
  }

  Future<String> _buildDigitalSignature() async {
    final fullName = (await _storage.read(key: 'full_name'))?.trim();
    final displayName = (await _storage.read(key: 'user_display_name'))?.trim();
    final email = (await _storage.read(key: 'user_email'))?.trim();
    final signer = [fullName, displayName, email]
        .whereType<String>()
        .firstWhere((value) => value.isNotEmpty, orElse: () => 'utente_wecoop');
    final signedAt = DateTime.now().toIso8601String();
    return '$signer|$signedAt';
  }

  Future<void> _activateService() async {
    final l10n = AppLocalizations.of(context)!;

    if (_isServiceActive) {
      await _deactivateService();
      return;
    }

    if (!_allChecked) {
      _log('activate_blocked_missing_consents', {
        'gdpr': _gdprConsent,
        'shareCv': _shareCvConsent,
        'whatsapp': _whatsappConsent,
        'terms': _termsConsent,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('consentRequired'))),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      _log('activate_started', {
        'trackingKey': widget.trackingKey,
        'gdpr': _gdprConsent,
        'shareCv': _shareCvConsent,
        'whatsapp': _whatsappConsent,
        'terms': _termsConsent,
      });

      final resolvedId = await LavoroService.resolveProfileId();
      _log('resolved_profile_id', {'resolvedId': resolvedId});

      final profileResult = await LavoroService.createOrUpdateProfile(
        profileId: resolvedId,
      );
      _log('profile_result', profileResult);

      final profileData = profileResult['data'];
      final profileId =
          (profileResult['profileId'] ??
                  (profileData is Map<String, dynamic>
                      ? (profileData['id'] ??
                          profileData['profileId'] ??
                          profileData['profile_id'])
                      : null))
              ?.toString();

      _log('effective_profile_id', {
        'profileId': profileId,
        'profileDataType': profileData.runtimeType.toString(),
      });

      if (profileId == null || profileId.isEmpty) {
        throw Exception('profile_id_missing');
      }

      final digitalSignature = await _buildDigitalSignature();
      _log('consent_signature_ready', {
        'signaturePreview':
            digitalSignature.length > 18
                ? '${digitalSignature.substring(0, 18)}...'
                : digitalSignature,
      });

      final consentResult = await LavoroService.submitConsent(
        profileId: profileId,
        gdpr: _gdprConsent,
        shareCv: _shareCvConsent,
        whatsapp: _whatsappConsent,
        terms: _termsConsent,
        digitalSignature: digitalSignature,
      );
      _log('consent_result', consentResult);
      if (consentResult['success'] != true) {
        throw Exception(consentResult['message'] ?? 'consent_failed');
      }

      final activationResult = await LavoroService.activateJobService(
        profileId: profileId,
      );
      _log('activation_result', activationResult);
      if (activationResult['success'] != true) {
        throw Exception(activationResult['message'] ?? 'activation_failed');
      }

      final wachatbotResult = await LavoroService.triggerWachatbot(
        profileId: profileId,
        message: l10n.translate('whatsAppActivationText'),
      );
      _log('wachatbot_result', wachatbotResult);

      final now = DateTime.now().toIso8601String();
      final payload = {
        'currentStatus': 'in_review',
        'updatedAt': now,
        'timeline': [
          {'status': 'profile_created', 'at': now},
          {'status': 'cv_generated', 'at': now},
          {'status': 'service_activated', 'at': now},
          {'status': 'consent_signed', 'at': now},
          {'status': 'in_review', 'at': now},
        ],
        'consents': {
          'gdpr': _gdprConsent,
          'shareCv': _shareCvConsent,
          'whatsapp': _whatsappConsent,
          'terms': _termsConsent,
        },
      };
      _log('tracking_payload', payload);
      await _storage.write(key: widget.trackingKey, value: jsonEncode(payload));
      _log('tracking_saved', {'trackingKey': widget.trackingKey});

      if (!mounted) return;
      setState(() {
        _isServiceActive = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('workServiceActivated'))),
      );
      Navigator.of(context).pop(true);
      _log('activate_completed', {'openWhatsAppAutomatically': false});
    } catch (error, stackTrace) {
      _log('activate_failed', {
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.sendingError)));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _deactivateService() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _saving = true;
    });

    try {
      final profileId = await LavoroService.resolveProfileId();
      if (profileId == null || profileId.isEmpty) {
        throw Exception('profile_id_missing');
      }

      final result = await LavoroService.updateJobStatus(
        profileId: profileId,
        status: 'disattivato',
        note: 'Servizio lavoro disattivato dall\'utente tramite app',
      );
      if (result['success'] != true) {
        throw Exception(result['message'] ?? 'deactivation_failed');
      }

      final rawTracking = await _storage.read(key: widget.trackingKey);
      final now = DateTime.now().toIso8601String();
      Map<String, dynamic> tracking = {
        'currentStatus': 'deactivated',
        'updatedAt': now,
        'timeline': [
          {'status': 'deactivated', 'at': now},
        ],
      };

      if (rawTracking != null && rawTracking.isNotEmpty) {
        try {
          final decoded = jsonDecode(rawTracking);
          if (decoded is Map<String, dynamic>) {
            final timeline =
                decoded['timeline'] is List
                    ? List<Map<String, dynamic>>.from(
                      (decoded['timeline'] as List)
                          .whereType<Map>()
                          .map((item) => Map<String, dynamic>.from(item)),
                    )
                    : <Map<String, dynamic>>[];
            timeline.add({'status': 'deactivated', 'at': now});
            tracking = {
              ...decoded,
              'currentStatus': 'deactivated',
              'updatedAt': now,
              'timeline': timeline,
            };
          }
        } catch (_) {}
      }

      await _storage.write(key: widget.trackingKey, value: jsonEncode(tracking));

      if (!mounted) return;
      setState(() {
        _isServiceActive = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('workServiceDeactivated'))),
      );
      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      _log('deactivate_failed', {
        'error': error.toString(),
        'stackTrace': stackTrace.toString(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.sendingError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    const paperTone = Color(0xFFF8F2E8);
    const paperEdge = Color(0xFFE1D3BE);
    final accent = _isServiceActive ? const Color(0xFF8E3B2E) : const Color(0xFF234B5C);
    final buttonLabel =
        _isServiceActive
            ? l10n.translate('deactivateServiceCta')
            : l10n.translate('activateServiceCta');

    if (_isCheckingStatus) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.translate('activateWorkService'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isServiceActive
              ? l10n.translate('deactivateServiceCta')
              : l10n.translate('activateWorkService'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.alphaBlend(accent.withOpacity(0.07), scheme.surfaceContainerLowest),
              scheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isServiceActive
                            ? l10n.translate('workServiceAlreadyActive')
                            : l10n.translate('workServiceQuestion'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Consulta e sottoscrivi le condizioni del servizio in una forma chiara e leggibile.',
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: paperTone,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: paperEdge),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 22,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accent.withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      _isServiceActive
                                          ? 'Servizio in essere'
                                          : 'Atto di adesione',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                        color: accent,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'WECOOP',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.6,
                                      color: accent.withOpacity(0.88),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                _isServiceActive
                                    ? 'Mandato di supporto al lavoro'
                                    : 'Accordo per l\'attivazione del supporto al lavoro',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                  color: const Color(0xFF2D241B),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                height: 1,
                                color: paperEdge,
                              ),
                              const SizedBox(height: 18),
                              Text(
                                _isServiceActive
                                    ? l10n.translate('activateWorkServiceActiveDesc')
                                    : l10n.translate('activateWorkServiceInfo'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.75,
                                  color: Color(0xFF3E3428),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.56),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: paperEdge.withOpacity(0.9)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Oggetto del consenso',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                        color: accent,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _isServiceActive
                                          ? 'Il tuo mandato e attualmente valido. Puoi mantenerlo attivo oppure revocarlo con effetto immediato.'
                                          : 'Autorizzi WECOOP a utilizzare i dati del tuo profilo professionale per accompagnarti nella ricerca di opportunita lavorative e nelle comunicazioni strettamente connesse al servizio.',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.6,
                                        color: Color(0xFF4A4034),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!_isServiceActive) ...[
                                const SizedBox(height: 22),
                                Text(
                                  'Clausole da approvare',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _ContractConsentTile(
                                  value: _gdprConsent,
                                  title: l10n.translate('consentGdpr'),
                                  subtitle:
                                      'Autorizzo il trattamento dei dati personali per la gestione del servizio lavoro.',
                                  accentColor: accent,
                                  onTap: () => setState(() => _gdprConsent = !_gdprConsent),
                                ),
                                const SizedBox(height: 10),
                                _ContractConsentTile(
                                  value: _shareCvConsent,
                                  title: l10n.translate('consentShareCv'),
                                  subtitle:
                                      'Autorizzo la condivisione del CV con partner selezionati quando utile alla candidatura.',
                                  accentColor: accent,
                                  onTap:
                                      () => setState(() => _shareCvConsent = !_shareCvConsent),
                                ),
                                const SizedBox(height: 10),
                                _ContractConsentTile(
                                  value: _whatsappConsent,
                                  title: l10n.translate('consentWhatsapp'),
                                  subtitle:
                                      'Accetto contatti operativi tramite WhatsApp per aggiornamenti e opportunita.',
                                  accentColor: accent,
                                  onTap:
                                      () => setState(() => _whatsappConsent = !_whatsappConsent),
                                ),
                                const SizedBox(height: 10),
                                _ContractConsentTile(
                                  value: _termsConsent,
                                  title: l10n.translate('consentTerms'),
                                  subtitle:
                                      'Dichiaro di aver letto e compreso le condizioni del servizio e le modalita di utilizzo.',
                                  accentColor: accent,
                                  onTap: () => setState(() => _termsConsent = !_termsConsent),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'La sottoscrizione del presente atto richiede l\'approvazione integrale di tutte le clausole sopra riportate.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.55,
                                    color: scheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                decoration: BoxDecoration(
                  color: scheme.surface.withOpacity(0.96),
                  border: Border(
                    top: BorderSide(color: scheme.outlineVariant.withOpacity(0.55)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _activateService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon:
                        _saving
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Icon(
                              _isServiceActive
                                  ? Icons.gpp_bad_outlined
                                  : Icons.draw_outlined,
                            ),
                    label: Text(buttonLabel),
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

class _ContractConsentTile extends StatelessWidget {
  final bool value;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _ContractConsentTile({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: value ? accentColor.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: value ? accentColor.withOpacity(0.45) : const Color(0xFFD8CBB7),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: value ? accentColor : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: value ? accentColor : const Color(0xFFB6A791),
                    width: 1.4,
                  ),
                ),
                alignment: Alignment.center,
                child:
                    value
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                        : const Icon(
                          Icons.add_rounded,
                          color: Color(0xFF8C7C68),
                          size: 18,
                        ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: Color(0xFF31261C),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.55,
                        color: Color(0xFF5B4F41),
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

class StatoCandidaturaScreen extends StatefulWidget {
  final String trackingKey;
  final String cvCacheKey;

  const StatoCandidaturaScreen({
    super.key,
    required this.trackingKey,
    required this.cvCacheKey,
  });

  @override
  State<StatoCandidaturaScreen> createState() => _StatoCandidaturaScreenState();
}

class _StatoCandidaturaScreenState extends State<StatoCandidaturaScreen> {
  static const List<String> _statusOrder = [
    'profile_created',
    'cv_generated',
    'service_activated',
    'consent_signed',
    'in_review',
    'ready_to_send',
    'sent',
    'under_evaluation',
    'interview',
    'deactivated',
    'closed',
    'not_selected',
  ];

  final _storage = SecureStorageService();
  Map<String, dynamic>? _tracking;
  bool _loading = true;

  String _normalizeStatus(String raw) {
    final value = raw.trim().toLowerCase();
    const map = {
      'profile_created': 'profile_created',
      'profilo_creato': 'profile_created',
      'perfil_creado': 'profile_created',
      'cv_generated': 'cv_generated',
      'service_activated': 'service_activated',
      'servizio_attivato': 'service_activated',
      'servicio_activado': 'service_activated',
      'consent_signed': 'consent_signed',
      'consenso_firmato': 'consent_signed',
      'consentimiento_firmado': 'consent_signed',
      'in_review': 'in_review',
      'in_revisione': 'in_review',
      'en_revision': 'in_review',
      'ready_to_send': 'ready_to_send',
      'pronto_invio': 'ready_to_send',
      'listo_envio': 'ready_to_send',
      'sent': 'sent',
      'inviato': 'sent',
      'enviado': 'sent',
      'under_evaluation': 'under_evaluation',
      'in_valutazione': 'under_evaluation',
      'en_evaluacion': 'under_evaluation',
      'interview': 'interview',
      'colloquio': 'interview',
      'entrevista': 'interview',
      'deactivated': 'deactivated',
      'disattivato': 'deactivated',
      'desactivado': 'deactivated',
      'closed': 'closed',
      'chiuso': 'closed',
      'cerrado': 'closed',
      'not_selected': 'not_selected',
      'non_selezionato': 'not_selected',
      'no_seleccionado': 'not_selected',
    };
    return map[value] ?? value;
  }

  @override
  void initState() {
    super.initState();
    _loadTracking();
  }

  Future<void> _loadTracking() async {
    final rawTracking = await _storage.read(key: widget.trackingKey);
    final rawCvCache = await _storage.read(key: widget.cvCacheKey);

    Map<String, dynamic>? tracking;
    if (rawTracking != null && rawTracking.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawTracking);
        if (decoded is Map<String, dynamic>) {
          tracking = decoded;
        }
      } catch (_) {}
    }

    final hasCvCache =
        rawCvCache != null && rawCvCache.isNotEmpty && rawCvCache != '[]';

    final profileId = await LavoroService.resolveProfileId();
    if (profileId != null && profileId.isNotEmpty) {
      try {
        final remote = await LavoroService.getJobStatus(profileId: profileId);
        if (remote['success'] == true) {
          final data =
            remote['data'] is Map<String, dynamic>
              ? remote['data'] as Map<String, dynamic>
              : <String, dynamic>{};
          final job =
            data['job'] is Map<String, dynamic>
              ? data['job'] as Map<String, dynamic>
              : <String, dynamic>{};
          final remoteStatus = _normalizeStatus(
          LavoroService.extractJobStatus(remote) ?? '',
          );
          final remoteUpdatedAt =
            (job['updatedAt'] ??
                job['updated_at'] ??
                data['updatedAt'] ??
                data['updated_at'] ??
                '')
              .toString()
              .trim();
          final remoteTimeline =
            job['history'] is List
              ? job['history']
              : (data['timeline'] is List ? data['timeline'] : null);

          tracking = {
            'currentStatus':
                remoteStatus.isEmpty
                    ? (hasCvCache ? 'cv_generated' : 'profile_created')
                    : remoteStatus,
            'updatedAt':
                remoteUpdatedAt.isEmpty
                    ? DateTime.now().toIso8601String()
                    : remoteUpdatedAt,
            'timeline':
              remoteTimeline is List
                ? remoteTimeline
                        .whereType<Map>()
                        .map(
                          (e) => {
                            'status': _normalizeStatus(
                              (e['status'] ?? '').toString(),
                            ),
                            'at': e['at']?.toString() ?? '',
                          },
                        )
                        .toList()
                    : (tracking?['timeline'] ?? []),
          };
        }
      } catch (_) {}
    }

    tracking ??= {
      'currentStatus': hasCvCache ? 'cv_generated' : 'profile_created',
      'updatedAt': DateTime.now().toIso8601String(),
      'timeline': [
        {'status': 'profile_created', 'at': DateTime.now().toIso8601String()},
        if (hasCvCache)
          {'status': 'cv_generated', 'at': DateTime.now().toIso8601String()},
      ],
    };

    if (!mounted) return;
    setState(() {
      _tracking = tracking;
      _loading = false;
    });
  }

  String _statusLabel(AppLocalizations l10n, String status) {
    const keyByStatus = {
      'profile_created': 'jobStatusProfileCreated',
      'cv_generated': 'jobStatusCvGenerated',
      'service_activated': 'jobStatusServiceActivated',
      'consent_signed': 'jobStatusConsentSigned',
      'in_review': 'jobStatusInReview',
      'ready_to_send': 'jobStatusReadyToSend',
      'sent': 'jobStatusSent',
      'under_evaluation': 'jobStatusUnderEvaluation',
      'interview': 'jobStatusInterview',
      'deactivated': 'jobStatusDeactivated',
      'closed': 'jobStatusClosed',
      'not_selected': 'jobStatusNotSelected',
    };
    return l10n.translate(keyByStatus[status] ?? 'status');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final currentStatus =
        (_tracking?['currentStatus'] ?? 'profile_created').toString();
    final currentIndex = _statusOrder.indexOf(currentStatus);
    final updatedAt = (_tracking?['updatedAt'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('applicationStatusTitle'))),
      body: SafeArea(
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_tracking == null)
                      Text(
                        l10n.translate('noStatusYet'),
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    if (updatedAt.isNotEmpty)
                      Text(
                        '${l10n.translate('statusUpdatedAt')}: $updatedAt',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    const SizedBox(height: 12),
                    ..._statusOrder.asMap().entries.map((entry) {
                      final index = entry.key;
                      final status = entry.value;
                      final reached =
                          currentIndex >= 0 && index <= currentIndex;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          reached
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: reached ? scheme.primary : scheme.outline,
                        ),
                        title: Text(_statusLabel(l10n, status)),
                      );
                    }),
                  ],
                ),
      ),
    );
  }
}

class FormazioneLavoroScreen extends StatelessWidget {
  const FormazioneLavoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('viewTraining'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.translate('trainingIntro'),
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            _TrainingCard(
              title: l10n.translate('trainingCardCvTitle'),
              description: l10n.translate('trainingCardCvDesc'),
            ),
            const SizedBox(height: 10),
            _TrainingCard(
              title: l10n.translate('trainingCardInterviewTitle'),
              description: l10n.translate('trainingCardInterviewDesc'),
            ),
            const SizedBox(height: 10),
            _TrainingCard(
              title: l10n.translate('trainingCardDigitalTitle'),
              description: l10n.translate('trainingCardDigitalDesc'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingCard extends StatelessWidget {
  final String title;
  final String description;

  const _TrainingCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(description, style: TextStyle(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: scheme.onSurface.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: scheme.onPrimaryContainer, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: scheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
