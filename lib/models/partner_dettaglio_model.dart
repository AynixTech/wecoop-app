import 'partner_model.dart';
import 'offerta_formativa_model.dart';

/// Dettaglio completo di un Partner Accademico: dati anagrafici, offerta
/// formativa (raggruppabile per categoria) e materiale multimediale.
class PartnerDettaglio {
  final Partner partner;
  final List<OffertaFormativa> offerteFormative;
  final List<PartnerMedia> media;

  const PartnerDettaglio({
    required this.partner,
    required this.offerteFormative,
    required this.media,
  });

  /// Offerte raggruppate per categoria (Lauree, Master, …). Le categorie vuote
  /// vengono raccolte sotto "Altro".
  Map<String, List<OffertaFormativa>> get offertePerCategoria {
    final map = <String, List<OffertaFormativa>>{};
    for (final o in offerteFormative) {
      final cat = o.categoria.trim().isEmpty ? 'Altro' : o.categoria.trim();
      map.putIfAbsent(cat, () => []).add(o);
    }
    return map;
  }

  List<PartnerMedia> get galleria => media.where((m) => m.isImmagine).toList();
  List<PartnerMedia> get video => media.where((m) => m.isVideo).toList();
  List<PartnerMedia> get documenti => media.where((m) => m.isPdf).toList();

  factory PartnerDettaglio.fromJson(Map<String, dynamic> json) {
    final partnerJson = json['partner'] as Map<String, dynamic>? ?? {};
    final offerteJson = json['offerte_formative'] as List<dynamic>? ?? [];
    final mediaJson = json['media'] as List<dynamic>? ?? [];
    return PartnerDettaglio(
      partner: Partner.fromJson(partnerJson),
      offerteFormative: offerteJson
          .map((e) => OffertaFormativa.fromJson(e as Map<String, dynamic>))
          .toList(),
      media: mediaJson
          .map((e) => PartnerMedia.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
