import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/firma_digitale_provider.dart';
import 'package:wecoop_app/services/http_client_service.dart';
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

class _VisualizzaDocumentoWidgetState extends State<VisualizzaDocumentoWidget> {
  String? _localPdfPath;
  bool _previewLoading = false;
  String? _previewError;

  @override
  void initState() {
    super.initState();
    AppLogger.d(
      '📄 [DocView] initState richiestaId=${widget.richiestaId} userId=${widget.userId}',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLogger.d('📄 [DocView] postFrameCallback -> _loadDocumento');
      _loadDocumento();
    });
  }

  Future<void> _loadDocumento() async {
    AppLogger.d('📄 [DocView] _loadDocumento start');
    if (!mounted) return;
    setState(() {
      _previewLoading = true;
      _previewError = null;
      _localPdfPath = null;
    });

    final provider =
        Provider.of<FirmaDigitaleProvider>(context, listen: false);
    AppLogger.d('📄 [DocView] provider.step before init: ${provider.step}');
    provider.iniziaFlusso(
      richiestaId: widget.richiestaId,
      userId: widget.userId,
      telefono: widget.telefono,
    );
    AppLogger.d('📄 [DocView] iniziaFlusso completato, scarico documento...');
    await provider.scaricaDocumento();
    AppLogger.d(
      '📄 [DocView] scaricaDocumento completato step=${provider.step} hasError=${provider.hasError}',
    );

    if (!mounted) return;

    if (provider.documento == null) {
      AppLogger.d(
        '❌ [DocView] documento nullo, error=${provider.errorMessage} code=${provider.errorCode}',
      );
      setState(() {
        _previewLoading = false;
        _previewError = provider.errorMessage;
      });
      return;
    }

    AppLogger.d(
      '✅ [DocView] documento ricevuto url=${provider.documento!.url} nome=${provider.documento!.nome}',
    );
    await _scaricaAnteprimaLocale(provider.documento!.url, provider.documento!.nome);
  }

  bool _isSpacesSignedUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('digitaloceanspaces.com') ||
        lower.contains('amazonaws.com') ||
        lower.contains('x-amz-signature');
  }

  Future<http.Response> _fetchPdfBytes(String url) async {
    final uri = Uri.parse(url);
    // URL firmato Spaces: niente Authorization Bearer (rompe la firma SigV4).
    if (_isSpacesSignedUrl(url)) {
      return http.get(
        uri,
        headers: const {'Accept': 'application/pdf,application/octet-stream,*/*'},
      ).timeout(const Duration(seconds: 45));
    }
    return HttpClientService.get(
      uri,
      headers: const {'Accept': 'application/pdf,application/octet-stream,*/*'},
    );
  }

  Future<void> _scaricaAnteprimaLocale(String url, String nome) async {
    try {
      AppLogger.d('📄 [DocView] download anteprima da $url');
      final response = await _fetchPdfBytes(url);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final bytes = response.bodyBytes;
      if (bytes.length < 5 ||
          String.fromCharCodes(bytes.take(5)) != '%PDF-') {
        throw Exception('Risposta non PDF (${bytes.length} bytes)');
      }

      final safeName = nome.replaceAll(RegExp(r'[^\w.\-]'), '_');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/du_preview_$safeName');
      await file.writeAsBytes(bytes, flush: true);
      AppLogger.d('✅ [DocView] anteprima salvata path=${file.path}');

      if (!mounted) return;
      setState(() {
        _localPdfPath = file.path;
        _previewLoading = false;
        _previewError = null;
      });
    } catch (e) {
      AppLogger.d('❌ [DocView] anteprima locale fallita: $e');
      if (!mounted) return;
      setState(() {
        _localPdfPath = null;
        _previewLoading = false;
        _previewError = e.toString();
      });
    }
  }

  Future<void> _apriDocumentoEsterno(String url) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('invalidDocumentUrl'))),
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('cannotOpenDocumentExternally'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<FirmaDigitaleProvider>(
      builder: (context, provider, _) {
        final loadingMeta = provider.isLoading && provider.documento == null;
        final showPreviewBusy = loadingMeta || _previewLoading;

        AppLogger.d(
          '📄 [DocView] build step=${provider.step} isLoading=${provider.isLoading} hasDoc=${provider.documento != null} hasError=${provider.hasError} localPdf=${_localPdfPath != null}',
        );
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
                              filePath: _localPdfPath!,
                              enableSwipe: true,
                              swipeHorizontal: false,
                              autoSpacing: true,
                              pageSnap: true,
                              onError: (error) {
                                AppLogger.d('❌ [DocView] PDFView error: $error');
                              },
                              onPageError: (page, error) {
                                AppLogger.d(
                                  '❌ [DocView] PDFView page=$page error=$error',
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
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: showPreviewBusy ? null : _loadDocumento,
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n.translate('reloadPreview')),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _apriDocumentoEsterno(provider.documento!.url),
                            icon: const Icon(Icons.open_in_new),
                            label: Text(l10n.translate('openInBrowser')),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: provider.documento != null &&
                              !provider.isLoading &&
                              !showPreviewBusy
                          ? widget.onFirmaClick
                          : null,
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
