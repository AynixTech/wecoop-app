import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/documento.dart';
import '../../services/app_localizations.dart';
import '../../services/documento_service.dart';

class DocumentiScreen extends StatefulWidget {
  final bool showFamilyDocuments;
  final String initialSoggetto;

  const DocumentiScreen({
    super.key,
    this.showFamilyDocuments = false,
    this.initialSoggetto = DocumentoSoggetto.richiedente,
  });

  @override
  State<DocumentiScreen> createState() => _DocumentiScreenState();
}

class _DocumentiScreenState extends State<DocumentiScreen> {
  final DocumentoService _documentoService = DocumentoService();
  bool _isLoading = true;
  late String _selectedSoggetto;

  String _localizedSoggettoLabel(String soggetto) {
    final l10n = AppLocalizations.of(context)!;
    return soggetto == DocumentoSoggetto.familiare
        ? l10n.familyMember.toLowerCase()
        : l10n.applicant.toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    _selectedSoggetto =
        widget.showFamilyDocuments
            ? widget.initialSoggetto
            : DocumentoSoggetto.richiedente;
    _loadDocumenti();
  }

  Future<void> _loadDocumenti() async {
    setState(() => _isLoading = true);
    await _documentoService.getDocumenti();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _caricaDocumento(String tipo, String soggetto) async {
    final l10n = AppLocalizations.of(context)!;
    // Mostra dialog per scegliere la fonte
    final fonte = await _scegliSorgenteDocumento();
    if (fonte == null) return;

    if (fonte == 'file') {
      // File singolo: PDF o immagine, nessun fronte/retro
      final documento = await _documentoService.caricaDocumento(
        tipo: tipo,
        soggetto: soggetto,
      );
      if (documento != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.uploadDocumentSuccess(_localizedSoggettoLabel(soggetto)),
            ),
          ),
        );
        _loadDocumenti();
      }
    } else {
      // Camera o Galleria: chiede fronte e poi retro
      await _caricaDocumentoFronteRetro(tipo, fonte, soggetto);
    }
  }

  /// Flusso a 2 step per fotocamera/galleria: FRONTE poi RETRO
  Future<void> _caricaDocumentoFronteRetro(
    String tipo,
    String fonte,
    String soggetto,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    // --- STEP 1: FRONTE ---
    if (!mounted) return;
    final procediFrente = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.flip_to_front, color: scheme.primary, size: 28),
                const SizedBox(width: 10),
                Flexible(child: Text(l10n.documentFrontTitle)),
              ],
            ),
            content: Text(
              fonte == 'camera'
                  ? l10n.documentFrontCameraPrompt
                  : l10n.documentFrontGalleryPrompt,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.proceed),
              ),
            ],
          ),
    );
    if (procediFrente != true || !mounted) return;

    final fileFrente =
        fonte == 'camera'
            ? await _documentoService.prendiImmagineDaFotocamera()
            : await _documentoService.prendiImmagineDaGalleria();
    if (fileFrente == null || !mounted) return;

    // --- STEP 2: RETRO ---
    final procediRetro = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.flip_to_back, color: scheme.secondary, size: 28),
                const SizedBox(width: 10),
                Flexible(child: Text(l10n.documentBackTitle)),
              ],
            ),
            content: Text(
              fonte == 'camera'
                  ? l10n.documentBackCameraPrompt
                  : l10n.documentBackGalleryPrompt,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.secondary,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.proceed),
              ),
            ],
          ),
    );
    if (procediRetro != true || !mounted) return;

    final fileRetro =
        fonte == 'camera'
            ? await _documentoService.prendiImmagineDaFotocamera()
            : await _documentoService.prendiImmagineDaGalleria();
    if (fileRetro == null || !mounted) return;

    // Upload fronte + retro
    setState(() => _isLoading = true);
    final documento = await _documentoService.caricaDocumentoDueLati(
      tipo: tipo,
      fileFrente: fileFrente,
      fileRetro: fileRetro,
      soggetto: soggetto,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            documento != null
                ? l10n.uploadDocumentSuccessFrontBack(
                  _localizedSoggettoLabel(soggetto),
                )
                : '${l10n.error}. ${l10n.retry}.',
          ),
          backgroundColor: documento != null ? scheme.secondary : scheme.error,
        ),
      );
      _loadDocumenti();
    }
  }

  Future<String?> _scegliSorgenteDocumento() async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.upload_file, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.uploadDocumentHow)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context, 'camera'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: scheme.primary),
                      borderRadius: BorderRadius.circular(12),
                      color: scheme.primaryContainer,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: scheme.onPrimary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.takePhoto,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.takePhotoHint,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => Navigator.pop(context, 'gallery'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: scheme.tertiary),
                      borderRadius: BorderRadius.circular(12),
                      color: scheme.tertiaryContainer,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.tertiary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.photo_library,
                            color: scheme.onTertiary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.chooseGallery,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.chooseGalleryHint,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => Navigator.pop(context, 'file'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: scheme.secondary),
                      borderRadius: BorderRadius.circular(12),
                      color: scheme.secondaryContainer,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.insert_drive_file,
                            color: scheme.onSecondary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.uploadFileLabel,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.uploadFileHint,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _rimuoviDocumento(Documento documento) async {
    final l10n = AppLocalizations.of(context)!;
    final conferma = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.deleteDocumentTitle),
            content: Text(l10n.deleteDocumentConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  l10n.deleteLabel,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );

    if (conferma == true) {
      await _documentoService.rimuoviDocumento(documento.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.documentDeleted)));
        _loadDocumenti();
      }
    }
  }

  Future<void> _apriDocumento(Documento documento) async {
    await OpenFile.open(documento.filePath);
  }

  Future<void> _openWhatsAppSupport() async {
    const phoneNumber = '393515112113';
    final message = Uri.encodeComponent(
      'Ciao, ho problemi con il caricamento dei documenti',
    );
    final uri = Uri.parse('https://wa.me/$phoneNumber?text=$message');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cannotOpenWhatsApp),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.showFamilyDocuments
              ? AppLocalizations.of(context)!.documentsApplicantAndFamilyTitle
              : AppLocalizations.of(context)!.myDocumentsTitle,
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    AppLocalizations.of(context)!.manageYourDocuments,
                    style: TextStyle(
                      fontSize: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.documentSourcesHint,
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.supportedFormats,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (widget.showFamilyDocuments) ...[
                    _buildSoggettoSelector(),
                    const SizedBox(height: 16),
                    _buildDocumentSection(
                      title:
                          _selectedSoggetto == DocumentoSoggetto.familiare
                              ? AppLocalizations.of(
                                context,
                              )!.documentsFamilyTitle
                              : AppLocalizations.of(
                                context,
                              )!.documentsApplicantTitle,
                      soggetto: _selectedSoggetto,
                      subtitle:
                          _selectedSoggetto == DocumentoSoggetto.familiare
                              ? AppLocalizations.of(
                                context,
                              )!.documentsFamilyUploadSubtitle
                              : AppLocalizations.of(
                                context,
                              )!.documentsPersonalSubtitle,
                    ),
                  ] else
                    _buildDocumentSection(
                      title:
                          AppLocalizations.of(context)!.documentsApplicantTitle,
                      soggetto: DocumentoSoggetto.richiedente,
                      subtitle:
                          AppLocalizations.of(
                            context,
                          )!.documentsPersonalSubtitle,
                    ),
                  const SizedBox(height: 16),
                  // WhatsApp Support Card
                  InkWell(
                    onTap: _openWhatsAppSupport,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer,
                        border: Border.all(color: scheme.secondary, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: scheme.secondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.chat,
                              color: scheme.onSecondary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.whatsappDocumentSupport,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: scheme.secondary,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: scheme.secondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
    );
  }

  Widget _buildDocumentSection({
    required String title,
    required String soggetto,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 12),
        ...TipoDocumento.all.map((tipo) {
          final doc = _documentoService.getDocumentoByTipo(
            tipo,
            soggetto: soggetto,
          );
          return _DocumentoCard(
            tipo: tipo,
            documento: doc,
            onCarica: () => _caricaDocumento(tipo, soggetto),
            onRimuovi: doc != null ? () => _rimuoviDocumento(doc) : null,
            onApri: doc != null ? () => _apriDocumento(doc) : null,
          );
        }),
      ],
    );
  }

  Widget _buildSoggettoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.documentsSelectSubject,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: Text(AppLocalizations.of(context)!.applicant),
                selected: _selectedSoggetto == DocumentoSoggetto.richiedente,
                onSelected: (selected) {
                  if (!selected) return;
                  setState(() {
                    _selectedSoggetto = DocumentoSoggetto.richiedente;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: Text(AppLocalizations.of(context)!.familyMember),
                selected: _selectedSoggetto == DocumentoSoggetto.familiare,
                onSelected: (selected) {
                  if (!selected) return;
                  setState(() {
                    _selectedSoggetto = DocumentoSoggetto.familiare;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DocumentoCard extends StatelessWidget {
  final String tipo;
  final Documento? documento;
  final VoidCallback onCarica;
  final VoidCallback? onRimuovi;
  final VoidCallback? onApri;

  const _DocumentoCard({
    required this.tipo,
    required this.documento,
    required this.onCarica,
    this.onRimuovi,
    this.onApri,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasDocumento = documento != null;
    final isScaduto = documento?.isScaduto ?? false;
    final staPerScadere = documento?.staPerScadere ?? false;

    Color borderColor = scheme.outlineVariant;
    Color? backgroundColor;

    if (isScaduto) {
      borderColor = scheme.error;
      backgroundColor = scheme.errorContainer;
    } else if (staPerScadere) {
      borderColor = scheme.tertiary;
      backgroundColor = scheme.tertiaryContainer;
    } else if (hasDocumento) {
      borderColor = scheme.secondary;
      backgroundColor = scheme.secondaryContainer;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasDocumento ? Icons.check_circle : Icons.upload_file,
                  color:
                      isScaduto
                          ? scheme.error
                          : staPerScadere
                          ? scheme.tertiary
                          : hasDocumento
                          ? scheme.secondary
                          : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TipoDocumento.getDisplayName(tipo),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasDocumento) ...[
                        const SizedBox(height: 4),
                        if (documento!.filePathRetro != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: scheme.primary),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flip,
                                  size: 13,
                                  color: scheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  AppLocalizations.of(context)!.frontAndBack,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text(
                            documento!.fileName,
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (documento!.dataScadenza != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.expiryDateLabel(
                              DateFormat(
                                'dd/MM/yyyy',
                              ).format(documento!.dataScadenza!),
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isScaduto
                                      ? scheme.error
                                      : staPerScadere
                                      ? scheme.tertiary
                                      : scheme.onSurfaceVariant,
                              fontWeight:
                                  isScaduto || staPerScadere
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (isScaduto)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '⚠️ ${AppLocalizations.of(context)!.documentExpiredUpdateNow}',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (staPerScadere && !isScaduto)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '⚠️ ${AppLocalizations.of(context)!.documentExpiringInDays(documento!.dataScadenza!.difference(DateTime.now()).inDays)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCarica,
                    icon: Icon(hasDocumento ? Icons.refresh : Icons.upload),
                    label: Text(
                      hasDocumento
                          ? AppLocalizations.of(context)!.updateLabel
                          : AppLocalizations.of(context)!.uploadLabel,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          hasDocumento ? scheme.tertiary : scheme.primary,
                      foregroundColor: scheme.onPrimary,
                    ),
                  ),
                ),
                if (hasDocumento) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onApri,
                    icon: const Icon(Icons.visibility),
                    tooltip: AppLocalizations.of(context)!.viewLabel,
                  ),
                  IconButton(
                    onPressed: onRimuovi,
                    icon: const Icon(Icons.delete),
                    color: scheme.error,
                    tooltip: AppLocalizations.of(context)!.deleteLabel,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
