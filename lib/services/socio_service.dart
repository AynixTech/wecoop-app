import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'dart:io';

class SocioService {
  static const String baseUrl = 'https://www.wecoop.org/wp-json/wecoop/v1';
  static const storage = FlutterSecureStorage();

  /// Verifica se l'utente è un socio attivo (PUBBLICO)
  static Future<bool> isSocio() async {
    try {
      final email = await storage.read(key: 'user_email');

      if (email == null) {
        print('Nessuna email trovata');
        return false;
      }

      final encodedEmail = Uri.encodeComponent(email);
      final url = '$baseUrl/soci/verifica/$encodedEmail';
      print('Verifico socio su: $url');

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_attivo'] == true;
      }
      return false;
    } catch (e) {
      print('Errore verifica socio: $e');
      return false;
    }
  }

  /// Verifica se c'è una richiesta di adesione in attesa (PUBBLICO)
  static Future<bool> hasRichiestaInAttesa() async {
    try {
      final email = await storage.read(key: 'user_email');

      if (email == null) return false;

      final encodedEmail = Uri.encodeComponent(email);
      final url = '$baseUrl/soci/verifica/$encodedEmail';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Se is_socio è true ma status è pending
        return data['is_socio'] == true && data['status'] == 'pending';
      }
      return false;
    } catch (e) {
      print('Errore verifica richiesta: $e');
      return false;
    }
  }

  /// Invia richiesta di adesione come socio (PUBBLICO - no auth richiesta)
  static Future<Map<String, dynamic>> richiestaAdesioneSocio({
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
    String? provincia,
    String? motivazione,
  }) async {
    try {
      final url = '$baseUrl/soci/richiesta';

      print('=== INVIANDO RICHIESTA ADESIONE SOCIO ===');
      print('URL: $url');

      final body = jsonEncode({
        'nome': nome,
        'cognome': cognome,
        'codice_fiscale': codiceFiscale,
        'data_nascita': dataNascita,
        'luogo_nascita': luogoNascita,
        'indirizzo': indirizzo,
        'citta': citta,
        'cap': cap,
        'provincia': provincia ?? '',
        'telefono': telefono,
        'email': email,
        'professione': professione ?? '',
        'motivazione': motivazione ?? 'Richiesta di adesione alla cooperativa',
      });

      print('Body: $body');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Richiesta inviata con successo',
          'numero_pratica': data['data']?['numero_pratica'],
        };
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Dati non validi',
        };
      } else if (response.statusCode == 409) {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Hai già una richiesta in attesa',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Errore durante l\'invio',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Timeout: il server non risponde. Riprova più tardi.',
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'Nessuna connessione internet. Verifica la connessione.',
      };
    } catch (e) {
      print('Errore generico: $e');
      return {
        'success': false,
        'message': 'Errore imprevisto: ${e.toString()}',
      };
    }
  }

  /// Invia richiesta servizio (SOLO SOCI ATTIVI)
  static Future<Map<String, dynamic>> inviaRichiestaServizio({
    required String servizio,
    required String categoria,
    required Map<String, dynamic> dati,
  }) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      final url = '$baseUrl/servizi/richiesta';

      print('=== INVIANDO RICHIESTA SERVIZIO ===');
      print('URL: $url');
      print('Token presente: ${token != null}');

      final body = jsonEncode({
        'servizio': servizio,
        'categoria': categoria,
        'data_richiesta': DateTime.now().toIso8601String(),
        'dati': dati,
      });

      print('Body: $body');

      final headers = <String, String>{'Content-Type': 'application/json'};

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .post(Uri.parse(url), headers: headers, body: body)
          .timeout(const Duration(seconds: 30));

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Richiesta inviata con successo',
          'numero_pratica': data['data']?['numero_pratica'],
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Devi essere un socio attivo per richiedere servizi',
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Non hai i permessi per richiedere questo servizio',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Errore durante l\'invio',
        };
      }
    } on TimeoutException {
      return {'success': false, 'message': 'Timeout: il server non risponde'};
    } on SocketException {
      return {'success': false, 'message': 'Nessuna connessione internet'};
    } catch (e) {
      print('Errore: $e');
      return {'success': false, 'message': 'Errore: ${e.toString()}'};
    }
  }
}
