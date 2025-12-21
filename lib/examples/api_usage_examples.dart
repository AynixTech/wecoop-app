// 📱 ESEMPI DI UTILIZZO - WECOOP API
// Copia e usa questi esempi nel tuo codice

import 'package:flutter/material.dart';
import 'package:wecoop_app/services/socio_service.dart';

// ============================================
// 1️⃣ VERIFICA SE UTENTE È SOCIO
// ============================================
Future<void> checkIfSocio() async {
  final isSocio = await SocioService.isSocio();
  
  if (isSocio) {
    print('✅ Utente è un socio attivo');
    // Mostra servizi riservati ai soci
  } else {
    print('❌ Utente non è socio');
    // Mostra form adesione
  }
}

// ============================================
// 2️⃣ VERIFICA RICHIESTA IN ATTESA
// ============================================
Future<void> checkPendingRequest() async {
  final hasPending = await SocioService.hasRichiestaInAttesa();
  
  if (hasPending) {
    print('⏳ Richiesta adesione in attesa di approvazione');
    // Mostra messaggio "La tua richiesta è in elaborazione"
  } else {
    print('✅ Nessuna richiesta in attesa');
  }
}

// ============================================
// 3️⃣ INVIA RICHIESTA ADESIONE SOCIO
// ============================================
Future<void> inviaRichiestaAdesione(BuildContext context) async {
  final result = await SocioService.richiestaAdesioneSocio(
    nome: 'Mario',
    cognome: 'Rossi',
    codiceFiscale: 'RSSMRA90A15H501X',
    dataNascita: '1990-01-15',
    luogoNascita: 'Roma',
    indirizzo: 'Via Roma 123',
    citta: 'Milano',
    cap: '20100',
    telefono: '+39 333 1234567',
    email: 'mario.rossi@example.com',
    professione: 'Ingegnere',
    provincia: 'MI',
    motivazione: 'Voglio contribuire alla cooperativa',
  );

  if (result['success'] == true) {
    print('✅ Richiesta inviata!');
    print('ID Richiesta: ${result['richiesta_id']}');
    print('Status: ${result['status']}'); // "pending"
    
    // Mostra dialog successo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('✅ Richiesta Inviata'),
        content: Text(result['message']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  } else {
    print('❌ Errore: ${result['message']}');
    
    // Mostra errore
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );
  }
}

// ============================================
// 4️⃣ OTTIENI DATI UTENTE CORRENTE
// ============================================
Future<void> getUserData() async {
  final userData = await SocioService.getMe();
  
  if (userData != null) {
    print('✅ Dati utente ricevuti:');
    print('Nome: ${userData['nome']} ${userData['cognome']}');
    print('Email: ${userData['email']}');
    print('Tessera: ${userData['numero_tessera']}');
    print('Status: ${userData['status_socio']}'); // attivo/sospeso/cessato
    print('Anni socio: ${userData['anni_socio']}');
    print('Quota pagata: ${userData['quota_pagata']}');
    print('URL Tessera: ${userData['tessera_url']}');
    
    // Usa i dati per precompilare form
    final nomeCompleto = '${userData['nome']} ${userData['cognome']}';
    final telefono = userData['telefono'];
    final citta = userData['citta'];
  } else {
    print('❌ Impossibile ottenere dati utente (non autenticato o errore)');
  }
}

// ============================================
// 5️⃣ INVIA RICHIESTA SERVIZIO
// ============================================
Future<void> richiestaPermessoSoggiorno(BuildContext context) async {
  final result = await SocioService.inviaRichiestaServizio(
    servizio: 'Permesso di Soggiorno',
    categoria: 'Lavoro Subordinato',
    dati: {
      'nome_completo': 'Mario Rossi',
      'data_nascita': '1990-01-15',
      'paese_provenienza': 'Romania',
      'tipo_contratto': 'Tempo determinato',
      'nome_azienda': 'ABC srl',
      'email': 'mario.rossi@example.com',
      'telefono': '+39 333 1234567',
    },
  );

  if (result['success'] == true) {
    print('✅ Richiesta servizio inviata!');
    print('ID: ${result['id']}');
    print('Numero pratica: ${result['numero_pratica']}'); // WECOOP-2025-00001
    print('Data richiesta: ${result['data_richiesta']}');
    
    // Mostra numero pratica all'utente
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Richiesta Inviata'),
          ],
        ),
        content: Text(
          'La tua richiesta è stata ricevuta!\n\n'
          'Numero pratica: ${result['numero_pratica']}\n\n'
          'Sarai contattato via email per i prossimi passi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  } else {
    print('❌ Errore: ${result['message']}');
    
    if (result['message']?.contains('autenticato') == true) {
      // Token scaduto o non valido
      Navigator.pushReplacementNamed(context, '/login');
    } else if (result['message']?.contains('soci') == true) {
      // Non è socio
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Devi essere un socio attivo per richiedere servizi'),
          action: SnackBarAction(
            label: 'Diventa Socio',
            onPressed: () {
              Navigator.pushNamed(context, '/adesione-socio');
            },
          ),
        ),
      );
    } else {
      // Altri errori
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }
}

// ============================================
// 6️⃣ RICHIESTA CITTADINANZA
// ============================================
Future<void> richiestaCittadinanza(BuildContext context) async {
  final result = await SocioService.inviaRichiestaServizio(
    servizio: 'Cittadinanza Italiana',
    categoria: 'Per residenza',
    dati: {
      'nome_completo': 'Mario Rossi',
      'data_nascita': '1990-01-15',
      'paese_nascita': 'Romania',
      'data_arrivo_italia': '2015-03-10',
      'indirizzo_residenza_attuale': 'Via Roma 123, Milano',
      'email': 'mario@example.com',
      'telefono': '+39 333 1234567',
    },
  );

  // Gestisci come esempio 5
  if (result['success'] == true) {
    print('Numero pratica: ${result['numero_pratica']}');
  }
}

// ============================================
// 7️⃣ RICHIESTA 730
// ============================================
Future<void> richiesta730(BuildContext context) async {
  final result = await SocioService.inviaRichiestaServizio(
    servizio: 'Mediazione Fiscale',
    categoria: '730',
    dati: {
      'nome_completo': 'Mario Rossi',
      'codice_fiscale': 'RSSMRA90A15H501X',
      'data_nascita': '1990-01-15',
      'indirizzo_residenza': 'Via Roma 123, Milano',
      'anno_fiscale': '2024',
      'email': 'mario@example.com',
      'telefono': '+39 333 1234567',
    },
  );

  if (result['success'] == true) {
    print('Richiesta 730 inviata: ${result['numero_pratica']}');
  }
}

// ============================================
// 8️⃣ APRIRE PARTITA IVA
// ============================================
Future<void> aprirePartitaIva(BuildContext context) async {
  final result = await SocioService.inviaRichiestaServizio(
    servizio: 'Supporto Contabile',
    categoria: 'Aprire Partita IVA',
    dati: {
      'nome_completo': 'Mario Rossi',
      'codice_fiscale': 'RSSMRA90A15H501X',
      'data_nascita': '1990-01-15',
      'tipo_attivita': 'Consulenza informatica',
      'email': 'mario@example.com',
      'telefono': '+39 333 1234567',
    },
  );

  if (result['success'] == true) {
    print('Richiesta apertura P.IVA: ${result['numero_pratica']}');
  }
}

// ============================================
// 9️⃣ LISTA SOCI (Solo Admin)
// ============================================
Future<void> getListaSoci() async {
  // Tutti i soci attivi
  final sociAttivi = await SocioService.getSoci(
    status: 'attivo',
    perPage: 50,
    page: 1,
  );
  
  print('Totale soci attivi: ${sociAttivi.length}');
  for (var socio in sociAttivi) {
    print('${socio['nome']} ${socio['cognome']} - ${socio['email']}');
  }
  
  // Ricerca per nome
  final risultatiRicerca = await SocioService.getSoci(
    status: 'attivo',
    search: 'Mario',
  );
  
  print('Soci trovati con "Mario": ${risultatiRicerca.length}');
}

// ============================================
// 🔟 WIDGET COMPLETO - STATO SOCIO
// ============================================
class SocioStatusWidget extends StatefulWidget {
  @override
  _SocioStatusWidgetState createState() => _SocioStatusWidgetState();
}

class _SocioStatusWidgetState extends State<SocioStatusWidget> {
  bool _isLoading = true;
  bool _isSocio = false;
  bool _hasPending = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    
    _isSocio = await SocioService.isSocio();
    
    if (!_isSocio) {
      _hasPending = await SocioService.hasRichiestaInAttesa();
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (_isSocio) {
      return Card(
        color: Colors.green[50],
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.verified, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Socio Attivo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text('Hai accesso a tutti i servizi'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (_hasPending) {
      return Card(
        color: Colors.orange[50],
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.schedule, color: Colors.orange, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Richiesta in Attesa',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text('La tua richiesta è in elaborazione'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        color: Colors.blue[50],
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 32),
              SizedBox(height: 8),
              Text(
                'Diventa Socio',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text('Unisciti a WECOOP per accedere ai servizi'),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/adesione-socio');
                },
                child: Text('Richiedi Adesione'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
