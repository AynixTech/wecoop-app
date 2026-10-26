import 'package:flutter/material.dart';

import '../../models/curriculum_cv.dart';
import '../../theme/theme.dart';
import '../../widgets/design_system/design_system.dart';

/// Campo testuale di una voce (esperienza, istruzione, ...).
class CampoVoce {
  final String chiave;
  final String etichetta;
  final bool obbligatorio;
  final bool multilinea;
  final String? suggerimento;
  final TextInputType? tastiera;

  const CampoVoce(
    this.chiave,
    this.etichetta, {
    this.obbligatorio = false,
    this.multilinea = false,
    this.suggerimento,
    this.tastiera,
  });
}

const _mesi = [
  'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
  'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre',
];

String etichettaMese(String valore) {
  if (valore.isEmpty) return '';
  final parts = valore.split('-');
  if (parts.length < 2) return parts[0];
  final m = int.tryParse(parts[1]) ?? 0;
  return m >= 1 && m <= 12 ? '${_mesi[m - 1]} ${parts[0]}' : parts[0];
}

/// Selettore mese/anno: restituisce 'YYYY-MM', 'YYYY' oppure '' (cancellato).
Future<String?> scegliMese(BuildContext context, {required String titolo, String iniziale = ''}) {
  final oggi = DateTime.now();
  final parts = iniziale.split('-');
  int? anno = int.tryParse(parts.isNotEmpty ? parts[0] : '');
  int? mese = parts.length > 1 ? int.tryParse(parts[1]) : null;
  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        title: Text(titolo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int?>(
              value: mese,
              decoration: const InputDecoration(labelText: 'Mese (facoltativo)'),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('—')),
                for (var i = 1; i <= 12; i++)
                  DropdownMenuItem<int?>(value: i, child: Text(_mesi[i - 1])),
              ],
              onChanged: (v) => setLocal(() => mese = v),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<int>(
              value: anno,
              decoration: const InputDecoration(labelText: 'Anno'),
              menuMaxHeight: 320,
              items: [
                for (var y = oggi.year + 6; y >= 1950; y--)
                  DropdownMenuItem<int>(value: y, child: Text('$y')),
              ],
              onChanged: (v) => setLocal(() => anno = v),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, ''), child: const Text('Cancella')),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          FilledButton(
            onPressed: anno == null
                ? null
                : () => Navigator.pop(
                      ctx,
                      mese == null ? '$anno' : '$anno-${mese.toString().padLeft(2, '0')}',
                    ),
            child: const Text('OK'),
          ),
        ],
      ),
    ),
  );
}

class _CampoMese extends StatelessWidget {
  const _CampoMese({required this.etichetta, required this.valore, required this.onChanged, this.enabled = true});

  final String etichetta;
  final String valore;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.inputBr,
      onTap: !enabled
          ? null
          : () async {
              final v = await scegliMese(context, titolo: etichetta, iniziale: valore);
              if (v != null) onChanged(v);
            },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etichetta,
          enabled: enabled,
          border: OutlineInputBorder(borderRadius: AppRadius.inputBr),
          suffixIcon: const Icon(Icons.calendar_month_outlined),
          isDense: true,
        ),
        child: Text(
          valore.isEmpty ? (enabled ? 'Seleziona' : '—') : etichettaMese(valore),
          style: AppTypography.bodyL.copyWith(
            color: valore.isEmpty ? AppColors.textMuted : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Modulo a schermo intero per aggiungere/modificare una voce.
/// Lavora su una copia JSON: annullando, la voce originale non cambia.
Future<Map<String, dynamic>?> modificaVoce(
  BuildContext context, {
  required String titolo,
  required Map<String, dynamic> json,
  required List<CampoVoce> campi,
  bool conPeriodo = false,
  bool conLivelloQcer = false,
  bool conAnno = false,
}) {
  return Navigator.push<Map<String, dynamic>>(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _ModuloVoce(
        titolo: titolo,
        json: Map<String, dynamic>.from(json),
        campi: campi,
        conPeriodo: conPeriodo,
        conLivelloQcer: conLivelloQcer,
        conAnno: conAnno,
      ),
    ),
  );
}

class _ModuloVoce extends StatefulWidget {
  const _ModuloVoce({
    required this.titolo,
    required this.json,
    required this.campi,
    required this.conPeriodo,
    required this.conLivelloQcer,
    required this.conAnno,
  });

  final String titolo;
  final Map<String, dynamic> json;
  final List<CampoVoce> campi;
  final bool conPeriodo;
  final bool conLivelloQcer;
  final bool conAnno;

  @override
  State<_ModuloVoce> createState() => _ModuloVoceState();
}

class _ModuloVoceState extends State<_ModuloVoce> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _ctrl = {
    for (final c in widget.campi) c.chiave: TextEditingController(text: (widget.json[c.chiave] ?? '').toString()),
  };
  late String _inizio = (widget.json['inizio'] ?? '').toString();
  late String _fine = (widget.json['fine'] ?? '').toString();
  late bool _inCorso = widget.json['inCorso'] == true;
  late String _livello = (widget.json['livello'] ?? '').toString();
  late String _anno = (widget.json['anno'] ?? '').toString();
  String? _erroreDate;

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _conferma() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.conPeriodo && _inizio.isNotEmpty && _fine.isNotEmpty && !_inCorso && _fine.compareTo(_inizio) < 0) {
      setState(() => _erroreDate = 'La data di fine non può essere precedente alla data di inizio.');
      return;
    }
    final out = Map<String, dynamic>.from(widget.json);
    for (final e in _ctrl.entries) {
      out[e.key] = e.value.text.trim();
    }
    if (widget.conPeriodo) {
      out['inizio'] = _inizio;
      out['fine'] = _inCorso ? '' : _fine;
      out['inCorso'] = _inCorso;
    }
    if (widget.conLivelloQcer) out['livello'] = _livello;
    if (widget.conAnno) out['anno'] = _anno;
    Navigator.pop(context, out);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titolo),
        actions: [TextButton(onPressed: _conferma, child: const Text('Fatto'))],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              for (final c in widget.campi) ...[
                AppTextField(
                  label: c.etichetta,
                  controller: _ctrl[c.chiave],
                  required: c.obbligatorio,
                  hint: c.suggerimento,
                  keyboardType: c.multilinea ? TextInputType.multiline : c.tastiera,
                  maxLines: c.multilinea ? 6 : 1,
                  validator: c.obbligatorio
                      ? (v) => (v ?? '').trim().isEmpty ? 'Campo obbligatorio' : null
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (widget.conLivelloQcer) ...[
                DropdownButtonFormField<String>(
                  value: livelliQcer.contains(_livello) ? _livello : '',
                  decoration: const InputDecoration(labelText: 'Livello (autovalutazione QCER)'),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('Non indicato')),
                    for (final l in livelliQcer)
                      DropdownMenuItem(value: l, child: Text(descrizioneQcer[l]!)),
                  ],
                  onChanged: (v) => setState(() => _livello = v ?? ''),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'A1–A2: base · B1–B2: autonomo · C1–C2: padronanza. '
                  'È una tua dichiarazione, non una certificazione.',
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (widget.conAnno) ...[
                _CampoMese(
                  etichetta: 'Anno di conseguimento',
                  valore: _anno,
                  onChanged: (v) => setState(() => _anno = v.split('-').first),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (widget.conPeriodo) ...[
                Row(
                  children: [
                    Expanded(
                      child: _CampoMese(
                        etichetta: 'Inizio',
                        valore: _inizio,
                        onChanged: (v) => setState(() {
                          _inizio = v;
                          _erroreDate = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _CampoMese(
                        etichetta: 'Fine',
                        valore: _inCorso ? '' : _fine,
                        enabled: !_inCorso,
                        onChanged: (v) => setState(() {
                          _fine = v;
                          _erroreDate = null;
                        }),
                      ),
                    ),
                  ],
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('In corso'),
                  value: _inCorso,
                  onChanged: (v) => setState(() {
                    _inCorso = v;
                    _erroreDate = null;
                  }),
                ),
                if (_erroreDate != null)
                  Text(_erroreDate!, style: AppTypography.bodyM.copyWith(color: AppColors.error)),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: 'Salva voce', onPressed: _conferma),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> confermaEliminazione(BuildContext context, String cosa) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Eliminare $cosa?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annulla')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Elimina')),
      ],
    ),
  );
  return r == true;
}

/// Elenco di voci con modifica, eliminazione e riordino (frecce su/giù).
class ListaVoci<T> extends StatelessWidget {
  const ListaVoci({
    super.key,
    required this.voci,
    required this.titolo,
    required this.sottotitolo,
    required this.onModifica,
    required this.onElimina,
    required this.onSposta,
    required this.vuoto,
  });

  final List<T> voci;
  final String Function(T) titolo;
  final String Function(T) sottotitolo;
  final void Function(int index) onModifica;
  final void Function(int index) onElimina;
  final void Function(int from, int to) onSposta;
  final String vuoto;

  @override
  Widget build(BuildContext context) {
    if (voci.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(vuoto, style: AppTypography.bodyM.copyWith(color: AppColors.textMuted)),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < voci.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.xs, AppSpacing.sm),
              onTap: () => onModifica(i),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titolo(voci[i]).isEmpty ? '(senza titolo)' : titolo(voci[i]),
                          style: AppTypography.bodyL.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (sottotitolo(voci[i]).isNotEmpty)
                          Text(
                            sottotitolo(voci[i]),
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Sposta su',
                    visualDensity: VisualDensity.compact,
                    onPressed: i == 0 ? null : () => onSposta(i, i - 1),
                    icon: const Icon(Icons.arrow_upward),
                  ),
                  IconButton(
                    tooltip: 'Sposta giù',
                    visualDensity: VisualDensity.compact,
                    onPressed: i == voci.length - 1 ? null : () => onSposta(i, i + 1),
                    icon: const Icon(Icons.arrow_downward),
                  ),
                  IconButton(
                    tooltip: 'Elimina',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => onElimina(i),
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Elenco di voci brevi (competenze, patenti, lingue madre) riordinabili.
class EditorEtichette extends StatefulWidget {
  const EditorEtichette({
    super.key,
    required this.etichetta,
    required this.valori,
    required this.onChanged,
    this.suggerimento,
    this.descrizione,
  });

  final String etichetta;
  final String? descrizione;
  final String? suggerimento;
  final List<String> valori;
  final ValueChanged<List<String>> onChanged;

  @override
  State<EditorEtichette> createState() => _EditorEtichetteState();
}

class _EditorEtichetteState extends State<EditorEtichette> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _aggiungi() {
    final v = _ctrl.text.trim();
    if (v.isEmpty) return;
    if (widget.valori.any((e) => e.toLowerCase() == v.toLowerCase())) {
      _ctrl.clear();
      return;
    }
    widget.onChanged([...widget.valori, v]);
    _ctrl.clear();
  }

  void _sposta(int from, int to) {
    final list = [...widget.valori];
    final item = list.removeAt(from);
    list.insert(to, item);
    widget.onChanged(list);
  }

  @override
  Widget build(BuildContext context) {
    final valori = widget.valori;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.etichetta, style: AppTypography.label),
        if (widget.descrizione != null)
          Text(widget.descrizione!, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: AppSpacing.xs),
        for (var i = 0; i < valori.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.only(left: AppSpacing.md),
            decoration: BoxDecoration(color: AppColors.chipBg, borderRadius: AppRadius.inputBr),
            child: Row(
              children: [
                Expanded(child: Text(valori[i], style: AppTypography.bodyM)),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Sposta su',
                  onPressed: i == 0 ? null : () => _sposta(i, i - 1),
                  icon: const Icon(Icons.arrow_upward, size: 18),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Rimuovi',
                  onPressed: () => widget.onChanged([...valori]..removeAt(i)),
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _aggiungi(),
                decoration: InputDecoration(
                  hintText: widget.suggerimento ?? 'Aggiungi…',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: AppRadius.inputBr),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filledTonal(
              tooltip: 'Aggiungi',
              onPressed: _aggiungi,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}
