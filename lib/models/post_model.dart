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
    // Pulisce l'excerpt dai tag HTML
    String rawExcerpt = json['excerpt']['rendered'] ?? '';
    String cleanExcerpt = parse(rawExcerpt).body?.text ?? '';

    // Recupera l'immagine in evidenza, se esiste
    String featuredImage = '';
    if (json['_embedded'] != null &&
        json['_embedded']['wp:featuredmedia'] != null &&
        (json['_embedded']['wp:featuredmedia'] as List).isNotEmpty) {
      featuredImage =
          json['_embedded']['wp:featuredmedia'][0]['source_url'] ?? '';
    }

    return Post(
      id: json['id'],
      title: json['title']['rendered'] ?? '',
      excerpt: cleanExcerpt,
      imageUrl: featuredImage,
      link: json['link'] ?? '',
    );
  }
}
