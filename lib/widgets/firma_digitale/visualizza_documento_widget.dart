import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/attivazione_service.dart';
import 'package:wecoop_app/services/firma_digitale_provider.dart';
import 'package:wecoop_app/services/socio_service.dart';
import 'package:wecoop_app/theme/theme.dart';
import 'package:wecoop_app/utils/app_logger.dart';

class VisualizzaDocumentoWidget extends StatefulWidget {
  /// Null = Documento Unico user-level (senza pratica).
  final int? richiestaId;
  final int userId;
  final String telefono;
  final VoidCallback onFirmaClick;

  const VisualizzaDocumentoWidget({
    super.key,
    this.richiestaId,
    required this.userId,
    required this.telefono,
    required this.onFirmaClick,
  });

  @override
  State<VisualizzaDocumentoWidget> createState() =>
      _VisualizzaDocumentoWidgetState();
}

class _VisualizzaDocumentoWidgetState extends State<VisualizzaDocumentoWidget>
    with WidgetsBindingObserver {
  String? _localPdfPath;
  Key _pdfViewKey = UniqueKey();
  bool _previewLoading = false;
  String? _previewError;
  bool _hasReadDocument = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppLogger.d(
      '📄 [DocView] initState richiestaId=${widget.richiestaId} userId=${widget.userId}',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLogger.d('📄 [DocView] postFrameCallback -> _loadDocumento');
      _loadDocumento();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _deletePreviewFile(_localPdfPath);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _localPdfPath != null &&
        !_previewLoading) {
      // Android PlatformView can go blank after background; remount without re-download.
      AppLogger.d('📄 [DocView] resumed -> remount PDFView');
      setState(() {
        _pdfViewKey = UniqueKey();
      });
    }
  }

  Future<void> _deletePreviewFile(String? path) async {
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  Future<void> _loadDocumento() async {
    AppLogger.d('📄 [DocView] _loadDocumento start');
    if (!mounted) return;
    final previousPath = _localPdfPath;
    setState(() {
      _previewLoading = true;
      _previewError = null;
      _localPdfPath = null;
      _hasReadDocument = false;
    });
    await _deletePreviewFile(previousPath);

    final provider =
        Provider.of<FirmaDigitaleProvider>(context, listen: false);
    provider.iniziaFlusso(
      richiestaId: widget.richiestaId,
      userId: widget.userId,
      telefono: widget.telefono,
    );
    await provider.scaricaDocumento();

    if (!mounted) return;

    if (provider.documento == null) {
      AppLogger.d(
        '❌ [DocView] documento nullo, error=${provider.errorMessage}',
      );
      setState(() {
        _previewLoading = false;
        _previewError = provider.errorMessage;
        _hasReadDocument = false;
      });
      return;
    }

    final nome = provider.documento!.nome;
    // Preferisci stream PDF autenticato (niente WebView / Spaces lato client).
    final fromApi = await _scaricaPdfAutenticato(nome);
    if (fromApi) return;

    // Fallback: URL firmato Spaces (se l'API non è disponibile).
    final url = provider.documento!.url;
    if (url.isNotEmpty) {
      AppLogger.d('📄 [DocView] fallback download Spaces url=$url');
      await _scaricaDaUrl(url, nome);
      return;
    }

    if (!mounted) return;
    setState(() {
      _previewLoading = false;
      _previewError = 'PDF non disponibile';
      _hasReadDocument = false;
    });
  }

  Future<bool> _scaricaPdfAutenticato(String nome) async {
    try {
      Map<String, dynamic> result;
      if (widget.richiestaId == null) {
        AppLogger.d('📄 [DocView] GET /documento-unico/download (user-level)');
        result = await AttivazioneService.downloadDocumentoUnicoPdf();
      } else {
        AppLogger.d(
          '📄 [DocView] GET /documento-unico/${widget.richiestaId}/download-merged',
        );
        result = await SocioService.getDocumentoUnicoMergedPdf(
          widget.richiestaId!,
        );
      }

      if (result['success'] != true) {
        AppLogger.d('⚠️ [DocView] API PDF fail: ${result['message']}');
        return false;
      }

      final bytes = result['pdf_bytes'] as List<int>?;
      if (bytes == null || bytes.length < 5) return false;
      final header = String.fromCharCodes(bytes.take(5));
      if (header != '%PDF-') return false;

      final filename = (result['filename'] as String?) ?? nome;
      await _persistPreview(bytes, filename);
      return true;
    } catch (e) {
      AppLogger.d('⚠️ [DocView] API PDF eccezione: $e');
      return false;
    }
  }

  Future<void> _scaricaDaUrl(String url, String nome) async {
    try {
      final uri = Uri.parse(url);
      final response = await http
          .get(
            uri,
            headers: const {
              'Accept': 'application/pdf,application/octet-stream,*/*',
            },
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final bytes = response.bodyBytes;
      if (bytes.length < 5 ||
          String.fromCharCodes(bytes.take(5)) != '%PDF-') {
        throw Exception('Risposta non PDF (${bytes.length} bytes)');
      }
      await _persistPreview(bytes, nome);
    } catch (e) {
      AppLogger.d('❌ [DocView] download URL fallito: $e');
      if (!mounted) return;
      setState(() {
        _localPdfPath = null;
        _previewLoading = false;
        _previewError = e.toString();
        _hasReadDocument = false;
      });
    }
  }

  Future<void> _persistPreview(List<int> bytes, String nome) async {
    final safeName = nome.replaceAll(RegExp(r'[^\w.\-]'), '_');
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/du_preview_${stamp}_$safeName');
    await file.writeAsBytes(bytes, flush: true);
    AppLogger.d('✅ [DocView] anteprima salvata path=${file.path}');
    if (!mounted) return;
    setState(() {
      _localPdfPath = file.path;
      _pdfViewKey = UniqueKey();
      _previewLoading = false;
      _previewError = null;
      _hasReadDocument = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<FirmaDigitaleProvider>(
      builder: (context, provider, _) {
        final loadingMeta = provider.isLoading && provider.documento == null;
        final showPreviewBusy = loadingMeta || _previewLoading;
        final canSign = provider.documento != null &&
            _localPdfPath != null &&
            _hasReadDocument &&
            !provider.isLoading &&
            !showPreviewBusy;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.infoBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('singleDocumentLabel'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (provider.documento != null)
                    Text(
                      '${l10n.translate('generatedOn')} ${_formatData(provider.documento!.dataGenerazione)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            Expanded(
              child: showPreviewBusy
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(l10n.translate('loadingDocument')),
                        ],
                      ),
                    )
                  : provider.hasError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${l10n.error}: ${provider.errorMessage}',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadDocumento,
                                child: Text(l10n.retry),
                              ),
                            ],
                          ),
                        )
                      : _localPdfPath != null
                          ? PDFView(
                              key: _pdfViewKey,
                              filePath: _localPdfPath!,
                              enableSwipe: true,
                              swipeHorizontal: false,
                              autoSpacing: true,
                              pageSnap: true,
                              onError: (error) {
                                AppLogger.d(
                                  '❌ [DocView] PDFView error: $error',
                                );
                              },
                            )
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.picture_as_pdf_outlined,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _previewError != null
                                          ? '${l10n.translate('docViewLoadError')}: $_previewError'
                                          : l10n.translate('docViewLoadError'),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _loadDocumento,
                                      child: Text(l10n.retry),
                                    ),
                                  ],
                                ),
                              ),
                            ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (provider.documento != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: showPreviewBusy ? null : _loadDocumento,
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.translate('reloadPreview')),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: _hasReadDocument,
                      onChanged: showPreviewBusy || _localPdfPath == null
                          ? null
                          : (value) {
                              setState(() {
                                _hasReadDocument = value ?? false;
                              });
                            },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.translate('documentReadAck')),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: canSign ? widget.onFirmaClick : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: Text(
                        l10n.translate('signDocument'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatData(DateTime data) {
    return '${data.day}/${data.month}/${data.year} ${data.hour}:${data.minute.toString().padLeft(2, '0')}';
  }
}
