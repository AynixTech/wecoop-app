import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/partner_ficha_catalog.dart';
import '../../../models/offerta_formativa_model.dart';
import '../../../models/partner_dettaglio_model.dart';
import '../../../models/partner_model.dart';
import '../../../services/app_localizations.dart';
import '../../../services/contenuti_service.dart';
import '../../../services/socio_service.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/share_helper.dart';

// ─────────────────────────────────────────────────────────────
// TAB – Vetrina Partner Accademici (design Figma UNIUMA)
// ─────────────────────────────────────────────────────────────

class PartnerAccademiciTab extends StatefulWidget {
  final ContenutiService contenutiService;
  const PartnerAccademiciTab({super.key, required this.contenutiService});

  @override
  State<PartnerAccademiciTab> createState() => _PartnerAccademiciTabState();
}

class _PartnerAccademiciTabState extends State<PartnerAccademiciTab>
    with AutomaticKeepAliveClientMixin {
  List<Partner> _partners = [];
  bool _isLoading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPartners();
  }

  Future<void> _loadPartners() async {
    try {
      final data = await widget.contenutiService.getPartnerAccademici();
      if (mounted) {
        setState(() {
          _partners = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _openFicha(Partner p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PartnerFichaScreen(
          partner: p,
          contenutiService: widget.contenutiService,
        ),
      ),
    );
  }

  void _openOrientazione({Partner? partner}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PartnerOrientazioneScreen(
          partner: partner,
          contenutiService: widget.contenutiService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;

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
              const Icon(Icons.cloud_off, size: 60, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(l10n.translate('errorLoading'), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadPartners();
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        setState(() {
          _isLoading = true;
          _error = null;
        });
        await _loadPartners();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            l10n.translate('partnerAccademiciHeaderTitle'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate('partnerAccademiciHeaderSubtitle'),
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          if (_partners.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  const Icon(Icons.school_outlined,
                      size: 60, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    l10n.translate('partnerAccademiciNessuno'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          else
            ..._partners.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _PartnerShowcaseCard(
                  partner: p,
                  lang: lang,
                  onOpen: () => _openFicha(p),
                ),
              ),
            ),
          const SizedBox(height: 8),
          _StartHereCard(
            onTap: () => _openOrientazione(
              partner: _partners.isNotEmpty ? _partners.first : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerShowcaseCard extends StatelessWidget {
  final Partner partner;
  final String lang;
  final VoidCallback onOpen;

  const _PartnerShowcaseCard({
    required this.partner,
    required this.lang,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ficha = fichaForPartnerName(partner.nome);
    final loc = ficha?.localeFor(lang);
    final coverAsset = ficha?.coverAsset;
    final tagline = loc?.cardTagline.isNotEmpty == true
        ? loc!.cardTagline
        : (partner.descrizione.isNotEmpty
            ? partner.descrizione
            : partner.descrizioneEstesa);
    final affiliation = loc?.affiliation ?? '';
    final tags = loc?.tags ??
        [
          if (partner.tipo.isNotEmpty && partner.tipo != 'generico')
            partner.tipo,
        ];

    return Material(
      color: AppColors.surface,
      elevation: 0,
      shadowColor: AppColors.shadow.withOpacity(0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: coverAsset != null
                      ? Image.asset(coverAsset, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.bgSubtle,
                          child: const Icon(Icons.account_balance_outlined,
                              size: 40, color: AppColors.textMuted),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _PartnerAvatar(logoUrl: partner.logoUrl, size: 48, round: true),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                partner.nome,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (partner.citta.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  partner.citta,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (tagline.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        tagline,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                    if (affiliation.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        affiliation,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags
                            .map(
                              (t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.chipBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  t,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onOpen,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFD7EBF3),
                          foregroundColor: AppColors.primaryDark,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          l10n.translate('partnerAccademiciConosci'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
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

class _StartHereCard extends StatelessWidget {
  final VoidCallback onTap;
  const _StartHereCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: const Color(0xFFEAF4F8),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chat_bubble_outline,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('partnerAccademiciStartTitle'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.translate('partnerAccademiciStartMessage'),
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textSecondary,
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

// ─────────────────────────────────────────────────────────────
// FICHA – Dettaglio partner
// ─────────────────────────────────────────────────────────────

class PartnerFichaScreen extends StatefulWidget {
  final Partner partner;
  final ContenutiService contenutiService;

  const PartnerFichaScreen({
    super.key,
    required this.partner,
    required this.contenutiService,
  });

  @override
  State<PartnerFichaScreen> createState() => _PartnerFichaScreenState();
}

class _PartnerFichaScreenState extends State<PartnerFichaScreen> {
  PartnerDettaglio? _dettaglio;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data =
          await widget.contenutiService.getPartnerDettaglio(widget.partner.id);
      if (mounted) {
        setState(() {
          _dettaglio = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openAdmission(PartnerFicha ficha) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PartnerAmmissioneScreen(
          partner: widget.partner,
          ficha: ficha,
          contenutiService: widget.contenutiService,
        ),
      ),
    );
  }

  void _openOrientazione() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PartnerOrientazioneScreen(
          partner: widget.partner,
          contenutiService: widget.contenutiService,
          offerte: _dettaglio?.offerteFormative ?? const [],
        ),
      ),
    );
  }

  Future<void> _openMedia(String url) async {
    if (url.isEmpty) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final ficha = fichaForPartnerName(widget.partner.nome);
    final loc = ficha?.localeFor(lang);
    final d = _dettaglio;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.partner.nome.toUpperCase()),
        titleSpacing: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ficha?.coverAsset != null
                            ? Image.asset(ficha!.coverAsset, fit: BoxFit.cover)
                            : (d != null && d.galleria.isNotEmpty)
                                ? Image.network(
                                    d.galleria.first.url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.bgSubtle,
                                      child: const Icon(
                                          Icons.account_balance_outlined,
                                          size: 48,
                                          color: AppColors.textMuted),
                                    ),
                                  )
                                : Container(
                                    color: AppColors.bgSubtle,
                                    child: const Icon(
                                        Icons.account_balance_outlined,
                                        size: 48,
                                        color: AppColors.textMuted),
                                  ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _PartnerAvatar(
                                  logoUrl: widget.partner.logoUrl,
                                  size: 56,
                                  round: true,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.partner.nome,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (widget.partner.citta.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          widget.partner.citta,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                      if (loc?.affiliation.isNotEmpty ==
                                          true) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          loc!.affiliation,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              loc?.detailHeadline.isNotEmpty == true
                                  ? loc!.detailHeadline
                                  : (d?.partner.descrizioneEstesa.isNotEmpty ==
                                          true
                                      ? d!.partner.descrizioneEstesa
                                      : widget.partner.descrizione),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if ((loc?.detailDescription ?? '').isNotEmpty ||
                                widget.partner.descrizione.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                loc?.detailDescription.isNotEmpty == true
                                    ? loc!.detailDescription
                                    : widget.partner.descrizione,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            if (loc != null && loc.stats.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  for (var i = 0; i < loc.stats.length; i++) ...[
                                    if (i > 0) const SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF5F8),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              loc.stats[i].value,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primaryDark,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              loc.stats[i].label,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                            if (ficha != null) ...[
                              const SizedBox(height: 18),
                              InkWell(
                                onTap: () => _openAdmission(ficha),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          l10n.translate(
                                              'partnerAccademiciSeeAdmission'),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward,
                                          size: 18,
                                          color: AppColors.primaryDark),
                                    ],
                                  ),
                                ),
                              ),
                            ],

                            // Offerte formative (se presenti in API)
                            if (d != null && d.offerteFormative.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Text(
                                l10n.translate(
                                    'partnerAccademiciOffertaFormativa'),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...d.offerteFormative.map(
                                (o) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _OffertaMiniCard(
                                    offerta: o,
                                    onInfo: () {
                                      if (o.linkInfo.isNotEmpty) {
                                        launchUrl(Uri.parse(o.linkInfo),
                                            mode:
                                                LaunchMode.externalApplication);
                                      } else {
                                        _openOrientazione();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],

                            if (d != null && d.video.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                l10n.translate('partnerAccademiciVideo'),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...d.video.map(
                                (m) => Card(
                                  child: ListTile(
                                    leading: const Icon(
                                        Icons.play_circle_outline),
                                    title: Text(m.titolo.isNotEmpty
                                        ? m.titolo
                                        : 'Video'),
                                    trailing: const Icon(Icons.open_in_new,
                                        size: 18),
                                    onTap: () => _openMedia(m.url),
                                  ),
                                ),
                              ),
                            ],

                            if (d != null && d.documenti.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                l10n.translate('partnerAccademiciBrochure'),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...d.documenti.map(
                                (m) => Card(
                                  child: ListTile(
                                    leading: const Icon(
                                        Icons.picture_as_pdf_outlined),
                                    title: Text(m.titolo.isNotEmpty
                                        ? m.titolo
                                        : 'Documento'),
                                    trailing: const Icon(
                                        Icons.download_outlined,
                                        size: 18),
                                    onTap: () => _openMedia(m.url),
                                  ),
                                ),
                              ),
                            ],

                            if (d != null && d.galleria.length > 1) ...[
                              const SizedBox(height: 16),
                              Text(
                                l10n.translate('partnerAccademiciGalleria'),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 120,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: d.galleria.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, i) {
                                    final m = d.galleria[i];
                                    return GestureDetector(
                                      onTap: () => _openMedia(m.url),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          m.url,
                                          width: 160,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            width: 160,
                                            color: AppColors.bgSubtle,
                                            child: const Icon(
                                                Icons.broken_image_outlined),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _StickyOrientCta(
                  onPressed: _openOrientazione,
                  label: l10n.translate('partnerAccademiciRequestOrient'),
                  hint: l10n.translate('partnerAccademiciRequestOrientHint'),
                ),
              ],
            ),
    );
  }
}

class _OffertaMiniCard extends StatelessWidget {
  final OffertaFormativa offerta;
  final VoidCallback onInfo;
  const _OffertaMiniCard({required this.offerta, required this.onInfo});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            offerta.titolo,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (offerta.categoria.isNotEmpty || offerta.durata.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              [offerta.categoria, offerta.durata]
                  .where((e) => e.isNotEmpty)
                  .join(' · '),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
          if (offerta.descrizione.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              offerta.descrizione,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton(
                onPressed: onInfo,
                child: Text(l10n.translate('studiareItaliaRequestInfo')),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  final url =
                      'https://www.wecoop.org/offerte-formative/${offerta.id}';
                  shareText(
                    context,
                    text: '${offerta.titolo}\n\n$url',
                    subject: offerta.titolo,
                  );
                },
                icon: const Icon(Icons.share_outlined, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AMMISSIONE – Accordion requisiti
// ─────────────────────────────────────────────────────────────

class PartnerAmmissioneScreen extends StatefulWidget {
  final Partner partner;
  final PartnerFicha ficha;
  final ContenutiService contenutiService;

  const PartnerAmmissioneScreen({
    super.key,
    required this.partner,
    required this.ficha,
    required this.contenutiService,
  });

  @override
  State<PartnerAmmissioneScreen> createState() =>
      _PartnerAmmissioneScreenState();
}

class _PartnerAmmissioneScreenState extends State<PartnerAmmissioneScreen> {
  late List<bool> _expanded;

  @override
  void initState() {
    super.initState();
    final n = widget.ficha
        .localeFor('it')
        .admissionSections
        .length; // length is same across langs
    _expanded = List<bool>.filled(n, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final loc = widget.ficha.localeFor(lang);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.partner.nome.toUpperCase()),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Row(
                  children: [
                    const Icon(Icons.school_outlined,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n
                            .translate('partnerAccademiciAdmissionCrumb')
                            .replaceAll('{name}', widget.partner.nome),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD7EBF3),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '04',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('partnerAccademiciAdmissionTitle'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            loc.admissionIntro,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                for (var i = 0; i < loc.admissionSections.length; i++) ...[
                  _AdmissionAccordion(
                    title: loc.admissionSections[i].titleKey,
                    body: loc.admissionSections[i].bodyKey,
                    steps: loc.admissionSections[i].stepsKeys,
                    expanded: _expanded[i],
                    onToggle: () =>
                        setState(() => _expanded[i] = !_expanded[i]),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          _StickyOrientCta(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PartnerOrientazioneScreen(
                    partner: widget.partner,
                    contenutiService: widget.contenutiService,
                  ),
                ),
              );
            },
            label: l10n.translate('partnerAccademiciRequestOrient'),
            hint: l10n.translate('partnerAccademiciRequestOrientHint'),
          ),
        ],
      ),
    );
  }
}

class _AdmissionAccordion extends StatelessWidget {
  final String title;
  final String? body;
  final List<String> steps;
  final bool expanded;
  final VoidCallback onToggle;

  const _AdmissionAccordion({
    required this.title,
    required this.body,
    required this.steps,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EAF0)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (steps.isNotEmpty)
                    ...steps.asMap().entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '${e.key + 1}. ${e.value}',
                              style: const TextStyle(
                                fontSize: 13.5,
                                height: 1.45,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                  if (body != null && body!.isNotEmpty)
                    Text(
                      body!,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: AppColors.textSecondary,
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

// ─────────────────────────────────────────────────────────────
// ORIENTAZIONE – Form WECOOP
// ─────────────────────────────────────────────────────────────

class PartnerOrientazioneScreen extends StatefulWidget {
  final Partner? partner;
  final ContenutiService contenutiService;
  final List<OffertaFormativa> offerte;

  const PartnerOrientazioneScreen({
    super.key,
    this.partner,
    required this.contenutiService,
    this.offerte = const [],
  });

  @override
  State<PartnerOrientazioneScreen> createState() =>
      _PartnerOrientazioneScreenState();
}

class _PartnerOrientazioneScreenState extends State<PartnerOrientazioneScreen> {
  final _helpCtrl = TextEditingController();
  OffertaFormativa? _selectedProgram;
  List<OffertaFormativa> _offerte = [];
  bool _privacy = false;
  bool _sending = false;
  bool _loadingOfferte = false;

  @override
  void initState() {
    super.initState();
    _offerte = List.of(widget.offerte);
    if (_offerte.isEmpty && widget.partner != null) {
      _loadOfferte();
    }
  }

  Future<void> _loadOfferte() async {
    setState(() => _loadingOfferte = true);
    try {
      final d = await widget.contenutiService
          .getPartnerDettaglio(widget.partner!.id);
      if (mounted) {
        setState(() {
          _offerte = d?.offerteFormative ?? const [];
          _loadingOfferte = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingOfferte = false);
    }
  }

  @override
  void dispose() {
    _helpCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_privacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('privacyRequired'))),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      final res = await SocioService.inviaRichiestaServizio(
        servizio: 'study_italy_service',
        categoria: 'studiare_in_italia',
        dati: {
          'tipo_richiesta': 'orientazione_partner_accademico',
          if (widget.partner != null) 'partner_id': widget.partner!.id,
          if (widget.partner != null) 'partner_nome': widget.partner!.nome,
          if (_selectedProgram != null) ...{
            'programma_id': _selectedProgram!.id,
            'programma_titolo': _selectedProgram!.titolo,
          },
          'messaggio': _helpCtrl.text.trim(),
          'privacy_accepted': true,
        },
      );
      if (!mounted) return;
      final ok = res['success'] == true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? l10n.translate('partnerAccademiciConsulenzaInviata')
              : l10n.translate('partnerAccademiciConsulenzaErrore')),
          backgroundColor: ok ? null : Theme.of(context).colorScheme.error,
        ),
      );
      if (ok) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(l10n.translate('partnerAccademiciConsulenzaErrore'))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final partner = widget.partner;
    final city = partner?.citta ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.translate('partnerAccademiciOrientTitle')),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                Text(
                  l10n.translate('partnerAccademiciOrientHeadline'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.translate('partnerAccademiciOrientSubtitle'),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (partner != null) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5EAF0)),
                    ),
                    child: Row(
                      children: [
                        _PartnerAvatar(
                          logoUrl: partner.logoUrl,
                          size: 48,
                          round: true,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.translate(
                                    'partnerAccademiciInstitutionLabel'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                city.isNotEmpty
                                    ? '${partner.nome} · $city'
                                    : partner.nome,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  l10n.translate('partnerAccademiciProgramLabel'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<OffertaFormativa?>(
                  value: _selectedProgram,
                  isExpanded: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surface,
                    hintText: l10n.translate('partnerAccademiciProgramHint'),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5EAF0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5EAF0)),
                    ),
                  ),
                  items: [
                    DropdownMenuItem<OffertaFormativa?>(
                      value: null,
                      child: Text(
                        l10n.translate('partnerAccademiciProgramHint'),
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    ..._offerte.map(
                      (o) => DropdownMenuItem<OffertaFormativa?>(
                        value: o,
                        child: Text(o.titolo, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: _loadingOfferte
                      ? null
                      : (v) => setState(() => _selectedProgram = v),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.translate('partnerAccademiciHelpLabel'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _helpCtrl,
                  maxLines: 5,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surface,
                    hintText: l10n.translate('partnerAccademiciHelpHint'),
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5EAF0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5EAF0)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _privacy,
                        onChanged: (v) =>
                            setState(() => _privacy = v ?? false),
                        activeColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _privacy = !_privacy),
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: l10n.translate(
                                    'partnerAccademiciPrivacyCheck'),
                              ),
                              const TextSpan(text: ' '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: GestureDetector(
                                  onTap: () => launchUrl(
                                    Uri.parse(
                                        'https://www.wecoop.org/privacy-policy/'),
                                    mode: LaunchMode.externalApplication,
                                  ),
                                  child: Text(
                                    l10n.translate('privacyPolicy'),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (partner != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n
                        .translate('partnerAccademiciNoEnrollDisclaimer')
                        .replaceAll('{name}', partner.nome),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: Color(0xFFE8EEF2))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _sending ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.translate('partnerAccademiciContinueRequest'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.translate('partnerAccademiciOrientFooter'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
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

class _StickyOrientCta extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final String hint;

  const _StickyOrientCta({
    required this.onPressed,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: Color(0xFFE8EEF2))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerAvatar extends StatelessWidget {
  final String logoUrl;
  final double size;
  final bool round;

  const _PartnerAvatar({
    required this.logoUrl,
    this.size = 48,
    this.round = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = round ? size / 2 : 10.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.bgSubtle,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFE5EAF0)),
      ),
      clipBehavior: Clip.hardEdge,
      child: logoUrl.isNotEmpty
          ? Image.network(
              logoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.business_outlined,
                color: AppColors.textMuted,
                size: size * 0.45,
              ),
            )
          : Icon(
              Icons.business_outlined,
              color: AppColors.textMuted,
              size: size * 0.45,
            ),
    );
  }
}
