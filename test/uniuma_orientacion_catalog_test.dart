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

  test('UNIUMA catalog has 10 selectable options', () {
    final selectable =
        uniumaOrientacionPrograms.where((p) => p.selectable).toList();
    expect(selectable.length, 10);
    expect(selectable.first.codice, 'undecided');
    expect(selectable.last.codice, 'master_criminologia');
    expect(isUniumaPartnerName('Società Umanitaria'), isTrue);
    expect(isUniumaPartnerName('Altro Partner'), isFalse);
  });

  test('embedded offerte include category headers', () {
    final offerte =
        uniumaOfferteAsFormative(partnerId: 1, partnerNome: 'UNIUMA', lang: 'es');
    expect(offerte.length, uniumaOrientacionPrograms.length);
    expect(offerte.where((o) => isUniumaProgramHeader(o)).length, 3);
  });

  test('ficha list hides undecided and headers', () {
    final offerte =
        uniumaOfferteAsFormative(partnerId: 1, partnerNome: 'UNIUMA', lang: 'it');
    final ficha = offerte.where(isUniumaFichaOfferta).toList();
    expect(ficha.length, 9);
    expect(ficha.any(isUniumaUndecided), isFalse);
    expect(ficha.any(isUniumaProgramHeader), isFalse);
    expect(ficha.first.titolo, 'Criminologia e Tutela Sociale');
    expect(ficha.first.descrizione, isEmpty);
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
    expect(it.categoria, 'Umanistico');
    expect(en.categoria, 'Humanities');
  });

  test('every ficha program is localized for it/es/en/fr/ar/zh', () {
    const langs = ['it', 'es', 'en', 'fr', 'ar', 'zh'];
    final base = uniumaOfferteAsFormative(partnerId: 1, partnerNome: 'U')
        .where(isUniumaFichaOfferta)
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
      // IT e ES devono differire (nessun testo ES “inchiodato”).
      expect(p.titoloFor('it'), isNot(equals(p.titoloFor('es'))),
          reason: p.codice);
    }

    // Anche partendo da titoli API in spagnolo, la UI IT/EN si localizza.
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
    expect(asIt.first.categoria, 'Umanistico');
    expect(asIt.first.durata, 'triennale');
    expect(asEs.first.titolo, 'Criminología y Protección Social');
    expect(asEs.first.categoria, 'Humanidades');
    expect(asEs.first.durata, 'trienal');
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
    expect(isLaunchableHttpUrl('hdr_hum'), isFalse);
    expect(
      isLaunchableHttpUrl('https://www.wecoop.org/formazione/info'),
      isTrue,
    );
  });
}
