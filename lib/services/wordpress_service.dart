import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wecoop_app/services/secure_storage_service.dart';
import '../models/post_model.dart';
import '../utils/html_utils.dart';

class WordpressService {
  static const String baseUrl = 'https://www.wecoop.org/wp-json/wp/v2';
  static final storage = SecureStorageService();

  // Recupera gli ultimi post con immagini
  Future<List<Post>> getPosts({int perPage = 5}) async {
    // Ottiene la lingua corrente
    final languageCode = await storage.read(key: 'language_code') ?? 'it';
    
    // aggiungiamo _embed per avere l'immagine completa
    final url = Uri.parse('$baseUrl/posts?per_page=$perPage&_embed');
    final response = await http.get(
      url,
      headers: {
        'Accept-Language': languageCode,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> rawData = json.decode(response.body);
      // Decodifica HTML in ogni post
      final List<dynamic> decodedData = rawData.map((item) {
        if (item is Map<String, dynamic>) {
          return decodeHtmlInMap(item);
        }
        return item;
      }).toList();
      return decodedData.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Errore nel recupero dei post: ${response.statusCode}');
    }
  }
}
