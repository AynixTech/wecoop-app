import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/pratica_documento.dart';
import '../../services/app_localizations.dart';
import '../../services/socio_service.dart';
import '../../theme/theme.dart';
import '../../utils/service_request_labels.dart';
import 'storico_pratica_dettaglio_screen.dart';

/// Storico pratiche: elenca le richieste di servizio (WC-…) con pagamento/firma
/// e i documenti fiscali (730, CU, ISEE) caricati dagli operatori.
class StoricoPraticheScreen extends StatefulWidget {
  const StoricoPraticheScreen({super.key});

  @override
  State<StoricoPraticheScreen> createState() => _StoricoPraticheScreenState();
}

class _StoricoPraticheScreenState extends State<StoricoPraticheScreen> {
  bool _loading = true;
  bool _error = false;
  List<Map<String, dynamic>> _pratiche = [];
  List<PraticaDocumento> _documenti = [];
  int? _downloadingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final bundle = await SocioService.getStoricoPraticheBundle();
      if (!mounted) return;
      if (bundle['success'] != true) {
        setState(() {
          _error = true;
          _loading = false;
        });
        return;
      }
      final pratiche = bundle['pratiche'];
      final docs = bundle['documenti'];
      setState(() {
        _pratiche = pratiche is List
            ? pratiche
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : [];
        _documenti = docs is List<PraticaDocumento>
            ? docs
            : (docs is List
                ? docs.whereType<PraticaDocumento>().toList()
                : <PraticaDocumento>[]);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  void _openPratica(Map<String, dynamic> pratica) {
    final id = pratica['id'];
    final richiestaId = id is int ? id : int.tryParse('$id');
    if (richiestaId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoricoPraticaDettaglioScreen(
          richiestaId: richiestaId,
          initial: pratica,
        ),
      ),
    ).then((_) => _load());
  }

  IconData _iconForTipo(PraticaDocumento doc) {
    if (doc.isPdf) return Icons.picture_as_pdf_rounded;
    final mime = (doc.mimeType ?? '').toLowerCase();
    if (mime.contains('image')) return Icons.image_rounded;
    return Icons.description_rounded;
  }

  Future<void> _openDocument(PraticaDocumento doc) async {
    final l10n = AppLocalizations.of(context)!;

    setState(() => _downloadingId = doc.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('storicoPraticheOpening')),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    final result = await SocioService.downloadDocumentoPratica(doc);

    if (!mounted) return;
    setState(() => _downloadingId = null);

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (result['message'] as String?) ??
                l10n.translate('storicoPraticheDownloadError'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final List<int> bytes = (result['bytes'] as List<int>?) ?? <int>[];
    final String filename =
        (result['filename'] as String?) ?? 'documento_${doc.id}.pdf';
    final String mime = (result['mime'] as String?) ?? '';

    if (bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('storicoPraticheDownloadError')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final file = await _saveToDisk(bytes, filename);
    if (file == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('storicoPraticheDownloadError')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final isPdf = mime.toLowerCase().contains('pdf') ||
        filename.toLowerCase().endsWith('.pdf') ||
        doc.isPdf;

    if (isPdf) {
      await _openPdfInApp(file, title: doc.titolo);
    } else {
      await OpenFile.open(file.path);
    }
  }

  Future<File?> _saveToDisk(List<int> bytes, String filename) async {
    try {
      final safeFilename = filename.trim().isEmpty
          ? 'documento.pdf'
          : filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

      Directory directory;
      try {
        directory = await getApplicationDocumentsDirectory();
      } catch (_) {
        directory = await getTemporaryDirectory();
      }

      final filePath = '${directory.path}/$safeFilename';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Errore salvataggio documento: $e');
      return null;
    }
  }

  Future<void> _openPdfInApp(File file, {String? title}) async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(title ?? 'Documento PDF')),
          body: PDFView(
            filePath: file.path,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageSnap: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('storicoPraticheTitle')),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(theme, scheme, l10n),
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(Icons.cloud_off_rounded,
              size: 56, color: scheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Center(
            child: Text(
              l10n.translate('storicoPraticheError'),
              style: theme.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.tonal(
              onPressed: _load,
              child: Text(l10n.translate('storicoPraticheRetry')),
            ),
          ),
        ],
      );
    }

    if (_pratiche.isEmpty && _documenti.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(Icons.folder_off_outlined,
              size: 56, color: scheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                l10n.translate('storicoPraticheEmpty'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_pratiche.isNotEmpty) ...[
          Text(
            'Le tue pratiche',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ..._pratiche.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _praticaCard(theme, scheme, l10n, p),
              )),
          if (_documenti.isNotEmpty) const SizedBox(height: 12),
        ],
        if (_documenti.isNotEmpty) ...[
          Text(
            'Documenti fiscali',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ..._documenti.map((doc) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _documentoCard(theme, scheme, doc),
              )),
        ],
      ],
    );
  }

  Widget _praticaCard(
    ThemeData theme,
    ColorScheme scheme,
    AppLocalizations l10n,
    Map<String, dynamic> p,
  ) {
    final numero = (p['numero_pratica'] ?? '').toString();
    final servizio = ServiceRequestLabels.servizio(l10n, p['servizio']);
    final stato = (p['stato'] ?? p['status'] ?? '').toString();
    final payStato = (p['payment_status'] ?? '').toString();
    final firma = (p['firma_stato'] ?? '').toString();
    final meta = <String>[];
    if (stato.isNotEmpty) meta.add(stato);
    if (payStato.isNotEmpty) meta.add('Pagamento: $payStato');
    if (firma.isNotEmpty) meta.add('Firma: $firma');
    final created = p['created_at']?.toString();
    if (created != null && created.length >= 10) {
      meta.add(created.substring(0, 10).split('-').reversed.join('/'));
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openPratica(p),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.assignment_outlined, color: scheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      numero.isNotEmpty
                          ? numero
                          : (servizio.isNotEmpty ? servizio : 'Pratica'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (servizio.isNotEmpty && numero.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        servizio,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        meta.join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _documentoCard(
    ThemeData theme,
    ColorScheme scheme,
    PraticaDocumento doc,
  ) {
    final isDownloading = _downloadingId == doc.id;
    final List<String> meta = [];
    if (doc.anno != null) meta.add(doc.anno.toString());
    if (doc.fileSizeLabel.isNotEmpty) meta.add(doc.fileSizeLabel);
    if (doc.dataCaricamento != null) {
      final d = doc.dataCaricamento!;
      meta.add(
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}',
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isDownloading ? null : () => _openDocument(doc),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_iconForTipo(doc), color: scheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.titolo.isNotEmpty ? doc.titolo : doc.tipoLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doc.tipoLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        meta.join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              isDownloading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.download_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
