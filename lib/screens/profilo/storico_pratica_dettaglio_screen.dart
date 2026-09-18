import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/app_localizations.dart';
import '../../services/socio_service.dart';
import '../../theme/theme.dart';
import '../../utils/service_request_labels.dart';
import '../servizi/pagamento_screen.dart';

/// Dettaglio di una pratica di servizio dallo Storico (stato, pagamento, firma, documenti).
class StoricoPraticaDettaglioScreen extends StatefulWidget {
  final int richiestaId;
  final Map<String, dynamic>? initial;

  const StoricoPraticaDettaglioScreen({
    super.key,
    required this.richiestaId,
    this.initial,
  });

  @override
  State<StoricoPraticaDettaglioScreen> createState() =>
      _StoricoPraticaDettaglioScreenState();
}

class _StoricoPraticaDettaglioScreenState
    extends State<StoricoPraticaDettaglioScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _dettaglio;
  int? _downloadingDocId;

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
    try {
      final data = await SocioService.getDettaglioRichiesta(widget.richiestaId);
      if (!mounted) return;
      if (data == null) {
        setState(() {
          _dettaglio = widget.initial;
          _loading = false;
          _error = widget.initial == null
              ? 'Pratica non trovata o non accessibile'
              : null;
        });
        return;
      }
      setState(() {
        _dettaglio = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dettaglio = widget.initial;
        _loading = false;
        _error = e.toString();
      });
    }
  }

  List<Map<String, dynamic>> _parseDocs(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> _apriDocumentoPubblicato(Map<String, dynamic> doc) async {
    final docId = doc['id'] is int
        ? doc['id'] as int
        : int.tryParse('${doc['id'] ?? ''}');
    if (docId == null) return;

    setState(() => _downloadingDocId = docId);
    final result = await SocioService.downloadDocumentoRichiesta(
      richiestaId: widget.richiestaId,
      docId: docId,
      fileName: (doc['file_name'] ?? doc['descrizione'] ?? '').toString(),
    );
    if (!mounted) return;
    setState(() => _downloadingDocId = null);

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (result['message'] as String?) ?? 'Impossibile scaricare il documento',
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
        const SnackBar(
          content: Text('File vuoto'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes, flush: true);
      await OpenFile.open(file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossibile aprire il file: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final d = _dettaglio ?? widget.initial ?? {};

    final numero = (d['numero_pratica'] ?? '').toString();
    final servizio = ServiceRequestLabels.servizioFromRecord(l10n, d);
    final categoria = ServiceRequestLabels.categoriaFromRecord(l10n, d);
    final stato = (d['stato'] ?? d['status'] ?? '').toString();
    final pagamento = d['pagamento'] is Map
        ? Map<String, dynamic>.from(d['pagamento'] as Map)
        : <String, dynamic>{};
    final docsCliente = _parseDocs(d['documenti']);
    final docsPubblicati = _parseDocs(d['documenti_risultato']);
    final puoPagare = d['puo_pagare'] == true;
    final firmato = d['firmato'] == true ||
        (d['firma_stato']?.toString().toLowerCase() == 'firmato');
    final paymentId = pagamento['id'] is int
        ? pagamento['id'] as int
        : int.tryParse('${pagamento['id'] ?? ''}');

    return Scaffold(
      appBar: AppBar(
        title: Text(numero.isNotEmpty ? numero : 'Pratica'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_error != null) ...[
                    Text(_error!, style: TextStyle(color: scheme.error)),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    servizio.isNotEmpty ? servizio : 'Servizio',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (categoria.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(categoria, style: theme.textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 12),
                  _chip(scheme, 'Stato', stato.isEmpty ? '—' : stato),
                  const SizedBox(height: 8),
                  _chip(
                    scheme,
                    'Pagamento',
                    _pagamentoLabel(pagamento, d),
                  ),
                  const SizedBox(height: 8),
                  _chip(
                    scheme,
                    'Firma',
                    firmato
                        ? 'Firmato'
                        : (d['firma_stato']?.toString() ??
                            (d['documento_unico_url'] != null
                                ? 'In attesa'
                                : 'Non disponibile')),
                  ),
                  if (puoPagare && paymentId != null) ...[
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PagamentoScreen(
                              paymentId: paymentId,
                              richiestaId: widget.richiestaId,
                            ),
                          ),
                        ).then((_) => _load());
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text('Vai al pagamento'),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Documenti disponibili',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Documenti pubblicati da WeCoop per questa pratica.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (docsPubblicati.isEmpty)
                    Text(
                      'Nessun documento pubblicato al momento.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    )
                  else
                    ...docsPubblicati.map((doc) {
                      final name = (doc['file_name'] ??
                              doc['descrizione'] ??
                              doc['tipo'] ??
                              'Documento')
                          .toString();
                      final tipo = (doc['tipo'] ?? '').toString();
                      final docId = doc['id'] is int
                          ? doc['id'] as int
                          : int.tryParse('${doc['id'] ?? ''}');
                      final busy = docId != null && _downloadingDocId == docId;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.description_outlined,
                          color: scheme.primary,
                        ),
                        title: Text(name),
                        subtitle: tipo.isNotEmpty ? Text(tipo) : null,
                        trailing: busy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                icon: const Icon(Icons.download_outlined),
                                tooltip: 'Visualizza / Scarica',
                                onPressed: () => _apriDocumentoPubblicato(doc),
                              ),
                        onTap: busy ? null : () => _apriDocumentoPubblicato(doc),
                      );
                    }),
                  if (docsCliente.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Documenti inviati',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...docsCliente.map((doc) {
                      final name = (doc['file_name'] ??
                              doc['tipo'] ??
                              'Documento')
                          .toString();
                      final origine = (doc['origine'] ?? '').toString();
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.upload_file_outlined,
                          color: scheme.onSurfaceVariant,
                        ),
                        title: Text(name),
                        subtitle: origine.isNotEmpty
                            ? Text(origine)
                            : const Text('Caricato da te'),
                      );
                    }),
                  ],
                ],
              ),
            ),
    );
  }

  String _pagamentoLabel(Map<String, dynamic> pagamento, Map<String, dynamic> d) {
    if (pagamento['ricevuto'] == true) {
      final importo = pagamento['importo'];
      return importo != null ? 'Pagato (€$importo)' : 'Pagato';
    }
    final fromList = d['payment_status']?.toString();
    final importo = d['payment_importo'] ?? pagamento['importo'];
    if (fromList != null && fromList.isNotEmpty) {
      return importo != null ? '$fromList (€$importo)' : fromList;
    }
    final stato = (pagamento['stato'] ?? '').toString();
    if (stato.isNotEmpty) {
      return importo != null ? '$stato (€$importo)' : stato;
    }
    return 'Nessun pagamento';
  }

  Widget _chip(ColorScheme scheme, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
