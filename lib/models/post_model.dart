import 'package:html/parser.dart' show parse;

class Post {
  final int id;
  final String title;
  final String excerpt;
  final String imageUrl;
  final String link; // Link all'articolo completo

  Post({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.imageUrl,
    required this.link,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // Alcuni endpoint WP restituiscono i campi come {rendered: ...},
    // altri come stringa diretta. Gestiamo entrambi i casi.
    String rawExcerpt = _rendered(json['excerpt']);
    String cleanExcerpt = parse(rawExcerpt).body?.text ?? '';

    // Recupera l'immagine in evidenza.
    // Backend Node -> campo piatto "image_url".
    // Legacy WordPress -> _embedded['wp:featuredmedia'][0]['source_url'].
    String featuredImage = (json['image_url'] ?? '').toString();
    if (featuredImage.isEmpty) {
      final embedded = json['_embedded'];
      if (embedded is Map) {
        final media = embedded['wp:featuredmedia'];
        if (media is List && media.isNotEmpty) {
          final first = media.first;
          if (first is Map && first['source_url'] != null) {
            featuredImage = first['source_url'].toString();
          }
        }
      }
    }

    return Post(
      id: _parseInt(json['id']),
      title: _rendered(json['title']),
      excerpt: cleanExcerpt,
      imageUrl: featuredImage,
      link: json['link']?.toString() ?? '',
    );
  }

  /// Estrae il valore testuale da un campo WP che può essere
  /// una Map {rendered: "..."} oppure direttamente una stringa.
  static String _rendered(dynamic value) {
    if (value == null) return '';
    if (value is Map) return (value['rendered'] ?? '').toString();
    return value.toString();
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
