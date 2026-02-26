import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import '../../services/firma_digitale_service.dart';
import '../../models/firma_digitale_models.dart';
import '../../services/socio_service.dart';
import '../servizi/pagamento_screen.dart';
import '../firma_digitale/firma_documento_screen.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;
  List<Map<String, dynamic>> _tutteRichieste = [];
  String? _filtroStato;
  bool _localeInitialized = false;
  final storage = SecureStorageService();
  String? _richiestaIdToOpen;
  final Map<int, FirmaStatus> _firmaStatusByRichiesta = {};

  List<Map<String, dynamic>> _filtriStato = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initializeLocale();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Controlla se c'è un ID richiesta da aprire (da deep link)
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['richiesta_id'] != null && _richiestaIdToOpen == null) {
      _richiestaIdToOpen = args['richiesta_id'].toString();
      print('📋 Richiesta da aprire: $_richiestaIdToOpen');
      
      // Apri il dettaglio dopo che le richieste sono caricate
      if (!_isLoading && _tutteRichieste.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _apriRichiestaById(_richiestaIdToOpen!);
          _richiestaIdToOpen = null; // Reset per evitare aperture multiple
        });
      }
    }
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('it_IT', null);
    if (mounted) {
      setState(() => _localeInitialized = true);
    }
    _caricaRichieste();
  }

  Future<void> _caricaRichieste() async {
    // Verifica se l'utente è loggato
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      // Utente non loggato, non caricare richieste
      if (mounted) {
        setState(() {
          _tutteRichieste = [];
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final result = await SocioService.getRichiesteUtente(
        page: 1,
        perPage: 100,
        stato: _filtroStato,
      );

      if (result['success'] == true) {
        if (mounted) {
          setState(() {
            _tutteRichieste = List<Map<String, dynamic>>.from(
              result['data'] ?? [],
            );
            _isLoading = false;
          });
          
          // Se c'è una richiesta da aprire, aprila dopo il caricamento
          if (_richiestaIdToOpen != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _apriRichiestaById(_richiestaIdToOpen!);
              _richiestaIdToOpen = null;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        // Non mostrare errore se l'utente non è loggato
        if (result['message']?.contains('login') != true) {
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? l10n.errorLoadingData),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      // Non mostrare errore generico, l'utente potrebbe non essere loggato
      print('Errore caricamento richieste: $e');
    }
  }

  List<Map<String, dynamic>> _getRichiesteDelGiorno(DateTime day) {
    return _tutteRichieste.where((richiesta) {
      final dataRichiesta = DateTime.tryParse(
        richiesta['data_richiesta'] ?? '',
      );
      if (dataRichiesta == null) return false;
      return isSameDay(dataRichiesta, day);
    }).toList();
  }

  Color _getStatoColor(String stato) {
    switch (stato) {
      case 'awaiting_payment':
      case 'pending_payment':
        return Colors.orange;
      case 'processing':
      case 'in_lavorazione':
        return Colors.blue;
      case 'completed':
      case 'completata':
        return Colors.green;
      case 'cancelled':
      case 'annullata':
        return Colors.red;
      case 'in_attesa':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatoIcon(String stato) {
    switch (stato) {
      case 'awaiting_payment':
      case 'pending_payment':
        return Icons.payment;
      case 'processing':
      case 'in_lavorazione':
        return Icons.hourglass_empty;
      case 'completed':
      case 'completata':
        return Icons.check_circle;
      case 'cancelled':
      case 'annullata':
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
    
    switch (stato) {
      case 'pending':
        return l10n.paymentStatusPending;
      case 'awaiting_payment':
      case 'pending_payment':
        return l10n.paymentStatusAwaitingPayment;
      case 'paid':
        return l10n.paymentStatusPaid;
      case 'completed':
      case 'completata':
        return l10n.paymentStatusCompleted;
      case 'failed':
        return l10n.paymentStatusFailed;
      case 'cancelled':
      case 'annullata':
        return l10n.paymentStatusCancelled;
      case 'processing':
      case 'in_lavorazione':
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
    
    switch (categoria) {
      case '730':
      case 'tax_return_730':
        return l10n.taxReturn730;
      case 'form_compilation':
        return l10n.formCompilation;
      case 'residence_permit':
        return l10n.residencePermit;
      case 'citizenship':
        return l10n.citizenship;
      case 'tourist_visa':
        return l10n.touristVisa;
      case 'asylum_request':
        return l10n.asylumRequest;
      case 'income_tax_return':
        return l10n.incomeTaxReturn;
      case 'vat_number_opening':
        return l10n.vatNumberOpening;
      case 'accounting_management':
        return l10n.accountingManagement;
      case 'tax_compliance':
        return l10n.taxCompliance;
      case 'tax_consultation':
        return l10n.taxConsultation;
      case 'tax_debt_management':
        return l10n.taxDebtManagement;
      case 'tax_mediation':
        return l10n.taxMediation;
      default:
        return categoria;
    }
  }

  String _getServizioLabelTradotto(String servizio) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return servizio;
    
    switch (servizio) {
      case 'caf_tax_assistance':
        return l10n.cafTaxAssistance;
      case 'immigration_desk':
        return l10n.immigrationDesk;
      case 'tax_mediation':
        return l10n.taxMediation;
      case 'accounting_support':
        return l10n.accountingSupport;
      default:
        return servizio;
    }
  }

  Future<void> _mostraDettaglioRichiesta(Map<String, dynamic> richiesta) async {
    final richiestaDettaglio = Map<String, dynamic>.from(richiesta);
    final firmaRichiestaId = _resolveFirmaRichiestaId(richiesta);

    final servizioIdInLista = _resolveServizioId(richiestaDettaglio);
    if (servizioIdInLista == 'N/A' && firmaRichiestaId != null) {
      try {
        print('🔎 [Dettaglio] servizioId assente in lista, provo GET dettaglio richiesta id=$firmaRichiestaId');
        final dettaglio = await SocioService.getDettaglioRichiesta(firmaRichiestaId);
        if (dettaglio != null && dettaglio.isNotEmpty) {
          richiestaDettaglio.addAll(dettaglio);
          print('✅ [Dettaglio] richiesta arricchita da endpoint dettaglio, servizioId=${_resolveServizioId(richiestaDettaglio)}');
        } else {
          print('⚠️ [Dettaglio] endpoint dettaglio non ha restituito dati utili per servizioId');
        }
      } catch (e) {
        print('❌ [Dettaglio] errore recupero dettaglio richiesta id=$firmaRichiestaId: $e');
      }
    }

    if (firmaRichiestaId != null) {
      try {
        print('📊 [FirmaFlow] pre-check dettaglio stato firma richiestaId=$firmaRichiestaId');
        final statoFirma = await FirmaDigitaleService.ottieniStatoFirma(firmaRichiestaId);
        if (mounted) {
          setState(() {
            _firmaStatusByRichiesta[firmaRichiestaId] = statoFirma;
          });
        }
        print('📊 [FirmaFlow] pre-check esito richiestaId=$firmaRichiestaId firmato=${statoFirma.firmato}');
      } on FirmaDigitaleException catch (e) {
        if (e.code == 'NOT_FOUND') {
          if (mounted) {
            setState(() {
              _firmaStatusByRichiesta[firmaRichiestaId] = FirmaStatus(
                firmato: false,
                richiestaId: firmaRichiestaId,
              );
            });
          }
          print('📊 [FirmaFlow] pre-check: nessuna firma esistente richiestaId=$firmaRichiestaId');
        } else {
          print('❌ [FirmaFlow] pre-check errore stato firma richiestaId=$firmaRichiestaId code=${e.code} msg=${e.message}');
        }
      } catch (e) {
        print('❌ [FirmaFlow] pre-check eccezione stato firma richiestaId=$firmaRichiestaId: $e');
      }
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDettaglioSheet(richiestaDettaglio),
    );
  }

  Future<void> _confermaEliminaRichiesta(Map<String, dynamic> richiesta, {bool fromBottomSheet = false}) async {
    final l10n = AppLocalizations.of(context)!;
    final stato = richiesta['stato'] ?? '';
    
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
              '${l10n.paymentService}: ${_getServizioLabelTradotto(richiesta['servizio'] ?? '')}',
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.deleteRequest),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _eliminaRichiesta(richiesta['id'] as int, fromBottomSheet: fromBottomSheet);
    }
  }

  Future<void> _eliminaRichiesta(int richiestaId, {bool fromBottomSheet = false}) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Guarda el contexto del navigator antes de operaciones asíncronas
    final navigator = Navigator.of(context);
    
    try {
      // Mostra loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final result = await SocioService.deleteRichiesta(richiestaId);

      // Chiudi loading - usa il navigator salvato
      if (mounted) {
        navigator.pop();
      }

      if (result['success'] == true) {
        // Chiudi bottom sheet solo se chiamato da lì
        if (fromBottomSheet && mounted) {
          navigator.pop();
        }
        
        // Mostra successo
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${l10n.requestDeleted}'),
              backgroundColor: Colors.green,
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
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      // Chiudi loading
      if (mounted) {
        navigator.pop();
      }

      // Mostra errore
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.cannotDeleteRequest}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _visualizzaRicevuta(int? paymentId, String numeroPratica, {int? richiestaId}) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Se non abbiamo payment ID ma abbiamo richiesta ID, mostra messaggio
    if (paymentId == null && richiestaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${l10n.errorDownloadingReceipt}: ID pagamento mancante'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    try {
      // Mostra loading
      showDialog(
        context: context,
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

      // Se non abbiamo paymentId, usa richiestaId per cercare il pagamento
      int actualPaymentId = paymentId ?? 0;
      
      if (paymentId == null && richiestaId != null) {
        print('⚠️ Payment ID mancante, uso richiesta ID: $richiestaId');
        // TODO: Chiamare API per ottenere payment ID da richiesta ID
        // Per ora usiamo richiestaId come fallback
        actualPaymentId = richiestaId;
      }

      // Ottieni ricevuta PDF
      final result = await SocioService.getRicevutaPdf(actualPaymentId);

      // Chiudi loading
      if (mounted) Navigator.pop(context);

      if (result['success'] == true) {
        // Il backend ritorna il PDF direttamente come bytes
        final pdfBytes = result['pdf_bytes'] as List<int>?;
        final filename = result['filename'] as String? ?? 'ricevuta.pdf';

        if (pdfBytes != null) {
          // Salva il PDF automaticamente e aprilo
          try {
            final savedFile = await _salvaPdfLocale(pdfBytes, filename);
            
            if (savedFile != null && mounted) {
              // Apri il PDF automaticamente
              final result = await OpenFile.open(savedFile.path);
              
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
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'Apri',
                    textColor: Colors.white,
                    onPressed: () => OpenFile.open(savedFile.path),
                  ),
                ),
              );
              
              print('✅ PDF salvato e aperto: ${savedFile.path}');
              print('📱 OpenFile result: ${result.message}');
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('⚠️ PDF ricevuto ma impossibile salvarlo'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          } catch (e) {
            print('❌ Errore salvataggio/apertura PDF: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Errore: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }
        } else {
          // Vecchio formato con URL
          final receiptUrl = result['receipt_url'] as String?;
          if (receiptUrl != null && mounted) {
            await _apriRicevutaWeb(receiptUrl);
          }
        }
      } else {
        // Mostra errore
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${result['message'] ?? l10n.errorDownloadingReceipt}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      // Chiudi loading se aperto
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Mostra errore
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${l10n.errorDownloadingReceipt}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<File?> _salvaPdfLocale(List<int> pdfBytes, String filename) async {
    try {
      // 1. Richiedi permessi storage (solo Android)
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          print('⚠️ Permesso storage negato');
          // Su Android 13+ non serve più il permesso WRITE_EXTERNAL_STORAGE
          // Proviamo comunque a salvare in app-specific directory
        }
      }
      
      // 2. Ottieni directory appropriata
      Directory? directory;
      
      if (Platform.isAndroid) {
        // Prova a ottenere la directory Download pubblica
        try {
          // Per Android, usa la directory Download pubblica
          directory = Directory('/storage/emulated/0/Download');
          
          // Se non esiste, usa directory app-specific
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        } catch (e) {
          print('⚠️ Impossibile accedere a Download, uso directory app: $e');
          directory = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        // Per iOS, usa directory Documents dell'app
        directory = await getApplicationDocumentsDirectory();
      } else {
        // Fallback per altre piattaforme
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) {
        print('❌ Impossibile ottenere directory');
        return null;
      }
      
      // 3. Crea il percorso completo del file
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      
      // 4. Scrivi i bytes sul file
      await file.writeAsBytes(pdfBytes);
      
      print('✅ PDF salvato in: $filePath');
      print('📁 Directory: ${directory.path}');
      print('📄 File size: ${pdfBytes.length} bytes');
      
      return file;
    } catch (e) {
      print('❌ Errore salvataggio PDF: $e');
      return null;
    }
  }

  Future<void> _apriRicevutaWeb(String url) async {
    // Apre l'URL nel browser esterno
    // Nota: richiede url_launcher package, ma per ora usiamo un placeholder
    // In produzione, decommenta il codice sotto e aggiungi url_launcher al pubspec.yaml
    
    /*
    import 'package:url_launcher/url_launcher.dart';
    
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cannotOpenFile),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    */
    
    // Placeholder: mostra URL in un dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('URL Ricevuta'),
          content: SelectableText(url),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ],
        ),
      );
    }
  }

  String _buildViewerUrl(String sourceUrl) {
    // Evita Google gview su Android WebView: può fallire con ERR_BLOCKED_BY_ORB.
    // Carichiamo direttamente il PDF/URL originale.
    return sourceUrl;
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
    } catch (_) {}

    final normalized = value.replaceAll('\\', '/');
    final parts = normalized.split('/').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return 'N/A';
    return Uri.decodeComponent(parts.last);
  }

  Map<String, dynamic> _sanitizeMetadata(Map<String, dynamic> metadata) {
    final sanitized = Map<String, dynamic>.from(metadata);
    const sensitivePathKeys = [
      'documento_url',
      'documento_download_url',
      'url',
      'filepath',
      'path',
      'file_path',
      'file',
      'filename',
      'nome_file',
    ];

    for (final key in sensitivePathKeys) {
      if (sanitized[key] is String) {
        sanitized[key] = _extractFileName(sanitized[key] as String);
      }
    }

    return sanitized;
  }

  Future<void> _visualizzaDocumentoUnico(String url) async {
    if (!mounted) return;

    final uri = Uri.tryParse(url);
    if (uri != null) {
      final openedExternal = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (openedExternal) {
        print('✅ [DocSigned] documento aperto esternamente: $url');
        return;
      }
    }

    final viewerUrl = _buildViewerUrl(url);

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String startedUrl) {
            print('🌐 [DocSigned] onPageStarted: $startedUrl');
          },
          onPageFinished: (String finishedUrl) {
            print('✅ [DocSigned] onPageFinished: $finishedUrl');
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ [DocSigned] WebView error code=${error.errorCode} type=${error.errorType} description=${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(viewerUrl));

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Documento Unico Firmato')),
          body: WebViewWidget(controller: controller),
        ),
      ),
    );
  }

  void _apriRichiestaById(String id) {
    print('🔍 Cerco richiesta con ID: $id');
    
    final richiesta = _tutteRichieste.firstWhere(
      (r) => r['id'].toString() == id,
      orElse: () => {},
    );
    
    if (richiesta.isNotEmpty) {
      print('✅ Richiesta trovata: ${richiesta['numero_pratica']}');
      _mostraDettaglioRichiesta(richiesta);
    } else {
      print('❌ Richiesta non trovata: $id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Richiesta non trovata'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  bool _isRichiestaFirmabile(Map<String, dynamic> richiesta) {
    if (richiesta['puo_firmare'] == true) {
      return true;
    }

    final stato = (richiesta['stato'] ?? '').toString().toLowerCase();
    return stato == 'pending_firma' ||
        stato == 'awaiting_signature' ||
        stato == 'in_attesa_firma' ||
        stato == 'da_firmare' ||
        stato == 'paid' ||
        stato == 'completed' ||
        stato == 'completata';
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

  String? _resolveDocumentoUnicoUrl(FirmaStatus? firmaStatus) {
    final downloadUrl = firmaStatus?.documentoDownloadUrl;
    if (_isValidWebUrl(downloadUrl)) {
      return downloadUrl!.trim();
    }

    final documentoUrl = firmaStatus?.documentoUrl;
    if (_isValidWebUrl(documentoUrl)) {
      return documentoUrl!.trim();
    }

    return null;
  }

  String? _resolveDocumentoUnicoUrlFromRichiesta(Map<String, dynamic> richiesta) {
    final candidates = [
      richiesta['documento_unico_url'],
      richiesta['documento_url'],
      richiesta['documento_download_url'],
      richiesta['modello_unico_url'],
      richiesta['url_documento'],
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString();
      if (_isValidWebUrl(value)) {
        return value!.trim();
      }
    }

    return null;
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

  Future<void> _apriFirmaDocumento(Map<String, dynamic> richiesta) async {
    final firmaRichiestaId = _resolveFirmaRichiestaId(richiesta);
    print('🔐 [FirmaFlow] Avvio apertura firma');
    print('🔐 [FirmaFlow] Campi ID candidati: richiesta_id=${richiesta['richiesta_id']} id_richiesta=${richiesta['id_richiesta']} request_id=${richiesta['request_id']} service_request_id=${richiesta['service_request_id']} id=${richiesta['id']}');
    print('🔐 [FirmaFlow] ID selezionato per endpoint documento-unico: $firmaRichiestaId');

    if (firmaRichiestaId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID richiesta non valido per firma digitale'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      print('📊 [FirmaFlow] controllo stato firma per richiestaId=$firmaRichiestaId');
      final statoFirma = await FirmaDigitaleService.ottieniStatoFirma(firmaRichiestaId);
      print('📊 [FirmaFlow] stato firma ricevuto: firmato=${statoFirma.firmato}, documentoUrl=${statoFirma.documentoUrl}, documentoDownloadUrl=${statoFirma.documentoDownloadUrl}');

      if (statoFirma.firmato) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Documento già firmato. Non è possibile rifirmare questa richiesta.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

    } on FirmaDigitaleException catch (e) {
      if (e.code == 'NOT_FOUND') {
        print('📊 [FirmaFlow] nessuna firma esistente per richiestaId=$firmaRichiestaId, continuo con il flusso');
      } else {
        print('❌ [FirmaFlow] errore durante controllo stato firma: ${e.code} - ${e.message}');
      }
    } catch (e) {
      print('❌ [FirmaFlow] eccezione non prevista durante controllo stato firma: $e');
    }

    final userIdRaw = await storage.read(key: 'user_id');
    final socioIdRaw = await storage.read(key: 'socio_id');
    final telefonoRaw =
        await storage.read(key: 'telefono') ?? await storage.read(key: 'user_phone');

    final parsedUserId = userIdRaw != null ? int.tryParse(userIdRaw) : null;
    final parsedSocioId = socioIdRaw != null ? int.tryParse(socioIdRaw) : null;
    final userId = parsedUserId ?? parsedSocioId;
    final telefono = telefonoRaw?.trim();

    print('🔐 [FirmaFlow] Storage user_id raw: $userIdRaw');
    print('🔐 [FirmaFlow] Storage socio_id raw: $socioIdRaw');
    print('🔐 [FirmaFlow] Storage telefono presente: ${telefono != null && telefono.isNotEmpty}');
    print('🔐 [FirmaFlow] userId parse: $userId');

    if (!mounted) return;

    if (userId == null || telefono == null || telefono.isEmpty) {
      print('❌ [FirmaFlow] Dati utente mancanti, blocco apertura firma');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dati utente non disponibili per la firma digitale (user_id/socio_id o telefono mancanti)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context);
    print('🔐 [FirmaFlow] Bottom sheet chiuso, apro FirmaDocumentoScreen');

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FirmaDocumentoScreen(
          richiestaId: firmaRichiestaId,
          userId: userId,
          telefono: telefono,
        ),
      ),
    );

    print('🔐 [FirmaFlow] Rientro da FirmaDocumentoScreen, ricarico richieste');

    _caricaRichieste();
  }

  Widget _buildDettaglioSheet(Map<String, dynamic> richiesta) {
    final stato = richiesta['stato'] ?? '';
    final statoLabel = _getStatoLabelTradotto(stato);
    final pagamento = richiesta['pagamento'] ?? {};
    final puoPagare = richiesta['puo_pagare'] == true;
    final richiestaIdRaw = richiesta['id'];
    final richiestaId = richiestaIdRaw is int
        ? richiestaIdRaw
        : int.tryParse(richiestaIdRaw?.toString() ?? '');
    final firmaRichiestaId = _resolveFirmaRichiestaId(richiesta);
    final isFirmabile = _isRichiestaFirmabile(richiesta);
    final firmaStatus =
      firmaRichiestaId != null ? _firmaStatusByRichiesta[firmaRichiestaId] : null;
    final isGiaFirmata = firmaStatus?.firmato == true;
    final documentoUnicoUrl =
        _resolveDocumentoUnicoUrl(firmaStatus) ??
        _resolveDocumentoUnicoUrlFromRichiesta(richiesta);
    final canOpenFirmaCta = documentoUnicoUrl != null && !isGiaFirmata;
    
    // Debug: verifica dati pagamento COMPLETI
    print('📋 ==================== DEBUG RICHIESTA ====================');
    print('📋 Richiesta ID: $richiestaId');
    print('📋 Stato: $stato');
    print('📋 Numero pratica: ${richiesta['numero_pratica']}');
    print('💰 ==================== PAGAMENTO COMPLETO ====================');
    print('💰 Pagamento object: $pagamento');
    print('💰 Pagamento keys: ${pagamento.keys.toList()}');
    print('🔑 pagamento["id"]: ${pagamento['id']}');
    print('🔑 pagamento["payment_id"]: ${pagamento['payment_id']}');
    print('🔑 pagamento["pagamento_id"]: ${pagamento['pagamento_id']}');
    print('✅ pagamento["ricevuto"]: ${pagamento['ricevuto']}');
    print('🔐 [FirmaFlow] CTA abilitata: $canOpenFirmaCta');
    print('🔐 [FirmaFlow] isFirmabile=$isFirmabile stato=$stato puo_firmare=${richiesta['puo_firmare']} richiestaId=$richiestaId isGiaFirmata=$isGiaFirmata');
    print('📋 =========================================================');
    
    // Stato awaiting_payment significa che c'è un pagamento da effettuare
    final isAwaitingPayment = stato == 'awaiting_payment' || stato == 'pending_payment';

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
                              _getServizioLabelTradotto(richiesta['servizio'] ?? ''),
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
                        'ID Richiesta',
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
                            'ID Transazione',
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
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green.shade700,
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
                                        color: Colors.green.shade900,
                                      ),
                                    ),
                                    if (pagamento['metodo'] != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${AppLocalizations.of(context)!.paymentMethod}: ${pagamento['metodo']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.green.shade700,
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
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                        ),
                      ],

                      if (canOpenFirmaCta) ...[
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _apriFirmaDocumento(richiesta),
                          icon: const Icon(Icons.verified_user),
                          label: const Text('Apri Modello Unico e Firma con OTP'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                        ),
                      ],

                      if (isFirmabile && isGiaFirmata) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified, color: Colors.orange),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Documento già firmato. La firma OTP non è più disponibile.',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              initiallyExpanded: false,
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: const EdgeInsets.only(bottom: 8),
                              leading: const Icon(Icons.badge, color: Colors.blue),
                              title: const Text(
                                'Dettagli Firma Digitale',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: const Text(
                                'Tocca per espandere',
                                style: TextStyle(fontSize: 12),
                              ),
                              children: [
                                _buildInfoRow(
                                  'Firmato',
                                  (firmaStatus?.firmato == true) ? 'Sì' : 'No',
                                  Icons.verified,
                                ),
                                if ((firmaStatus?.id ?? '').isNotEmpty)
                                  _buildInfoRow(
                                    'Firma ID',
                                    firmaStatus!.id!,
                                    Icons.fingerprint,
                                  ),
                                if (firmaStatus?.dataFirma != null)
                                  _buildInfoRow(
                                    'Timestamp firma',
                                    _formatData(firmaStatus!.dataFirma!.toIso8601String()),
                                    Icons.access_time,
                                  ),
                                if ((firmaStatus?.metodo ?? '').isNotEmpty)
                                  _buildInfoRow(
                                    'Tipo firma',
                                    firmaStatus!.metodo!,
                                    Icons.fact_check,
                                  ),
                                if ((firmaStatus?.status ?? '').isNotEmpty)
                                  _buildInfoRow(
                                    'Stato firma',
                                    firmaStatus!.status!,
                                    Icons.rule,
                                  ),
                                if ((firmaStatus?.firmaHash ?? '').isNotEmpty)
                                  _buildInfoRow(
                                    'Hash firma',
                                    firmaStatus!.firmaHash!,
                                    Icons.tag,
                                  ),
                                if ((firmaStatus?.documentoHashSha256 ?? '').isNotEmpty)
                                  _buildInfoRow(
                                    'Hash documento (SHA256)',
                                    firmaStatus!.documentoHashSha256!,
                                    Icons.security,
                                  ),
                                if ((firmaStatus?.deviceFirma ?? '').isNotEmpty)
                                  _buildInfoRow(
                                    'Device firma',
                                    firmaStatus!.deviceFirma!,
                                    Icons.devices,
                                  ),
                                if ((firmaStatus?.documentoUrl ?? '').isNotEmpty)
                                  _buildInfoRow(
                                    'Nome file documento',
                                    _extractFileName(firmaStatus!.documentoUrl),
                                    Icons.link,
                                  ),
                                if ((firmaStatus?.documentoDownloadUrl ?? '').isNotEmpty)
                                  _buildInfoRow(
                                    'Nome file download',
                                    _extractFileName(firmaStatus!.documentoDownloadUrl),
                                    Icons.download,
                                  ),
                                if (firmaStatus?.metadata != null &&
                                    firmaStatus!.metadata!.isNotEmpty)
                                  _buildInfoRow(
                                    'Metadata firma',
                                    jsonEncode(_sanitizeMetadata(firmaStatus.metadata!)),
                                    Icons.data_object,
                                  ),
                              ],
                            ),
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
                            
                            print('🧾 Tentativo scarica ricevuta:');
                            print('   - Payment ID: $paymentId');
                            print('   - Transaction ID: $transactionId');
                            print('   - Richiesta ID: $richiestaId');
                            
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
                                        const Text('Ricevuta Non Disponibile'),
                                      ],
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Il sistema sta elaborando il tuo pagamento.',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text('Dettagli pagamento:'),
                                        const SizedBox(height: 8),
                                        Text('• Pratica: ${richiesta['numero_pratica']}'),
                                        if (transactionId != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            '• ID Transazione: ${transactionId.substring(0, 20)}...',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                        if (pagamento['metodo'] != null) ...[
                                          const SizedBox(height: 4),
                                          Text('• Metodo: ${pagamento['metodo']}'),
                                        ],
                                        if (pagamento['data'] != null) ...[
                                          const SizedBox(height: 4),
                                          Text('• Data: ${_formatData(pagamento['data'])}'),
                                        ],
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.lightbulb_outline, size: 20, color: Colors.blue),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'La ricevuta sarà disponibile a breve. Riprova tra qualche minuto o contatta il supporto.',
                                                  style: TextStyle(fontSize: 12),
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
                                        child: const Text('Chiudi'),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _caricaRichieste(); // Ricarica per vedere se ora c'è l'ID
                                        },
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Ricarica'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
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
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                        ),

                        if (documentoUnicoUrl != null) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => _visualizzaDocumentoUnico(documentoUnicoUrl),
                            icon: const Icon(Icons.description_outlined),
                            label: const Text('Visualizza Documento Unico'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: BorderSide(color: Colors.blue.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              minimumSize: const Size(double.infinity, 0),
                            ),
                          ),
                        ],
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
    
    // Inizializza filtri con traduzioni
    if (_filtriStato.isEmpty) {
      _filtriStato = [
        {'label': l10n.all, 'value': null},
        {'label': l10n.paymentStatusAwaitingPayment, 'value': 'awaiting_payment'},
        {'label': l10n.paymentStatusCompleted, 'value': 'completed'},
      ];
    }
    
    if (!_localeInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myRequests),
      ),
      body: RefreshIndicator(
        onRefresh: _caricaRichieste,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Filtri stato
                  Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _filtriStato.length,
                      itemBuilder: (context, index) {
                        final filtro = _filtriStato[index];
                        final isSelected = _filtroStato == filtro['value'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text(filtro['label']),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _filtroStato =
                                    selected
                                        ? filtro['value'] as String?
                                        : null;
                              });
                              _caricaRichieste();
                            },
                            backgroundColor: Colors.grey.shade200,
                            selectedColor: Colors.amber.shade100,
                            checkmarkColor: Colors.amber.shade700,
                          ),
                        );
                      },
                    ),
                  ),

                  // Calendario
                  Card(
                    margin: const EdgeInsets.all(8),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate:
                          (day) => isSameDay(_selectedDay, day),
                      calendarFormat: _calendarFormat,
                      eventLoader: _getRichiesteDelGiorno,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      locale: 'it_IT',
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.amber.shade300,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    ),
                  ),

                  // Lista richieste
                  Expanded(child: _buildListaRichieste()),
                ],
              ),
      ),
    );
  }

  Widget _buildListaRichieste() {
    final richieste =
        _selectedDay != null
            ? _getRichiesteDelGiorno(_selectedDay!)
            : _tutteRichieste;

    if (richieste.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _selectedDay != null
                  ? AppLocalizations.of(context)!.noRequestsThisDay
                  : AppLocalizations.of(context)!.noRequestsFound,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: richieste.length,
      itemBuilder: (context, index) {
        final richiesta = richieste[index];
        return _buildRichiestaCard(richiesta);
      },
    );
  }

  Widget _buildRichiestaCard(Map<String, dynamic> richiesta) {
    final stato = richiesta['stato'] ?? '';
    final statoLabel = _getStatoLabelTradotto(stato);
    final pagamento = richiesta['pagamento'] ?? {};
    final puoPagare = richiesta['puo_pagare'] == true;
    final isAwaitingPayment = stato == 'awaiting_payment' || stato == 'pending_payment';
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
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getServizioLabelTradotto(richiesta['servizio'] ?? ''),
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
                        color: Colors.green.shade700,
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
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context)!.paymentReceived,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
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
                            richiestaId: richiesta['id'] as int?,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 16,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppLocalizations.of(context)!.downloadReceipt,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue.shade700,
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
              if ((isAwaitingPayment || puoPagare) && richiesta['id'] != null && pagamento['ricevuto'] != true) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PagamentoScreen(
                            richiestaId: richiesta['id'] as int,
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
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete, color: Colors.white, size: 32),
              SizedBox(height: 4),
              Text(
                'Elimina',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
