import 'package:html/parser.dart' as html_parser;

/// Decodifica le entità HTML in una stringa
String decodeHtmlEntities(String text) {
  if (text.isEmpty) return text;
  
  // Usa il parser HTML per decodificare le entità
  final document = html_parser.parse(text);
  return document.body?.text ?? text;
}

/// Decodifica le entità HTML in un Map (tipicamente response JSON)
Map<String, dynamic> decodeHtmlInMap(Map<String, dynamic> data) {
  final decoded = <String, dynamic>{};
  
  data.forEach((key, value) {
    if (value is String) {
      decoded[key] = decodeHtmlEntities(value);
    } else if (value is Map<String, dynamic>) {
      decoded[key] = decodeHtmlInMap(value);
    } else if (value is List) {
      decoded[key] = value.map((item) {
        if (item is String) {
          return decodeHtmlEntities(item);
        } else if (item is Map<String, dynamic>) {
          return decodeHtmlInMap(item);
        }
        return item;
      }).toList();
    } else {
      decoded[key] = value;
    }
  });
  
  return decoded;
}
