import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import '../../services/socio_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;
  List<Map<String, dynamic>> _tutteRichieste = [];
  String? _filtroStato;
  bool _localeInitialized = false;

  List<Map<String, dynamic>> _filtriStato = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('it_IT', null);
    if (mounted) {
      setState(() => _localeInitialized = true);
    }
    _caricaRichieste();
  }

  Future<void> _caricaRichieste() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final result = await SocioService.getRichiesteUtente(
        page: 1,
        perPage: 100,
        stato: _filtroStato,
      );

      if (result['success'] == true) {
        if (mounted) {
          setState(() {
            _tutteRichieste = List<Map<String, dynamic>>.from(
              result['data'] ?? [],
            );
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? l10n.errorLoadingData),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.error}: ${e.toString()}')));
      }
    }
  }

  List<Map<String, dynamic>> _getRichiesteDelGiorno(DateTime day) {
    return _tutteRichieste.where((richiesta) {
      final dataRichiesta = DateTime.tryParse(
        richiesta['data_richiesta'] ?? '',
      );
      if (dataRichiesta == null) return false;
      return isSameDay(dataRichiesta, day);
    }).toList();
  }

  Color _getStatoColor(String stato) {
    switch (stato) {
      case 'pending_payment':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatoIcon(String stato) {
    switch (stato) {
      case 'pending_payment':
        return Icons.payment;
      case 'processing':
        return Icons.hourglass_empty;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Future<void> _apriLinkPagamento(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cannotOpenPaymentLink),
          ),
        );
      }
    }
  }

  void _mostraDettaglioRichiesta(Map<String, dynamic> richiesta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDettaglioSheet(richiesta),
    );
  }

  Widget _buildDettaglioSheet(Map<String, dynamic> richiesta) {
    final stato = richiesta['stato'] ?? '';
    final statoLabel = richiesta['stato_label'] ?? '';
    final pagamento = richiesta['pagamento'] ?? {};
    final paymentLink = richiesta['payment_link'];
    final puoPagare = richiesta['puo_pagare'] == true;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder:
          (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getStatoColor(stato).withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatoIcon(stato),
                        size: 32,
                        color: _getStatoColor(stato),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              richiesta['servizio'] ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              richiesta['categoria'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildInfoRow(
                        'Numero Pratica',
                        richiesta['numero_pratica'] ?? 'N/A',
                        Icons.confirmation_number,
                      ),
                      _buildInfoRow('Stato', statoLabel, Icons.info_outline),
                      _buildInfoRow(
                        'Data Richiesta',
                        _formatData(richiesta['data_richiesta']),
                        Icons.calendar_today,
                      ),

                      if (richiesta['prezzo_formattato'] != null) ...[
                        const Divider(height: 32),
                        _buildInfoRow(
                          'Importo',
                          richiesta['prezzo_formattato'],
                          Icons.euro,
                        ),
                      ],

                      const Divider(height: 32),
                      const Text(
                        'Informazioni Pagamento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildInfoRow(
                        'Stato Pagamento',
                        pagamento['ricevuto'] == true ? 'Pagato' : 'Non pagato',
                        pagamento['ricevuto'] == true
                            ? Icons.check_circle
                            : Icons.pending,
                      ),

                      if (pagamento['metodo'] != null)
                        _buildInfoRow(
                          'Metodo',
                          pagamento['metodo'],
                          Icons.payment,
                        ),

                      if (pagamento['data'] != null)
                        _buildInfoRow(
                          'Data Pagamento',
                          _formatData(pagamento['data']),
                          Icons.calendar_today,
                        ),

                      if (pagamento['transazione_id'] != null)
                        _buildInfoRow(
                          'ID Transazione',
                          pagamento['transazione_id'],
                          Icons.receipt,
                        ),

                      if (puoPagare && paymentLink != null) ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _apriLinkPagamento(paymentLink);
                          },
                          icon: const Icon(Icons.payment),
                          label: Text(AppLocalizations.of(context)!.payNow),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 0),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatData(String? data) {
    if (data == null) return 'N/A';
    try {
      final dt = DateTime.parse(data);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return data;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Inizializza filtri con traduzioni
    if (_filtriStato.isEmpty) {
      _filtriStato = [
        {'label': l10n.all, 'value': null},
        {'label': l10n.pending, 'value': 'pending_payment'},
        {'label': 'In lavorazione', 'value': 'processing'},
        {'label': 'Completate', 'value': 'completed'},
        {'label': 'Annullate', 'value': 'cancelled'},
      ];
    }
    
    if (!_localeInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myRequests),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _caricaRichieste,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Filtri stato
                  Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _filtriStato.length,
                      itemBuilder: (context, index) {
                        final filtro = _filtriStato[index];
                        final isSelected = _filtroStato == filtro['value'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text(filtro['label']),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _filtroStato =
                                    selected
                                        ? filtro['value'] as String?
                                        : null;
                              });
                              _caricaRichieste();
                            },
                            backgroundColor: Colors.grey.shade200,
                            selectedColor: Colors.amber.shade100,
                            checkmarkColor: Colors.amber.shade700,
                          ),
                        );
                      },
                    ),
                  ),

                  // Calendario
                  Card(
                    margin: const EdgeInsets.all(8),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate:
                          (day) => isSameDay(_selectedDay, day),
                      calendarFormat: _calendarFormat,
                      eventLoader: _getRichiesteDelGiorno,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      locale: 'it_IT',
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.amber.shade300,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    ),
                  ),

                  // Lista richieste
                  Expanded(child: _buildListaRichieste()),
                ],
              ),
    );
  }

  Widget _buildListaRichieste() {
    final richieste =
        _selectedDay != null
            ? _getRichiesteDelGiorno(_selectedDay!)
            : _tutteRichieste;

    if (richieste.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _selectedDay != null
                  ? 'Nessuna richiesta per questo giorno'
                  : 'Nessuna richiesta trovata',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: richieste.length,
      itemBuilder: (context, index) {
        final richiesta = richieste[index];
        return _buildRichiestaCard(richiesta);
      },
    );
  }

  Widget _buildRichiestaCard(Map<String, dynamic> richiesta) {
    final stato = richiesta['stato'] ?? '';
    final statoLabel = richiesta['stato_label'] ?? '';
    final pagamento = richiesta['pagamento'] ?? {};
    final paymentLink = richiesta['payment_link'];
    final puoPagare = richiesta['puo_pagare'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _mostraDettaglioRichiesta(richiesta),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatoColor(stato).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatoColor(stato),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatoIcon(stato),
                          size: 14,
                          color: _getStatoColor(stato),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statoLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatoColor(stato),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (richiesta['prezzo_formattato'] != null)
                    Text(
                      richiesta['prezzo_formattato'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                richiesta['servizio'] ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                richiesta['categoria'] ?? '',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.confirmation_number,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    richiesta['numero_pratica'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatData(richiesta['data_richiesta']),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              if (pagamento['ricevuto'] == true) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Pagamento ricevuto',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (pagamento['metodo'] != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${pagamento['metodo']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              if (puoPagare && paymentLink != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _apriLinkPagamento(paymentLink),
                    icon: const Icon(Icons.payment, size: 18),
                    label: Text(AppLocalizations.of(context)!.payNow),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
