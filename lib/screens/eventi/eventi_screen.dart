import 'package:flutter/material.dart';
import '../../models/evento_model.dart';
import '../../services/eventi_service.dart';
import '../../services/app_localizations.dart';
import 'evento_detail_screen.dart';

class EventiScreen extends StatefulWidget {
  const EventiScreen({super.key});

  @override
  State<EventiScreen> createState() => _EventiScreenState();
}

class _EventiScreenState extends State<EventiScreen> {
  List<Evento> _eventi = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _categoriaFiltro;

  @override
  void initState() {
    super.initState();
    _caricaEventi();
  }

  Future<void> _caricaEventi() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final result = await EventiService.getEventi(
      perPage: 50,
      categoria: _categoriaFiltro,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          _eventi = result['eventi'] as List<Evento>;
        } else {
          _errorMessage = result['message'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.events),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _categoriaFiltro = value == 'tutti' ? null : value;
              });
              _caricaEventi();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'tutti', child: Text(l10n.allEvents)),
              PopupMenuItem(value: 'culturale', child: Text(l10n.cultural)),
              PopupMenuItem(value: 'sportivo', child: Text(l10n.sports)),
              PopupMenuItem(value: 'formazione', child: Text(l10n.training)),
              PopupMenuItem(value: 'sociale', child: Text(l10n.social)),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _caricaEventi,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _caricaEventi,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_eventi.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              l10n.noEventsAvailable,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _eventi.length,
      itemBuilder: (context, index) {
        return _EventoCard(
          evento: _eventi[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventoDetailScreen(
                  eventoId: _eventi[index].id,
                  evento: _eventi[index],
                ),
              ),
            ).then((_) => _caricaEventi());
          },
        );
      },
    );
  }
}

class _EventoCard extends StatelessWidget {
  final Evento evento;
  final VoidCallback onTap;

  const _EventoCard({required this.evento, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dataEvento = DateTime.tryParse(evento.dataInizio);
    final isPassato = dataEvento != null && dataEvento.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (evento.immagineCopertina != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    Image.network(
                      evento.immagineCopertina!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        color: const Color(0xFFE3F2FD),
                        child: const Icon(Icons.event, size: 64, color: Color(0xFF2196F3)),
                      ),
                    ),
                    if (evento.sonoIscritto)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                l10n.enrolled,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (isPassato)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: Center(
                            child: Text(
                              l10n.eventConcluded,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (evento.categoria != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        evento.categoria!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    evento.titolo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF2196F3)),
                      const SizedBox(width: 8),
                      Text(
                        _formatData(evento.dataInizio, evento.oraInizio),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        evento.online ? Icons.videocam : Icons.location_on,
                        size: 16,
                        color: const Color(0xFF2196F3),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          evento.online
                              ? l10n.online
                              : evento.luogo ?? evento.citta ?? l10n.locationToBeDefined,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (evento.richiedeIscrizione) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 16, color: Color(0xFF2196F3)),
                        const SizedBox(width: 8),
                        Text(
                          '${evento.partecipantiCount}/${evento.maxPartecipanti > 0 ? evento.maxPartecipanti : '∞'} ${l10n.participants}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (evento.postiDisponibili > 0 && evento.postiDisponibili <= 5)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '(${evento.postiDisponibili} ${l10n.spotsRemaining})',
                              style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (evento.prezzo > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.euro, size: 16, color: Color(0xFF2196F3)),
                        const SizedBox(width: 8),
                        Text(
                          evento.prezzoFormattato,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
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

  String _formatData(String dataStr, String? ora) {
    try {
      final data = DateTime.parse(dataStr);
      final giorno = data.day.toString().padLeft(2, '0');
      final mese = data.month.toString().padLeft(2, '0');
      final anno = data.year;
      
      String result = '$giorno/$mese/$anno';
      if (ora != null && ora.isNotEmpty) {
        result += ' - $ora';
      }
      
      return result;
    } catch (e) {
      return dataStr;
    }
  }
}
