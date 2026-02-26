import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wecoop_app/services/firma_digitale_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class VisualizzaDocumentoWidget extends StatefulWidget {
  final int richiestaId;
  final int userId;
  final String telefono;
  final VoidCallback onFirmaClick;

  const VisualizzaDocumentoWidget({
    super.key,
    required this.richiestaId,
    required this.userId,
    required this.telefono,
    required this.onFirmaClick,
  });

  @override
  State<VisualizzaDocumentoWidget> createState() =>
      _VisualizzaDocumentoWidgetState();
}

class _VisualizzaDocumentoWidgetState extends State<VisualizzaDocumentoWidget> {
  late WebViewController _webViewController;

  String _buildViewerUrl(String sourceUrl) {
    final lower = sourceUrl.toLowerCase();
    if (lower.endsWith('.pdf')) {
      final encoded = Uri.encodeComponent(sourceUrl);
      return 'https://docs.google.com/gview?embedded=1&url=$encoded';
    }
    return sourceUrl;
  }

  @override
  void initState() {
    super.initState();
    print('📄 [DocView] initState richiestaId=${widget.richiestaId} userId=${widget.userId}');
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('🌐 [DocView] WebView onPageStarted: $url');
          },
          onPageFinished: (String url) {
            print('✅ [DocView] WebView onPageFinished: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ [DocView] WebView error code=${error.errorCode} type=${error.errorType} description=${error.description}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Errore caricamento: ${error.description}')),
            );
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🌐 [DocView] Navigation request: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      );

    // Carica il documento quando il widget inizializza
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('📄 [DocView] postFrameCallback -> _loadDocumento');
      _loadDocumento();
    });
  }

  void _loadDocumento() async {
    print('📄 [DocView] _loadDocumento start');
    final provider =
        Provider.of<FirmaDigitaleProvider>(context, listen: false);
    print('📄 [DocView] provider.step before init: ${provider.step}');
    provider.iniziaFlusso(
      richiestaId: widget.richiestaId,
      userId: widget.userId,
      telefono: widget.telefono,
    );
    print('📄 [DocView] iniziaFlusso completato, scarico documento...');
    await provider.scaricaDocumento();
    print('📄 [DocView] scaricaDocumento completato step=${provider.step} hasError=${provider.hasError}');

    if (provider.documento != null) {
      print('✅ [DocView] documento ricevuto url=${provider.documento!.url} nome=${provider.documento!.nome}');
      final viewerUrl = _buildViewerUrl(provider.documento!.url);
      print('🌐 [DocView] viewerUrl=$viewerUrl');
      _webViewController.loadRequest(
        Uri.parse(viewerUrl),
      );
      print('🌐 [DocView] loadRequest inviato alla WebView');
    } else {
      print('❌ [DocView] documento nullo, error=${provider.errorMessage} code=${provider.errorCode}');
    }
  }

  Future<void> _apriDocumentoEsterno(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL documento non valido')),
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile aprire il documento esternamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FirmaDigitaleProvider>(
      builder: (context, provider, _) {
        print('📄 [DocView] build step=${provider.step} isLoading=${provider.isLoading} hasDoc=${provider.documento != null} hasError=${provider.hasError}');
        return Column(
          children: [
            // Intestazione
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Documento Unico',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (provider.documento != null)
                    Text(
                      'Generato il ${_formatData(provider.documento!.dataGenerazione)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            // WebView per il PDF
            Expanded(
              child: provider.isLoading && provider.documento == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          const Text('Caricamento documento...'),
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
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Errore: ${provider.errorMessage}',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadDocumento,
                                child: const Text('Riprova'),
                              ),
                            ],
                          ),
                        )
                      : provider.documento != null
                          ? WebViewWidget(
                              controller: _webViewController,
                            )
                          : const SizedBox.expand(),
            ),
            // Bottom action button
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (provider.documento != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _loadDocumento,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Ricarica anteprima'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _apriDocumentoEsterno(provider.documento!.url),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Apri nel browser'),
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
                      onPressed: provider.documento != null && !provider.isLoading
                          ? widget.onFirmaClick
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: const Text(
                        'Firma Documento',
                        style: TextStyle(
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
