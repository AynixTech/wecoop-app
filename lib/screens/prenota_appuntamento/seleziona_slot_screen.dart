import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/appuntamento_model.dart';
import '../../services/appuntamenti_service.dart';
import '../../services/app_localizations.dart';

/// Pagina di selezione slot appuntamento (stile Calendly).
///
/// Mostra gli slot proposti dall'operatore per una richiesta di servizio,
/// raggruppati per giorno. Se esiste gia' un appuntamento confermato, mostra
/// il riepilogo con opzioni di annullamento/riprogrammazione.
class SelezionaSlotScreen extends StatefulWidget {
  final int richiestaId;
  final String? servizioLabel;

  const SelezionaSlotScreen({
    super.key,
    required this.richiestaId,
    this.servizioLabel,
  });

  @override
  State<SelezionaSlotScreen> createState() => _SelezionaSlotScreenState();
}

class _SelezionaSlotScreenState extends State<SelezionaSlotScreen> {
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  List<AppuntamentoSlot> _slots = [];
  Appuntamento? _appuntamento;
  int? _selectedSlotId;

  /// Se true, siamo in modalita' riprogrammazione (mostra slot anche se c'e' appuntamento).
  bool _rescheduling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await AppuntamentiService.getSlot(widget.richiestaId);
    if (!mounted) return;
    if (res['success'] == true) {
      final data = res['data'] as SlotDisponibilita;
      setState(() {
        _slots = data.slots;
        _appuntamento = data.appuntamento;
        _selectedSlotId = null;
        _loading = false;
      });
    } else {
      setState(() {
        _error = res['message']?.toString();
        _loading = false;
      });
    }
  }

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  String _tr(String key, String fallback) {
    final v = _l10n.translate(key);
    return v == key ? fallback : v;
  }

  /// Raggruppa gli slot per giorno (chiave yyyy-MM-dd).
  Map<DateTime, List<AppuntamentoSlot>> _groupByDay() {
    final map = <DateTime, List<AppuntamentoSlot>>{};
    for (final s in _slots) {
      final d = s.dataOra;
      if (d == null) continue;
      final key = DateTime(d.year, d.month, d.day);
      map.putIfAbsent(key, () => []).add(s);
    }
    final sortedKeys = map.keys.toList()..sort();
    return {for (final k in sortedKeys) k: (map[k]!..sort((a, b) => a.dataOra!.compareTo(b.dataOra!)))};
  }

  Future<void> _confirmBooking() async {
    if (_selectedSlotId == null) return;
    setState(() => _submitting = true);

    final Map<String, dynamic> res;
    if (_rescheduling && _appuntamento != null) {
      res = await AppuntamentiService.riprogramma(
        appuntamentoId: _appuntamento!.id,
        nuovoSlotId: _selectedSlotId!,
      );
    } else {
      res = await AppuntamentiService.prenota(
        richiestaId: widget.richiestaId,
        slotId: _selectedSlotId!,
      );
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    if (res['success'] == true) {
      final scheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr('appointmentConfirmed', 'Appuntamento confermato')),
          backgroundColor: scheme.secondary,
        ),
      );
      Navigator.pop(context, true);
    } else {
      _showError(res['message']?.toString() ?? _tr('connectionError', 'Errore di connessione'));
    }
  }

  Future<void> _cancelAppointment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_tr('cancelAppointment', 'Annulla appuntamento')),
        content: Text(_tr('cancelAppointmentConfirm',
            'Vuoi annullare questo appuntamento? Potrai sceglierne uno nuovo tra gli slot disponibili.')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(_l10n.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            child: Text(_tr('confirm', 'Conferma')),
          ),
        ],
      ),
    );
    if (confirmed != true || _appuntamento == null) return;

    setState(() => _submitting = true);
    final res = await AppuntamentiService.annulla(_appuntamento!.id);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (res['success'] == true) {
      await _load();
    } else {
      _showError(res['message']?.toString() ?? _tr('connectionError', 'Errore di connessione'));
    }
  }

  void _showError(String message) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: scheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tr('bookAppointment', 'Prenota appuntamento')),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _buildMessageState(
        icon: Icons.error_outline,
        title: _tr('errorLoading', 'Errore nel caricamento'),
        subtitle: _error,
      );
    }

    // Appuntamento gia' confermato e non in riprogrammazione.
    if (_appuntamento != null && _appuntamento!.isConfirmed && !_rescheduling) {
      return _buildConfirmedView();
    }

    if (_slots.isEmpty) {
      return _buildMessageState(
        icon: Icons.event_busy,
        title: _tr('noSlotsAvailable', 'Nessuno slot disponibile'),
        subtitle: _tr('noSlotsAvailableDesc',
            'Al momento non ci sono date disponibili. Riprova piu tardi o contatta l\'operatore.'),
      );
    }

    return _buildSlotSelection();
  }

  Widget _buildMessageState({required IconData icon, required String title, String? subtitle}) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 60),
        Icon(icon, size: 64, color: scheme.onSurface.withOpacity(0.4)),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurface.withOpacity(0.7)),
          ),
        ],
      ],
    );
  }

  Widget _buildConfirmedView() {
    final scheme = Theme.of(context).colorScheme;
    final appt = _appuntamento!;
    final dateFmt = _formatFullDate(appt.dataOra);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.secondary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.secondary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.event_available, color: scheme.secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _tr('appointmentConfirmed', 'Appuntamento confermato'),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _infoRow(Icons.calendar_today, _tr('appointmentDate', 'Data e ora'), dateFmt),
              if (appt.durataMin > 0)
                _infoRow(Icons.timelapse, _tr('duration', 'Durata'), '${appt.durataMin} min'),
              if ((appt.sede ?? '').isNotEmpty)
                _infoRow(Icons.location_on_outlined, _tr('location', 'Sede'), appt.sede!),
              if ((appt.indirizzo ?? '').isNotEmpty)
                _infoRow(Icons.map_outlined, _tr('address', 'Indirizzo'), appt.indirizzo!),
              if ((appt.note ?? '').isNotEmpty)
                _infoRow(Icons.notes, _tr('notes', 'Note'), appt.note!),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (appt.canModify) ...[
          ElevatedButton.icon(
            onPressed: _submitting ? null : () => setState(() => _rescheduling = true),
            icon: const Icon(Icons.edit_calendar),
            label: Text(_tr('rescheduleAppointment', 'Riprogramma')),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _submitting ? null : _cancelAppointment,
            icon: const Icon(Icons.cancel_outlined),
            label: Text(_tr('cancelAppointment', 'Annulla appuntamento')),
            style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
          ),
        ] else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: scheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _tr('cannotModifyWithinLimit',
                            'Non e possibile modificare l\'appuntamento a meno di {hours} ore dall\'orario previsto.')
                        .replaceAll('{hours}', appt.rescheduleLimitHours.toString()),
                    style: TextStyle(fontSize: 13, color: scheme.onSurface.withOpacity(0.7)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: scheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotSelection() {
    final grouped = _groupByDay();
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        if (_rescheduling)
          Container(
            width: double.infinity,
            color: scheme.primary.withOpacity(0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.edit_calendar, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _tr('rescheduleHint', 'Seleziona una nuova data per il tuo appuntamento.'),
                    style: TextStyle(fontSize: 13, color: scheme.primary, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _rescheduling = false;
                    _selectedSlotId = null;
                  }),
                  child: Text(_l10n.cancel),
                ),
              ],
            ),
          ),
        if (widget.servizioLabel != null && widget.servizioLabel!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.servizioLabel!,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _tr('selectSlot', 'Scegli data e ora'),
              style: TextStyle(color: scheme.onSurface.withOpacity(0.7)),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              for (final entry in grouped.entries) _buildDaySection(entry.key, entry.value),
            ],
          ),
        ),
        _buildConfirmBar(),
      ],
    );
  }

  Widget _buildDaySection(DateTime day, List<AppuntamentoSlot> slots) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(width: 10),
              Text(
                _formatDayHeader(day),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: slots.map(_buildSlotChip).toList(),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildSlotChip(AppuntamentoSlot slot) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _selectedSlotId == slot.id;
    final time = slot.dataOra != null ? DateFormat('HH:mm').format(slot.dataOra!) : '--:--';

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _selectedSlotId = slot.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? scheme.primary : scheme.onSurface.withOpacity(0.15),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: selected ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
            if ((slot.sede ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  slot.sede!,
                  style: TextStyle(
                    fontSize: 11,
                    color: selected ? scheme.onPrimary.withOpacity(0.85) : scheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmBar() {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          boxShadow: [
            BoxShadow(
              color: scheme.onSurface.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_selectedSlotId == null || _submitting) ? null : _confirmBooking,
            child: _submitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    _rescheduling
                        ? _tr('confirmReschedule', 'Conferma nuova data')
                        : _tr('confirmBooking', 'Conferma prenotazione'),
                  ),
          ),
        ),
      ),
    );
  }

  String _formatDayHeader(DateTime day) {
    final locale = _l10n.locale.languageCode;
    try {
      return toBeginningOfSentenceCase(DateFormat('EEEE d MMMM', locale).format(day)) ?? '';
    } catch (_) {
      return DateFormat('dd/MM/yyyy').format(day);
    }
  }

  String _formatFullDate(DateTime? d) {
    if (d == null) return '--';
    final locale = _l10n.locale.languageCode;
    try {
      return DateFormat('EEEE d MMMM yyyy, HH:mm', locale).format(d);
    } catch (_) {
      return DateFormat('dd/MM/yyyy HH:mm').format(d);
    }
  }
}
