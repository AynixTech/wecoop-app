import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/eventi_service.dart';

class EventiDebugScreen extends StatefulWidget {
  const EventiDebugScreen({super.key});

  @override
  State<EventiDebugScreen> createState() => _EventiDebugScreenState();
}

class _EventiDebugScreenState extends State<EventiDebugScreen> {
  String _output = 'Premi i pulsanti per testare le chiamate API\n\n';
  bool _isLoading = false;

  void _log(String message) {
    setState(() {
      _output += '$message\n';
    });
    print(message);
  }

  Future<void> _getUserId() async {
    setState(() {
      _isLoading = true;
      _output = '';
    });

    _log('=== TEST GET USER ID ===\n');
    final result = await EventiService.getUserId();

    _log('Risultato:');
    _log('Success: ${result['success']}');
    if (result['success'] == true) {
      final data = result['data'];
      _log('User ID: ${data['id'] ?? data['user_id']}');
      _log('Email: ${data['email']}');
      _log('Nome: ${data['nome']} ${data['cognome']}');
    } else {
      _log('Errore: ${result['message']}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getMieiEventi() async {
    setState(() {
      _isLoading = true;
      _output = '';
    });

    _log('=== TEST GET MIEI EVENTI ===\n');
    final result = await EventiService.getMieiEventi();

    _log('Risultato:');
    _log('Success: ${result['success']}');
    _log('Totale: ${result['totale']}');
    _log('Eventi count: ${(result['eventi'] as List?)?.length ?? 0}');

    if ((result['eventi'] as List?)?.isNotEmpty == true) {
      final eventi = result['eventi'] as List;
      for (var i = 0; i < eventi.length; i++) {
        _log('\nEvento #$i:');
        _log('  Titolo: ${eventi[i].titolo}');
        _log('  ID: ${eventi[i].id}');
        _log('  Sono iscritto: ${eventi[i].sonoIscritto}');
      }
    } else {
      _log('\n⚠️ Nessun evento trovato!');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _debugEventi() async {
    setState(() {
      _isLoading = true;
      _output = '';
    });

    _log('=== TEST DEBUG EVENTI ===\n');
    final result = await EventiService.debugEventi();

    _log('Risultato:');
    _log('Success: ${result['success']}');

    if (result['success'] == true) {
      _log('\nDati completi:\n${result['data']}');
    } else {
      _log('Errore: ${result['message']}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testIscrizione(int eventoId) async {
    setState(() {
      _isLoading = true;
      _output = '';
    });

    _log('=== TEST ISCRIZIONE EVENTO $eventoId ===\n');

    // 1. Iscrivi
    _log('1️⃣ Iscrizione...');
    final iscrizioneResult = await EventiService.iscriviEvento(
      eventoId: eventoId,
    );
    _log('Success: ${iscrizioneResult['success']}');
    _log('Message: ${iscrizioneResult['message']}');

    if (iscrizioneResult['success'] == true) {
      await Future.delayed(const Duration(seconds: 1));

      // 2. Verifica con getEvento
      _log('\n2️⃣ Verifica con getEvento...');
      final eventoResult = await EventiService.getEvento(eventoId);
      if (eventoResult['success'] == true) {
        final evento = eventoResult['evento'];
        _log('sono_iscritto: ${evento.sonoIscritto}');
        _log('stato_iscrizione: ${evento.statoIscrizione}');
      }

      await Future.delayed(const Duration(seconds: 1));

      // 3. Verifica con getMieiEventi
      _log('\n3️⃣ Verifica con getMieiEventi...');
      final mieiEventiResult = await EventiService.getMieiEventi();
      _log('Totale miei eventi: ${mieiEventiResult['totale']}');

      if ((mieiEventiResult['eventi'] as List?)?.isNotEmpty == true) {
        final trovato = (mieiEventiResult['eventi'] as List).any(
          (e) => e.id == eventoId,
        );
        _log(
          trovato
              ? '✅ Evento trovato in miei-eventi!'
              : '❌ Evento NON trovato in miei-eventi!',
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _output));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Log copiati negli appunti')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Eventi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyToClipboard,
            tooltip: 'Copia log',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _output = '';
              });
            },
            tooltip: 'Pulisci log',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                _output,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Test API',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _getUserId,
                      icon: const Icon(Icons.person),
                      label: const Text('Get User ID'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _getMieiEventi,
                      icon: const Icon(Icons.event),
                      label: const Text('Get Miei Eventi'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _debugEventi,
                      icon: const Icon(Icons.bug_report),
                      label: const Text('Debug Eventi'),
                    ),
                    ElevatedButton.icon(
                      onPressed:
                          _isLoading ? null : () => _showTestIscrizioneDialog(),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Test Iscrizione'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTestIscrizioneDialog() {
    final controller = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Test Iscrizione'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ID Evento',
                hintText: 'Inserisci ID evento',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              ElevatedButton(
                onPressed: () {
                  final eventoId = int.tryParse(controller.text);
                  Navigator.pop(context);
                  if (eventoId != null) {
                    _testIscrizione(eventoId);
                  }
                },
                child: const Text('Test'),
              ),
            ],
          ),
    );
  }
}
