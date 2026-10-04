import 'package:flutter/material.dart';
import 'package:wecoop_app/utils/app_logger.dart';
import '../../theme/theme.dart';
import 'dart:async';
import 'dart:convert';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import '../../services/socio_service.dart';
import '../../services/http_client_service.dart';
import '../../config/api_config.dart';
import '../servizi/pagamento_screen.dart';
import '../prenota_appuntamento/seleziona_slot_screen.dart';
import '../profilo/completa_profilo_screen.dart';
import '../../utils/service_request_labels.dart';
import '../../utils/parse_helpers.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

/// Tab "Richieste": lista paginata delle pratiche/servizi dell'utente
/// (ex CalendarScreen — il calendario è stato rimosso).
class CalendarScreen extends StatefulWidget {
  final String? initialRichiestaId;

  const CalendarScreen({super.key, this.initialRichiestaId});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
  with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  static const int _perPage = 20;
  bool _hasLoadedOnLanding = false;
  List<Map<String, dynamic>> _tutteRichieste = [];
  String? _filtroStato;
  final storage = SecureStorageService();
  String? _richiestaIdToOpen;
  bool _isOpeningDettaglioRichiesta = false;
  bool _emailSuggestShown = false;
  Timer? _autoRefreshTimer;
  DateTime? _lastAutoRefreshAt;

  static const Duration _autoRefreshInterval = Duration(seconds: 45);
  static const Duration _minAutoRefreshGap = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialRichiestaId != null &&
        widget.initialRichiestaId!.isNotEmpty) {
      _richiestaIdToOpen = widget.initialRichiestaId;
    }
    _startAutoRefreshTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _triggerAutoRefresh(reason: 'app_resumed');
    }
  }

  void _startAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(_autoRefreshInterval, (_) {
      _triggerAutoRefresh(reason: 'periodic_timer');
    });
  }

  Future<void> _triggerAutoRefresh({required String reason}) async {
    if (!mounted || _isLoading || _loadingMore) return;

    final now = DateTime.now();
    if (_lastAutoRefreshAt != null &&
        now.difference(_lastAutoRefreshAt!) < _minAutoRefreshGap) {
      return;
    }

    _lastAutoRefreshAt = now;
    AppLogger.d('🔄 [CalendarAutoRefresh] start reason=$reason');
    await _caricaRichieste(reset: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Aggiorna automaticamente le richieste al primo atterraggio sulla schermata.
    if (!_hasLoadedOnLanding) {
      _hasLoadedOnLanding = true;
      _caricaRichieste(reset: true);
    }

    _scheduleOpenPendingRichiesta();
  }

  bool get _isCalendarTabVisible => TickerMode.of(context);

  void _scheduleOpenPendingRichiesta() {
    if (_richiestaIdToOpen == null || _isLoading || _tutteRichieste.isEmpty) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryOpenPendingRichiesta();
    });
  }

  void _tryOpenPendingRichiesta() {
    final id = _richiestaIdToOpen;
    if (id == null || !mounted || !_isCalendarTabVisible) return;
    _richiestaIdToOpen = null;
    _apriRichiestaById(id);
  }

  Future<void> _caricaRichieste({bool reset = true}) async {
    if (!reset) {
      await _loadNextPage();
      return;
    }

    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      if (mounted) {
        setState(() {
          _tutteRichieste = [];
          _isLoading = false;
          _loadingMore = false;
          _hasMore = false;
          _page = 1;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _page = 1;
        _hasMore = true;
        _isLoading = true;
        _loadingMore = false;
      });
    }

    try {
      final result = await SocioService.getRichiesteUtente(
        page: 1,
        perPage: _perPage,
        stato: _filtroStato,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final pageItems = List<Map<String, dynamic>>.from(
          result['data'] ?? [],
        );
        final pagination = result['pagination'];
        final hasMoreApi = pagination is Map
            ? pagination['has_more'] == true
            : pageItems.length >= _perPage;

        setState(() {
          _tutteRichieste = pageItems;
          _page = 1;
          _hasMore = hasMoreApi;
          _isLoading = false;
          _loadingMore = false;
        });
        _scheduleOpenPendingRichiesta();
        _ensureFilteredHasItems();
      } else {
        setState(() {
          _isLoading = false;
          _loadingMore = false;
          _hasMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMore = false;
        });
      }
      AppLogger.d('Errore caricamento richieste: $e');
    }
  }

  /// Con filtro attivo, se la pagina corrente non ha match carica la successiva.
  void _ensureFilteredHasItems() {
    if (_filtroStato == null || _isLoading || _loadingMore || !_hasMore) return;
    if (_getRichiesteFiltrate().length >= 8) return;
    _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if (_loadingMore || !_hasMore || _isLoading) return;
    final next = _page + 1;
    if (mounted) setState(() => _loadingMore = true);

    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      if (mounted) {
        setState(() {
          _loadingMore = false;
          _hasMore = false;
        });
      }
      return;
    }

    try {
      final result = await SocioService.getRichiesteUtente(
        page: next,
        perPage: _perPage,
        stato: _filtroStato,
      );
      if (!mounted) return;
      if (result['success'] == true) {
        final pageItems = List<Map<String, dynamic>>.from(
          result['data'] ?? [],
        );
        final pagination = result['pagination'];
        final hasMoreApi = pagination is Map
            ? pagination['has_more'] == true
            : pageItems.length >= _perPage;
        setState(() {
          _tutteRichieste.addAll(pageItems);
          _page = next;
          _hasMore = hasMoreApi;
          _loadingMore = false;
        });
        _ensureFilteredHasItems();
      } else {
        setState(() {
          _loadingMore = false;
          _hasMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingMore = false);
      AppLogger.d('Errore load more richieste: $e');
    }
  }

  bool _isRichiestaPaid(Map<String, dynamic> richiesta) {
    final pagamento = richiesta['pagamento'];
    if (pagamento is Map && pagamento['ricevuto'] == true) return true;
    final stato = (richiesta['stato'] ?? richiesta['status'] ?? '').toString();
    return _canonicalStato(stato) == 'paid';
  }

  List<Map<String, dynamic>> _getRichiesteFiltrate() {
    if (_filtroStato == null) return _tutteRichieste;

    if (_filtroStato == 'paid') {
      return _tutteRichieste.where(_isRichiestaPaid).toList();
    }

    // Con filtro BE già applicato, rifiniamo lato client per alias di stato.
    return _tutteRichieste.where((richiesta) {
      final stato = (richiesta['stato'] ?? richiesta['status'] ?? '').toString();
      final canonical = _canonicalStato(stato);
      if (_filtroStato == 'awaiting_signature') {
        // Post-pagamento lo status è spesso `paid` finché non parte il DU.
        if (canonical == 'awaiting_signature') return true;
        if (canonical == 'paid') return true;
        return richiesta['puo_firmare'] == true;
      }
      return canonical == _filtroStato;
    }).toList();
  }

  String _normalizeStato(String stato) {
    return stato.trim().toLowerCase().replaceAll(' ', '_');
  }

  String _canonicalStato(String stato) {
    final normalized = _normalizeStato(stato);

    if (normalized == 'awaiting_payment' ||
        normalized == 'pending_payment' ||
        normalized == 'in_attesa_di_pagamento' ||
        normalized == 'in_attesa_pagamento' ||
        normalized == 'in_attesa_del_pagamento' ||
        (normalized.contains('attesa') && normalized.contains('pagament'))) {
      return 'awaiting_payment';
    }

    if (normalized == 'awaiting_signature' ||
        normalized == 'da_firmare' ||
        normalized == 'pending_firma' ||
        normalized == 'pending_digital_signature' ||
        normalized == 'in_attesa_di_firma' ||
        normalized == 'in_attesa_firma' ||
        normalized == 'pendiente_de_firma' ||
        (normalized.contains('firma') && normalized.contains('attesa')) ||
        (normalized.contains('firma') && normalized.contains('pending'))) {
      return 'awaiting_signature';
    }

    if (normalized == 'completed' ||
        normalized == 'completata' ||
        normalized == 'completato') {
      return 'completed';
    }

    if (normalized == 'cancelled' ||
        normalized == 'annullata' ||
        normalized == 'annullato') {
      return 'cancelled';
    }

    if (normalized == 'integrazione_documentale' ||
        normalized == 'document_integration' ||
        normalized == 'integracion_documental' ||
        (normalized.contains('integ') && normalized.contains('document'))) {
      return 'integrazione_documentale';
    }

    if (normalized == 'processing' || normalized == 'in_lavorazione') {
      return 'processing';
    }

    if (normalized == 'paid' || normalized == 'pagato' || normalized == 'pagado') {
      return 'paid';
    }

    if (normalized == 'awaiting_appointment' ||
        normalized == 'in_attesa_appuntamento' ||
        normalized == 'in_attesa_di_appuntamento' ||
        (normalized.contains('appunt') && normalized.contains('attesa')) ||
        (normalized.contains('appoint') && normalized.contains('await'))) {
      return 'awaiting_appointment';
    }

    if (normalized == 'appointment_confirmed' ||
        normalized == 'appuntamento_confermato' ||
        (normalized.contains('appunt') && normalized.contains('conferm')) ||
        (normalized.contains('appoint') && normalized.contains('confirm'))) {
      return 'appointment_confirmed';
    }

    return normalized;
  }

  bool _isAwaitingPaymentStatus(String stato) {
    return _canonicalStato(stato) == 'awaiting_payment';
  }

  bool _isAwaitingAppointmentStatus(String stato) {
    return _canonicalStato(stato) == 'awaiting_appointment';
  }

  bool _isAppointmentConfirmedStatus(String stato) {
    return _canonicalStato(stato) == 'appointment_confirmed';
  }

  /// Traduce [key] con fallback se la chiave non e' presente nel dizionario.
  String _trFallback(AppLocalizations l10n, String key, String fallback) {
    final v = l10n.translate(key);
    return v == key ? fallback : v;
  }

  Color _getStatoColor(String stato) {
    switch (_canonicalStato(stato)) {
      case 'awaiting_payment':
        return const Color(0xFF9c27b0); // Viola
      case 'paid':
        return const Color(0xFF673ab7); // Viola scuro
      case 'awaiting_signature':
        return const Color(0xFFff6f00); // Arancione scuro
      case 'integrazione_documentale':
        return const Color(0xFFe91e63); // Rosa
      case 'awaiting_appointment':
        return const Color(0xFF00897b); // Teal
      case 'appointment_confirmed':
        return const Color(0xFF2e7d32); // Verde scuro
      case 'processing':
        return AppColors.info;
      case 'completed':
        return AppColors.secondary;
      case 'cancelled':
        return AppColors.error;
      case 'in_attesa':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatoIcon(String stato) {
    switch (_canonicalStato(stato)) {
      case 'awaiting_payment':
        return Icons.payment;
      case 'paid':
        return Icons.paid;
      case 'awaiting_signature':
        return Icons.edit_document;
      case 'integrazione_documentale':
        return Icons.upload_file;
      case 'awaiting_appointment':
        return Icons.event_available;
      case 'appointment_confirmed':
        return Icons.event_available;
      case 'processing':
        return Icons.hourglass_empty;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'in_attesa':
        return Icons.schedule;
      default:
        return Icons.info;
    }
  }

  String _getStatoLabelTradotto(String stato) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return stato;
    switch (_canonicalStato(stato)) {
      case 'pending':
        return l10n.paymentStatusPending;
      case 'awaiting_payment':
        return l10n.paymentStatusAwaitingPayment;
      case 'paid':
        return l10n.paymentStatusPaid;
      case 'awaiting_signature':
        return l10n.paymentStatusAwaitingSignature;
      case 'integrazione_documentale':
        return l10n.documentIntegrationStatus;
      case 'awaiting_appointment':
        return _trFallback(l10n, 'statusAwaitingAppointment', 'In attesa di appuntamento');
      case 'appointment_confirmed':
        return _trFallback(l10n, 'statusAppointmentConfirmed', 'Appuntamento confermato');
      case 'completed':
        return l10n.paymentStatusCompleted;
      case 'failed':
        return l10n.paymentStatusFailed;
      case 'cancelled':
        return l10n.paymentStatusCancelled;
      case 'processing':
        return l10n.processing;
      case 'in_attesa':
        return l10n.pending;
      default:
        return stato;
    }
  }

  String _getCategoriaLabelTradotta(String categoria) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return categoria;
    return ServiceRequestLabels.categoria(l10n, categoria);
  }

  String _getServizioLabelTradotto(Object? servizioOrRecord) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      if (servizioOrRecord is Map) {
        return (servizioOrRecord['servizio_label'] ??
                servizioOrRecord['servizio'] ??
                '')
            .toString();
      }
      return servizioOrRecord?.toString() ?? '';
    }
    if (servizioOrRecord is Map) {
      return ServiceRequestLabels.servizioFromRecord(l10n, servizioOrRecord);
    }
    return ServiceRequestLabels.servizio(l10n, servizioOrRecord);
  }

  /// Se il profilo non ha email, suggerisce (una volta) di completarlo per
  /// ricevere le notifiche via email. Non blocca l'apertura del dettaglio.
  Future<void> _maybeSuggestCompletaProfilo() async {
    if (_emailSuggestShown) return;
    try {
      final res = await SocioService.getProfiloCompleto();
      if (res['success'] != true) return;
      final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
      final email = (data['email'] ?? '').toString().trim();
      final completo = data['profilo_completo'] == true;
      if (email.isNotEmpty && completo) return; // tutto ok, niente avviso
      if (!mounted) return;
      _emailSuggestShown = true;
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.mark_email_unread_rounded, color: AppColors.primary, size: 26),
              const SizedBox(width: 10),
              Expanded(child: Text(l10n.translate('wantEmailsTitle'))),
            ],
          ),
          content: Text(
            l10n.translate('wantEmailsMessage'),
            style: const TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.noThanks),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CompletaProfiloScreen()),
                );
              },
              child: Text(l10n.completeProfile),
            ),
          ],
        );
        },
      );
    } catch (_) {
      // Silenzioso.
    }
  }

  Future<void> _mostraDettaglioRichiesta(Map<String, dynamic> richiesta) async {
    if (_isOpeningDettaglioRichiesta) {
      AppLogger.d('ℹ️ [Dettaglio] apertura già in corso, ignoro tap duplicato');
      return;
    }

    _isOpeningDettaglioRichiesta = true;

    // Se il profilo non ha un'email, invita a completarlo (una volta a sessione)
    // così può ricevere le notifiche via email sulle sue pratiche.
    await _maybeSuggestCompletaProfilo();

    try {
    final richiestaDettaglio = Map<String, dynamic>.from(richiesta);
    final firmaRichiestaId = _resolveFirmaRichiestaId(richiesta);

    final servizioIdInLista = _resolveServizioId(richiestaDettaglio);
    if (servizioIdInLista == 'N/A' && firmaRichiestaId != null) {
      try {
        AppLogger.d('🔎 [Dettaglio] servizioId assente in lista, provo GET dettaglio richiesta id=$firmaRichiestaId');
        final dettaglio = await SocioService.getDettaglioRichiesta(firmaRichiestaId);
        if (dettaglio != null && dettaglio.isNotEmpty) {
          richiestaDettaglio.addAll(dettaglio);
          AppLogger.d('✅ [Dettaglio] richiesta arricchita da endpoint dettaglio, servizioId=${_resolveServizioId(richiestaDettaglio)}');
        } else {
          AppLogger.d('⚠️ [Dettaglio] endpoint dettaglio non ha restituito dati utili per servizioId');
        }
      } catch (e) {
        AppLogger.d('❌ [Dettaglio] errore recupero dettaglio richiesta id=$firmaRichiestaId: $e');
      }
    }

    if (!mounted) return;
    if (!_isCalendarTabVisible) {
      AppLogger.d(
        'ℹ️ [Dettaglio] calendar non visibile, non apro bottom sheet',
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDettaglioSheet(richiestaDettaglio),
    );
    } finally {
      _isOpeningDettaglioRichiesta = false;
    }
  }

  Future<void> _confermaEliminaRichiesta(Map<String, dynamic> richiesta, {bool fromBottomSheet = false}) async {
    final l10n = AppLocalizations.of(context)!;
    final stato = richiesta['stato'] ?? richiesta['status'] ?? '';
    
    // Verifica se eliminabile
    if (stato != 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.onlyPendingCanBeDeleted),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRequest),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deleteRequestConfirm),
            const SizedBox(height: 16),
            Text(
              '${l10n.fileNumber}: ${richiesta['numero_pratica'] ?? 'N/A'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${l10n.paymentService}: ${_getServizioLabelTradotto(richiesta)}',
            ),
            const SizedBox(height: 16),
            Text(
              l10n.deleteRequestWarning,
              style: const TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.deleteRequest),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final id = parseIntOrNull(richiesta['id']);
      if (id != null) {
        await _eliminaRichiesta(id, fromBottomSheet: fromBottomSheet);
      }
    }
  }

  Future<void> _eliminaRichiesta(int richiestaId, {bool fromBottomSheet = false}) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Nested navigator (tab Calendar) vs root (dialog di loading).
    final nestedNavigator = Navigator.of(context);
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    
    try {
      // Mostra loading sul root navigator (default di showDialog)
      showDialog(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final result = await SocioService.deleteRichiesta(richiestaId);

      // Chiudi loading sul root, non sul navigator del tab
      if (mounted && rootNavigator.canPop()) {
        rootNavigator.pop();
      }

      if (result['success'] == true) {
        // Chiudi bottom sheet solo se chiamato da lì (è sul nested navigator)
        if (fromBottomSheet && mounted && nestedNavigator.canPop()) {
          nestedNavigator.pop();
        }
        
        // Mostra successo
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${l10n.requestDeleted}'),
              backgroundColor: AppColors.secondary,
            ),
          );
        }

        // Ricarica lista
        if (mounted) {
          _caricaRichieste();
        }
      } else {
        // Mostra errore
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${result['message'] ?? l10n.cannotDeleteRequest}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      // Chiudi loading sul root
      if (mounted && rootNavigator.canPop()) {
        rootNavigator.pop();
      }

      // Mostra errore
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.cannotDeleteRequest}: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _visualizzaRicevuta(int? paymentId, String numeroPratica, {int? richiestaId}) async {
    final l10n = AppLocalizations.of(context)!;
    final traceId = 'RICEVUTA-${DateTime.now().millisecondsSinceEpoch}';
    final startedAt = DateTime.now();
    AppLogger.d('🧾 [$traceId] start paymentId=$paymentId richiestaId=$richiestaId numeroPratica=$numeroPratica');
    
    // Se non abbiamo payment ID ma abbiamo richiesta ID, mostra messaggio
    if (paymentId == null && richiestaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${l10n.errorDownloadingReceipt}: ${l10n.translate('paymentIdMissing')}'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    // Loading sul root navigator: Calendar è nested. Un pop sul context dello
    // screen chiuderebbe il bottom sheet e lascerebbe "Descargando factura..."
    // bloccato sopra il PDF (come nello screenshot del bug).
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    var loadingDialogVisible = false;

    void dismissLoadingDialog() {
      if (!loadingDialogVisible) return;
      if (rootNavigator.canPop()) {
        rootNavigator.pop();
      }
      loadingDialogVisible = false;
    }

    try {
      showDialog(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.downloadingReceipt),
                ],
              ),
            ),
          ),
        ),
      );
      loadingDialogVisible = true;

      // Se non abbiamo paymentId, usa richiestaId per cercare il pagamento
      int actualPaymentId = paymentId ?? 0;
      
      if (paymentId == null && richiestaId != null) {
        AppLogger.d('⚠️ [$traceId] paymentId mancante, uso richiestaId=$richiestaId');
        // Il backend `/pagamento/:id/ricevuta` gestisce il fallback: se l'id
        // non corrisponde a un payment, cerca il pagamento per request_id.
        actualPaymentId = richiestaId;
      }

      // Ottieni ricevuta PDF
      final result = await SocioService.getRicevutaPdf(actualPaymentId);
      final elapsedMs = DateTime.now().difference(startedAt).inMilliseconds;
      AppLogger.d('🧾 [$traceId] service result success=${result['success']} keys=${result.keys.toList()} elapsedMs=$elapsedMs');

      // Chiudi loading PRIMA di aprire il PDF (stesso root navigator del showDialog)
      if (mounted) {
        dismissLoadingDialog();
      }

      if (result['success'] == true) {
        AppLogger.d('🧾 [$traceId] priorità renderer locale; fallback web solo se necessario');

        // Il backend ritorna il PDF direttamente come bytes
        final pdfBytes = result['pdf_bytes'] as List<int>?;
        final filename = result['filename'] as String? ?? 'ricevuta.pdf';
        AppLogger.d('🧾 [$traceId] local branch filename=$filename bytes=${pdfBytes?.length ?? 0}');

        if (pdfBytes != null) {
          // Salva il PDF automaticamente e aprilo
          try {
            final normalizedPdfBytes = _normalizzaPdfBytes(
              pdfBytes,
              context: 'ricevuta_$actualPaymentId',
            );
            final isValid = _isPdfBytesProbablyValid(normalizedPdfBytes);
            AppLogger.d('📄 [$traceId] bytes validazione pdf: $isValid');

            if (!isValid) {
              AppLogger.d('⚠️ [$traceId] bytes ricevuta non validi, uso fallback web autenticato');
              final receiptUrl = result['receipt_url'] as String?;
              final receiptFilename = result['filename'] as String?;
              final opened = await _apriRicevutaFallbackWeb(
                paymentId: actualPaymentId,
                receiptUrl: receiptUrl,
                receiptFilename: receiptFilename,
                traceId: traceId,
              );
              AppLogger.d('🧾 [$traceId] fallback dopo bytes invalidi opened=$opened');
              if (!opened) {
                AppLogger.d('⚠️ [$traceId] fallback non riuscito, provo comunque renderer locale con bytes normalizzati');
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      opened
                          ? '⚠️ ${AppLocalizations.of(context)!.translate('receiptPdfInvalidOpenedFallback')}'
                          : '❌ ${AppLocalizations.of(context)!.translate('receiptPdfInvalidNoFallback')}',
                    ),
                    backgroundColor: opened ? Colors.orange : AppColors.error,
                  ),
                );
              }
              if (opened) {
                return;
              }
            }

            final savedFile = await _salvaPdfLocale(normalizedPdfBytes, filename);
            AppLogger.d('🧾 [$traceId] savedFile path=${savedFile?.path}');
            
            if (savedFile != null && mounted) {
              await _apriPdfInApp(savedFile, title: filename);
              AppLogger.d('🧾 [$traceId] apertura locale completata');
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '✅ ${l10n.receiptDownloaded}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              filename,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.secondary,
                  duration: const Duration(seconds: 4),
                ),
              );
              
              AppLogger.d('✅ [$traceId] PDF salvato e aperto in-app: ${savedFile.path}');
            } else if (mounted) {
              AppLogger.d('❌ [$traceId] savedFile null dopo _salvaPdfLocale');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('⚠️ ${AppLocalizations.of(context)!.translate('receiptPdfSaveFailed')}'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          } catch (e) {
            AppLogger.d('❌ [$traceId] Errore salvataggio/apertura PDF: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ ${AppLocalizations.of(context)!.error}: $e'),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }
        } else {
          // Vecchio formato con URL
          final receiptUrl = result['receipt_url'] as String?;
          if (receiptUrl != null && mounted) {
            AppLogger.d('🧾 [$traceId] legacy receipt_url branch: $receiptUrl');
            await _apriRicevutaWeb(receiptUrl);
          } else {
            AppLogger.d('⚠️ [$traceId] nessun pdf_bytes e nessun receipt_url, provo fallback endpoint');
            await _apriRicevutaFallbackWeb(
              paymentId: actualPaymentId,
              receiptUrl: receiptUrl,
              receiptFilename: result['filename'] as String?,
              traceId: traceId,
            );
          }
        }
      } else {
        AppLogger.d('❌ [$traceId] service error message=${result['message']}');
        // Mostra errore
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${result['message'] ?? l10n.errorDownloadingReceipt}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.d('❌ [$traceId] eccezione: $e');
      if (mounted) {
        dismissLoadingDialog();
      }

      // Mostra errore
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.errorDownloadingReceipt}: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<File?> _salvaPdfLocale(List<int> pdfBytes, String filename) async {
    try {
      final safeFilename = filename.trim().isEmpty
          ? 'ricevuta.pdf'
          : filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

      Directory directory;
      try {
        directory = await getApplicationDocumentsDirectory();
      } catch (e) {
        AppLogger.d('⚠️ [FileSave] Documents directory non disponibile, fallback temp: $e');
        directory = await getTemporaryDirectory();
      }

      final filePath = '${directory.path}/$safeFilename';
      final file = File(filePath);

      await file.writeAsBytes(pdfBytes);

      AppLogger.d('✅ [FileSave] PDF salvato in directory privata: $filePath');
      AppLogger.d('📁 [FileSave] Directory: ${directory.path}');
      AppLogger.d('📄 [FileSave] File size: ${pdfBytes.length} bytes');

      return file;
    } catch (e) {
      AppLogger.d('❌ [FileSave] Errore salvataggio PDF: $e');
      return null;
    }
  }

  List<int> _normalizzaPdfBytes(List<int> bytes, {String context = 'pdf'}) {
    if (bytes.isEmpty) return bytes;

    const pdfHeader = [37, 80, 68, 70, 45]; // %PDF-
    const eofMarker = [37, 37, 69, 79, 70]; // %%EOF

    int findSequence(List<int> source, List<int> sequence, {int start = 0}) {
      if (sequence.isEmpty || source.length < sequence.length) return -1;
      for (var index = start; index <= source.length - sequence.length; index++) {
        var isMatch = true;
        for (var offset = 0; offset < sequence.length; offset++) {
          if (source[index + offset] != sequence[offset]) {
            isMatch = false;
            break;
          }
        }
        if (isMatch) return index;
      }
      return -1;
    }

    List<int> workingBytes = bytes;

    int? parseHexByte(String value) {
      if (value.length != 2) return null;
      final parsed = int.tryParse(value, radix: 16);
      if (parsed == null || parsed < 0 || parsed > 255) return null;
      return parsed;
    }

    List<int> decodeEscapedQuotedBytes(String rawText) {
      var source = rawText;
      if (source.startsWith('"')) {
        source = source.substring(1);
      }
      if (source.endsWith('"')) {
        source = source.substring(0, source.length - 1);
      }

      final output = <int>[];
      for (var i = 0; i < source.length; i++) {
        final char = source[i];
        if (char != r'\') {
          output.add(source.codeUnitAt(i) & 0xFF);
          continue;
        }

        if (i + 1 >= source.length) {
          output.add(92);
          break;
        }

        final next = source[i + 1];
        i++;

        final nextCode = next.codeUnitAt(0);
        final isOctalDigit = nextCode >= 48 && nextCode <= 55; // 0-7
        if (isOctalDigit) {
          var octal = next;
          var consumed = 0;

          while (consumed < 2 && i + 1 < source.length) {
            final peek = source[i + 1];
            final peekCode = peek.codeUnitAt(0);
            final peekIsOctal = peekCode >= 48 && peekCode <= 55;
            if (!peekIsOctal) break;
            i++;
            consumed++;
            octal += peek;
          }

          final parsedOctal = int.tryParse(octal, radix: 8);
          if (parsedOctal != null) {
            output.add(parsedOctal & 0xFF);
            continue;
          }
        }

        switch (next) {
          case '"':
            output.add(34);
            break;
          case r'\':
            output.add(92);
            break;
          case '/':
            output.add(47);
            break;
          case 'b':
            output.add(8);
            break;
          case 'f':
            output.add(12);
            break;
          case 'n':
            output.add(10);
            break;
          case 'r':
            output.add(13);
            break;
          case 't':
            output.add(9);
            break;
          case 'u':
            if (i + 4 <= source.length - 1) {
              final hex = source.substring(i + 1, i + 5);
              final parsed = int.tryParse(hex, radix: 16);
              if (parsed != null) {
                if (parsed <= 0xFF) {
                  output.add(parsed);
                } else {
                  output.addAll(utf8.encode(String.fromCharCode(parsed)));
                }
                i += 4;
                break;
              }
            }
            output.add(117); // 'u'
            break;
          case 'x':
            if (i + 2 <= source.length - 1) {
              final hex = source.substring(i + 1, i + 3);
              final parsed = parseHexByte(hex);
              if (parsed != null) {
                output.add(parsed);
                i += 2;
                break;
              }
            }
            output.add(120); // 'x'
            break;
          default:
            output.add(92); // preserva il backslash originale
            output.add(next.codeUnitAt(0) & 0xFF);
            break;
        }
      }

      return output;
    }

    final looksQuoted = workingBytes.isNotEmpty && workingBytes.first == 34;
    if (looksQuoted) {
      try {
        final rawText = latin1.decode(workingBytes);
        final rawHead = rawText.length > 120 ? '${rawText.substring(0, 120)}...' : rawText;
        AppLogger.d('📄 [PdfNormalize][$context] quoted payload detected, rawHead=$rawHead');
        workingBytes = decodeEscapedQuotedBytes(rawText);
        AppLogger.d('📄 [PdfNormalize][$context] quoted unescape success len=${workingBytes.length} first8=${workingBytes.take(8).toList()}');
      } catch (e) {
        AppLogger.d('❌ [PdfNormalize][$context] quoted payload normalization failed: $e');
      }
    }

    final startIndex = findSequence(workingBytes, pdfHeader);
    final eofIndex = findSequence(
      workingBytes,
      eofMarker,
      start: startIndex >= 0 ? startIndex : 0,
    );
    AppLogger.d('📄 [PdfNormalize][$context] len=${workingBytes.length} startIndex=$startIndex eofIndex=$eofIndex first8=${workingBytes.take(8).toList()}');

    if (startIndex <= 0 && eofIndex == -1) {
      return workingBytes;
    }

    final normalizedStart = startIndex >= 0 ? startIndex : 0;
    final normalizedEndExclusive =
        eofIndex >= 0 ? eofIndex + eofMarker.length : workingBytes.length;

    if (normalizedStart >= normalizedEndExclusive ||
        normalizedStart < 0 ||
        normalizedEndExclusive > workingBytes.length) {
      return workingBytes;
    }

    final normalized = workingBytes.sublist(normalizedStart, normalizedEndExclusive);
    AppLogger.d('📄 [PdfNormalize][$context] normalizedLen=${normalized.length} normalizedFirst8=${normalized.take(8).toList()}');
    return normalized;
  }

  bool _isPdfBytesProbablyValid(List<int> bytes) {
    if (bytes.length < 16) return false;
    final headerOk = bytes.length >= 5 &&
        bytes[0] == 37 &&
        bytes[1] == 80 &&
        bytes[2] == 68 &&
        bytes[3] == 70 &&
        bytes[4] == 45;
    if (!headerOk) return false;

    final textTail = latin1.decode(
      bytes.sublist(bytes.length > 2048 ? bytes.length - 2048 : 0),
      allowInvalid: true,
    );

    return textTail.contains('%%EOF') || textTail.contains('startxref');
  }

  Future<bool> _apriPdfFallbackAutenticato(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) {
        return false;
      }

      final token = await storage.read(key: 'jwt_token');
      final headers = <String, String>{
        'Accept': 'application/pdf,application/octet-stream,*/*',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await HttpClientService.get(uri, headers: headers);
      if (response.statusCode != 200) {
        AppLogger.d('⚠️ [PdfFallbackAuth] status=${response.statusCode} url=$url');
        return false;
      }

      final normalizedPdfBytes = _normalizzaPdfBytes(
        response.bodyBytes,
        context: 'fallback_auth_pdf',
      );
      final isValid = _isPdfBytesProbablyValid(normalizedPdfBytes);
      if (!isValid) {
        AppLogger.d('⚠️ [PdfFallbackAuth] bytes non validi url=$url');
        return false;
      }

      final filename = _extractFileName(url) == 'N/A'
          ? 'documento_unico.pdf'
          : _extractFileName(url);
      final savedFile = await _salvaPdfLocale(normalizedPdfBytes, filename);
      if (savedFile == null) {
        AppLogger.d('❌ [PdfFallbackAuth] salvataggio file fallito url=$url');
        return false;
      }

      await _apriPdfInApp(savedFile, title: filename);
      AppLogger.d('✅ [PdfFallbackAuth] PDF aperto in-app da URL autenticata');
      return true;
    } catch (e) {
      AppLogger.d('❌ [PdfFallbackAuth] eccezione: $e');
      return false;
    }
  }

  Future<bool> _apriRicevutaFallbackWeb({
    required int paymentId,
    String? receiptUrl,
    String? receiptFilename,
    String? traceId,
  }) async {
    final tag = traceId ?? 'RicevutaFallback';
    AppLogger.d('🧾 [$tag] start paymentId=$paymentId receiptUrl=$receiptUrl');
    final token = await storage.read(key: 'jwt_token');
    AppLogger.d('🧾 [$tag] tokenPresent=${token != null && token.isNotEmpty}');

    // 1) Se abbiamo un URL diretto della ricevuta, scarichiamolo in modo
    //    autenticato e apriamolo con il viewer PDF locale. Evitiamo Google Docs
    //    Viewer perché su URL protette mostra "Anteprima non disponibile".
    if (receiptUrl != null && _isValidWebUrl(receiptUrl)) {
      final openedAuth = await _apriPdfFallbackAutenticato(receiptUrl);
      AppLogger.d('🧾 [$tag] download autenticato receiptUrl opened=$openedAuth');
      if (openedAuth) {
        return true;
      }
    }

    // 2) Fallback: genera/scarica la ricevuta dal backend Node usando il
    //    paymentId. L'endpoint autenticato GET /api/pagamento/:id/ricevuta
    //    ritorna direttamente il PDF (rigenerandolo se necessario) e, se lo
    //    storage DigitalOcean Spaces è configurato, lo archivia lì.
    //    NB: le vecchie URL pubbliche WordPress (wp-content/uploads/...) non
    //    sono più valide dopo la migrazione a DigitalOcean Spaces, dove le key
    //    sono randomiche (fatture/<timestamp>-<random>.pdf) e non ricostruibili
    //    dal solo nome file.
    final ricevutaUrl = '${ApiConfig.baseUrl}/pagamento/$paymentId/ricevuta';
    AppLogger.d('🧾 [$tag] provo fallback backend ricevuta url=$ricevutaUrl (filename=$receiptFilename)');
    final openedBackend = await _apriPdfFallbackAutenticato(ricevutaUrl);
    AppLogger.d('🧾 [$tag] fallback backend opened=$openedBackend');
    if (openedBackend) {
      return true;
    }

    AppLogger.d('❌ [$tag] fallback fallito paymentId=$paymentId');
    return false;
  }

  Future<void> _apriPdfInApp(File file, {String? title}) async {
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title ?? AppLocalizations.of(context)!.translate('pdfDocumentTitle')),
          ),
          body: PDFView(
            filePath: file.path,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageSnap: true,
            onRender: (pages) {
              AppLogger.d('📄 [PdfView] render completed pages=$pages path=${file.path}');
            },
            onError: (error) {
              AppLogger.d('❌ [PdfView] onError: $error path=${file.path}');
            },
            onPageError: (page, error) {
              AppLogger.d('❌ [PdfView] onPageError page=$page error=$error path=${file.path}');
            },
          ),
        ),
      ),
    );
  }

  Future<void> _apriRicevutaWeb(String url) async {
    // Scarica il PDF in modo autenticato e aprilo con il viewer locale.
    // Evitiamo Google Docs Viewer perché su URL protette mostra
    // "Anteprima non disponibile".
    final opened = await _apriPdfFallbackAutenticato(url);

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.cannotOpenFile),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _extractFileName(String? rawPathOrUrl) {
    if (rawPathOrUrl == null || rawPathOrUrl.trim().isEmpty) {
      return 'N/A';
    }

    final value = rawPathOrUrl.trim();
    try {
      final uri = Uri.parse(value);
      if (uri.pathSegments.isNotEmpty) {
        final candidate = Uri.decodeComponent(uri.pathSegments.last);
        if (candidate.isNotEmpty) {
          return candidate;
        }
      }
    } catch (e) { AppLogger.d("ignored: $e"); }

    final normalized = value.replaceAll('\\', '/');
    final parts = normalized.split('/').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return 'N/A';
    return Uri.decodeComponent(parts.last);
  }


  void _apriRichiestaById(String id) {
    AppLogger.d('🔍 Cerco richiesta con ID: $id');
    
    final richiesta = _tutteRichieste.firstWhere(
      (r) => r['id'].toString() == id,
      orElse: () => {},
    );
    
    if (richiesta.isNotEmpty) {
      AppLogger.d('✅ Richiesta trovata: ${richiesta['numero_pratica']}');
      _mostraDettaglioRichiesta(richiesta);
    } else {
      AppLogger.d('❌ Richiesta non trovata: $id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.translate('requestNotFound')),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }


  bool _hasMeaningfulValue(String? value) {
    if (value == null) return false;
    final normalized = value.trim().toLowerCase();
    return normalized.isNotEmpty && normalized != 'null' && normalized != 'undefined';
  }

  bool _isValidWebUrl(String? value) {
    if (!_hasMeaningfulValue(value)) return false;
    final raw = value!.trim();
    final uri = Uri.tryParse(raw);
    if (uri == null) return false;
    final scheme = uri.scheme.toLowerCase();
    return (scheme == 'http' || scheme == 'https') && uri.host.isNotEmpty;
  }


  int? _resolveFirmaRichiestaId(Map<String, dynamic> richiesta) {
    final candidates = [
      richiesta['richiesta_id'],
      richiesta['id_richiesta'],
      richiesta['request_id'],
      richiesta['service_request_id'],
      richiesta['id'],
    ];

    for (final candidate in candidates) {
      if (candidate is int) return candidate;
      if (candidate is String) {
        final parsed = int.tryParse(candidate);
        if (parsed != null) return parsed;
      }
    }

    return null;
  }

  String? _coerceNonEmptyId(dynamic value) {
    if (value == null) return null;

    if (value is int) return value.toString();

    final parsed = value.toString().trim();
    if (parsed.isEmpty || parsed.toLowerCase() == 'null') {
      return null;
    }

    return parsed;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
    }
    return <String, dynamic>{};
  }

  String _resolveServizioId(Map<String, dynamic> richiesta) {
    final servizioMap = _asMap(richiesta['servizio']);
    final servizioDettaglioMap = _asMap(richiesta['servizio_dettaglio']);

    final candidates = [
      richiesta['servizioId'],
      richiesta['servizio_id'],
      richiesta['id_servizio'],
      richiesta['service_id'],
      servizioMap['id'],
      servizioMap['servizio_id'],
      servizioMap['id_servizio'],
      servizioMap['service_id'],
      servizioMap['servizioId'],
      servizioDettaglioMap['id'],
      servizioDettaglioMap['servizio_id'],
      servizioDettaglioMap['service_id'],
    ];

    for (final candidate in candidates) {
      final value = _coerceNonEmptyId(candidate);
      if (value != null) {
        return value;
      }
    }

    return 'N/A';
  }


  /// Apre/scarica un documento risultato tramite download autenticato (signed URL).
  Future<void> _apriDocumentoRisultato(
    int richiestaId,
    Map<String, dynamic> doc,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final docId = doc['id'] is int
        ? doc['id'] as int
        : int.tryParse('${doc['id'] ?? ''}');
    if (docId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('cannotOpenDocument')),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final result = await SocioService.downloadDocumentoRichiesta(
      richiestaId: richiestaId,
      docId: docId,
      fileName: (doc['file_name'] ?? doc['descrizione'] ?? '').toString(),
    );

    if (!mounted) return;
    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (result['message'] as String?) ??
                l10n.translate('cannotOpenDocument'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final List<int> bytes = (result['bytes'] as List<int>?) ?? <int>[];
    final String filename =
        (result['filename'] as String?) ?? 'documento_$docId.pdf';
    if (bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('cannotOpenDocument')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes, flush: true);
      // Preferisci visualizzatore PDF interno se disponibile; altrimenti apri esterno.
      if (filename.toLowerCase().endsWith('.pdf') && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: Text(filename)),
              body: PDFView(filePath: file.path),
            ),
          ),
        );
      } else {
        final uri = Uri.file(file.path);
        final opened =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!opened && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('cannotOpenDocument')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('cannotOpenDocument')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Sezione documenti risultato: mostra i documenti pubblicati dall'operatore.
  List<Widget> _buildDocumentiRisultatoSection(
    Map<String, dynamic> richiesta,
    int? richiestaId,
  ) {
    final raw = richiesta['documenti_risultato'];
    if (raw is! List || raw.isEmpty || richiestaId == null) {
      return const [];
    }

    final documenti = raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .where((d) => d['id'] != null)
        .toList();

    if (documenti.isEmpty) {
      return const [];
    }

    final l10n = AppLocalizations.of(context)!;

    return [
      const Divider(height: 32),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_done, color: AppColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.translate('resultDocumentsTitle'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.translate('resultDocumentsInfo'),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 12),
            ...documenti.map((doc) {
              final fileName = (doc['file_name'] ?? '').toString();
              final descrizione = (doc['descrizione'] ?? '').toString();
              final isPdf = fileName.toLowerCase().endsWith('.pdf');

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.successBg),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName.isNotEmpty ? fileName : 'Documento',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (descrizione.isNotEmpty && descrizione != fileName) ...[
                            const SizedBox(height: 2),
                            Text(
                              descrizione,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          _apriDocumentoRisultato(richiestaId, doc),
                      icon: const Icon(Icons.download),
                      color: AppColors.secondary,
                      tooltip: l10n.translate('downloadDocument'),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    ];
  }

  /// Sezione integrazione documentale: mostra i documenti richiesti dall'operatore
  /// e permette al cliente di caricarli.
  List<Widget> _buildIntegrazioneDocumentaleSection(
    Map<String, dynamic> richiesta,
    int richiestaId,
  ) {
    final initial = richiesta['integrazione_documentale'];
    if (initial is! Map || initial['attiva'] != true) {
      return const [];
    }

    String? uploadingTipo;

    return [
      const Divider(height: 32),
      StatefulBuilder(
        builder: (context, setSectionState) {
          final l10n = AppLocalizations.of(context)!;
          final integ = (richiesta['integrazione_documentale'] as Map)
              .cast<String, dynamic>();
          final note = (integ['note'] ?? '').toString();
          final documenti = (integ['documenti'] is List)
              ? List<Map<String, dynamic>>.from(
                  (integ['documenti'] as List).map(
                    (e) => Map<String, dynamic>.from(e as Map),
                  ),
                )
              : <Map<String, dynamic>>[];
          final tuttiCaricati = integ['tutti_caricati'] == true;

          Future<void> aggiornaSezione() async {
            try {
              final fresh = await SocioService.getDettaglioRichiesta(richiestaId);
              if (fresh != null) {
                if (fresh['integrazione_documentale'] != null) {
                  richiesta['integrazione_documentale'] =
                      fresh['integrazione_documentale'];
                }
                if (fresh['stato'] != null || fresh['status'] != null) {
                  richiesta['stato'] = fresh['stato'] ?? fresh['status'];
                }
              }
            } catch (e) {
              AppLogger.d('⚠️ [Integrazione] errore aggiornamento sezione: $e');
            }
            if (mounted) setSectionState(() {});
          }

          Future<void> uploadDoc(String tipo) async {
            try {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
              );
              if (result == null || result.files.single.path == null) {
                return;
              }
              final file = File(result.files.single.path!);

              setSectionState(() => uploadingTipo = tipo);

              final res = await SocioService.uploadDocumentoIntegrazione(
                richiestaId: richiestaId,
                tipo: tipo,
                file: file,
              );

              if (!mounted) return;
              setSectionState(() => uploadingTipo = null);

              if (res['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.documentUploadedSuccess),
                    backgroundColor: AppColors.secondary,
                  ),
                );
                await aggiornaSezione();
                _caricaRichieste();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      (res['message'] ?? l10n.documentUploadError).toString(),
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                setSectionState(() => uploadingTipo = null);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.documentUploadError),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFe91e63).withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFe91e63).withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.folder_open, color: Color(0xFFe91e63)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.documentIntegrationTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFc2185b),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.documentIntegrationInfo,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.operatorNote,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(note, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  l10n.documentsToUpload,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...documenti.map((doc) {
                  final tipo = (doc['tipo'] ?? '').toString();
                  final label = (doc['label'] ?? tipo).toString();
                  final motivo = (doc['motivo'] ?? '').toString();
                  final caricato = (doc['stato'] ?? '') == 'caricato';
                  final isUploadingThis = uploadingTipo == tipo;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: caricato
                            ? AppColors.secondary
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          caricato
                              ? Icons.check_circle
                              : Icons.description_outlined,
                          color: caricato
                              ? AppColors.secondary
                              : const Color(0xFFe91e63),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (motivo.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  motivo,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 2),
                              Text(
                                caricato
                                    ? l10n.documentUploaded
                                    : l10n.documentPending,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: caricato
                                      ? AppColors.secondary
                                      : Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!caricato)
                          isUploadingThis
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : IconButton(
                                  onPressed: uploadingTipo != null
                                      ? null
                                      : () => uploadDoc(tipo),
                                  icon: const Icon(Icons.upload_file),
                                  color: const Color(0xFFe91e63),
                                  tooltip: l10n.uploadDocument,
                                ),
                      ],
                    ),
                  );
                }),
                if (tuttiCaricati) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.secondary),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.allDocumentsUploaded,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    ];
  }

  Widget _buildDettaglioSheet(Map<String, dynamic> richiesta) {
    final stato = richiesta['stato'] ?? richiesta['status'] ?? '';
    final statoLabel = _getStatoLabelTradotto(stato);
    final pagamento = richiesta['pagamento'] ?? {};
    final puoPagare = richiesta['puo_pagare'] == true;
    final richiestaIdRaw = richiesta['id'];
    final richiestaId = richiestaIdRaw is int
        ? richiestaIdRaw
        : int.tryParse(richiestaIdRaw?.toString() ?? '');
    // Documento Unico è a livello UTENTE (non pratica): nessuna CTA DU qui.
    // Debug: verifica dati pagamento COMPLETI
    AppLogger.d('📋 ==================== DEBUG RICHIESTA ====================');
    AppLogger.d('📋 Richiesta ID: $richiestaId');
    AppLogger.d('📋 Stato: $stato');
    AppLogger.d('📋 Numero pratica: ${richiesta['numero_pratica']}');
    AppLogger.d('💰 ==================== PAGAMENTO COMPLETO ====================');
    AppLogger.d('💰 Pagamento object: $pagamento');
    AppLogger.d('💰 Pagamento keys: ${pagamento.keys.toList()}');
    AppLogger.d('🔑 pagamento["id"]: ${pagamento['id']}');
    AppLogger.d('🔑 pagamento["payment_id"]: ${pagamento['payment_id']}');
    AppLogger.d('🔑 pagamento["pagamento_id"]: ${pagamento['pagamento_id']}');
    AppLogger.d('✅ pagamento["ricevuto"]: ${pagamento['ricevuto']}');
    AppLogger.d('📋 =========================================================');
    
    // Stato awaiting_payment significa che c'è un pagamento da effettuare
    final isAwaitingPayment = _isAwaitingPaymentStatus(stato);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder:
          (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getStatoColor(stato).withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatoIcon(stato),
                        size: 32,
                        color: _getStatoColor(stato),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getServizioLabelTradotto(richiesta),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getCategoriaLabelTradotta(richiesta['categoria'] ?? ''),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildInfoRow(
                        AppLocalizations.of(context)!.fileNumber,
                        richiesta['numero_pratica'] ?? 'N/A',
                        Icons.confirmation_number,
                      ),
                      _buildInfoRow(
                        AppLocalizations.of(context)!.translate('requestIdLabel'),
                        richiestaId?.toString() ?? 'N/A',
                        Icons.badge_outlined,
                      ),
                      _buildInfoRow(
                        AppLocalizations.of(context)!.status,
                        statoLabel,
                        Icons.info_outline,
                      ),
                      _buildInfoRow(
                        AppLocalizations.of(context)!.requestDate,
                        _formatData(richiesta['data_richiesta']),
                        Icons.calendar_today,
                      ),

                      // Sezione integrazione documentale
                      if (richiestaId != null)
                        ..._buildIntegrazioneDocumentaleSection(richiesta, richiestaId),

                      // Sezione documenti risultato (pubblicati dall'operatore)
                      ..._buildDocumentiRisultatoSection(richiesta, richiestaId),

                      if (richiesta['prezzo_formattato'] != null) ...[
                        const Divider(height: 32),
                        _buildInfoRow(
                          AppLocalizations.of(context)!.amount,
                          richiesta['prezzo_formattato'],
                          Icons.euro,
                        ),
                      ],

                      // Mostra sezione pagamento SOLO se c'è un pagamento attivo (non ancora completato)
                      if (isAwaitingPayment || (pagamento.isNotEmpty && pagamento['ricevuto'] != true)) ...[
                        const Divider(height: 32),
                        Text(
                          AppLocalizations.of(context)!.paymentInfo,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildInfoRow(
                          AppLocalizations.of(context)!.paymentStatus,
                          pagamento['ricevuto'] == true
                              ? AppLocalizations.of(context)!.paid
                              : AppLocalizations.of(context)!.notPaid,
                          pagamento['ricevuto'] == true
                              ? Icons.check_circle
                              : Icons.pending,
                        ),

                        if (pagamento['metodo'] != null)
                          _buildInfoRow(
                            AppLocalizations.of(context)!.paymentMethod,
                            pagamento['metodo'],
                            Icons.payment,
                          ),

                        if (pagamento['data'] != null)
                          _buildInfoRow(
                            AppLocalizations.of(context)!.paymentPaidDate,
                            _formatData(pagamento['data']),
                            Icons.calendar_today,
                          ),

                        if (pagamento['transazione_id'] != null)
                          _buildInfoRow(
                            AppLocalizations.of(context)!.translate('transactionIdLabel'),
                            pagamento['transazione_id'],
                            Icons.receipt,
                          ),
                      ],
                      
                      // Mostra messaggio di conferma se già pagato
                      if (pagamento['ricevuto'] == true) ...[
                        const Divider(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.secondary),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.secondary,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.paymentReceived,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                    if (pagamento['metodo'] != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${AppLocalizations.of(context)!.paymentMethod}: ${pagamento['metodo']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ],
                                    if (pagamento['data'] != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatData(pagamento['data']),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Pulsante Paga - Usa sempre la schermata interna se c'è richiestaId
                      // Mostra solo se NON è già stato pagato
                      if ((isAwaitingPayment || puoPagare) && richiestaId != null && pagamento['ricevuto'] != true) ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // Chiudi bottom sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PagamentoScreen(
                                  richiestaId: richiestaId,
                                ),
                              ),
                            ).then((_) {
                              // Ricarica le richieste quando torna indietro
                              _caricaRichieste();
                            });
                          },
                          icon: const Icon(Icons.payment),
                          label: Text(AppLocalizations.of(context)!.payNow),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                        ),
                      ],

                      // CTA appuntamento fisico (stile Calendly)
                      if (richiestaId != null &&
                          (_isAwaitingAppointmentStatus(stato) ||
                              _isAppointmentConfirmedStatus(stato))) ...[
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // Chiudi bottom sheet
                            _apriPrenotazioneAppuntamento(richiesta);
                          },
                          icon: Icon(
                            _isAppointmentConfirmedStatus(stato)
                                ? Icons.event_available
                                : Icons.event,
                          ),
                          label: Text(
                            _isAppointmentConfirmedStatus(stato)
                                ? _trFallback(AppLocalizations.of(context)!,
                                    'manageAppointment', 'Gestisci appuntamento')
                                : _trFallback(AppLocalizations.of(context)!,
                                    'bookAppointment', 'Prenota appuntamento'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getStatoColor(stato),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                        ),
                      ],
                      
                      // Pulsante Elimina - Solo per richieste pending
                      if (stato == 'pending' && richiestaId != null) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            _confermaEliminaRichiesta(richiesta, fromBottomSheet: true);
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: Text(AppLocalizations.of(context)!.deleteRequest),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                        ),
                      ],

                      // Pulsante Scarica Ricevuta - Solo per pagamenti completati
                      // PROBLEMA: Backend non ritorna payment ID, solo transaction_id
                      if (pagamento['ricevuto'] == true || stato == 'completed' || stato == 'completata') ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            // Prova diversi campi per l'ID del pagamento
                            // Il backend può ritornare String o int, gestiamo entrambi
                            final paymentIdRaw = pagamento['id'] ?? 
                                                 pagamento['payment_id'] ?? 
                                                 pagamento['pagamento_id'];
                            
                            final paymentId = paymentIdRaw is int 
                                ? paymentIdRaw 
                                : (paymentIdRaw is String ? int.tryParse(paymentIdRaw) : null);
                            
                            final transactionId = pagamento['transazione_id'] as String?;
                            
                            AppLogger.d('🧾 Tentativo scarica ricevuta:');
                            AppLogger.d('   - Payment ID: $paymentId');
                            AppLogger.d('   - Transaction ID: $transactionId');
                            AppLogger.d('   - Richiesta ID: $richiestaId');
                            
                            if (paymentId == null) {
                              // Mostra dialog informativo invece di errore
                              if (mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Row(
                                      children: [
                                        Icon(Icons.info_outline, color: Colors.orange),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(context)!.translate('receiptUnavailableTitle'),
                                        ),
                                      ],
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.translate('paymentProcessingMessage'),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(AppLocalizations.of(context)!.translate('paymentDetailsLabel')),
                                        const SizedBox(height: 8),
                                        Text('• ${AppLocalizations.of(context)!.fileNumber}: ${richiesta['numero_pratica']}'),
                                        if (transactionId != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            '• ${AppLocalizations.of(context)!.translate('transactionIdLabel')}: ${transactionId.substring(0, 20)}...',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                        if (pagamento['metodo'] != null) ...[
                                          const SizedBox(height: 4),
                                          Text('• ${AppLocalizations.of(context)!.paymentMethod}: ${pagamento['metodo']}'),
                                        ],
                                        if (pagamento['data'] != null) ...[
                                          const SizedBox(height: 4),
                                          Text('• ${AppLocalizations.of(context)!.date}: ${_formatData(pagamento['data'])}'),
                                        ],
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.infoBg,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.lightbulb_outline, size: 20, color: AppColors.info),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  AppLocalizations.of(context)!.translate('receiptAvailableSoonTip'),
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(AppLocalizations.of(context)!.close),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _caricaRichieste(); // Ricarica per vedere se ora c'è l'ID
                                        },
                                        icon: const Icon(Icons.refresh),
                                        label: Text(AppLocalizations.of(context)!.reload),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.info,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return;
                            }
                            
                            await _visualizzaRicevuta(
                              paymentId, 
                              richiesta['numero_pratica'] ?? 'N/A',
                              richiestaId: richiestaId,
                            );
                          },
                          icon: const Icon(Icons.receipt_long),
                          label: Text(AppLocalizations.of(context)!.downloadReceipt),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.info,
                            side: const BorderSide(color: AppColors.info),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                        ),

                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatData(String? data) {
    if (data == null) return 'N/A';
    try {
      final dt = DateTime.parse(data);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return data;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<Map<String, String?>> filtriStato = [
      {'label': l10n.all, 'value': null},
      {'label': l10n.paymentStatusAwaitingPayment, 'value': 'awaiting_payment'},
      {'label': l10n.paymentStatusPaid, 'value': 'paid'},
      {'label': l10n.paymentStatusAwaitingSignature, 'value': 'awaiting_signature'},
      {'label': l10n.paymentStatusCompleted, 'value': 'completed'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myRequests),
        actions: [
          IconButton(
            tooltip: l10n.reload,
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : () => _caricaRichieste(reset: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: filtriStato.length,
              itemBuilder: (context, index) {
                final filtro = filtriStato[index];
                final label = filtro['label'] ?? '';
                final value = filtro['value'];
                final isSelected = _filtroStato == filtro['value'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _filtroStato = selected ? value : null;
                      });
                      // Ricarica dalla pagina 1 con (eventuale) stato API.
                      _caricaRichieste(reset: true);
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: Colors.amber.shade100,
                    checkmarkColor: Colors.amber.shade700,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _caricaRichieste(reset: true),
              child: _isLoading
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),
                        Center(child: CircularProgressIndicator()),
                      ],
                    )
                  : _buildListaRichieste(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaRichieste() {
    final richieste = _getRichiesteFiltrate();

    if (richieste.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.noRequestsFound,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final showFooter = _loadingMore || _hasMore;
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is ScrollEndNotification && n.metrics.extentAfter < 240) {
          _loadNextPage();
        }
        return false;
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        itemCount: richieste.length + (showFooter ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= richieste.length) {
            if (_loadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            if (_hasMore) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextButton(
                  onPressed: _loadNextPage,
                  child: Text(
                    _trFallback(
                      AppLocalizations.of(context)!,
                      'loadMore',
                      'Carica altre',
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }
          return _buildRichiestaCard(richieste[index]);
        },
      ),
    );
  }

  /// Apre la pagina di selezione slot per una richiesta e ricarica al ritorno.
  void _apriPrenotazioneAppuntamento(Map<String, dynamic> richiesta) {
    final id = richiesta['id'];
    final richiestaId = id is int ? id : int.tryParse('${id ?? ''}');
    if (richiestaId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelezionaSlotScreen(
          richiestaId: richiestaId,
          servizioLabel: _getServizioLabelTradotto(richiesta),
        ),
      ),
    ).then((_) => _caricaRichieste());
  }

  /// CTA per la prenotazione/gestione dell'appuntamento fisico.
  Widget _buildAppuntamentoCta(Map<String, dynamic> richiesta, String stato) {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = _isAppointmentConfirmedStatus(stato);
    final color = _getStatoColor(stato);

    final label = confirmed
        ? _trFallback(l10n, 'manageAppointment', 'Gestisci appuntamento')
        : _trFallback(l10n, 'bookAppointment', 'Prenota appuntamento');

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _apriPrenotazioneAppuntamento(richiesta),
        icon: Icon(confirmed ? Icons.event_available : Icons.event, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildRichiestaCard(Map<String, dynamic> richiesta) {
    final stato = richiesta['stato'] ?? richiesta['status'] ?? '';
    final statoLabel = _getStatoLabelTradotto(stato);
    final pagamento = richiesta['pagamento'] ?? {};
    final puoPagare = richiesta['puo_pagare'] == true;
    final isAwaitingPayment = _isAwaitingPaymentStatus(stato);
    final canDelete = stato == 'pending';

    final cardContent = Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _mostraDettaglioRichiesta(richiesta),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatoColor(stato).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatoColor(stato),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatoIcon(stato),
                          size: 14,
                          color: _getStatoColor(stato),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statoLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatoColor(stato),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (richiesta['prezzo_formattato'] != null)
                    Text(
                      richiesta['prezzo_formattato'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getServizioLabelTradotto(richiesta),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getCategoriaLabelTradotta(richiesta['categoria'] ?? ''),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.confirmation_number,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    richiesta['numero_pratica'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatData(richiesta['data_richiesta']),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  // Mostra importo se disponibile
                  if (richiesta['prezzo_formattato'] != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.euro,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      richiesta['prezzo_formattato'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              
              // Badge "In attesa di pagamento" più visibile
              if (isAwaitingPayment) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.paymentRequired,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.orange.shade700,
                      ),
                    ],
                  ),
                ),
              ] else if (pagamento['ricevuto'] == true) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context)!.paymentReceived,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (pagamento['metodo'] != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${pagamento['metodo']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Icona ricevuta disponibile
                    if (pagamento['ricevuto'] == true)
                      InkWell(
                        onTap: () {
                          // Gestisci conversione String/int per payment ID
                          final paymentIdRaw = pagamento['id'];
                          final paymentId = paymentIdRaw is int 
                              ? paymentIdRaw 
                              : (paymentIdRaw is String ? int.tryParse(paymentIdRaw) : null);
                          
                          _visualizzaRicevuta(
                            paymentId,
                            richiesta['numero_pratica'] ?? 'N/A',
                            richiestaId: parseIntOrNull(richiesta['id']),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.infoBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 16,
                                color: AppColors.info,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context)!.downloadReceipt,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.info,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              // Bottone Paga - Usa schermata interna se c'è richiestaId
              if ((isAwaitingPayment || puoPagare) &&
                  parseIntOrNull(richiesta['id']) != null &&
                  pagamento['ricevuto'] != true) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final rid = parseIntOrNull(richiesta['id']);
                      if (rid == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PagamentoScreen(
                            richiestaId: rid,
                          ),
                        ),
                      ).then((_) {
                        // Ricarica le richieste quando torna indietro
                        _caricaRichieste();
                      });
                    },
                    icon: const Icon(Icons.payment, size: 18),
                    label: Text(AppLocalizations.of(context)!.payNow),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],

              // CTA appuntamento fisico (stile Calendly)
              if (richiesta['id'] != null &&
                  (_isAwaitingAppointmentStatus(stato) ||
                      _isAppointmentConfirmedStatus(stato))) ...[
                const SizedBox(height: 12),
                _buildAppuntamentoCta(richiesta, stato),
              ],
            ],
          ),
        ),
      ),
    );

    // Wrap con Dismissible solo se pending (swipe-to-delete)
    if (canDelete) {
      return Dismissible(
        key: Key('richiesta-${richiesta['id']}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          await _confermaEliminaRichiesta(richiesta, fromBottomSheet: false);
          return false; // Non dismissare automaticamente, lo fa _eliminaRichiesta
        },
        background: Container(
          color: AppColors.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.delete, color: Colors.white, size: 32),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.deleteLabel,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        child: cardContent,
      );
    } else {
      return cardContent;
    }
  }
}
