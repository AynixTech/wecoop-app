import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../models/curriculum_cv.dart';
import '../../services/curricula_service.dart';
import '../../theme/theme.dart';
import '../../widgets/design_system/design_system.dart';
import 'cv_editor_widgets.dart';
import 'cv_pdf_actions.dart';

enum _StatoSalvataggio { salvato, modificato, inCorso, offline, errore }

class CvEditorScreen extends StatefulWidget {
  const CvEditorScreen({super.key, required this.cvId, this.passaggioIniziale = 0});

  static const int passaggioAnteprima = 7;

  final int cvId;
  final int passaggioIniziale;

  @override
  State<CvEditorScreen> createState() => _CvEditorScreenState();
}

class _CvEditorScreenState extends State<CvEditorScreen> {
  static const _passaggi = [
    'Dati personali',
    'Profilo professionale',
    'Esperienze lavorative',
    'Istruzione e formazione',
    'Competenze linguistiche',
    'Competenze',
    'Informazioni aggiuntive',
    'Anteprima e PDF',
  ];

  CurriculumCv? _cv;
  CvDati _dati = CvDati();
  bool _loading = true;
  String? _erroreCaricamento;
  late int _passo = widget.passaggioIniziale.clamp(0, _passaggi.length - 1);

  _StatoSalvataggio _stato = _StatoSalvataggio.salvato;
  int _rev = 0;
  int _revSalvata = 0;
  Timer? _debounce;
  Future<bool>? _salvataggioInCorso;
  bool _salvaDiNuovo = false;

  bool _generando = false;
  File? _pdfLocale;
  List<String> _avvisiPdf = const [];

  Uint8List? _foto;
  bool _caricandoFoto = false;

  final _scroll = ScrollController();
  final _nome = TextEditingController();
  final _cognome = TextEditingController();
  final _email = TextEditingController();
  final _telefono = TextEditingController();
  final _citta = TextEditingController();
  final _titoloProfilo = TextEditingController();
  final _presentazione = TextEditingController();
  final _altro = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carica();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    for (final c in [_nome, _cognome, _email, _telefono, _citta, _titoloProfilo, _presentazione, _altro]) {
      c.dispose();
    }
    super.dispose();
  }

  // ------------------------------------------------------------ caricamento

  Future<void> _carica() async {
    setState(() {
      _loading = true;
      _erroreCaricamento = null;
    });
    final res = await CurriculaService.dettaglio(widget.cvId);
    if (!mounted) return;
    if (!res.ok) {
      setState(() {
        _loading = false;
        _erroreCaricamento = res.errore;
      });
      return;
    }
    _cv = res.data;
    _applicaDati(_cv!.dati ?? CvDati());
    setState(() => _loading = false);
    if (_cv!.haFoto) _caricaFoto();
    await _proponiRipristinoBackup();
  }

  void _applicaDati(CvDati d) {
    _dati = d;
    _nome.text = d.nome;
    _cognome.text = d.cognome;
    _email.text = d.email;
    _telefono.text = d.telefono;
    _citta.text = d.citta;
    _titoloProfilo.text = d.titoloProfilo;
    _presentazione.text = d.presentazione;
    _altro.text = d.altro;
  }

  Future<void> _caricaFoto() async {
    final bytes = await CurriculaService.scaricaFoto(widget.cvId);
    if (mounted && bytes != null) setState(() => _foto = Uint8List.fromList(bytes));
  }

  Future<void> _proponiRipristinoBackup() async {
    final backup = await CurriculaService.leggiBackupLocale(widget.cvId);
    if (backup == null || !mounted) return;
    final serverAt = _cv?.updatedAt;
    if (serverAt != null && !backup.at.isAfter(serverAt)) {
      await CurriculaService.eliminaBackupLocale(widget.cvId);
      return;
    }
    final ripristina = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifiche non salvate'),
        content: Text(
          'Su questo telefono ci sono modifiche del ${formatData(backup.at)} '
          'che non erano state salvate online. Vuoi recuperarle?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No, scarta')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Recupera')),
        ],
      ),
    );
    if (!mounted) return;
    if (ripristina == true) {
      setState(() => _applicaDati(backup.dati));
      _segnaModificato();
    } else {
      await CurriculaService.eliminaBackupLocale(widget.cvId);
    }
  }

  // ------------------------------------------------------------ salvataggio

  void _segnaModificato() {
    _rev++;
    setState(() => _stato = _StatoSalvataggio.modificato);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1800), () => _salva());
  }

  void _aggiorna(VoidCallback modifica) {
    setState(modifica);
    _segnaModificato();
  }

  /// Salva sul server. Se la rete manca, conserva una copia sul telefono.
  Future<bool> _salva({bool manuale = false}) async {
    _debounce?.cancel();
    if (_salvataggioInCorso != null) {
      _salvaDiNuovo = true;
      return _salvataggioInCorso!;
    }
    if (_rev == _revSalvata && !manuale) return true;

    final completer = Completer<bool>();
    _salvataggioInCorso = completer.future;
    if (mounted) setState(() => _stato = _StatoSalvataggio.inCorso);

    final rev = _rev;
    final snapshot = CvDati.fromJson(_dati.toJson());
    final res = await CurriculaService.salva(widget.cvId, dati: snapshot);
    var ok = res.ok;
    if (ok) {
      _cv = res.data;
      _revSalvata = rev;
    } else {
      await CurriculaService.salvaBackupLocale(widget.cvId, snapshot);
    }
    _salvataggioInCorso = null;

    final ancora = _salvaDiNuovo || (ok && _rev != _revSalvata);
    _salvaDiNuovo = false;
    if (ancora) {
      ok = await _salva();
    } else if (mounted) {
      setState(() {
        _stato = ok
            ? _StatoSalvataggio.salvato
            : (res.offline ? _StatoSalvataggio.offline : _StatoSalvataggio.errore);
      });
    }
    if (manuale && mounted) {
      mostraMessaggio(
        context,
        ok ? 'Bozza salvata.' : '${res.errore} Le modifiche restano su questo telefono.',
      );
    }
    completer.complete(ok);
    return ok;
  }

  Future<bool> _primaDiUscire() async {
    if (_stato == _StatoSalvataggio.salvato) return true;
    final ok = await _salva();
    if (ok || !mounted) return true;
    final esci = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Salvataggio non riuscito'),
        content: const Text(
          'Non è stato possibile salvare online. Le modifiche sono conservate su '
          'questo telefono e ti verranno proposte alla prossima apertura.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Resta')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Esci')),
        ],
      ),
    );
    return esci == true;
  }

  void _vaiA(int passo) {
    FocusScope.of(context).unfocus();
    if (_stato == _StatoSalvataggio.modificato) _salva();
    setState(() => _passo = passo);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _rinomina() async {
    final ctrl = TextEditingController(text: _cv?.titolo ?? '');
    final nuovo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nome del curriculum'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 160,
          decoration: const InputDecoration(hintText: 'Es. CV Magazziniere'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Salva')),
        ],
      ),
    );
    ctrl.dispose();
    if (nuovo == null || nuovo.isEmpty || !mounted) return;
    final res = await CurriculaService.salva(widget.cvId, titolo: nuovo);
    if (!mounted) return;
    if (res.ok) {
      setState(() => _cv!.titolo = res.data!.titolo);
    } else {
      mostraMessaggio(context, res.errore!);
    }
  }

  // ------------------------------------------------------------------ foto

  Future<void> _scegliFoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Scegli dalla galleria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Scatta una foto'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final picked = await ImagePicker().pickImage(source: source, maxWidth: 1600, maxHeight: 1600);
      if (picked == null || !mounted) return;
      setState(() => _caricandoFoto = true);
      final raw = await picked.readAsBytes();
      final decoded = img.decodeImage(raw);
      if (decoded == null) throw const FormatException();
      final oriented = img.bakeOrientation(decoded);
      final resized = oriented.width > 600 ? img.copyResize(oriented, width: 600) : oriented;
      final jpeg = img.encodeJpg(resized, quality: 85);
      await _salva();
      final res = await CurriculaService.caricaFoto(widget.cvId, jpeg);
      if (!mounted) return;
      if (!res.ok) {
        mostraMessaggio(context, res.errore!);
      } else {
        setState(() {
          _foto = Uint8List.fromList(jpeg);
          _cv = res.data;
          _dati.includiFoto = true;
        });
      }
    } on FormatException {
      if (mounted) mostraMessaggio(context, 'Immagine non valida: scegli una foto JPG o PNG.');
    } catch (_) {
      if (mounted) {
        mostraMessaggio(context, 'Impossibile usare la foto. Controlla i permessi di fotocamera e galleria.');
      }
    } finally {
      if (mounted) setState(() => _caricandoFoto = false);
    }
  }

  Future<void> _rimuoviFoto() async {
    await _salva();
    final res = await CurriculaService.rimuoviFoto(widget.cvId);
    if (!mounted) return;
    if (!res.ok) {
      mostraMessaggio(context, res.errore!);
      return;
    }
    setState(() {
      _foto = null;
      _cv = res.data;
      _dati.includiFoto = false;
    });
  }

  // ------------------------------------------------------------------ PDF

  Future<void> _generaPdf() async {
    FocusScope.of(context).unfocus();
    final problemi = _dati.problemiPerPdf();
    if (problemi.isNotEmpty) {
      mostraMessaggio(context, problemi.first);
      return;
    }
    setState(() => _generando = true);
    final salvato = await _salva(manuale: _stato != _StatoSalvataggio.salvato);
    if (!salvato) {
      if (mounted) setState(() => _generando = false);
      return;
    }
    final res = await CurriculaService.generaPdf(widget.cvId);
    if (!mounted) return;
    if (!res.ok) {
      setState(() => _generando = false);
      final dettaglio = res.problemi.isNotEmpty ? '\n• ${res.problemi.join('\n• ')}' : '';
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('PDF non generato'),
          content: Text('${res.errore}$dettaglio'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
        ),
      );
      return;
    }
    final cv = _cv!
      ..stato = res.data!.cv.stato
      ..ultimoPdf = res.data!.cv.ultimoPdf
      ..modificheNonGenerate = false;
    final file = await CurriculaService.scaricaPdf(
      cv.id,
      versione: res.data!.versione,
      nomeFile: nomeFilePdf(cv.titolo, res.data!.versione),
    );
    if (!mounted) return;
    setState(() {
      _generando = false;
      _avvisiPdf = res.data!.avvisi;
      _pdfLocale = file.data;
    });
    mostraMessaggio(context, 'PDF generato (versione ${res.data!.versione}).');
  }

  Future<File?> _pdfCorrente() async {
    if (_pdfLocale != null && _pdfLocale!.existsSync()) return _pdfLocale;
    final f = await scaricaPdfCv(context, _cv!);
    if (f != null) _pdfLocale = f;
    return f;
  }

  // ------------------------------------------------------------------ UI

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _stato == _StatoSalvataggio.salvato,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final puoUscire = await _primaDiUscire();
        if (puoUscire && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_cv?.titolo ?? 'Curriculum', overflow: TextOverflow.ellipsis),
          actions: [
            if (_cv != null)
              IconButton(
                tooltip: 'Rinomina',
                onPressed: _rinomina,
                icon: const Icon(Icons.drive_file_rename_outline),
              ),
          ],
        ),
        body: SafeArea(child: _corpo()),
        bottomNavigationBar: _loading || _erroreCaricamento != null ? null : _barraNavigazione(),
      ),
    );
  }

  Widget _corpo() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_erroreCaricamento != null) {
      return ErrorState(message: _erroreCaricamento!, retryLabel: 'Riprova', onRetry: _carica);
    }
    return Column(
      children: [
        _intestazionePassi(),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, AppSpacing.md, AppSpacing.screenPadding, AppSpacing.xxxl,
            ),
            children: _contenutoPasso(),
          ),
        ),
      ],
    );
  }

  Widget _indicatoreSalvataggio() {
    final (IconData icon, String testo, Color colore) = switch (_stato) {
      _StatoSalvataggio.salvato => (Icons.cloud_done_outlined, 'Salvato', AppColors.success),
      _StatoSalvataggio.modificato => (Icons.edit_outlined, 'Modifiche in corso…', AppColors.textMuted),
      _StatoSalvataggio.inCorso => (Icons.cloud_upload_outlined, 'Salvataggio…', AppColors.textMuted),
      _StatoSalvataggio.offline => (Icons.cloud_off_outlined, 'Offline: salvato sul telefono', AppColors.warning),
      _StatoSalvataggio.errore => (Icons.error_outline, 'Non salvato: riprova', AppColors.error),
    };
    return InkWell(
      onTap: _stato == _StatoSalvataggio.offline || _stato == _StatoSalvataggio.errore
          ? () => _salva(manuale: true)
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colore),
          const SizedBox(width: 4),
          Text(testo, style: AppTypography.caption.copyWith(color: colore)),
        ],
      ),
    );
  }

  Widget _intestazionePassi() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.sm, AppSpacing.screenPadding, AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Passaggio ${_passo + 1} di ${_passaggi.length}',
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                ),
              ),
              _indicatoreSalvataggio(),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: AppRadius.pillBr,
            child: LinearProgressIndicator(
              value: (_passo + 1) / _passaggi.length,
              minHeight: 5,
              backgroundColor: AppColors.bgSubtle,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _passaggi.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) => ChoiceChip(
                label: Text('${i + 1}. ${_passaggi[i]}'),
                selected: i == _passo,
                onSelected: (_) => _vaiA(i),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barraNavigazione() {
    final ultimo = _passo == _passaggi.length - 1;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compatta = constraints.maxWidth < 360 || MediaQuery.textScalerOf(context).scale(14) > 16;
            final indietro = _passo == 0 ? null : () => _vaiA(_passo - 1);
            return Row(
              children: [
                if (compatta)
                  IconButton(onPressed: indietro, icon: const Icon(Icons.arrow_back), tooltip: 'Indietro')
                else
                  TextButton.icon(
                    onPressed: indietro,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Indietro'),
                  ),
                const Spacer(),
                OutlinedButton(
                  onPressed: _stato == _StatoSalvataggio.inCorso ? null : () => _salva(manuale: true),
                  child: const Text('Salva bozza'),
                ),
                if (!ultimo) ...[
                  const SizedBox(width: AppSpacing.sm),
                  if (compatta)
                    FilledButton(onPressed: () => _vaiA(_passo + 1), child: const Text('Avanti'))
                  else
                    FilledButton.icon(
                      onPressed: () => _vaiA(_passo + 1),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Avanti'),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _titoloPasso(String titolo, String descrizione) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titolo, style: AppTypography.headingM),
            const SizedBox(height: 4),
            Text(descrizione, style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );

  Widget _campo(
    String label,
    TextEditingController c,
    void Function(String) set, {
    bool required = false,
    String? hint,
    TextInputType? keyboard,
    int maxLines = 1,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: AppTextField(
          label: label,
          controller: c,
          required: required,
          hint: hint,
          keyboardType: keyboard,
          maxLines: maxLines,
          onChanged: (v) {
            set(v);
            _segnaModificato();
          },
        ),
      );

  List<Widget> _contenutoPasso() {
    switch (_passo) {
      case 0:
        return _passoDatiPersonali();
      case 1:
        return _passoProfilo();
      case 2:
        return _passoEsperienze();
      case 3:
        return _passoIstruzione();
      case 4:
        return _passoLingue();
      case 5:
        return _passoCompetenze();
      case 6:
        return _passoAggiuntive();
      default:
        return _passoAnteprima();
    }
  }

  // ------------------------------------------------------------ passaggio 1

  List<Widget> _passoDatiPersonali() => [
        _titoloPasso(
          'Dati personali',
          'Abbiamo proposto i dati del tuo profilo WECOOP. Le modifiche fatte qui '
              'valgono solo per questo CV e non cambiano il tuo profilo.',
        ),
        _campo('Nome', _nome, (v) => _dati.nome = v, required: true),
        _campo('Cognome', _cognome, (v) => _dati.cognome = v, required: true),
        _campo('Email', _email, (v) => _dati.email = v,
            keyboard: TextInputType.emailAddress, hint: 'nome@esempio.it'),
        _campo('Telefono', _telefono, (v) => _dati.telefono = v,
            keyboard: TextInputType.phone, hint: '+39 333 1234567'),
        Padding(
          padding: const EdgeInsets.only(top: 0, bottom: AppSpacing.lg),
          child: Text(
            'Serve almeno un recapito: email o telefono.',
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
        ),
        _campo('Città / località', _citta, (v) => _dati.citta = v, hint: 'Es. Milano'),
        Text('Link professionali (facoltativi)', style: AppTypography.label),
        const SizedBox(height: AppSpacing.xs),
        ListaVoci<CvLink>(
          voci: _dati.links,
          titolo: (l) => l.etichetta.isEmpty ? l.url : l.etichetta,
          sottotitolo: (l) => l.etichetta.isEmpty ? '' : l.url,
          vuoto: 'Es. profilo LinkedIn o portfolio.',
          onModifica: (i) => _modificaLink(i),
          onElimina: (i) => _aggiorna(() => _dati.links.removeAt(i)),
          onSposta: (a, b) => _aggiorna(() => _dati.links.insert(b, _dati.links.removeAt(a))),
        ),
        if (_dati.links.length < 6)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _modificaLink(null),
              icon: const Icon(Icons.add_link),
              label: const Text('Aggiungi link'),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        _sezioneFoto(),
      ];

  Future<void> _modificaLink(int? i) async {
    final json = i == null ? CvLink().toJson() : _dati.links[i].toJson();
    final out = await modificaVoce(
      context,
      titolo: i == null ? 'Nuovo link' : 'Modifica link',
      json: json,
      campi: const [
        CampoVoce('etichetta', 'Etichetta', suggerimento: 'Es. LinkedIn'),
        CampoVoce('url', 'Indirizzo web', obbligatorio: true,
            suggerimento: 'https://…', tastiera: TextInputType.url),
      ],
    );
    if (out == null) return;
    _aggiorna(() {
      final link = CvLink.fromJson(out);
      if (i == null) {
        _dati.links.add(link);
      } else {
        _dati.links[i] = link;
      }
    });
  }

  Widget _sezioneFoto() {
    final haFoto = _cv?.haFoto == true;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 72,
              height: 88,
              color: AppColors.bgSubtle,
              child: _caricandoFoto
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : (_foto != null
                      ? Image.memory(_foto!, fit: BoxFit.cover)
                      : const Icon(Icons.person_outline, size: 36, color: AppColors.iconInactive)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Foto (facoltativa)', style: AppTypography.label),
                Text(
                  'Non è obbligatoria. Molti datori di lavoro valutano il CV anche senza foto.',
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                ),
                if (haFoto)
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text('Includi la foto nel PDF'),
                    value: _dati.includiFoto,
                    onChanged: (v) => _aggiorna(() => _dati.includiFoto = v),
                  ),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    TextButton(
                      onPressed: _caricandoFoto ? null : _scegliFoto,
                      child: Text(haFoto ? 'Cambia foto' : 'Aggiungi foto'),
                    ),
                    if (haFoto)
                      TextButton(
                        onPressed: _caricandoFoto ? null : _rimuoviFoto,
                        child: const Text('Rimuovi', style: TextStyle(color: AppColors.error)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ passaggio 2

  List<Widget> _passoProfilo() => [
        _titoloPasso(
          'Profilo professionale',
          'Facoltativo. Indica la posizione che cerchi e presentati in poche righe.',
        ),
        _campo('Posizione ricercata', _titoloProfilo,
            (v) => _dati.titoloProfilo = v, hint: 'Es. Addetta alle vendite'),
        _campo('Breve presentazione', _presentazione, (v) => _dati.presentazione = v,
            hint: 'Chi sei, cosa sai fare, cosa cerchi', keyboard: TextInputType.multiline, maxLines: 7),
      ];

  // ------------------------------------------------------------ passaggio 3

  static const _campiEsperienza = [
    CampoVoce('ruolo', 'Ruolo / mansione', obbligatorio: true, suggerimento: 'Es. Cameriere'),
    CampoVoce('datore', 'Datore di lavoro / organizzazione'),
    CampoVoce('localita', 'Località', suggerimento: 'Es. Torino'),
    CampoVoce('descrizione', 'Attività e risultati', multilinea: true,
        suggerimento: 'Cosa facevi, di cosa eri responsabile, risultati ottenuti'),
  ];

  List<Widget> _passoEsperienze() => [
        _titoloPasso(
          'Esperienze lavorative',
          'Aggiungi i lavori svolti, dal più recente. Puoi riordinarli con le frecce. '
              'Se non hai esperienze, passa pure al passaggio successivo.',
        ),
        ListaVoci<CvEsperienza>(
          voci: _dati.esperienze,
          titolo: (e) => e.ruolo,
          sottotitolo: (e) => [e.datore, e.periodo.etichetta].where((s) => s.isNotEmpty).join(' · '),
          vuoto: 'Nessuna esperienza inserita.',
          onModifica: (i) => _modificaEsperienza(i),
          onElimina: (i) async {
            if (await confermaEliminazione(context, 'questa esperienza')) {
              _aggiorna(() => _dati.esperienze.removeAt(i));
            }
          },
          onSposta: (a, b) => _aggiorna(() => _dati.esperienze.insert(b, _dati.esperienze.removeAt(a))),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Aggiungi esperienza',
          icon: Icons.add,
          variant: AppButtonVariant.secondary,
          onPressed: () => _modificaEsperienza(null),
        ),
      ];

  Future<void> _modificaEsperienza(int? i) async {
    final out = await modificaVoce(
      context,
      titolo: i == null ? 'Nuova esperienza' : 'Modifica esperienza',
      json: i == null ? CvEsperienza().toJson() : _dati.esperienze[i].toJson(),
      campi: _campiEsperienza,
      conPeriodo: true,
    );
    if (out == null) return;
    _aggiorna(() {
      final v = CvEsperienza.fromJson(out);
      if (i == null) {
        _dati.esperienze.add(v);
      } else {
        _dati.esperienze[i] = v;
      }
    });
  }

  // ------------------------------------------------------------ passaggio 4

  static const _campiIstruzione = [
    CampoVoce('titolo', 'Titolo o qualifica', obbligatorio: true, suggerimento: 'Es. Diploma di ragioneria'),
    CampoVoce('istituto', 'Istituto / ente di formazione'),
    CampoVoce('localita', 'Località'),
    CampoVoce('descrizione', 'Contenuti rilevanti', multilinea: true),
  ];

  List<Widget> _passoIstruzione() => [
        _titoloPasso(
          'Istruzione e formazione',
          'Titoli di studio, corsi e qualifiche. Puoi indicare anche titoli ottenuti all\'estero.',
        ),
        ListaVoci<CvIstruzione>(
          voci: _dati.istruzione,
          titolo: (e) => e.titolo,
          sottotitolo: (e) => [e.istituto, e.periodo.etichetta].where((s) => s.isNotEmpty).join(' · '),
          vuoto: 'Nessun titolo inserito.',
          onModifica: (i) => _modificaIstruzione(i),
          onElimina: (i) async {
            if (await confermaEliminazione(context, 'questa voce')) {
              _aggiorna(() => _dati.istruzione.removeAt(i));
            }
          },
          onSposta: (a, b) => _aggiorna(() => _dati.istruzione.insert(b, _dati.istruzione.removeAt(a))),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Aggiungi formazione',
          icon: Icons.add,
          variant: AppButtonVariant.secondary,
          onPressed: () => _modificaIstruzione(null),
        ),
      ];

  Future<void> _modificaIstruzione(int? i) async {
    final out = await modificaVoce(
      context,
      titolo: i == null ? 'Nuova voce' : 'Modifica voce',
      json: i == null ? CvIstruzione().toJson() : _dati.istruzione[i].toJson(),
      campi: _campiIstruzione,
      conPeriodo: true,
    );
    if (out == null) return;
    _aggiorna(() {
      final v = CvIstruzione.fromJson(out);
      if (i == null) {
        _dati.istruzione.add(v);
      } else {
        _dati.istruzione[i] = v;
      }
    });
  }

  // ------------------------------------------------------------ passaggio 5

  List<Widget> _passoLingue() => [
        _titoloPasso(
          'Competenze linguistiche',
          'Indica la tua lingua madre e le altre lingue che conosci con il livello che ti attribuisci.',
        ),
        EditorEtichette(
          etichetta: 'Lingua madre',
          suggerimento: 'Es. Spagnolo',
          valori: _dati.madrelingua,
          onChanged: (v) => _aggiorna(() => _dati.madrelingua = v),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Altre lingue', style: AppTypography.label),
        const SizedBox(height: AppSpacing.xs),
        ListaVoci<CvLingua>(
          voci: _dati.altreLingue,
          titolo: (l) => l.lingua,
          sottotitolo: (l) => [descrizioneQcer[l.livello] ?? '', l.note].where((s) => s.isNotEmpty).join(' · '),
          vuoto: 'Nessuna lingua aggiunta.',
          onModifica: (i) => _modificaLingua(i),
          onElimina: (i) => _aggiorna(() => _dati.altreLingue.removeAt(i)),
          onSposta: (a, b) => _aggiorna(() => _dati.altreLingue.insert(b, _dati.altreLingue.removeAt(a))),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Aggiungi lingua',
          icon: Icons.add,
          variant: AppButtonVariant.secondary,
          onPressed: () => _modificaLingua(null),
        ),
      ];

  Future<void> _modificaLingua(int? i) async {
    final out = await modificaVoce(
      context,
      titolo: i == null ? 'Nuova lingua' : 'Modifica lingua',
      json: i == null ? CvLingua().toJson() : _dati.altreLingue[i].toJson(),
      campi: const [
        CampoVoce('lingua', 'Lingua', obbligatorio: true, suggerimento: 'Es. Italiano'),
        CampoVoce('note', 'Note (facoltative)', suggerimento: 'Es. Certificazione CILS B1'),
      ],
      conLivelloQcer: true,
    );
    if (out == null) return;
    _aggiorna(() {
      final v = CvLingua.fromJson(out);
      if (i == null) {
        _dati.altreLingue.add(v);
      } else {
        _dati.altreLingue[i] = v;
      }
    });
  }

  // ------------------------------------------------------------ passaggio 6

  List<Widget> _passoCompetenze() => [
        _titoloPasso('Competenze', 'Tutte le voci sono facoltative. Aggiungi solo ciò che è utile.'),
        EditorEtichette(
          etichetta: 'Competenze digitali',
          suggerimento: 'Es. Excel, posta elettronica',
          valori: _dati.competenzeDigitali,
          onChanged: (v) => _aggiorna(() => _dati.competenzeDigitali = v),
        ),
        const SizedBox(height: AppSpacing.xl),
        EditorEtichette(
          etichetta: 'Competenze professionali',
          suggerimento: 'Es. Uso del muletto, cucina',
          valori: _dati.competenzeProfessionali,
          onChanged: (v) => _aggiorna(() => _dati.competenzeProfessionali = v),
        ),
        const SizedBox(height: AppSpacing.xl),
        EditorEtichette(
          etichetta: 'Competenze organizzative',
          suggerimento: 'Es. Gestione dei turni',
          valori: _dati.competenzeOrganizzative,
          onChanged: (v) => _aggiorna(() => _dati.competenzeOrganizzative = v),
        ),
        const SizedBox(height: AppSpacing.xl),
        EditorEtichette(
          etichetta: 'Competenze relazionali',
          suggerimento: 'Es. Lavoro in squadra',
          valori: _dati.competenzeRelazionali,
          onChanged: (v) => _aggiorna(() => _dati.competenzeRelazionali = v),
        ),
      ];

  // ------------------------------------------------------------ passaggio 7

  List<Widget> _passoAggiuntive() => [
        _titoloPasso('Informazioni aggiuntive', 'Sezioni facoltative: compila solo quelle utili alla candidatura.'),
        Text('Certificazioni', style: AppTypography.label),
        const SizedBox(height: AppSpacing.xs),
        ListaVoci<CvCertificazione>(
          voci: _dati.certificazioni,
          titolo: (c) => c.titolo,
          sottotitolo: (c) => [c.ente, c.anno].where((s) => s.isNotEmpty).join(' · '),
          vuoto: 'Es. HACCP, sicurezza sul lavoro.',
          onModifica: (i) => _modificaCertificazione(i),
          onElimina: (i) => _aggiorna(() => _dati.certificazioni.removeAt(i)),
          onSposta: (a, b) => _aggiorna(() => _dati.certificazioni.insert(b, _dati.certificazioni.removeAt(a))),
        ),
        _bottoneAggiungi('Aggiungi certificazione', () => _modificaCertificazione(null)),
        const SizedBox(height: AppSpacing.lg),
        Text('Progetti', style: AppTypography.label),
        const SizedBox(height: AppSpacing.xs),
        ListaVoci<CvProgetto>(
          voci: _dati.progetti,
          titolo: (p) => p.titolo,
          sottotitolo: (p) => p.descrizione.split('\n').first,
          vuoto: 'Nessun progetto.',
          onModifica: (i) => _modificaProgetto(i),
          onElimina: (i) => _aggiorna(() => _dati.progetti.removeAt(i)),
          onSposta: (a, b) => _aggiorna(() => _dati.progetti.insert(b, _dati.progetti.removeAt(a))),
        ),
        _bottoneAggiungi('Aggiungi progetto', () => _modificaProgetto(null)),
        const SizedBox(height: AppSpacing.lg),
        Text('Volontariato', style: AppTypography.label),
        const SizedBox(height: AppSpacing.xs),
        ListaVoci<CvVolontariato>(
          voci: _dati.volontariato,
          titolo: (v) => v.ruolo,
          sottotitolo: (v) => [v.organizzazione, v.periodo.etichetta].where((s) => s.isNotEmpty).join(' · '),
          vuoto: 'Nessuna attività di volontariato.',
          onModifica: (i) => _modificaVolontariato(i),
          onElimina: (i) => _aggiorna(() => _dati.volontariato.removeAt(i)),
          onSposta: (a, b) => _aggiorna(() => _dati.volontariato.insert(b, _dati.volontariato.removeAt(a))),
        ),
        _bottoneAggiungi('Aggiungi volontariato', () => _modificaVolontariato(null)),
        const SizedBox(height: AppSpacing.lg),
        EditorEtichette(
          etichetta: 'Patente di guida',
          suggerimento: 'Es. B',
          valori: _dati.patenti,
          onChanged: (v) => _aggiorna(() => _dati.patenti = v),
        ),
        const SizedBox(height: AppSpacing.xl),
        _campo('Altre informazioni', _altro, (v) => _dati.altro = v,
            hint: 'Es. disponibilità a turni, trasferte', keyboard: TextInputType.multiline, maxLines: 5),
      ];

  Widget _bottoneAggiungi(String label, VoidCallback onTap) => Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(onPressed: onTap, icon: const Icon(Icons.add), label: Text(label)),
      );

  Future<void> _modificaCertificazione(int? i) async {
    final out = await modificaVoce(
      context,
      titolo: i == null ? 'Nuova certificazione' : 'Modifica certificazione',
      json: i == null ? CvCertificazione().toJson() : _dati.certificazioni[i].toJson(),
      campi: const [
        CampoVoce('titolo', 'Certificazione', obbligatorio: true),
        CampoVoce('ente', 'Ente che l\'ha rilasciata'),
      ],
      conAnno: true,
    );
    if (out == null) return;
    _aggiorna(() {
      final v = CvCertificazione.fromJson(out);
      if (i == null) {
        _dati.certificazioni.add(v);
      } else {
        _dati.certificazioni[i] = v;
      }
    });
  }

  Future<void> _modificaProgetto(int? i) async {
    final out = await modificaVoce(
      context,
      titolo: i == null ? 'Nuovo progetto' : 'Modifica progetto',
      json: i == null ? CvProgetto().toJson() : _dati.progetti[i].toJson(),
      campi: const [
        CampoVoce('titolo', 'Nome del progetto', obbligatorio: true),
        CampoVoce('descrizione', 'Descrizione', multilinea: true),
      ],
    );
    if (out == null) return;
    _aggiorna(() {
      final v = CvProgetto.fromJson(out);
      if (i == null) {
        _dati.progetti.add(v);
      } else {
        _dati.progetti[i] = v;
      }
    });
  }

  Future<void> _modificaVolontariato(int? i) async {
    final out = await modificaVoce(
      context,
      titolo: i == null ? 'Nuova attività' : 'Modifica attività',
      json: i == null ? CvVolontariato().toJson() : _dati.volontariato[i].toJson(),
      campi: const [
        CampoVoce('ruolo', 'Ruolo / attività', obbligatorio: true),
        CampoVoce('organizzazione', 'Organizzazione'),
        CampoVoce('descrizione', 'Descrizione', multilinea: true),
      ],
      conPeriodo: true,
    );
    if (out == null) return;
    _aggiorna(() {
      final v = CvVolontariato.fromJson(out);
      if (i == null) {
        _dati.volontariato.add(v);
      } else {
        _dati.volontariato[i] = v;
      }
    });
  }

  // ------------------------------------------------------------ passaggio 8

  List<Widget> _passoAnteprima() {
    final problemi = _dati.problemiPerPdf();
    final cv = _cv!;
    final pdfAggiornato = cv.ultimoPdf != null && !cv.modificheNonGenerate && _stato == _StatoSalvataggio.salvato;
    return [
      _titoloPasso(
        'Anteprima e PDF',
        'Controlla i dati. Puoi tornare a qualsiasi sezione toccando i passaggi in alto.',
      ),
      if (problemi.isNotEmpty) ...[
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: AppRadius.cardBr),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Prima di generare il PDF', style: AppTypography.headingS),
              const SizedBox(height: AppSpacing.xs),
              for (final p in problemi) Text('• $p', style: AppTypography.bodyM),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
      _Anteprima(dati: _dati, foto: _dati.includiFoto ? _foto : null),
      const SizedBox(height: AppSpacing.xl),
      if (cv.ultimoPdf != null)
        Text(
          pdfAggiornato
              ? 'PDF aggiornato: versione ${cv.ultimoPdf!.versione} del ${formatData(cv.ultimoPdf!.createdAt)}.'
              : 'Hai fatto modifiche dopo l\'ultimo PDF (versione ${cv.ultimoPdf!.versione}). '
                  'Generando di nuovo verrà creata una nuova versione; la precedente resta disponibile.',
          style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
        ),
      for (final a in _avvisiPdf)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Text(a, style: AppTypography.bodyM.copyWith(color: AppColors.warning)),
        ),
      const SizedBox(height: AppSpacing.md),
      AppButton(
        label: cv.ultimoPdf == null ? 'Genera PDF' : 'Genera nuova versione PDF',
        icon: Icons.picture_as_pdf_outlined,
        loading: _generando,
        onPressed: problemi.isEmpty && !pdfAggiornato ? _generaPdf : null,
      ),
      if (cv.ultimoPdf != null) ...[
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _generando
                    ? null
                    : () async {
                        final f = await _pdfCorrente();
                        if (f != null && mounted) await apriPdf(context, f, titolo: cv.titolo);
                      },
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Visualizza'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Builder(
                builder: (btnCtx) => OutlinedButton.icon(
                  onPressed: _generando
                      ? null
                      : () async {
                          final f = await _pdfCorrente();
                          if (f != null && btnCtx.mounted) await condividiPdf(btnCtx, f, titolo: cv.titolo);
                        },
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Scarica'),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _generando
                    ? null
                    : () async {
                        final f = await _pdfCorrente();
                        if (f != null && mounted) await mostraGuidaStampa(context, f, cv.titolo);
                      },
                icon: const Icon(Icons.print_outlined),
                label: const Text('Stampa'),
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () => mostraVersioniPdf(context, cv),
          icon: const Icon(Icons.history),
          label: const Text('Versioni precedenti'),
        ),
      ],
    ];
  }
}

/// Anteprima nativa dei contenuti (stessa struttura del PDF).
class _Anteprima extends StatelessWidget {
  const _Anteprima({required this.dati, this.foto});

  final CvDati dati;
  final Uint8List? foto;

  @override
  Widget build(BuildContext context) {
    final contatti = [dati.email, dati.telefono, dati.citta].where((s) => s.trim().isNotEmpty).join(' · ');
    final sezioni = <Widget>[];

    void sezione(String titolo, List<Widget> figli) {
      if (figli.isEmpty) return;
      sezioni.addAll([
        const SizedBox(height: AppSpacing.lg),
        Text(
          titolo.toUpperCase(),
          style: AppTypography.overline.copyWith(color: AppColors.primaryDark, letterSpacing: 1),
        ),
        const Divider(height: 10),
        ...figli,
      ]);
    }

    Widget voce(String periodo, String titolo, String sotto, String descr) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (periodo.isNotEmpty)
                Text(periodo, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              Text(titolo, style: AppTypography.bodyL.copyWith(fontWeight: FontWeight.w700)),
              if (sotto.isNotEmpty) Text(sotto, style: AppTypography.bodyM),
              if (descr.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(descr, style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary)),
                ),
            ],
          ),
        );

    Widget riga(String etichetta, String valore) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text.rich(TextSpan(children: [
            TextSpan(text: '$etichetta: ', style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: valore),
          ])),
        );

    if (dati.presentazione.trim().isNotEmpty) {
      sezione('Profilo professionale', [Text(dati.presentazione, style: AppTypography.bodyM)]);
    }
    sezione('Esperienza lavorativa', [
      for (final e in dati.esperienze)
        voce(e.periodo.etichetta, e.ruolo, [e.datore, e.localita].where((s) => s.isNotEmpty).join(' · '), e.descrizione),
    ]);
    sezione('Istruzione e formazione', [
      for (final e in dati.istruzione)
        voce(e.periodo.etichetta, e.titolo, [e.istituto, e.localita].where((s) => s.isNotEmpty).join(' · '), e.descrizione),
    ]);
    sezione('Competenze linguistiche', [
      if (dati.madrelingua.isNotEmpty) riga('Lingua madre', dati.madrelingua.join(', ')),
      for (final l in dati.altreLingue)
        riga(l.lingua, [descrizioneQcer[l.livello] ?? 'livello non indicato', l.note].where((s) => s.isNotEmpty).join(' · ')),
    ]);
    sezione('Competenze', [
      if (dati.competenzeDigitali.isNotEmpty) riga('Digitali', dati.competenzeDigitali.join(' · ')),
      if (dati.competenzeProfessionali.isNotEmpty) riga('Professionali', dati.competenzeProfessionali.join(' · ')),
      if (dati.competenzeOrganizzative.isNotEmpty) riga('Organizzative', dati.competenzeOrganizzative.join(' · ')),
      if (dati.competenzeRelazionali.isNotEmpty) riga('Relazionali', dati.competenzeRelazionali.join(' · ')),
    ]);
    sezione('Informazioni aggiuntive', [
      for (final c in dati.certificazioni)
        riga('Certificazione', [c.titolo, c.ente, c.anno].where((s) => s.isNotEmpty).join(' · ')),
      for (final p in dati.progetti) voce('', p.titolo, '', p.descrizione),
      for (final v in dati.volontariato) voce(v.periodo.etichetta, v.ruolo, v.organizzazione, v.descrizione),
      if (dati.patenti.isNotEmpty) riga('Patente di guida', dati.patenti.join(', ')),
      if (dati.altro.trim().isNotEmpty) riga('Altre informazioni', dati.altro),
    ]);

    final nomeCompleto = '${dati.nome} ${dati.cognome}'.trim();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nomeCompleto.isEmpty ? 'Nome e cognome' : nomeCompleto, style: AppTypography.headingM),
                    if (dati.titoloProfilo.trim().isNotEmpty)
                      Text(dati.titoloProfilo, style: AppTypography.bodyL.copyWith(color: AppColors.primaryDark)),
                    if (contatti.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(contatti, style: AppTypography.bodyM),
                      ),
                    for (final l in dati.links)
                      Text(l.url, style: AppTypography.caption.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
              if (foto != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.memory(foto!, width: 56, height: 68, fit: BoxFit.cover),
                ),
            ],
          ),
          ...sezioni,
        ],
      ),
    );
  }
}
