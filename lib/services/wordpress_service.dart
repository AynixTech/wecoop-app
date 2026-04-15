import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/http_client_service.dart';
import '../models/post_model.dart';
import '../models/partner_model.dart';
import '../utils/html_utils.dart';

class WordpressService {
  static const String baseUrl = 'https://www.wecoop.org/wp-json/wp/v2';
  static const String wecoopApiUrl = 'https://www.wecoop.org/wp-json/wecoop/v1';
  static final storage = SecureStorageService();

  // Recupera gli ultimi post con immagini
  Future<List<Post>> getPosts({int perPage = 5}) async {
    // Ottiene la lingua corrente
    final languageCode = await storage.read(key: 'language_code') ?? 'it';

    // aggiungiamo _embed per avere l'immagine completa
    final url = Uri.parse('$baseUrl/posts?per_page=$perPage&_embed');
    final response = await HttpClientService.get(
      url,
      headers: {'Accept-Language': languageCode},
    );

    if (response.statusCode == 200) {
      final List<dynamic> rawData = json.decode(response.body);
      // Decodifica HTML in ogni post
      final List<dynamic> decodedData =
          rawData.map((item) {
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

  // Recupera i partner pubblicati, ordinati per campo 'ordine'
  Future<List<Partner>> getPartners({int perPage = 50}) async {
    final url = Uri.parse('$wecoopApiUrl/partners?per_page=$perPage');
    try {
      final response = await HttpClientService.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body);
        return rawData
            .map((json) => Partner.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Errore nel recupero dei partner: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('getPartners error: $e');
      return [];
    }
  }
}
