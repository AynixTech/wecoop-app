import 'dart:convert';
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
}
