import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/evento_model.dart';
import '../../services/eventi_service.dart';

class EventoDetailScreen extends StatefulWidget {
  final int eventoId;
  final Evento? evento;

  const EventoDetailScreen({super.key, required this.eventoId, this.evento});

  @override
  State<EventoDetailScreen> createState() => _EventoDetailScreenState();
}

class _EventoDetailScreenState extends State<EventoDetailScreen> {
  Evento? _evento;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _evento = widget.evento;
    _caricaDettagli();
  }

  Future<void> _caricaDettagli() async {
    setState(() {
      _isLoading = true;
    });
    
    final result = await EventiService.getEvento(widget.eventoId);
    
    if (result['success'] == true && mounted) {
      setState(() {
        _evento = result['evento'] as Evento?;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _iscriviEvento() async {
    if (_evento == null) return;
    
    if (mounted) {
      setState(() => _isLoading = true);
    }

    final result = await EventiService.iscriviEvento(eventoId: _evento!.id);

    if (mounted) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Operazione completata'),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        ),
      );

      if (result['success'] == true) {
        _caricaDettagli();
      }
    }
  }

  Future<void> _cancellaIscrizione() async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma cancellazione'),
        content: const Text('Sei sicuro di voler cancellare la tua iscrizione?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancella'),
          ),
        ],
      ),
    );

    if (conferma != true) return;

    if (_evento == null) return;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    final result = await EventiService.cancellaIscrizione(_evento!.id);

    if (mounted) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Operazione completata'),
          backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        ),
      );

      if (result['success'] == true) {
        _caricaDettagli();
      }
    }
  }

  Future<void> _apriLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_evento == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Caricamento...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final dataEvento = DateTime.tryParse(_evento!.dataInizio);
    final isPassato = dataEvento != null && dataEvento.isBefore(DateTime.now());

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _evento!.immagineCopertina != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          _evento!.immagineCopertina!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFE3F2FD),
                            child: const Icon(Icons.event, size: 100, color: Color(0xFF2196F3)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: const Color(0xFFE3F2FD),
                      child: const Icon(Icons.event, size: 100, color: Color(0xFF2196F3)),
                    ),
              title: Text(
                _evento!.titolo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_evento!.categoria != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _evento!.categoria!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  
                  // Info box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Data',
                          _formatData(_evento!.dataInizio, _evento!.oraInizio),
                        ),
                        if (_evento!.dataFine != null) ...[
                          const Divider(height: 24),
                          _buildInfoRow(
                            Icons.event_available,
                            'Fine',
                            _formatData(_evento!.dataFine!, _evento!.oraFine),
                          ),
                        ],
                        const Divider(height: 24),
                        _buildInfoRow(
                          _evento!.online ? Icons.videocam : Icons.location_on,
                          'Luogo',
                          _evento!.online
                              ? 'Online'
                              : '${_evento!.luogo ?? ''}\n${_evento!.indirizzo ?? ''}\n${_evento!.citta ?? ''}'.trim(),
                          onTap: _evento!.online && _evento!.linkOnline != null
                              ? () => _apriLink(_evento!.linkOnline!)
                              : null,
                        ),
                        if (_evento!.richiedeIscrizione) ...[
                          const Divider(height: 24),
                          _buildInfoRow(
                            Icons.people,
                            'Partecipanti',
                            '${_evento!.partecipantiCount}/${_evento!.maxPartecipanti > 0 ? _evento!.maxPartecipanti : '∞'}',
                          ),
                        ],
                        if (_evento!.prezzo > 0) ...[
                          const Divider(height: 24),
                          _buildInfoRow(
                            Icons.euro,
                            'Prezzo',
                            _evento!.prezzoFormattato,
                          ),
                        ],
                        if (_evento!.organizzatore != null) ...[
                          const Divider(height: 24),
                          _buildInfoRow(
                            Icons.person,
                            'Organizzatore',
                            _evento!.organizzatore!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Descrizione
                  const Text(
                    'Descrizione',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _evento!.descrizione,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5),
                  ),
                  
                  if (_evento!.programma != null && _evento!.programma!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Programma',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _evento!.programma!,
                      style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5),
                    ),
                  ],
                  
                  if (_evento!.galleria.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Galleria',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _evento!.galleria.length,
                        itemBuilder: (context, index) {
                          final img = _evento!.galleria[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                img.medium ?? img.url,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _evento!.richiedeIscrizione && !isPassato
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: _evento!.sonoIscritto
                    ? OutlinedButton(
                        onPressed: _isLoading ? null : _cancellaIscrizione,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Cancella iscrizione',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      )
                    : ElevatedButton(
                        onPressed: _isLoading || _evento!.postiDisponibili == 0
                            ? null
                            : _iscriviEvento,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                _evento!.postiDisponibili == 0 ? 'POSTI ESAURITI' : 'Iscriviti',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
              ),
            )
          : null,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: const Color(0xFF2196F3)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.open_in_new, size: 20, color: Color(0xFF2196F3)),
        ],
      ),
    );
  }

  String _formatData(String dataStr, String? ora) {
    try {
      final data = DateTime.parse(dataStr);
      final giorni = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
      final mesi = ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'];
      
      String result = '${giorni[data.weekday - 1]} ${data.day} ${mesi[data.month - 1]} ${data.year}';
      
      if (ora != null && ora.isNotEmpty) {
        result += ' - $ora';
      }
      
      return result;
    } catch (e) {
      return dataStr;
    }
  }
}
