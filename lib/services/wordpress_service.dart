import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class WordpressService {
  static const String baseUrl = 'https://www.wecoop.org/wp-json/wp/v2';

  // Recupera gli ultimi post con immagini
  Future<List<Post>> getPosts({int perPage = 5}) async {
    // aggiungiamo _embed per avere l'immagine completa
    final url = Uri.parse('$baseUrl/posts?per_page=$perPage&_embed');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Errore nel recupero dei post: ${response.statusCode}');
    }
  }
}
