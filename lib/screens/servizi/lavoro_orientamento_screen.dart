import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/app_localizations.dart';
import '../../services/lavoro_service.dart';
import '../../services/secure_storage_service.dart';
import 'cv_ai_screen.dart';

class LavoroOrientamentoScreen extends StatelessWidget {
  const LavoroOrientamentoScreen({super.key});

  static const String _jobServiceTrackingKey = 'job_service_tracking_v1';
  static const String _cvLocalCacheKey = 'cv_ai_local_cvs_v1';

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

  Future<void> _handleActivateWorkServiceTap(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AttivazioneServizioLavoroScreen(
              trackingKey: _jobServiceTrackingKey,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
              title: l10n.translate('activateWorkService'),
              description: l10n.translate('activateWorkServiceDesc'),
              onTap: () {
                _handleActivateWorkServiceTap(context);
              },
            ),
            const SizedBox(height: 12),
            _ServiceCard(
              icon: Icons.timeline_outlined,
              title: l10n.translate('viewApplicationStatus'),
              description: l10n.translate('viewApplicationStatusDesc'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => StatoCandidaturaScreen(
                          trackingKey: _jobServiceTrackingKey,
                          cvCacheKey: _cvLocalCacheKey,
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _ServiceCard(
              icon: Icons.school_outlined,
              title: l10n.translate('viewTraining'),
              description: l10n.translate('viewTrainingDesc'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FormazioneLavoroScreen(),
                  ),
                );
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

  const AttivazioneServizioLavoroScreen({super.key, required this.trackingKey});

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

  bool get _allChecked =>
      _gdprConsent && _shareCvConsent && _whatsappConsent && _termsConsent;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('workServiceActivated'))),
      );
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('activateWorkService'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.translate('workServiceQuestion'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: _gdprConsent,
                      title: Text(l10n.translate('consentGdpr')),
                      onChanged:
                          (value) =>
                              setState(() => _gdprConsent = value ?? false),
                    ),
                    CheckboxListTile(
                      value: _shareCvConsent,
                      title: Text(l10n.translate('consentShareCv')),
                      onChanged:
                          (value) =>
                              setState(() => _shareCvConsent = value ?? false),
                    ),
                    CheckboxListTile(
                      value: _whatsappConsent,
                      title: Text(l10n.translate('consentWhatsapp')),
                      onChanged:
                          (value) =>
                              setState(() => _whatsappConsent = value ?? false),
                    ),
                    CheckboxListTile(
                      value: _termsConsent,
                      title: Text(l10n.translate('consentTerms')),
                      onChanged:
                          (value) =>
                              setState(() => _termsConsent = value ?? false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _activateService,
                  icon:
                      _saving
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.check_circle_outline),
                  label: Text(l10n.translate('activateServiceCta')),
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
          final remoteStatus = _normalizeStatus(
            (data['currentStatus'] ?? data['status'] ?? data['state'] ?? '')
                .toString(),
          );
          final remoteUpdatedAt =
              (data['updatedAt'] ?? data['updated_at'] ?? '').toString().trim();

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
                data['timeline'] is List
                    ? (data['timeline'] as List)
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
