import 'package:html/parser.dart' show parse;

class Post {
  final int id;
  final String title;
  final String excerpt;
  final String imageUrl;
  final String link; // Link all'articolo completo
  final DateTime? publishedAt;
  final String? sourceName;

  Post({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.imageUrl,
    required this.link,
    this.publishedAt,
    this.sourceName,
  });

  /// Etichetta categoria corta per le card (es. IMMIGRAZIONE), derivata da
  /// [sourceName] del feed RSS senza richiedere un campo dedicato nel backend.
  String get categoryLabel {
    final raw = (sourceName ?? '').trim();
    final s = raw.toLowerCase();
    if (s.contains('cittadinanza')) return 'CITTADINANZA';
    if (s.contains('soggiorno') || s.contains('documenti')) return 'DOCUMENTI';
    if (s.contains('lavoro')) return 'LAVORO';
    if (s.contains('diritti')) return 'DIRITTI';
    if (s.contains('asilo') || s.contains('frontiere')) return 'ASILO';
    if (s.contains('caf') || s.contains('patronato')) return 'CAF';
    if (s.contains('immigraz') || s.contains('migrator') || s.contains('legge')) {
      return 'IMMIGRAZIONE';
    }
    if (raw.isEmpty) return 'NOTIZIE';
    final cleaned = raw
        .replaceFirst(RegExp(r'^Google News\s*[—\-]\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'\s+IT(?:\s*\(.*\))?$', caseSensitive: false), '')
        .trim();
    if (cleaned.isEmpty) return 'NOTIZIE';
    return cleaned.toUpperCase();
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    // Alcuni endpoint WP restituiscono i campi come {rendered: ...},
    // altri come stringa diretta. Gestiamo entrambi i casi.
    String rawExcerpt = _rendered(json['excerpt']);
    String cleanExcerpt = parse(rawExcerpt).body?.text ?? '';
    cleanExcerpt = cleanExcerpt.replaceAll(RegExp(r'\s+'), ' ').trim();

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
      publishedAt: _parseDate(json['published_at'] ?? json['date']),
      sourceName: _nullableString(json['source_name'] ?? json['sourceName']),
    );
  }

  /// Estrae il valore testuale da un campo WP che può essere
  /// una Map {rendered: "..."} oppure direttamente una stringa.
  static String _rendered(dynamic value) {
    if (value == null) return '';
    if (value is Map) return (value['rendered'] ?? '').toString();
    return value.toString();
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
