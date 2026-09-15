import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final d = _dettaglio ?? widget.initial ?? {};

    final numero = (d['numero_pratica'] ?? '').toString();
    final servizio = ServiceRequestLabels.servizio(l10n, d['servizio']);
    final categoria = ServiceRequestLabels.categoria(l10n, d['categoria']);
    final stato = (d['stato'] ?? d['status'] ?? '').toString();
    final pagamento = d['pagamento'] is Map
        ? Map<String, dynamic>.from(d['pagamento'] as Map)
        : <String, dynamic>{};
    final docs = d['documenti'] is List
        ? (d['documenti'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];
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
                    'Documenti',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (docs.isEmpty)
                    Text(
                      'Nessun documento allegato a questa pratica.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    )
                  else
                    ...docs.map((doc) {
                      final name = (doc['file_name'] ??
                              doc['tipo'] ??
                              'Documento')
                          .toString();
                      final origine = (doc['origine'] ?? '').toString();
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.description_outlined,
                          color: scheme.primary,
                        ),
                        title: Text(name),
                        subtitle: origine.isNotEmpty ? Text(origine) : null,
                      );
                    }),
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
