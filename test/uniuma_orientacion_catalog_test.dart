import 'package:flutter_test/flutter_test.dart';
import 'package:wecoop_app/data/uniuma_orientacion_catalog.dart';
import 'package:wecoop_app/models/offerta_formativa_model.dart';
import 'package:wecoop_app/models/partner_model.dart';

void main() {
  test('UNIUMA brochure documenti prepends Italian PDF when missing', () {
    final docs = uniumaBrochureDocumenti(const []);
    expect(docs.length, 1);
    expect(docs.first.titolo, contains('Italiano'));
    expect(docs.first.url, startsWith(kUniumaAssetUrlPrefix));
  });

  test('UNIUMA brochure documenti keeps Italian first over API ES', () {
    final docs = uniumaBrochureDocumenti([
      PartnerMedia(
        id: 1,
        tipo: 'brochure',
        titolo: 'Brochure UNIUMA 2026–2027 (Español)',
        descrizione: 'ES',
        url: kUniumaBrochureEsUrl,
        mime: 'application/pdf',
        ordine: 0,
      ),
    ]);
    expect(docs.length, 2);
    expect(docs.first.titolo, contains('Italiano'));
    expect(docs.last.titolo, contains('Español'));
  });

  test('UNIUMA catalog has 10 selectable options with undecided last', () {
    final selectable =
        uniumaOrientacionPrograms.where((p) => p.selectable).toList();
    expect(selectable.length, 10);
    expect(selectable.first.codice, 'hum_criminologia');
    expect(selectable.last.codice, 'undecided');
    expect(selectable.last.titoloFor('it'), 'Devo ancora decidere');
    expect(isUniumaPartnerName('Società Umanitaria'), isTrue);
    expect(isUniumaPartnerName('Altro Partner'), isFalse);
  });

  test('embedded offerte include A/B category headers', () {
    final offerte =
        uniumaOfferteAsFormative(partnerId: 1, partnerNome: 'UNIUMA', lang: 'it');
    expect(offerte.length, uniumaOrientacionPrograms.length);
    expect(offerte.where((o) => isUniumaProgramHeader(o)).length, 2);
    expect(
      offerte.firstWhere((o) => o.linkInfo == 'hdr_laurea').titolo,
      'A. CORSI DI LAUREA IN MEDIAZIONE LINGUISTICA E CULTURALE',
    );
    expect(
      offerte.firstWhere((o) => o.linkInfo == 'hdr_post').titolo,
      'B. POST-LAUREA',
    );
    // Un solo header A: niente secondo «A.» tra umanistico ed economico.
    expect(
      offerte.where((o) => o.linkInfo == 'hdr_laurea').length,
      1,
    );
  });

  test('dedupe drops legacy hdr_eco duplicate A header from API', () {
    final embedded =
        uniumaCanonicalOfferte(partnerId: 1, partnerNome: 'U', lang: 'it');
    final withLegacy = [
      ...embedded.take(4), // hdr_laurea + 3 umanistici
      OffertaFormativa(
        id: 99,
        titolo: 'A. CORSI DI LAUREA IN MEDIAZIONE LINGUISTICA E CULTURALE',
        descrizione: 'hdr_eco',
        partnerId: 1,
        partnerNome: 'U',
        partnerLogoUrl: '',
        partnerSitoWeb: '',
        categoria: 'Económico',
        durata: 'header',
        linkInfo: 'hdr_eco',
        imageUrl: '',
        ordine: 50,
      ),
      ...embedded.skip(4),
    ];
    final cleaned = localizeUniumaOfferte(withLegacy, 'it');
    expect(cleaned.where((o) => o.linkInfo == 'hdr_eco'), isEmpty);
    expect(cleaned.where((o) => o.linkInfo == 'hdr_laurea').length, 1);
    expect(
      cleaned.where((o) => o.titolo.contains('CORSI DI LAUREA')).length,
      1,
    );
  });

  test('ficha list shows headers and courses, hides undecided', () {
    final offerte =
        uniumaOfferteAsFormative(partnerId: 1, partnerNome: 'UNIUMA', lang: 'it');
    final ficha = offerte.where(isUniumaFichaOfferta).toList();
    // 2 header + 8 triennale + 1 master
    expect(ficha.length, 11);
    expect(ficha.any(isUniumaUndecided), isFalse);
    expect(ficha.where(isUniumaProgramHeader).length, 2);
    expect(
      ficha.firstWhere((o) => o.linkInfo == 'hum_criminologia').titolo,
      'Criminologia e Tutela Sociale',
    );
    expect(
      ficha.firstWhere((o) => o.linkInfo == 'hum_criminologia').categoria,
      'Dipartimento Umanistico – Triennale – ECTS 180',
    );
    expect(
      ficha.firstWhere((o) => o.linkInfo == 'eco_gestion').titolo,
      'Business Management',
    );
    expect(
      ficha.firstWhere((o) => o.linkInfo == 'master_criminologia').categoria,
      'Master annuale – ECTS 60',
    );
  });

  test('titles follow app language', () {
    final es = localizeUniumaOfferta(
      uniumaOfferteAsFormative(partnerId: 1, partnerNome: 'U', lang: 'es')
          .firstWhere((o) => o.linkInfo == 'hum_criminologia'),
      'es',
    );
    final it = localizeUniumaOfferta(es, 'it');
    final en = localizeUniumaOfferta(es, 'en');
    expect(es.titolo, 'Criminología y Protección Social');
    expect(it.titolo, 'Criminologia e Tutela Sociale');
    expect(en.titolo, 'Criminology and Social Protection');
    expect(it.categoria, contains('Dipartimento Umanistico'));
    expect(it.categoria, contains('ECTS 180'));
    expect(en.categoria, contains('Humanities Department'));
  });

  test('every ficha program is localized for it/es/en/fr/ar/zh', () {
    const langs = ['it', 'es', 'en', 'fr', 'ar', 'zh'];
    final base = uniumaOfferteAsFormative(partnerId: 1, partnerNome: 'U')
        .where(isUniumaFichaOfferta)
        .where((o) => !isUniumaProgramHeader(o))
        .toList();
    expect(base, hasLength(9));

    for (final p in uniumaOrientacionPrograms.where((e) => e.showInFicha)) {
      for (final lang in langs) {
        expect(p.titoli.containsKey(lang), isTrue,
            reason: '${p.codice} missing titolo $lang');
        expect(p.categorie.containsKey(lang), isTrue,
            reason: '${p.codice} missing categoria $lang');
        expect(p.titoloFor(lang).trim(), isNotEmpty);
      }
      if (p.selectable) {
        expect(p.titoloFor('it'), isNot(equals(p.titoloFor('es'))),
            reason: p.codice);
      }
    }

    final fromApiEs = base.map((o) {
      final es = localizeUniumaOfferta(o, 'es');
      return OffertaFormativa(
        id: es.id,
        titolo: es.titolo,
        descrizione: '',
        partnerId: es.partnerId,
        partnerNome: es.partnerNome,
        partnerLogoUrl: '',
        partnerSitoWeb: '',
        categoria: es.categoria,
        durata: 'triennale',
        linkInfo: es.linkInfo,
        imageUrl: '',
        ordine: es.ordine,
      );
    }).toList();

    final asIt = localizeUniumaOfferte(fromApiEs, 'it');
    final asEs = localizeUniumaOfferte(fromApiEs, 'es');
    final asFr = localizeUniumaOfferte(fromApiEs, 'fr');
    expect(asIt.first.titolo, 'Criminologia e Tutela Sociale');
    expect(asIt.first.categoria, 'Dipartimento Umanistico – Triennale – ECTS 180');
    expect(asEs.first.titolo, 'Criminología y Protección Social');
    expect(asEs.first.categoria, contains('Departamento de Humanidades'));
    expect(asFr.first.titolo, 'Criminologie et Protection Sociale');
    expect(asIt.map((e) => e.titolo).toSet().length, 9);
    expect(asEs.map((e) => e.titolo).toSet().length, 9);
  });

  test('UNIUMA linkInfo codes are not launchable URLs', () {
    for (final p in uniumaOrientacionPrograms) {
      expect(isLaunchableHttpUrl(p.codice), isFalse,
          reason: 'codice ${p.codice} must not open via url_launcher');
    }
    expect(isLaunchableHttpUrl('undecided'), isFalse);
    expect(isLaunchableHttpUrl('hdr_laurea'), isFalse);
    expect(isLaunchableHttpUrl('hdr_hum'), isFalse);
    expect(
      isLaunchableHttpUrl('https://www.wecoop.org/formazione/info'),
      isTrue,
    );
  });

  test('legacy titles still resolve to catalog codes', () {
    final legacy = OffertaFormativa(
      id: 1,
      titolo: 'Design Multiculturale',
      descrizione: '',
      partnerId: 1,
      partnerNome: 'U',
      partnerLogoUrl: '',
      partnerSitoWeb: '',
      categoria: 'Umanistico',
      durata: 'triennale',
      linkInfo: '',
      imageUrl: '',
      ordine: 1,
    );
    final opt = uniumaOptionForOfferta(legacy);
    expect(opt?.codice, 'hum_diseno_multi');
    final localized = localizeUniumaOfferta(legacy, 'it');
    expect(localized.titolo, 'Progettazione Multiculturale');
  });
}
