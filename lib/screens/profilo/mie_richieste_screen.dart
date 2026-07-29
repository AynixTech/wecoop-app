import 'package:flutter/material.dart';

import '../../models/supporto_ticket_model.dart';
import '../../services/supporto_service.dart';

/// Schermata "Le mie richieste": elenca i ticket di supporto creati
/// dall'utente, con numero ticket, servizio, priorità, stato e data
/// (come la lista "Richieste Supporto" del back-office).
class MieRichiesteScreen extends StatefulWidget {
  const MieRichiesteScreen({super.key});

  @override
  State<MieRichiesteScreen> createState() => _MieRichiesteScreenState();
}

class _MieRichiesteScreenState extends State<MieRichiesteScreen> {
  bool _loading = true;
  bool _error = false;
  String? _errorMessage;
  List<SupportoTicket> _tickets = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
      _errorMessage = null;
    });

    final result = await SupportoService.getMieRichieste();
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _tickets = (result['data'] as List<SupportoTicket>?) ?? [];
        _loading = false;
      });
    } else {
      setState(() {
        _error = true;
        _errorMessage = result['message'] as String?;
        _loading = false;
      });
    }
  }

  Color _statusColor(String status, ColorScheme scheme) {
    switch (status) {
      case 'aperta':
        return Colors.blue;
      case 'in_lavorazione':
        return Colors.orange;
      case 'risolta':
        return Colors.green;
      case 'chiusa':
        return Colors.grey;
      default:
        return scheme.primary;
    }
  }

  Color _prioritaColor(String priorita) {
    switch (priorita) {
      case 'alta':
        return Colors.red;
      case 'bassa':
        return Colors.green;
      case 'media':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Le mie richieste')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(theme, scheme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme scheme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(Icons.cloud_off_rounded, size: 56, color: scheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage ?? 'Impossibile caricare le richieste',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.tonal(
              onPressed: _load,
              child: const Text('Riprova'),
            ),
          ),
        ],
      );
    }

    if (_tickets.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(Icons.sms_outlined, size: 56, color: scheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Non hai ancora richieste di supporto.',
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
      itemCount: _tickets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final t = _tickets[index];
        final statusColor = _statusColor(t.status, scheme);
        final prioritaColor = _prioritaColor(t.priorita);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: scheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.confirmation_number_outlined,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.serviceName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.numeroTicket,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if ((t.messaggio ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    t.messaggio!.trim(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withOpacity(0.75),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _chip(
                      label: t.statusLabel,
                      color: statusColor,
                    ),
                    _chip(
                      label: 'Priorità: ${t.priorita}',
                      color: prioritaColor,
                    ),
                    if (t.dataFormattata.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t.dataFormattata,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
