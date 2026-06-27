import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/pratica_documento.dart';
import '../../services/app_localizations.dart';
import '../../services/socio_service.dart';

/// Schermata "Storico pratiche": elenca i documenti (730, ISEE, ...) caricati
/// dagli operatori e li rende consultabili/scaricabili dal cliente.
class StoricoPraticheScreen extends StatefulWidget {
  const StoricoPraticheScreen({super.key});

  @override
  State<StoricoPraticheScreen> createState() => _StoricoPraticheScreenState();
}

class _StoricoPraticheScreenState extends State<StoricoPraticheScreen> {
  bool _loading = true;
  bool _error = false;
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
      final docs = await SocioService.getStoricoPratiche();
      if (!mounted) return;
      setState(() {
        _documenti = docs;
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
          backgroundColor: Colors.red.shade600,
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
          backgroundColor: Colors.red.shade600,
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
          backgroundColor: Colors.red.shade600,
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

    if (_documenti.isEmpty) {
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

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _documenti.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doc = _documenti[index];
        final isDownloading = _downloadingId == doc.id;

        final List<String> meta = [];
        if (doc.anno != null) meta.add(doc.anno.toString());
        if (doc.fileSizeLabel.isNotEmpty) meta.add(doc.fileSizeLabel);
        if (doc.dataCaricamento != null) {
          final d = doc.dataCaricamento!;
          meta.add(
              '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}');
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
      },
    );
  }
}
