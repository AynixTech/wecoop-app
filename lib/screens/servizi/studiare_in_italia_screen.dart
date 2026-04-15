import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/app_localizations.dart';
import '../../services/wordpress_service.dart';
import '../../models/offerta_formativa_model.dart';

// ─────────────────────────────────────────────────────────────
// ENTRY POINT – Schermata intro con CTA e tab "Percorsi"
// ─────────────────────────────────────────────────────────────
class StudiareInItaliaScreen extends StatefulWidget {
  const StudiareInItaliaScreen({super.key});

  @override
  State<StudiareInItaliaScreen> createState() => _StudiareInItaliaScreenState();
}

class _StudiareInItaliaScreenState extends State<StudiareInItaliaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _wpService = WordpressService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('studiareItalia')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.translate('studiareItaliaTabForm')),
            Tab(text: l10n.translate('studiareItaliaTabPercorsi')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _IntroTab(onStart: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const _StudiareItaliaFormScreen(),
              ),
            );
          }),
          _PercorsiTab(wpService: _wpService),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 1 – Intro + CTA + Supporto WeCoop
// ─────────────────────────────────────────────────────────────
class _IntroTab extends StatelessWidget {
  final VoidCallback onStart;
  const _IntroTab({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.school, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                Text(
                  l10n.translate('studiareItalia'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.translate('studiareItaliaSubtitle'),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Supporto WeCoop (Screen 8)
          Text(
            l10n.translate('studiareItaliaSupportTitle'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...['studiareItaliaSupportDoc', 'studiareItaliaSupportVisto',
              'studiareItaliaSupportServizi', 'studiareItaliaSupportLavoro']
              .map((key) => _SupportItem(icon: _supportIcon(key), label: l10n.translate(key))),
          const SizedBox(height: 28),

          // CTA Inizia
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                l10n.translate('studiareItaliaStart'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _supportIcon(String key) {
    switch (key) {
      case 'studiareItaliaSupportDoc':   return Icons.description_outlined;
      case 'studiareItaliaSupportVisto': return Icons.flight_outlined;
      case 'studiareItaliaSupportServizi': return Icons.support_agent_outlined;
      case 'studiareItaliaSupportLavoro': return Icons.work_outline;
      default: return Icons.check_circle_outline;
    }
  }
}

class _SupportItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SupportItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: scheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 2 – Percorsi formativi disponibili (Screen 7)
// ─────────────────────────────────────────────────────────────
class _PercorsiTab extends StatefulWidget {
  final WordpressService wpService;
  const _PercorsiTab({required this.wpService});

  @override
  State<_PercorsiTab> createState() => _PercorsiTabState();
}

class _PercorsiTabState extends State<_PercorsiTab>
    with AutomaticKeepAliveClientMixin {
  List<OffertaFormativa> _offerte = [];
  bool _isLoading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadOfferte();
  }

  Future<void> _loadOfferte() async {
    try {
      final data = await widget.wpService.getOfferteFormative();
      if (mounted) setState(() { _offerte = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 60, color: scheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(l10n.translate('errorLoading'), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () {
                setState(() { _isLoading = true; _error = null; });
                _loadOfferte();
              }, child: const Text('Riprova')),
            ],
          ),
        ),
      );
    }

    if (_offerte.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school_outlined, size: 60, color: scheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(l10n.translate('studiareItaliaNoPercorsi'), textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _offerte.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _OffertaCard(offerta: _offerte[index]),
    );
  }
}

class _OffertaCard extends StatelessWidget {
  final OffertaFormativa offerta;
  const _OffertaCard({required this.offerta});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (offerta.imageUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      offerta.imageUrl,
                      width: 56, height: 56,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          Container(width: 56, height: 56,
                              decoration: BoxDecoration(color: scheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.school, color: scheme.onSurfaceVariant)),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (offerta.partnerNome.isNotEmpty)
                        Text(offerta.partnerNome,
                            style: TextStyle(fontSize: 12, color: scheme.primary,
                                fontWeight: FontWeight.w600)),
                      Text(offerta.titolo,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            if (offerta.categoria.isNotEmpty || offerta.durata.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (offerta.categoria.isNotEmpty)
                    _Chip(label: offerta.categoria, color: scheme.secondaryContainer,
                        textColor: scheme.onSecondaryContainer),
                  if (offerta.durata.isNotEmpty)
                    _Chip(label: offerta.durata, color: scheme.tertiaryContainer,
                        textColor: scheme.onTertiaryContainer),
                ],
              ),
            ],
            if (offerta.descrizione.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(offerta.descrizione,
                  style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                  maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  if (offerta.linkInfo.isNotEmpty) {
                    launchUrl(Uri.parse(offerta.linkInfo),
                        mode: LaunchMode.externalApplication);
                  } else {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const _StudiareItaliaFormScreen()));
                  }
                },
                icon: const Icon(Icons.info_outline, size: 16),
                label: Text(l10n.translate('studiareItaliaRequestInfo')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _Chip({required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w600)),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FORM MULTI-STEP (Screens 2-5)
// ─────────────────────────────────────────────────────────────
class _StudiareItaliaFormScreen extends StatefulWidget {
  const _StudiareItaliaFormScreen();

  @override
  State<_StudiareItaliaFormScreen> createState() => _StudiareItaliaFormScreenState();
}

class _StudiareItaliaFormScreenState extends State<_StudiareItaliaFormScreen> {
  int _currentStep = 0;
  static const int _totalSteps = 4;
  bool _isSubmitting = false;

  // Step 1 – Dati base
  final _nomeCognomeCtrl     = TextEditingController();
  final _paeseOrigineCtrl    = TextEditingController();
  final _emailCtrl           = TextEditingController();
  final _whatsappCtrl        = TextEditingController();

  // Step 2 – Profilo
  final _etaCtrl      = TextEditingController();
  String? _titoloStudio;
  String? _livelloItaliano;
  String? _livelloInglese;

  // Step 3 – Obiettivi
  final _cosaStudiareCtrl = TextEditingController();
  String? _quandoIniziare;
  bool? _giaStudiato;

  // Step 4 – Situazione
  bool? _haDocumenti;
  bool _helpVisto       = false;
  bool _helpIscrizione  = false;
  bool _helpOrientamento = false;

  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());
  final _wpService = WordpressService();

  @override
  void dispose() {
    _nomeCognomeCtrl.dispose();
    _paeseOrigineCtrl.dispose();
    _emailCtrl.dispose();
    _whatsappCtrl.dispose();
    _etaCtrl.dispose();
    _cosaStudiareCtrl.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() => _formKeys[_currentStep].currentState?.validate() ?? false;

  void _nextStep() {
    if (!_validateCurrentStep()) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final aiutoList = <String>[];
    if (_helpVisto) aiutoList.add('Visto');
    if (_helpIscrizione) aiutoList.add('Iscrizione');
    if (_helpOrientamento) aiutoList.add('Orientamento');

    final data = {
      'nome_cognome':     _nomeCognomeCtrl.text.trim(),
      'paese_origine':    _paeseOrigineCtrl.text.trim(),
      'email':            _emailCtrl.text.trim(),
      'whatsapp':         _whatsappCtrl.text.trim(),
      'eta':              _etaCtrl.text.trim(),
      'titolo_studio':    _titoloStudio ?? '',
      'livello_italiano': _livelloItaliano ?? '',
      'livello_inglese':  _livelloInglese ?? '',
      'cosa_studiare':    _cosaStudiareCtrl.text.trim(),
      'quando_iniziare':  _quandoIniziare ?? '',
      'gia_studiato':     _giaStudiato == true ? 'Sì' : (_giaStudiato == false ? 'No' : ''),
      'ha_documenti':     _haDocumenti == true ? 'Sì' : (_haDocumenti == false ? 'No' : ''),
      'aiuto_richiesto':  aiutoList.join(', '),
    };

    final result = await _wpService.submitStudiareItalia(data);
    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const _StudiareItaliaSuccessScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore: ${result['message'] ?? 'Riprova più tardi.'}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final stepTitles = [
      l10n.translate('studiareItaliaFormStep1'),
      l10n.translate('studiareItaliaFormStep2'),
      l10n.translate('studiareItaliaFormStep3'),
      l10n.translate('studiareItaliaFormStep4'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('studiareItalia')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${_currentStep + 1} / $_totalSteps  –  ${stepTitles[_currentStep]}',
                      style: TextStyle(fontWeight: FontWeight.w600, color: scheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / _totalSteps,
                    minHeight: 6,
                    backgroundColor: scheme.surfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: _formKeys[_currentStep],
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: [
                  _buildStep1(l10n),
                  _buildStep2(l10n),
                  _buildStep3(l10n),
                  _buildStep4(l10n),
                ][_currentStep],
              ),
            ),
          ),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : _prevStep,
                      child: Text(l10n.translate('studiareItaliaBack')),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(
                            _currentStep == _totalSteps - 1
                                ? l10n.translate('studiareItaliaSendRequest')
                                : l10n.translate('studiareItaliaNext'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Dati base ──────────────────────────────────────
  Widget _buildStep1(AppLocalizations l10n) {
    return Column(
      children: [
        _FormField(
          controller: _nomeCognomeCtrl,
          label: l10n.translate('studiareItaliaNameSurname'),
          icon: Icons.person_outline,
          required: true,
          validator: (v) => v == null || v.trim().isEmpty ? l10n.translate('fieldRequired') : null,
        ),
        const SizedBox(height: 16),
        _FormField(
          controller: _paeseOrigineCtrl,
          label: l10n.translate('studiareItaliaCountryOrigin'),
          icon: Icons.flag_outlined,
        ),
        const SizedBox(height: 16),
        _FormField(
          controller: _emailCtrl,
          label: l10n.translate('email'),
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          required: true,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return l10n.translate('fieldRequired');
            if (!v.contains('@')) return l10n.translate('invalidEmail');
            return null;
          },
        ),
        const SizedBox(height: 16),
        _FormField(
          controller: _whatsappCtrl,
          label: l10n.translate('studiareItaliaWhatsapp'),
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  // ── Step 2: Profilo ────────────────────────────────────────
  Widget _buildStep2(AppLocalizations l10n) {
    const livelliLingua = ['Nessuno', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    const titoliStudio = [
      'Nessuno', 'Scuola primaria', 'Scuola secondaria inferiore',
      'Scuola secondaria superiore', 'Laurea triennale', 'Laurea magistrale', 'Dottorato',
    ];

    return Column(
      children: [
        _FormField(
          controller: _etaCtrl,
          label: l10n.translate('studiareItaliaAge'),
          icon: Icons.cake_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _DropdownField(
          label: l10n.translate('studiareItaliaEducation'),
          value: _titoloStudio,
          items: titoliStudio,
          icon: Icons.school_outlined,
          onChanged: (v) => setState(() => _titoloStudio = v),
        ),
        const SizedBox(height: 16),
        _DropdownField(
          label: l10n.translate('studiareItaliaItalianLevel'),
          value: _livelloItaliano,
          items: livelliLingua,
          icon: Icons.translate,
          onChanged: (v) => setState(() => _livelloItaliano = v),
        ),
        const SizedBox(height: 16),
        _DropdownField(
          label: l10n.translate('studiareItaliaEnglishLevel'),
          value: _livelloInglese,
          items: livelliLingua,
          icon: Icons.language,
          onChanged: (v) => setState(() => _livelloInglese = v),
        ),
      ],
    );
  }

  // ── Step 3: Obiettivi ──────────────────────────────────────
  Widget _buildStep3(AppLocalizations l10n) {
    const opzioniInizio = ['Subito', 'Entro 3 mesi', 'Entro 6 mesi', 'Entro 1 anno'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormField(
          controller: _cosaStudiareCtrl,
          label: l10n.translate('studiareItaliaWhatStudy'),
          icon: Icons.menu_book_outlined,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _DropdownField(
          label: l10n.translate('studiareItaliaWhenStart'),
          value: _quandoIniziare,
          items: opzioniInizio,
          icon: Icons.event_outlined,
          onChanged: (v) => setState(() => _quandoIniziare = v),
        ),
        const SizedBox(height: 16),
        _YesNoField(
          label: l10n.translate('studiareItaliaAlreadyStudied'),
          value: _giaStudiato,
          onChanged: (v) => setState(() => _giaStudiato = v),
        ),
      ],
    );
  }

  // ── Step 4: Situazione ─────────────────────────────────────
  Widget _buildStep4(AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _YesNoField(
          label: l10n.translate('studiareItaliaHasDocuments'),
          value: _haDocumenti,
          onChanged: (v) => setState(() => _haDocumenti = v),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.translate('studiareItaliaHelpNeeded'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        _CheckboxTile(
          label: l10n.translate('studiareItaliaHelpVisto'),
          value: _helpVisto,
          color: scheme.primary,
          onChanged: (v) => setState(() => _helpVisto = v ?? false),
        ),
        _CheckboxTile(
          label: l10n.translate('studiareItaliaHelpIscrizione'),
          value: _helpIscrizione,
          color: scheme.primary,
          onChanged: (v) => setState(() => _helpIscrizione = v ?? false),
        ),
        _CheckboxTile(
          label: l10n.translate('studiareItaliaHelpOrientamento'),
          value: _helpOrientamento,
          color: scheme.primary,
          onChanged: (v) => setState(() => _helpOrientamento = v ?? false),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: scheme.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.translate('studiareItaliaPrivacyNote'),
                  style: TextStyle(fontSize: 12, color: scheme.onPrimaryContainer),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SUCCESSO (Screen 6)
// ─────────────────────────────────────────────────────────────
class _StudiareItaliaSuccessScreen extends StatelessWidget {
  const _StudiareItaliaSuccessScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('studiareItalia'))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: scheme.primary, size: 64),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.translate('studiareItaliaSuccessTitle'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.translate('studiareItaliaSuccessMessage'),
                style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Torna alla root (pop fino alla schermata principale)
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home_outlined),
                  label: Text(l10n.translate('studiareItaliaGoToServices')),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
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

// ─────────────────────────────────────────────────────────────
// WIDGET HELPERS
// ─────────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool required;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.required = false,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
      ),
      validator: validator,
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }
}

class _YesNoField extends StatelessWidget {
  final String label;
  final bool? value;
  final ValueChanged<bool?> onChanged;

  const _YesNoField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            _ToggleChip(
              label: 'Sì',
              selected: value == true,
              color: scheme.primary,
              onTap: () => onChanged(true),
            ),
            const SizedBox(width: 10),
            _ToggleChip(
              label: 'No',
              selected: value == false,
              color: scheme.primary,
              onTap: () => onChanged(false),
            ),
          ],
        ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          border: Border.all(color: selected ? color : Colors.grey.shade400, width: 1.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CheckboxTile extends StatelessWidget {
  final String label;
  final bool value;
  final Color color;
  final ValueChanged<bool?> onChanged;

  const _CheckboxTile({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      activeColor: color,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }
}
