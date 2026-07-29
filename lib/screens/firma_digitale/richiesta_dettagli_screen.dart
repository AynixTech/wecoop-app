import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/screens/firma_digitale/firma_documento_screen.dart';

/// Questa è una schermata che visualizza i dettagli di una richiesta
/// e permette all'utente di firmarla digitalmente.
/// 
/// PRONTA PER PRODUZIONE - Basta integrare nella tua app!
class RichiestaDettagliScreen extends StatefulWidget {
  final int richiestaId;
  final String titolo;
  final String descrizione;
  final String stato; // pending_firma, firmato, rifiutato

  const RichiestaDettagliScreen({
    super.key,
    required this.richiestaId,
    required this.titolo,
    required this.descrizione,
    required this.stato,
  });

  @override
  State<RichiestaDettagliScreen> createState() =>
      _RichiestaDettagliScreenState();
}

class _RichiestaDettagliScreenState extends State<RichiestaDettagliScreen> {
  final _storage = SecureStorageService();
  int? _userId;
  String? _telefono;
  bool _caricamento = true;

  @override
  void initState() {
    super.initState();
    _caricaDatiUtente();
  }

  Future<void> _caricaDatiUtente() async {
    try {
      final userId = await _storage.read(key: 'user_id');
      final telefono = await _storage.read(key: 'user_phone');

      setState(() {
        _userId = userId != null ? int.parse(userId) : null;
        _telefono = telefono;
        _caricamento = false;
      });
    } catch (e) {
      setState(() => _caricamento = false);
    }
  }

  void _avviaFirmaDigitale() {
    final l10n = AppLocalizations.of(context)!;
    if (_userId == null || _telefono == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('userDataUnavailable')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FirmaDocumentoScreen(
          richiestaId: widget.richiestaId,
          userId: _userId!,
          telefono: _telefono!,
        ),
      ),
    );
  }

  Color _getColorFromStato(String stato) {
    switch (stato) {
      case 'firmato':
        return AppColors.secondary;
      case 'rifiutato':
        return AppColors.error;
      case 'pending_firma':
      default:
        return Colors.orange;
    }
  }

  String _getTextFromStato(String stato) {
    final l10n = AppLocalizations.of(context)!;
    switch (stato) {
      case 'firmato':
        return '✅ ${l10n.translate('signedLabel')}';
      case 'rifiutato':
        return '❌ ${l10n.rejected}';
      case 'pending_firma':
      default:
        return '⏳ ${l10n.translate('awaitingSignatureStatus')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('requestDetailsTitle')),
        elevation: 0,
      ),
      body: _caricamento
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header con stato
                  Container(
                    width: double.infinity,
                    color: _getColorFromStato(widget.stato).withOpacity(0.1),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.titolo,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getColorFromStato(widget.stato),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getTextFromStato(widget.stato),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contenuto
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Descrizione
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.descriptionLabel,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.descrizione,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Info documento
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '📄 ${l10n.translate('documentSectionTitle')}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.translate('singleDocumentLabel'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.infoBg,
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'PDF',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primaryDark,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // CTA Firma
                        if (widget.stato == 'pending_firma')
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.infoBg,
                                  border: Border.all(
                                      color: AppColors.infoBg),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '🔐 ${l10n.translate('readyToSignQuestion')}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryDark,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.translate('signWithOtpHint'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.primaryDark,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: _avviaFirmaDigitale,
                                  icon: const Icon(Icons.security),
                                  label: Text(l10n.translate('signDocument')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        // Se già firmato
                        if (widget.stato == 'firmato')
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.successBg,
                              border: Border.all(
                                  color: AppColors.successBg),
                              borderRadius: BorderRadius.circular(8),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.translate('signedDocumentTitle'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.secondary,
                                            ),
                                      ),
                                      Text(
                                        l10n.translate('signatureLegallyValid'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.secondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
