import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SocioService {
  static const String baseUrl = 'https://www.wecoop.org/wp-json';
  final storage = const FlutterSecureStorage();

  /// Verifica se l'utente loggato è un socio attivo
  Future<bool> isSocio() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      final nicename = await storage.read(key: 'user_nicename');

      if (token == null || nicename == null) {
        return false;
      }

      // Chiamata all'endpoint WordPress per verificare lo stato socio
      final url = Uri.parse('$baseUrl/wecoop/v1/user-meta/$nicename');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Verifica se l'utente ha il campo 'is_socio' = true
        // oppure se ha un campo specifico come 'membership_status' = 'active'
        final isSocio =
            data['is_socio'] == true ||
            data['is_socio'] == 'true' ||
            data['membership_status'] == 'active';

        // Salva lo stato in cache
        await storage.write(key: 'is_socio', value: isSocio.toString());

        return isSocio;
      }

      return false;
    } catch (e) {
      print('Errore verifica socio: $e');

      // Fallback: controlla la cache
      final cachedStatus = await storage.read(key: 'is_socio');
      return cachedStatus == 'true';
    }
  }

  /// Invia richiesta di adesione come socio
  /// Ritorna un Map con 'success' e 'message' invece di solo bool
  /// NOTA: Può essere chiamata anche da utenti non loggati
  Future<Map<String, dynamic>> richiestaAdesioneSocio({
    required String nome,
    required String cognome,
    required String codiceFiscale,
    required String dataNascita,
    required String luogoNascita,
    required String indirizzo,
    required String citta,
    required String cap,
    required String telefono,
    required String email,
    String? professione,
    String? note,
  }) async {
    try {
      final token = await storage.read(key: 'jwt_token');

      final url = Uri.parse('$baseUrl/wecoop/v1/richiesta-adesione-socio');

      final body = {
        'nome': nome,
        'cognome': cognome,
        'codice_fiscale': codiceFiscale,
        'data_nascita': dataNascita,
        'luogo_nascita': luogoNascita,
        'indirizzo': indirizzo,
        'citta': citta,
        'cap': cap,
        'telefono': telefono,
        'email': email,
        'professione': professione ?? '',
        'note': note ?? '',
        'data_richiesta': DateTime.now().toIso8601String(),
      };

      print('=== RICHIESTA ADESIONE SOCIO ===');
      print('URL: $url');
      print('Token presente: ${token != null && token.isNotEmpty}');
      print('Body: ${jsonEncode(body)}');

      // Headers - aggiungi token solo se presente
      final headers = <String, String>{'Content-Type': 'application/json'};

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Timeout: il server non risponde');
            },
          );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Segna come richiesta in attesa
        await storage.write(key: 'adesione_richiesta', value: 'pending');

        // Prova a parsare la risposta
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': true,
            'message':
                responseData['message'] ?? 'Richiesta inviata con successo',
            'id': responseData['id'],
          };
        } catch (e) {
          return {'success': true, 'message': 'Richiesta inviata con successo'};
        }
      } else if (response.statusCode == 409) {
        // Richiesta già esistente
        return {
          'success': false,
          'message': 'Hai già una richiesta di adesione in attesa',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Sessione scaduta. Effettua nuovamente il login.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Endpoint non trovato. Contatta l\'amministratore.',
        };
      } else {
        // Prova a leggere il messaggio di errore dal server
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message':
                errorData['message'] ??
                'Errore del server (${response.statusCode})',
          };
        } catch (e) {
          return {
            'success': false,
            'message':
                'Errore del server (${response.statusCode}): ${response.body}',
          };
        }
      }
    } catch (e) {
      print('ECCEZIONE durante richiesta adesione: $e');

      String errorMessage = 'Errore di connessione';
      if (e.toString().contains('SocketException')) {
        errorMessage =
            'Impossibile connettersi al server. Verifica la connessione internet.';
      } else if (e.toString().contains('Timeout')) {
        errorMessage = 'Il server impiega troppo tempo a rispondere. Riprova.';
      } else {
        errorMessage = 'Errore: ${e.toString()}';
      }

      return {'success': false, 'message': errorMessage};
    }
  }

  /// Verifica se c'è una richiesta di adesione in pending
  Future<bool> hasRichiestaInAttesa() async {
    final status = await storage.read(key: 'adesione_richiesta');
    return status == 'pending';
  }

  /// Pulisce lo stato di adesione (per logout)
  Future<void> clearAdesioneStatus() async {
    await storage.delete(key: 'is_socio');
    await storage.delete(key: 'adesione_richiesta');
  }
}
