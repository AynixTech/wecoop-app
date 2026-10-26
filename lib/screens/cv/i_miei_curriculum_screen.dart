import 'package:flutter/material.dart';

import '../../models/curriculum_cv.dart';
import '../../services/curricula_service.dart';
import '../../theme/theme.dart';
import '../../widgets/design_system/design_system.dart';
import 'cv_editor_screen.dart';
import 'cv_pdf_actions.dart';

/// Punto d'ingresso del Generatore CV V1.0: «Crea un CV» e «Il mio profilo →
/// I miei Curriculum» aprono entrambi questa schermata.
class IMieiCurriculumScreen extends StatefulWidget {
  const IMieiCurriculumScreen({super.key});

  @override
  State<IMieiCurriculumScreen> createState() => _IMieiCurriculumScreenState();
}

class _IMieiCurriculumScreenState extends State<IMieiCurriculumScreen> {
  bool _loading = true;
  bool _creating = false;
  CvRisultato<CvElenco>? _res;
  Map<String, dynamic>? _bozzaVecchioFlusso;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    setState(() => _loading = true);
    final res = await CurriculaService.elenco();
    final bozza = res.ok ? await CurriculaService.bozzaVecchioFlussoDaImportare() : null;
    if (!mounted) return;
    setState(() {
      _res = res;
      _bozzaVecchioFlusso = bozza;
      _loading = false;
    });
  }

  List<CurriculumCv> get _curricula => _res?.data?.curricula ?? const [];
  List<CurriculumStorico> get _storico => _res?.data?.storico ?? const [];

  Future<void> _apriEditor(int id, {int passaggioIniziale = 0}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CvEditorScreen(cvId: id, passaggioIniziale: passaggioIniziale),
      ),
    );
    if (mounted) await _carica();
  }

  Future<void> _creaNuovo() async {
    if (_creating) return;
    setState(() => _creating = true);
    final pre = await CurriculaService.prefill();
    final p = pre.data ?? const <String, String>{};
    final dati = CvDati(
      nome: p['nome'] ?? '',
      cognome: p['cognome'] ?? '',
      email: p['email'] ?? '',
      telefono: p['telefono'] ?? '',
      citta: p['citta'] ?? '',
    );
    final res = await CurriculaService.crea(dati: dati);
    if (!mounted) return;
    setState(() => _creating = false);
    if (!res.ok) {
      mostraMessaggio(context, res.errore!);
      return;
    }
    await _apriEditor(res.data!.id);
  }

  Future<void> _importaBozzaVecchioFlusso() async {
    final bozza = _bozzaVecchioFlusso;
    if (bozza == null) return;
    setState(() => _creating = true);
    final res = await CurriculaService.crea(bozzaLegacy: bozza);
    if (!mounted) return;
    setState(() => _creating = false);
    if (!res.ok) {
      mostraMessaggio(context, res.errore!);
      return;
    }
    await CurriculaService.segnaBozzaVecchioFlussoGestita();
    await _apriEditor(res.data!.id);
  }

  Future<void> _ignoraBozzaVecchioFlusso() async {
    await CurriculaService.segnaBozzaVecchioFlussoGestita();
    if (mounted) setState(() => _bozzaVecchioFlusso = null);
  }

  Future<void> _importaStorico(CurriculumStorico s) async {
    setState(() => _creating = true);
    final res = await CurriculaService.importaStorico(s.id);
    if (!mounted) return;
    setState(() => _creating = false);
    if (!res.ok) {
      mostraMessaggio(context, res.errore!);
      return;
    }
    mostraMessaggio(context, 'Curriculum copiato nel nuovo editor. L\'originale resta invariato.');
    await _apriEditor(res.data!.id);
  }

  Future<void> _visualizza(CurriculumCv cv) async {
    if (cv.ultimoPdf == null) {
      await _apriEditor(cv.id, passaggioIniziale: CvEditorScreen.passaggioAnteprima);
      return;
    }
    final file = await scaricaPdfCv(context, cv);
    if (file != null && mounted) await apriPdf(context, file, titolo: cv.titolo);
  }

  Future<void> _scarica(CurriculumCv cv) async {
    final file = await scaricaPdfCv(context, cv);
    if (file != null && mounted) await condividiPdf(context, file, titolo: cv.titolo);
  }

  Future<void> _stampa(CurriculumCv cv) async {
    final file = await scaricaPdfCv(context, cv);
    if (file != null && mounted) await mostraGuidaStampa(context, file, cv.titolo);
  }

  Future<void> _duplica(CurriculumCv cv) async {
    final res = await CurriculaService.duplica(cv.id);
    if (!mounted) return;
    if (!res.ok) {
      mostraMessaggio(context, res.errore!);
      return;
    }
    mostraMessaggio(context, 'Copia creata: «${res.data!.titolo}».');
    await _carica();
  }

  Future<void> _rinomina(CurriculumCv cv) async {
    final ctrl = TextEditingController(text: cv.titolo);
    final nuovo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rinomina curriculum'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 160,
          decoration: const InputDecoration(hintText: 'Es. CV Cameriere 2026'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Salva'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (nuovo == null || nuovo.isEmpty || nuovo == cv.titolo) return;
    final res = await CurriculaService.salva(cv.id, titolo: nuovo);
    if (!mounted) return;
    if (!res.ok) {
      mostraMessaggio(context, res.errore!);
      return;
    }
    await _carica();
  }

  Future<void> _elimina(CurriculumCv cv) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminare il curriculum?'),
        content: Text(
          '«${cv.titolo}» non sarà più visibile nell\'elenco. '
          'Questa operazione non può essere annullata dall\'app.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annulla')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (conferma != true) return;
    final res = await CurriculaService.elimina(cv.id);
    if (!mounted) return;
    if (!res.ok) {
      mostraMessaggio(context, res.errore!);
      return;
    }
    mostraMessaggio(context, 'Curriculum eliminato.');
    await _carica();
  }

  Future<void> _azioni(CurriculumCv cv) async {
    final haPdf = cv.ultimoPdf != null;
    final scelta = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        Widget voce(String id, IconData icon, String label, {bool enabled = true, Color? color}) =>
            ListTile(
              enabled: enabled,
              leading: Icon(icon, color: color),
              title: Text(label, style: TextStyle(color: color)),
              onTap: () => Navigator.pop(ctx, id),
            );
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(cv.titolo, style: AppTypography.headingS, maxLines: 2),
                ),
                voce('visualizza', Icons.visibility_outlined, 'Visualizza'),
                voce('modifica', Icons.edit_outlined, 'Modifica'),
                voce('scarica', Icons.download_outlined, 'Scarica PDF', enabled: haPdf),
                voce('stampa', Icons.print_outlined, 'Stampa', enabled: haPdf),
                voce('versioni', Icons.history, 'Versioni PDF', enabled: haPdf),
                voce('duplica', Icons.copy_outlined, 'Duplica'),
                voce('rinomina', Icons.drive_file_rename_outline, 'Rinomina'),
                voce('elimina', Icons.delete_outline, 'Elimina', color: AppColors.error),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || scelta == null) return;
    switch (scelta) {
      case 'visualizza':
        await _visualizza(cv);
      case 'modifica':
        await _apriEditor(cv.id);
      case 'scarica':
        await _scarica(cv);
      case 'stampa':
        await _stampa(cv);
      case 'versioni':
        await mostraVersioniPdf(context, cv);
      case 'duplica':
        await _duplica(cv);
      case 'rinomina':
        await _rinomina(cv);
      case 'elimina':
        await _elimina(cv);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('I miei Curriculum')),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final res = _res!;
    if (res.moduloDisattivato) {
      return const EmptyState(
        icon: Icons.construction_outlined,
        title: 'Servizio temporaneamente non disponibile',
        message: 'Il generatore di CV tornerà disponibile a breve. '
            'I tuoi curriculum sono al sicuro.',
      );
    }
    if (!res.ok) {
      return ErrorState(message: res.errore!, retryLabel: 'Riprova', onRetry: _carica);
    }

    final bozze = _curricula.where((c) => c.isBozza).toList();
    final completati = _curricula.where((c) => !c.isBozza).toList();
    final nessunCv = _curricula.isEmpty;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _carica,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              if (_bozzaVecchioFlusso != null) ...[
                _BannerBozzaVecchia(
                  onImporta: _importaBozzaVecchioFlusso,
                  onIgnora: _ignoraBozzaVecchioFlusso,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (nessunCv)
                _IntroPrimoCv(onCrea: _creaNuovo, loading: _creating)
              else ...[
                if (bozze.isNotEmpty) ...[
                  _RiprendiCard(
                    cv: bozze.first,
                    onRiprendi: () => _apriEditor(bozze.first.id),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                AppButton(
                  label: bozze.isNotEmpty ? 'Inizia un nuovo CV' : 'Crea nuovo CV',
                  icon: Icons.add,
                  variant: bozze.isNotEmpty ? AppButtonVariant.secondary : AppButtonVariant.primary,
                  loading: _creating,
                  onPressed: _creaNuovo,
                ),
                const SizedBox(height: AppSpacing.xxl),
                const SectionHeader(title: 'I miei Curriculum'),
                const SizedBox(height: AppSpacing.md),
                for (final cv in [...completati, ...bozze.skip(1)]) ...[
                  _CvCard(cv: cv, onTap: () => _azioni(cv)),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (completati.isEmpty && bozze.length <= 1)
                  Text(
                    'Quando generi il PDF, il curriculum comparirà qui tra quelli completati.',
                    style: AppTypography.bodyM.copyWith(color: AppColors.textMuted),
                  ),
              ],
              if (_storico.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxl),
                const SectionHeader(title: 'Versione precedente'),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Curriculum creati con il generatore precedente. Restano consultabili; '
                  'puoi copiarli nel nuovo editor per aggiornarli.',
                  style: AppTypography.bodyM.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final s in _storico) ...[
                  _StoricoCard(
                    storico: s,
                    onPdf: s.haPdf
                        ? () async {
                            final file = await scaricaPdfStorico(context, s);
                            if (file != null && mounted) {
                              await apriPdf(context, file, titolo: s.titolo);
                            }
                          }
                        : null,
                    onImporta: () => _importaStorico(s),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Servizio gratuito per gli utenti registrati. Il modello si ispira al CV '
                'europeo ma non è un documento ufficiale Europass.',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        if (_creating)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x33000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class _IntroPrimoCv extends StatelessWidget {
  const _IntroPrimoCv({required this.onCrea, required this.loading});

  final VoidCallback onCrea;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    Widget punto(IconData icon, String testo) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(testo, style: AppTypography.bodyM)),
            ],
          ),
        );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.description_outlined, size: 40, color: AppColors.primary),
          const SizedBox(height: AppSpacing.md),
          Text('Crea il tuo primo CV', style: AppTypography.headingM),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ti guidiamo passo dopo passo. Puoi fermarti quando vuoi: '
            'la bozza viene salvata e potrai riprenderla in seguito.',
            style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          punto(Icons.check_circle_outline, '8 passaggi semplici, tutti in italiano'),
          punto(Icons.check_circle_outline, 'PDF professionale pronto da scaricare e stampare'),
          punto(Icons.check_circle_outline, 'Puoi creare più CV e aggiornarli quando vuoi'),
          const SizedBox(height: AppSpacing.lg),
          AppButton(label: 'Inizia', icon: Icons.arrow_forward, loading: loading, onPressed: onCrea),
        ],
      ),
    );
  }
}

class _RiprendiCard extends StatelessWidget {
  const _RiprendiCard({required this.cv, required this.onRiprendi});

  final CurriculumCv cv;
  final VoidCallback onRiprendi;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm),
              Text('Bozza in corso', style: AppTypography.label.copyWith(color: AppColors.warning)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(cv.titolo, style: AppTypography.headingS),
          if (cv.updatedAt != null)
            Text(
              'Ultima modifica: ${formatData(cv.updatedAt)}',
              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
            ),
          const SizedBox(height: AppSpacing.md),
          AppButton(label: 'Riprendi compilazione', icon: Icons.play_arrow_rounded, onPressed: onRiprendi),
        ],
      ),
    );
  }
}

class _CvCard extends StatelessWidget {
  const _CvCard({required this.cv, required this.onTap});

  final CurriculumCv cv;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sottotitolo = cv.isBozza
        ? 'Bozza · modificata il ${formatData(cv.updatedAt)}'
        : 'PDF v${cv.ultimoPdf?.versione ?? 1} · ${formatData(cv.ultimoPdf?.createdAt)}';
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            cv.isBozza ? Icons.edit_note : Icons.picture_as_pdf_outlined,
            color: cv.isBozza ? AppColors.warning : AppColors.primary,
            size: 32,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cv.titolo, style: AppTypography.headingS, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(sottotitolo, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                if (cv.modificheNonGenerate)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Modifiche non ancora incluse nel PDF',
                      style: AppTypography.caption.copyWith(color: AppColors.warning),
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: AppColors.iconInactive),
        ],
      ),
    );
  }
}

class _StoricoCard extends StatelessWidget {
  const _StoricoCard({required this.storico, required this.onPdf, required this.onImporta});

  final CurriculumStorico storico;
  final VoidCallback? onPdf;
  final VoidCallback onImporta;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(storico.titolo, style: AppTypography.headingS),
          Text(
            'Creato il ${formatData(storico.createdAt)}',
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              TextButton.icon(
                onPressed: onPdf,
                icon: const Icon(Icons.visibility_outlined),
                label: Text(onPdf == null ? 'PDF non disponibile' : 'Visualizza PDF'),
              ),
              TextButton.icon(
                onPressed: onImporta,
                icon: const Icon(Icons.drive_file_move_outline),
                label: Text(storico.importato ? 'Copia di nuovo' : 'Copia nel nuovo editor'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerBozzaVecchia extends StatelessWidget {
  const _BannerBozzaVecchia({required this.onImporta, required this.onIgnora});

  final VoidCallback onImporta;
  final VoidCallback onIgnora;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.infoBg,
        borderRadius: AppRadius.cardBr,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hai una bozza non terminata', style: AppTypography.headingS),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Su questo telefono c\'è una bozza creata con il generatore precedente. '
            'Puoi recuperarla nel nuovo editor.',
            style: AppTypography.bodyM,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              FilledButton(onPressed: onImporta, child: const Text('Recupera bozza')),
              const SizedBox(width: AppSpacing.sm),
              TextButton(onPressed: onIgnora, child: const Text('Ignora')),
            ],
          ),
        ],
      ),
    );
  }
}
