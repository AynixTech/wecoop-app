import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'secure_storage_service.dart';

class AnnunciWecoopService {
  static const String _baseUrl =
      'https://www.wecoop.org/wp-json/wecoop/v1/annunci';

  final _storage = SecureStorageService();

  Future<String?> get _token async =>
      _storage.read(key: 'jwt_token');

  // -------------------------------------------------------------------------
  // GET lista annunci
  // -------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getAnnunci({
    String? categoria,
    String? citta,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      if (categoria != null && categoria.isNotEmpty) 'categoria': categoria,
      if (citta != null && citta.isNotEmpty) 'citta': citta,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return list.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // -------------------------------------------------------------------------
  // GET singolo annuncio
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>?> getAnnuncio(int id) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  // -------------------------------------------------------------------------
  // GET categorie
  // -------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getCategorie() async {
    final uri = Uri.parse('$_baseUrl/categorie');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  // -------------------------------------------------------------------------
  // POST crea annuncio (richiede login)
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> creaAnnuncio(
      Map<String, dynamic> data) async {
    final token = await _token;
    if (token == null) {
      return {'success': false, 'message': 'Devi effettuare il login.'};
    }
    final uri = Uri.parse(_baseUrl);
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'annuncio': body};
    }
    return {
      'success': false,
      'message': body['message'] ?? 'Errore nella creazione dell\'annuncio.',
    };
  }

  // -------------------------------------------------------------------------
  // DELETE annuncio
  // -------------------------------------------------------------------------
  Future<bool> eliminaAnnuncio(int id) async {
    final token = await _token;
    if (token == null) return false;
    final uri = Uri.parse('$_baseUrl/$id');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  // -------------------------------------------------------------------------
  // POST estendi pubblicazione
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> estendiPubblicazione(
      int id, int giorni) async {
    final token = await _token;
    if (token == null) {
      return {'success': false, 'message': 'Devi effettuare il login.'};
    }
    final uri = Uri.parse('$_baseUrl/$id/estendi');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'giorni': giorni}),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, ...body};
    }
    return {
      'success': false,
      'message': body['message'] ?? 'Errore.',
    };
  }

  // -------------------------------------------------------------------------
  // POST upload foto copertina
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> uploadCopertina(int id, File file) async {
    final token = await _token;
    if (token == null) {
      return {'success': false, 'message': 'Devi effettuare il login.'};
    }
    final uri = Uri.parse('$_baseUrl/$id/upload-copertina');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);
    final body = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, ...body};
    }
    return {
      'success': false,
      'message': body['message'] ?? 'Errore upload copertina.',
    };
  }

  // -------------------------------------------------------------------------
  // POST upload foto galleria
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> uploadFoto(int id, File file) async {
    final token = await _token;
    if (token == null) {
      return {'success': false, 'message': 'Devi effettuare il login.'};
    }
    final uri = Uri.parse('$_baseUrl/$id/upload-foto');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);
    final body = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, ...body};
    }
    return {
      'success': false,
      'message': body['message'] ?? 'Errore upload foto.',
    };
  }

  // -------------------------------------------------------------------------
  // DELETE foto galleria
  // -------------------------------------------------------------------------
  Future<bool> deleteFoto(int annuncioId, int attachmentId) async {
    final token = await _token;
    if (token == null) return false;
    final uri = Uri.parse('$_baseUrl/$annuncioId/foto/$attachmentId');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  // -------------------------------------------------------------------------
  // AI: migliora descrizione annuncio
  // -------------------------------------------------------------------------
  Future<Map<String, dynamic>> improveDescrizione({
    required String titolo,
    required String descrizione,
    String citta = '',
    String categoria = '',
  }) async {
    final token = await _token;
    if (token == null) {
      return {'success': false, 'message': 'Devi essere loggato.'};
    }
    try {
      final uri = Uri.parse('$_baseUrl/improve-description');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'titolo': titolo,
          'descrizione': descrizione,
          'citta': citta,
          'categoria': categoria,
        }),
      ).timeout(const Duration(seconds: 30));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>? ?? {};
        return {
          'success': true,
          'ai_description': (data['ai_description'] ?? '').toString(),
          'source': (data['source'] ?? '').toString(),
        };
      }
      return {'success': false, 'message': (body['message'] ?? 'Errore AI').toString()};
    } catch (e) {
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }
}
