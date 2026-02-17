import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/documento.dart';
import '../../services/app_localizations.dart';
import '../../services/documento_service.dart';

class DocumentiScreen extends StatefulWidget {
  const DocumentiScreen({super.key});

  @override
  State<DocumentiScreen> createState() => _DocumentiScreenState();
}

class _DocumentiScreenState extends State<DocumentiScreen> {
  final DocumentoService _documentoService = DocumentoService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocumenti();
  }

  Future<void> _loadDocumenti() async {
    setState(() => _isLoading = true);
    await _documentoService.getDocumenti();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _caricaDocumento(String tipo) async {
    // Mostra dialog per scegliere la fonte
    final fonte = await _scegliSorgenteDocumento();
    if (fonte == null) return;

    // Mostra dialog per selezionare la data di scadenza
    final dataScadenza = await _selezionaDataScadenza();
    if (dataScadenza == null) return;

    Documento? documento;
    
    if (fonte == 'camera') {
      documento = await _documentoService.caricaDocumentoDaFotocamera(
        tipo: tipo,
        dataScadenza: dataScadenza,
      );
    } else if (fonte == 'gallery') {
      documento = await _documentoService.caricaDocumentoDaGalleria(
        tipo: tipo,
        dataScadenza: dataScadenza,
      );
    } else {
      documento = await _documentoService.caricaDocumento(
        tipo: tipo,
        dataScadenza: dataScadenza,
      );
    }

    if (documento != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documento caricato con successo!')),
      );
      _loadDocumenti();
    }
  }

  Future<String?> _scegliSorgenteDocumento() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.upload_file, color: Colors.blue),
            SizedBox(width: 12),
            Expanded(
              child: Text('Come vuoi caricare il documento?'),
            ),
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
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blue.shade50,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scatta foto',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Usa la fotocamera',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
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
                    border: Border.all(color: Colors.purple.shade200),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.purple.shade50,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Galleria',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Scegli foto esistente',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
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
                    border: Border.all(color: Colors.green.shade200),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.green.shade50,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.insert_drive_file,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Carica file',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Carica PDF o immagine',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
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
            child: const Text('Annulla'),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _selezionaDataScadenza() async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      helpText: 'Seleziona data di scadenza',
      cancelText: 'Annulla',
      confirmText: 'Conferma',
    );
  }

  Future<void> _rimuoviDocumento(Documento documento) async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina documento'),
        content: const Text('Sei sicuro di voler eliminare questo documento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (conferma == true) {
      await _documentoService.rimuoviDocumento(documento.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento eliminato')),
        );
        _loadDocumenti();
      }
    }
  }

  Future<void> _apriDocumento(Documento documento) async {
    await OpenFile.open(documento.filePath);
  }

  Future<void> _openWhatsAppSupport() async {
    // TODO: Replace with your actual WhatsApp business number
    const phoneNumber = '393491234567'; // Example Italian number
    final message = Uri.encodeComponent('Ciao, ho problemi con il caricamento dei documenti');
    final uri = Uri.parse('https://wa.me/$phoneNumber?text=$message');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossibile aprire WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I miei documenti'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Carica e gestisci i tuoi documenti',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Puoi scattare foto, scegliere dalla galleria o caricare file',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Formati supportati: JPG, PNG, PDF',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ...TipoDocumento.all.map((tipo) {
                  final doc = _documentoService.getDocumentoByTipo(tipo);
                  return _DocumentoCard(
                    tipo: tipo,
                    documento: doc,
                    onCarica: () => _caricaDocumento(tipo),
                    onRimuovi: doc != null ? () => _rimuoviDocumento(doc) : null,
                    onApri: doc != null ? () => _apriDocumento(doc) : null,
                  );
                }),
                const SizedBox(height: 16),
                // WhatsApp Support Card
                InkWell(
                  onTap: _openWhatsAppSupport,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withOpacity(0.1),
                      border: Border.all(color: const Color(0xFF25D366), width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.chat,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.whatsappDocumentSupport,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF25D366),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Color(0xFF25D366),
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
    final hasDocumento = documento != null;
    final isScaduto = documento?.isScaduto ?? false;
    final staPerScadere = documento?.staPerScadere ?? false;

    Color borderColor = Colors.grey.shade300;
    Color? backgroundColor;

    if (isScaduto) {
      borderColor = Colors.red;
      backgroundColor = Colors.red.shade50;
    } else if (staPerScadere) {
      borderColor = Colors.orange;
      backgroundColor = Colors.orange.shade50;
    } else if (hasDocumento) {
      borderColor = Colors.green;
      backgroundColor = Colors.green.shade50;
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
                  color: isScaduto
                      ? Colors.red
                      : staPerScadere
                          ? Colors.orange
                          : hasDocumento
                              ? Colors.green
                              : Colors.grey,
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
                        Text(
                          documento!.fileName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (documento!.dataScadenza != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Scadenza: ${DateFormat('dd/MM/yyyy').format(documento!.dataScadenza!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isScaduto
                                  ? Colors.red
                                  : staPerScadere
                                      ? Colors.orange
                                      : Colors.grey,
                              fontWeight: isScaduto || staPerScadere
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
                  '⚠️ Documento scaduto! Aggiorna subito',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (staPerScadere && !isScaduto)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '⚠️ Documento in scadenza tra ${documento!.dataScadenza!.difference(DateTime.now()).inDays} giorni',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
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
                    label: Text(hasDocumento ? 'Aggiorna' : 'Carica'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          hasDocumento ? Colors.orange : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                if (hasDocumento) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onApri,
                    icon: const Icon(Icons.visibility),
                    tooltip: 'Visualizza',
                  ),
                  IconButton(
                    onPressed: onRimuovi,
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    tooltip: 'Elimina',
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
