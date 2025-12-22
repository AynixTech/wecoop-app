import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/evento_model.dart';
import '../utils/html_utils.dart';

class EventiService {
  static const String baseUrl = 'https://www.wecoop.org/wp-json/wecoop/v1';
  static const storage = FlutterSecureStorage();

  /// Ottiene gli headers comuni per tutte le richieste
  static Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final languageCode = await storage.read(key: 'language_code') ?? 'it';
    final headers = {
      'Content-Type': 'application/json',
      'Accept-Language': languageCode,
    };
    
    if (includeAuth) {
      final token = await storage.read(key: 'jwt_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }

  /// Get lista eventi
  static Future<Map<String, dynamic>> getEventi({
    int page = 1,
    int perPage = 10,
    String? categoria,
    String? dataDa,
    String? dataA,
    String? stato,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (categoria != null) 'categoria': categoria,
        if (dataDa != null) 'data_da': dataDa,
        if (dataA != null) 'data_a': dataA,
        if (stato != null) 'stato': stato,
      };

      final uri = Uri.parse('$baseUrl/eventi').replace(queryParameters: queryParams);
      final headers = await _getHeaders();

      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('GET $uri - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        final data = decodeHtmlInMap(rawData);
        return {
          'success': true,
          'eventi': (data['eventi'] as List)
              .map((e) => Evento.fromJson(e))
              .toList(),
          'pagination': data['pagination'],
        };
      }

      return {
        'success': false,
        'message': 'Errore nel caricamento degli eventi',
      };
    } catch (e) {
      print('Errore getEventi: $e');
      return {
        'success': false,
        'message': 'Errore di connessione: $e',
      };
    }
  }

  /// Get dettaglio evento
  static Future<Map<String, dynamic>> getEvento(int eventoId) async {
    try {
      final uri = Uri.parse('$baseUrl/eventi/$eventoId');
      final headers = await _getHeaders();

      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('GET $uri - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        final data = decodeHtmlInMap(rawData);
        return {
          'success': true,
          'evento': Evento.fromJson(data),
        };
      }

      return {
        'success': false,
        'message': 'Evento non trovato',
      };
    } catch (e) {
      print('Errore getEvento: $e');
      return {
        'success': false,
        'message': 'Errore di connessione: $e',
      };
    }
  }

  /// Iscrivi utente a evento
  static Future<Map<String, dynamic>> iscriviEvento({
    required int eventoId,
    String? nome,
    String? email,
    String? telefono,
    String? note,
  }) async {
    try {
      final token = await storage.read(key: 'jwt_token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Devi effettuare il login per iscriverti',
        };
      }

      final uri = Uri.parse('$baseUrl/eventi/$eventoId/iscrizione');

      final body = {
        if (nome != null) 'nome': nome,
        if (email != null) 'email': email,
        if (telefono != null) 'telefono': telefono,
        if (note != null) 'note': note,
      };

      final headers = await _getHeaders();
      
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      print('POST $uri - Status: ${response.statusCode}');
      print('Response: ${response.body}');

      final rawData = jsonDecode(response.body);
      final data = decodeHtmlInMap(rawData);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Iscrizione completata!',
          'partecipante': data['partecipante'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Errore durante l\'iscrizione',
      };
    } catch (e) {
      print('Errore iscriviEvento: $e');
      return {
        'success': false,
        'message': 'Errore di connessione: $e',
      };
    }
  }

  /// Cancella iscrizione
  static Future<Map<String, dynamic>> cancellaIscrizione(int eventoId) async {
    try {
      final token = await storage.read(key: 'jwt_token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Devi effettuare il login',
        };
      }

      final uri = Uri.parse('$baseUrl/eventi/$eventoId/iscrizione');

      final headers = await _getHeaders();
      
      final response = await http.delete(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('DELETE $uri - Status: ${response.statusCode}');

      final rawData = jsonDecode(response.body);
      final data = decodeHtmlInMap(rawData);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Iscrizione cancellata',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Errore durante la cancellazione',
      };
    } catch (e) {
      print('Errore cancellaIscrizione: $e');
      return {
        'success': false,
        'message': 'Errore di connessione: $e',
      };
    }
  }

  /// Get eventi dell'utente
  static Future<Map<String, dynamic>> getMieiEventi() async {
    try {
      final token = await storage.read(key: 'jwt_token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Devi effettuare il login',
        };
      }

      final uri = Uri.parse('$baseUrl/miei-eventi');

      final headers = await _getHeaders();
      
      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('GET $uri - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);
        final data = decodeHtmlInMap(rawData);
        return {
          'success': true,
          'eventi': (data['eventi'] as List)
              .map((e) => Evento.fromJson(e))
              .toList(),
          'totale': data['totale'],
        };
      }

      return {
        'success': false,
        'message': 'Errore nel caricamento',
      };
    } catch (e) {
      print('Errore getMieiEventi: $e');
      return {
        'success': false,
        'message': 'Errore di connessione: $e',
      };
    }
  }
}
