import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import '../../models/post_model.dart';
import '../../models/evento_model.dart';
import '../../models/documento.dart';
import '../../models/project_opportunity_catalog.dart';
import '../../services/wordpress_service.dart';
import '../../services/eventi_service.dart';
import '../../services/documento_service.dart';
import '../../services/socio_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../servizi/accoglienza_screen.dart';
import '../servizi/cv_ai_screen.dart';
import '../servizi/mediazione_fiscale_screen.dart';
import '../servizi/supporto_contabile_screen.dart';
import '../servizi/educazione_finanziaria_credito_screen.dart';
import '../servizi/lavoro_orientamento_screen.dart';
import '../onboarding/first_access_screen.dart';
import '../progetti/project_category_detail_screen.dart';
import '../eventi/evento_detail_screen.dart';
import '../profilo/completa_profilo_screen.dart';
import '../profilo/documenti_screen.dart';
import '../../widgets/language_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = SecureStorageService();
  String userName = '...'; // valore iniziale
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final token = await storage.read(key: 'jwt_token');
    final fullName = await storage.read(key: 'full_name');
    final displayName = await storage.read(key: 'user_display_name');
    final nicename = await storage.read(key: 'user_nicename');
    final email = await storage.read(key: 'user_email');

    // Priorità: full_name (nome + cognome) > display_name > nicename > email
    String finalName = 'Utente';
    bool logged = token != null && token.isNotEmpty;

    if (fullName != null && fullName.isNotEmpty) {
      finalName = fullName;
    } else if (displayName != null && displayName.isNotEmpty) {
      finalName = displayName;
    } else if (nicename != null && nicename.isNotEmpty) {
      finalName = nicename;
    } else if (email != null && email.isNotEmpty) {
      // Estrai il nome dalla parte prima della @
      finalName = email.split('@').first;
    }

    if (mounted) {
      setState(() {
        userName = finalName;
        isLoggedIn = logged;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          const LanguageSelector(),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [scheme.surfaceContainerLowest, scheme.surface],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GreetingSection(userName: userName, isLoggedIn: isLoggedIn),
                const SizedBox(height: 24),

                // Avviso documenti in scadenza
                if (isLoggedIn) const _DocumentiScadenzaSection(),
                if (isLoggedIn) const SizedBox(height: 24),

                if (!isLoggedIn)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
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
                              color: scheme.primary.withOpacity(0.28),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: scheme.onPrimary.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: scheme.onPrimary.withOpacity(0.35),
                                  ),
                                ),
                                child: Icon(
                                  Icons.login,
                                  color: scheme.onPrimary,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.alreadyRegistered,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: scheme.onPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.loginToAccess,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: scheme.onPrimary.withOpacity(
                                          0.9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: scheme.onPrimary,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!isLoggedIn) const SizedBox(height: 24),

                const _ServicesSection(),
                const SizedBox(height: 24),

                if (isLoggedIn) const _UserActionsSection(),
                if (isLoggedIn) const SizedBox(height: 24),

                const _UpcomingEventsSection(),

                const SizedBox(height: 24),

                _ActiveProjectsSection(),

                const SizedBox(height: 24),

                const _LatestPostsSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveProjectsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final categories = buildProjectOpportunityCatalog(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.translate('projectsOpportunitySectionTitle')),
        const SizedBox(height: 8),
        Text(
          l10n.translate('projectsOpportunitySectionSubtitle'),
          style: TextStyle(
            fontSize: 13,
            height: 1.45,
            color: scheme.onSurface.withOpacity(0.72),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ProjectCategoryDetailScreen(category: category),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 188,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        category.color.withOpacity(0.72),
                        category.color,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: scheme.onPrimary.withOpacity(0.14),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: category.color.withOpacity(0.28),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: scheme.onPrimary.withOpacity(0.22),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            category.icon,
                            size: 24,
                            color: scheme.onPrimary,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: scheme.onPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              category.summary,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                color: scheme.onPrimary.withOpacity(0.9),
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Text(
                          '${category.items.length} ${l10n.translate('availableOpportunitiesLabel')}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: scheme.onPrimary.withOpacity(0.88),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GreetingSection extends StatelessWidget {
  final String userName;
  final bool isLoggedIn;

  const _GreetingSection({required this.userName, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              scheme.secondary.withOpacity(0.24),
              scheme.primary,
            ),
            scheme.primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.24),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.hello}, $userName',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: scheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.welcome,
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.onPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.onPrimary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLoggedIn ? Icons.verified_user : Icons.person_outline,
                  color: scheme.onPrimary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isLoggedIn ? 'Area soci' : 'Guest',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? link;
  final String? ctaLabel;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.link,
    this.ctaLabel,
    this.onTap,
  });

  void _openLink() async {
    if (link == null || link!.isEmpty) return;

    final uri = Uri.parse(link!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $link');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap ?? (link != null ? _openLink : null),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 208,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.onSurface.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: scheme.onSurface.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      imageUrl!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            scheme.onSurface.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: scheme.onSurface,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withOpacity(0.7),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (ctaLabel != null && ctaLabel!.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: onTap ?? (link != null ? _openLink : null),
                          style: TextButton.styleFrom(
                            foregroundColor: scheme.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                          ),
                          label: Text(
                            ctaLabel!,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserActionsSection extends StatefulWidget {
  const _UserActionsSection();

  @override
  State<_UserActionsSection> createState() => _UserActionsSectionState();
}

class _UserActionsSectionState extends State<_UserActionsSection> {
  static const String _cvDraftKey = 'cv_ai_draft_v1';
  static const String _cvLocalCacheKey = 'cv_ai_local_cvs_v1';
  static const String _jobTrackingKey = 'job_service_tracking_v1';
  static const String _wecoopWhatsAppNumber = '393331234567';

  final SecureStorageService _storage = SecureStorageService();
  final DocumentoService _documentoService = DocumentoService();

  bool _loading = true;
  List<_UserActionCardData> _actions = const [];

  @override
  void initState() {
    super.initState();
    _loadActions();
  }

  Future<void> _loadActions() async {
    final snapshot = await _buildSnapshot();
    final nextActions = _buildActions(snapshot);
    if (!mounted) return;

    setState(() {
      _actions = nextActions;
      _loading = false;
    });
  }

  Future<_UserJourneySnapshot> _buildSnapshot() async {
    final profileValue = await _storage.read(key: 'profilo_completo');
    var profileComplete = _parseBool(profileValue, fallback: true);

    if (profileValue == null || profileValue.isEmpty) {
      final profileResponse = await SocioService.getProfiloCompleto();
      if (profileResponse['success'] == true) {
        final data = profileResponse['data'] as Map<String, dynamic>? ?? {};
        profileComplete = _parseDynamicBool(
          data['profilo_completo'],
          fallback: true,
        );
        await _storage.write(
          key: 'profilo_completo',
          value: profileComplete.toString(),
        );
      }
    }

    final rawCvCache = await _storage.read(key: _cvLocalCacheKey);
    final rawCvDraft = await _storage.read(key: _cvDraftKey);
    final rawTracking = await _storage.read(key: _jobTrackingKey);
    final rawApplicationStatus = await _storage.read(
      key: 'applications_status',
    );
    final rawCreditStatus = await _storage.read(key: 'credit_status');

    var documentsMissing = _parseBool(
      await _storage.read(key: 'documents_missing'),
    );

    if (!documentsMissing) {
      try {
        final scaduti = await _documentoService.getDocumentiScaduti();
        final inScadenza = await _documentoService.getDocumentiInScadenza();
        documentsMissing = scaduti.isNotEmpty || inScadenza.isNotEmpty;
      } catch (_) {}
    }

    return _UserJourneySnapshot(
      profileComplete: profileComplete,
      hasCv: _hasGeneratedCv(rawCvCache),
      hasCvDraft: rawCvDraft != null && rawCvDraft.trim().isNotEmpty,
      creditStarted:
          _parseBool(await _storage.read(key: 'credit_started')) ||
          _statusMatches(rawCreditStatus, const {
            'started',
            'draft',
            'in_progress',
          }),
      creditSubmitted:
          _parseBool(await _storage.read(key: 'credit_submitted')) ||
          _statusMatches(rawCreditStatus, const {
            'submitted',
            'sent',
            'under_review',
          }),
      documentsMissing: documentsMissing,
      applicationStatus: _extractApplicationStatus(
        rawTracking,
        rawApplicationStatus,
        rawCvCache,
      ),
    );
  }

  List<_UserActionCardData> _buildActions(_UserJourneySnapshot snapshot) {
    final l10n = AppLocalizations.of(context)!;
    final actions = <_UserActionCardData>[];
    final seen = <String>{};

    void addAction(_UserActionCardData action) {
      if (actions.length >= 4 || seen.contains(action.title)) return;
      seen.add(action.title);
      actions.add(action);
    }

    if (!snapshot.profileComplete) {
      addAction(
        _UserActionCardData(
          icon: Icons.person_rounded,
          title: l10n.completeProfile,
          status: l10n.translate('actionStatusIncomplete'),
          ctaLabel: l10n.continue_,
          onTap: () => _openScreen(const CompletaProfiloScreen()),
        ),
      );
    }

    if (snapshot.documentsMissing) {
      addAction(
        _UserActionCardData(
          icon: Icons.upload_file_rounded,
          title: l10n.translate('actionUploadMissingDocuments'),
          status: l10n.translate('actionStatusRequired'),
          ctaLabel: l10n.translate('ctaUploadNow'),
          onTap: () => _openScreen(const DocumentiScreen()),
        ),
      );
    }

    if (!snapshot.hasCv) {
      addAction(
        _UserActionCardData(
          icon: Icons.description_rounded,
          title:
              snapshot.hasCvDraft
                  ? l10n.translate('actionCompleteCv')
                  : l10n.translate('actionCreateCv'),
          status:
              snapshot.hasCvDraft
                  ? l10n.translate('actionStatusIncomplete')
                  : l10n.translate('actionStatusToStart'),
          ctaLabel:
              snapshot.hasCvDraft
                  ? l10n.continue_
                  : l10n.translate('ctaStartNow'),
          onTap: () => _openScreen(const CvAiScreen()),
        ),
      );
    }

    if (snapshot.creditSubmitted) {
      addAction(
        _UserActionCardData(
          icon: Icons.query_stats_rounded,
          title: l10n.translate('actionViewPracticeStatus'),
          status: l10n.translate('actionStatusSubmitted'),
          ctaLabel: l10n.translate('ctaViewStatus'),
          onTap: () => _openScreen(const EducazioneFinanziariaCreditoScreen()),
        ),
      );
    } else if (snapshot.creditStarted) {
      addAction(
        _UserActionCardData(
          icon: Icons.account_balance_wallet_rounded,
          title: l10n.translate('actionCompleteCreditRequest'),
          status: l10n.translate('actionStatusInProgress'),
          ctaLabel: l10n.continue_,
          onTap: () => _openScreen(const EducazioneFinanziariaCreditoScreen()),
        ),
      );
    }

    if (snapshot.hasCv &&
        _shouldShowApplicationStatus(snapshot.applicationStatus)) {
      addAction(
        _UserActionCardData(
          icon: Icons.timeline_rounded,
          title: l10n.translate('viewApplicationStatus'),
          status: _applicationStatusLabel(l10n, snapshot.applicationStatus),
          ctaLabel: l10n.translate('ctaViewStatus'),
          onTap:
              () => _openScreen(
                const StatoCandidaturaScreen(
                  trackingKey: _jobTrackingKey,
                  cvCacheKey: _cvLocalCacheKey,
                ),
              ),
        ),
      );
    } else if (snapshot.hasCv) {
      addAction(
        _UserActionCardData(
          icon: Icons.work_rounded,
          title: l10n.translate('activateWorkService'),
          status: l10n.translate('actionStatusRecommended'),
          ctaLabel: l10n.translate('activateServiceCta'),
          onTap: () => _openScreen(const LavoroOrientamentoScreen()),
        ),
      );
    }

    if (!snapshot.creditStarted && !snapshot.creditSubmitted) {
      addAction(
        _UserActionCardData(
          icon: Icons.credit_score_rounded,
          title: l10n.translate('actionDiscoverCreditEligibility'),
          status: l10n.translate('actionStatusRecommended'),
          ctaLabel: l10n.translate('ctaCheckEligibility'),
          onTap: () => _openScreen(const EducazioneFinanziariaCreditoScreen()),
        ),
      );
    }

    if (actions.length < 4 && snapshot.hasCv) {
      addAction(
        _UserActionCardData(
          icon: Icons.edit_document,
          title: l10n.translate('actionUpdateCv'),
          status: l10n.translate('actionStatusActive'),
          ctaLabel: l10n.continue_,
          onTap: () => _openScreen(const CvAiScreen()),
        ),
      );
    }

    if (actions.length < 4) {
      addAction(
        _UserActionCardData(
          icon: Icons.support_agent_rounded,
          title: l10n.translate('actionReplyToWecoop'),
          status: l10n.translate('actionStatusActive'),
          ctaLabel: l10n.translate('ctaOpenSupport'),
          onTap: _openContactWhatsApp,
        ),
      );
    }

    return actions.take(4).toList(growable: false);
  }

  Future<void> _openScreen(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    if (!mounted) return;
    setState(() => _loading = true);
    _loadActions();
  }

  Future<void> _openContactWhatsApp() async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.parse('https://wa.me/$_wecoopWhatsAppNumber');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.translate('cannotOpenWhatsApp'))),
    );
  }

  bool _parseBool(String? value, {bool fallback = false}) {
    if (value == null) return fallback;
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'si':
      case 'sì':
        return true;
      case 'false':
      case '0':
      case 'no':
        return false;
      default:
        return fallback;
    }
  }

  bool _parseDynamicBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return _parseBool(value, fallback: fallback);
    return fallback;
  }

  bool _statusMatches(String? rawStatus, Set<String> candidates) {
    if (rawStatus == null || rawStatus.trim().isEmpty) return false;
    return candidates.contains(rawStatus.trim().toLowerCase());
  }

  bool _hasGeneratedCv(String? raw) {
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

  String _extractApplicationStatus(
    String? rawTracking,
    String? rawApplicationStatus,
    String? rawCvCache,
  ) {
    if (rawTracking != null && rawTracking.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawTracking);
        if (decoded is Map<String, dynamic>) {
          final status =
              (decoded['currentStatus'] ?? decoded['status'] ?? '')
                  .toString()
                  .trim()
                  .toLowerCase();
          if (status.isNotEmpty) return status;
        }
      } catch (_) {}
    }

    if (rawApplicationStatus != null &&
        rawApplicationStatus.trim().isNotEmpty) {
      return rawApplicationStatus.trim().toLowerCase();
    }

    return _hasGeneratedCv(rawCvCache) ? 'cv_generated' : 'profile_created';
  }

  bool _shouldShowApplicationStatus(String status) {
    return const {
      'service_activated',
      'consent_signed',
      'in_review',
      'ready_to_send',
      'sent',
      'under_evaluation',
      'interview',
      'closed',
      'not_selected',
    }.contains(status);
  }

  String _applicationStatusLabel(AppLocalizations l10n, String status) {
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

    return l10n.translate(keyByStatus[status] ?? 'actionStatusInProgress');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.translate('userActionsSectionTitle')),
        const SizedBox(height: 8),
        Text(
          l10n.translate('userActionsSectionSubtitle'),
          style: TextStyle(
            fontSize: 13,
            height: 1.45,
            color: scheme.onSurface.withOpacity(0.72),
          ),
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else
          Column(
            children: [
              for (var index = 0; index < _actions.length; index++) ...[
                _UserActionCard(action: _actions[index]),
                if (index != _actions.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.ourServices),
        const SizedBox(height: 12),
        _ServiceButton(
          title: l10n.welcomeOrientation,
          imagePath: 'assets/images/home/accoglienza.jpg',
          onTap: () async {
            final storage = SecureStorageService();
            final token = await storage.read(key: 'jwt_token');
            final isLoggedIn = token != null && token.isNotEmpty;

            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        isLoggedIn
                            ? const AccoglienzaScreen()
                            : const FirstAccessScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _ServiceButton(
          title: l10n.translate('fiscalServices'),
          imagePath: 'assets/images/home/mediazione.jpg',
          onTap: () async {
            final storage = SecureStorageService();
            final token = await storage.read(key: 'jwt_token');
            final isLoggedIn = token != null && token.isNotEmpty;

            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        isLoggedIn
                            ? const MediazioneFiscaleScreen()
                            : const FirstAccessScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _ServiceButton(
          title: l10n.accountingSupport,
          imagePath: 'assets/images/home/contabile.jpg',
          onTap: () async {
            final storage = SecureStorageService();
            final token = await storage.read(key: 'jwt_token');
            final isLoggedIn = token != null && token.isNotEmpty;

            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        isLoggedIn
                            ? const SupportoContabileScreen()
                            : const FirstAccessScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _ServiceButton(
          title: l10n.translate('workAndOrientation'),
          imagePath: 'assets/images/home/cv_ai.jpg',
          onTap: () async {
            final storage = SecureStorageService();
            final token = await storage.read(key: 'jwt_token');
            final isLoggedIn = token != null && token.isNotEmpty;

            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        isLoggedIn
                            ? const LavoroOrientamentoScreen()
                            : const FirstAccessScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _ServiceButton(
          title: l10n.translate('financialEducationCredit'),
          imagePath: 'assets/images/home/orientamento.jpg',
          onTap: () async {
            final storage = SecureStorageService();
            final token = await storage.read(key: 'jwt_token');
            final isLoggedIn = token != null && token.isNotEmpty;

            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        isLoggedIn
                            ? const EducazioneFinanziariaCreditoScreen()
                            : const FirstAccessScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ServiceButton extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const _ServiceButton({
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: scheme.onSurface.withOpacity(0.14),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Immagine di sfondo
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback con colore gradiente se l'immagine non esiste
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          Color.alphaBlend(
                            scheme.secondary.withOpacity(0.28),
                            scheme.primary,
                          ),
                          scheme.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Overlay scuro per migliorare la leggibilità del testo
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [
                    scheme.onSurface.withOpacity(0.62),
                    scheme.primary.withOpacity(0.35),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            // Testo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: scheme.shadow.withOpacity(0.45),
                        blurRadius: 4,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Icona freccia a destra
            Positioned(
              right: 14,
              top: 14,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.onPrimary.withOpacity(0.18),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: scheme.onPrimary,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserJourneySnapshot {
  final bool profileComplete;
  final bool hasCv;
  final bool hasCvDraft;
  final bool creditStarted;
  final bool creditSubmitted;
  final bool documentsMissing;
  final String applicationStatus;

  const _UserJourneySnapshot({
    required this.profileComplete,
    required this.hasCv,
    required this.hasCvDraft,
    required this.creditStarted,
    required this.creditSubmitted,
    required this.documentsMissing,
    required this.applicationStatus,
  });
}

class _UserActionCardData {
  final IconData icon;
  final String title;
  final String status;
  final String ctaLabel;
  final VoidCallback onTap;

  const _UserActionCardData({
    required this.icon,
    required this.title,
    required this.status,
    required this.ctaLabel,
    required this.onTap,
  });
}

class _UserActionCard extends StatelessWidget {
  final _UserActionCardData action;

  const _UserActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outlineVariant.withOpacity(0.55)),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.primary,
                        Color.alphaBlend(
                          scheme.secondary.withOpacity(0.22),
                          scheme.primary,
                        ),
                      ],
                    ),
                  ),
                  child: Icon(action.icon, color: scheme.onPrimary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          action.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: action.onTap,
                child: Text(action.ctaLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _LatestPostsSection extends StatefulWidget {
  const _LatestPostsSection();

  @override
  State<_LatestPostsSection> createState() => _LatestPostsSectionState();
}

class _LatestPostsSectionState extends State<_LatestPostsSection> {
  final WordpressService wpService = WordpressService();
  late Future<List<Post>> postsFuture;

  @override
  void initState() {
    super.initState();
    postsFuture = wpService.getPosts(perPage: 5);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.latestArticles),
        const SizedBox(height: 12),
        FutureBuilder<List<Post>>(
          future: postsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('${l10n.errorLoading}: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text(l10n.noArticlesAvailable);
            }

            final posts = snapshot.data!;
            return SizedBox(
              height: 224,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _InfoCard(
                    title: post.title,
                    subtitle: post.excerpt,
                    imageUrl: post.imageUrl,
                    link: post.link,
                    ctaLabel: l10n.translate('ctaOpenArticle'),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _UpcomingEventsSection extends StatefulWidget {
  const _UpcomingEventsSection();

  @override
  State<_UpcomingEventsSection> createState() => _UpcomingEventsSectionState();
}

class _UpcomingEventsSectionState extends State<_UpcomingEventsSection> {
  late Future<List<Evento>> eventiFuture;

  @override
  void initState() {
    super.initState();
    eventiFuture = _loadEventi();
  }

  Future<List<Evento>> _loadEventi() async {
    try {
      final result = await EventiService.getEventi(stato: 'futuro', perPage: 5);
      if (result['success'] == true && result['eventi'] != null) {
        return result['eventi'] as List<Evento>;
      }
      return [];
    } catch (e) {
      print('Errore caricamento eventi: $e');
      return [];
    }
  }

  String _formatData(String dataStr) {
    try {
      final data = DateTime.parse(dataStr);
      final mesi = [
        'Gen',
        'Feb',
        'Mar',
        'Apr',
        'Mag',
        'Giu',
        'Lug',
        'Ago',
        'Set',
        'Ott',
        'Nov',
        'Dic',
      ];
      return '${data.day} ${mesi[data.month - 1]}';
    } catch (e) {
      return dataStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<Evento>>(
      future: eventiFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final eventi = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: l10n.upcomingEvents),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: eventi.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final evento = eventi[index];
                  return _InfoCard(
                    title: evento.titolo,
                    subtitle: _formatData(evento.dataInizio),
                    imageUrl: evento.immagineCopertina,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EventoDetailScreen(
                                eventoId: evento.id,
                                evento: evento,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// Sezione avviso documenti in scadenza
class _DocumentiScadenzaSection extends StatefulWidget {
  const _DocumentiScadenzaSection();

  @override
  State<_DocumentiScadenzaSection> createState() =>
      _DocumentiScadenzaSectionState();
}

class _DocumentiScadenzaSectionState extends State<_DocumentiScadenzaSection> {
  final DocumentoService _documentoService = DocumentoService();
  List<Documento> _documentiInScadenza = [];
  List<Documento> _documentiScaduti = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkDocumenti();
  }

  Future<void> _checkDocumenti() async {
    final inScadenza = await _documentoService.getDocumentiInScadenza();
    final scaduti = await _documentoService.getDocumentiScaduti();

    if (mounted) {
      setState(() {
        _documentiInScadenza = inScadenza;
        _documentiScaduti = scaduti;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_documentiScaduti.isEmpty && _documentiInScadenza.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Documenti scaduti (priorità alta)
        if (_documentiScaduti.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.error, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.error, color: scheme.error),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '⚠️ DOCUMENTI SCADUTI',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Hai ${_documentiScaduti.length} documento/i scaduto/i. Aggiornali subito!',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                ..._documentiScaduti.map(
                  (doc) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '• ${TipoDocumento.getDisplayName(doc.tipo)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DocumentiScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.upload),
                    label: const Text('Aggiorna documenti'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.error,
                      foregroundColor: scheme.onError,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Documenti in scadenza
        if (_documentiInScadenza.isNotEmpty) ...[
          if (_documentiScaduti.isNotEmpty) const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.secondary, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: scheme.secondary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '📅 Documenti in scadenza',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Hai ${_documentiInScadenza.length} documento/i che scadono a breve:',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                ..._documentiInScadenza.map((doc) {
                  final giorniRimanenti =
                      doc.dataScadenza!.difference(DateTime.now()).inDays;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '• ${TipoDocumento.getDisplayName(doc.tipo)} (tra $giorniRimanenti giorni)',
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DocumentiScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Gestisci documenti'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.secondary,
                      side: BorderSide(color: scheme.secondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
