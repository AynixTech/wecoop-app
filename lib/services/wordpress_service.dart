import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:wecoop_app/services/secure_storage_service.dart';
import 'package:wecoop_app/services/http_client_service.dart';
import '../models/post_model.dart';
import '../models/partner_model.dart';
import '../models/offerta_formativa_model.dart';
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

  // Recupera le offerte formative attive dal plugin wecoop-offerta-formativa
  Future<List<OffertaFormativa>> getOfferteFormative({int perPage = 20}) async {
    final url = Uri.parse('$wecoopApiUrl/offerte-formative?per_page=$perPage');
    try {
      final response = await HttpClientService.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body);
        return rawData
            .map((json) => OffertaFormativa.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Errore offerte formative: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('getOfferteFormative error: $e');
      return [];
    }
  }

  // Invia richiesta "Studiare in Italia" al plugin wecoop-offerta-formativa
  Future<Map<String, dynamic>> submitStudiareItalia(Map<String, dynamic> data) async {
    final url = Uri.parse('$wecoopApiUrl/studiare-italia');
    try {
      final response = await HttpClientService.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('submitStudiareItalia HTTP ${response.statusCode}: ${response.body}');
        return {'success': false, 'message': 'Errore server (${response.statusCode})'};
      }
    } catch (e) {
      debugPrint('submitStudiareItalia error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Invia richiesta generica (es. "Vivere in Italia") al plugin wecoop-leads
  Future<Map<String, dynamic>> submitLeadGenerico(Map<String, dynamic> data) async {
    final url = Uri.parse('$wecoopApiUrl/lead-generico');
    try {
      final response = await HttpClientService.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('submitLeadGenerico HTTP ${response.statusCode}: ${response.body}');
        return {'success': false, 'message': 'Errore server (${response.statusCode})'};
      }
    } catch (e) {
      debugPrint('submitLeadGenerico error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
