import 'dart:convert';
import 'package:http/http.dart' as http;

/// Utility per decodificare risposte HTTP mantenendo UTF-8 corretto
/// 
/// Questo risolve il problema di caratteri accentati che vengono
/// visualizzati come sequenze escape Unicode (\uXXXX) anziché come
/// caratteri leggibili (é, à, ù, etc.)
class ResponseUtils {
  /// Decodifica JSON dalla risposta HTTP mantenendo l'encoding UTF-8 corretto
  /// 
  /// **Problema risolto:**
  /// - `jsonDecode(response.body)` potrebbe perdere UTF-8 in certi casi
  /// - Questo metodo usa `utf8.decode(response.bodyBytes)` per garantire
  ///   che i byte vengono decodificati correttamente come UTF-8
  /// 
  /// **Verifica anche:**
  /// - Se il server invia l'header `Content-Type: application/json; charset=utf-8`
  /// - Fa logging se è mancante per debugging del server
  /// 
  /// **Fallback:**
  /// - Se utf8.decode fallisce, prova con response.body
  /// - Se entrambi falliscono, lancia l'eccezione per gestione dell'errore
  /// 
  /// **Uso:**
  /// ```dart
  /// final data = ResponseUtils.decodeJson(response);
  /// // al posto di: final data = jsonDecode(response.body);
  /// ```
  static dynamic decodeJson(http.Response response) {
    // Verifica se il server invia charset corretto
    final contentType = response.headers['content-type'] ?? '';
    final hasCharset = contentType.contains('charset=utf-8');

    if (!hasCharset) {
      print(
        '⚠️ [ResponseUtils] Header Warning: Content-Type non contiene charset=utf-8',
      );
      print('   Content-Type riportato: $contentType');
      print(
        '   🔧 Fix server-side: Aggiungi "charset=utf-8" nell\'header della risposta',
      );
    }

    try {
      // Metodo CORRETTO: decodifica i byte come UTF-8 prima di jsonDecode
      // Questo preserva i caratteri accentati: é, à, ù, etc.
      final jsonString = utf8.decode(response.bodyBytes);
      final decoded = jsonDecode(jsonString);
      return decoded;
    } catch (e) {
      print(
        '⚠️ [ResponseUtils] Errore UTF-8 decode, fallback a response.body: $e',
      );
      try {
        // Fallback: prova senza conversione UTF-8 esplicita
        return jsonDecode(response.body);
      } catch (e2) {
        print('❌ [ResponseUtils] Errore nel parsing JSON: $e2');
        print('   Response body: ${response.body.substring(0, 200)}...');
        rethrow;
      }
    }
  }

  /// Decodifica JSON da una stringa mantenendo UTF-8 corretto
  /// 
  /// Utile per decodificare JSON da stringhe che potrebbero avere
  /// problemi di encoding UTF-8.
  static dynamic decodeString(String jsonString) {
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      print('❌ [ResponseUtils] Errore nel parsing JSON string: $e');
      rethrow;
    }
  }

  /// Verifica se la risposta è valida JSON
  static bool isValidJson(String response) {
    try {
      jsonDecode(response);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Estrae il charset dall'header Content-Type
  /// Ritorna 'utf-8' se trovato, altrimenti null
  static String? extractCharset(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    final charsetMatch = RegExp(r'charset=([^;]+)').firstMatch(contentType);
    return charsetMatch?.group(1)?.trim().toLowerCase();
  }

  /// Logga informazioni di debug sulla risposta HTTP
  static void debugResponseEncoding(
    http.Response response, {
    String label = 'Response',
    int maxBodyLength = 200,
  }) {
    final contentType = response.headers['content-type'] ?? 'unknown';
    final charset = extractCharset(response);
    final bodyPreview = response.body.length > maxBodyLength
        ? '${response.body.substring(0, maxBodyLength)}...'
        : response.body;

    print('');
    print('🔍 === Debug: $label ===');
    print('   Status: ${response.statusCode}');
    print('   Content-Type: $contentType');
    print('   Charset detected: ${charset ?? 'NOT FOUND ⚠️'}');
    print('   Body length: ${response.body.length} bytes');
    print('   Body preview: $bodyPreview');
    print('');
  }
}
