/// Catalogo programmi UNIUMA / Società Umanitaria per «Solicitar orientación».
/// Spec V1.0 — 28 ottobre 2026. Se l'API restituisce `offerte_formative`,
/// quelle prevalgono su questo catalogo embedded.
library;

import '../models/offerta_formativa_model.dart';
import 'partner_ficha_catalog.dart';

const kUniumaBrochureEsUrl =
    'https://anthonydevhub.fra1.digitaloceanspaces.com/wecoop/uniuma/2026_brochure_es.pdf';

class UniumaProgramOption {
  final String codice;
  final String titolo;
  final String categoria;
  /// triennale | master | undecided | header
  final String livello;
  final bool selectable;

  const UniumaProgramOption({
    required this.codice,
    required this.titolo,
    required this.categoria,
    required this.livello,
    this.selectable = true,
  });
}

/// Headers non selezionabili + 10 opzioni selezionabili (spec §2.1).
const uniumaOrientacionPrograms = <UniumaProgramOption>[
  UniumaProgramOption(
    codice: 'undecided',
    titolo: 'Aún no lo sé',
    categoria: 'Orientación',
    livello: 'undecided',
  ),
  UniumaProgramOption(
    codice: 'hdr_hum',
    titolo:
        'Grado universitario trienal en Mediación Lingüística y Cultural — Departamento de Humanidades',
    categoria: 'Humanidades',
    livello: 'header',
    selectable: false,
  ),
  UniumaProgramOption(
    codice: 'hum_criminologia',
    titolo: 'Criminología y Protección Social',
    categoria: 'Humanidades',
    livello: 'triennale',
  ),
  UniumaProgramOption(
    codice: 'hum_diplomacia',
    titolo: 'Diplomacia Internacional y Derechos Humanos',
    categoria: 'Humanidades',
    livello: 'triennale',
  ),
  UniumaProgramOption(
    codice: 'hum_diseno_multi',
    titolo: 'Diseño Multicultural',
    categoria: 'Humanidades',
    livello: 'triennale',
  ),
  UniumaProgramOption(
    codice: 'hdr_eco',
    titolo:
        'Grado universitario trienal en Mediación Lingüística y Cultural — Departamento Económico',
    categoria: 'Económico',
    livello: 'header',
    selectable: false,
  ),
  UniumaProgramOption(
    codice: 'eco_artistico',
    titolo: 'Diseño Artístico (Milán)',
    categoria: 'Económico',
    livello: 'triennale',
  ),
  UniumaProgramOption(
    codice: 'eco_gestion',
    titolo: 'Gestión Empresarial (Milán)',
    categoria: 'Económico',
    livello: 'triennale',
  ),
  UniumaProgramOption(
    codice: 'eco_marketing',
    titolo: 'Marketing Ético y Desarrollo Digital (Milán)',
    categoria: 'Económico',
    livello: 'triennale',
  ),
  UniumaProgramOption(
    codice: 'eco_moda',
    titolo: 'Gestión Sostenible de la Moda (Génova)',
    categoria: 'Económico',
    livello: 'triennale',
  ),
  UniumaProgramOption(
    codice: 'eco_maritima',
    titolo:
        'Gestión para el Diseño y la Gestión Marítima, Turística y Portuaria (Génova)',
    categoria: 'Económico',
    livello: 'triennale',
  ),
  UniumaProgramOption(
    codice: 'hdr_master',
    titolo: 'Formación superior de posgrado',
    categoria: 'Posgrado',
    livello: 'header',
    selectable: false,
  ),
  UniumaProgramOption(
    codice: 'master_criminologia',
    titolo: 'Máster en Criminología e Psico-Sociología de la Desviación',
    categoria: 'Posgrado',
    livello: 'master',
  ),
];

bool isUniumaPartnerName(String? nome) {
  if (nome == null || nome.trim().isEmpty) return false;
  return fichaForPartnerName(nome)?.slug == 'uniuma';
}

/// Tutte le voci (intestazioni + opzioni) per il menu a tendina UNIUMA.
List<OffertaFormativa> uniumaOfferteAsFormative({
  required int partnerId,
  required String partnerNome,
}) {
  var i = 0;
  return uniumaOrientacionPrograms.map((p) {
    i += 1;
    return OffertaFormativa(
      id: p.selectable ? (-1000 - i) : (-2000 - i),
      titolo: p.titolo,
      descrizione: p.codice,
      partnerId: partnerId,
      partnerNome: partnerNome,
      partnerLogoUrl: '',
      partnerSitoWeb: '',
      categoria: p.categoria,
      durata: p.livello,
      linkInfo: p.codice,
      imageUrl: '',
      ordine: i,
    );
  }).toList();
}

bool isUniumaProgramHeader(OffertaFormativa o) =>
    o.durata == 'header' || o.linkInfo.startsWith('hdr_');

UniumaProgramOption? uniumaOptionForOfferta(OffertaFormativa? o) {
  if (o == null) return null;
  final code = o.linkInfo.isNotEmpty ? o.linkInfo : o.descrizione;
  for (final p in uniumaOrientacionPrograms) {
    if (p.codice == code || p.titolo == o.titolo) return p;
  }
  return null;
}
