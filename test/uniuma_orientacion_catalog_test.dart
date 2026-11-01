import 'package:flutter_test/flutter_test.dart';
import 'package:wecoop_app/data/uniuma_orientacion_catalog.dart';

void main() {
  test('UNIUMA brochure documenti prepends Italian PDF when missing', () {
    final docs = uniumaBrochureDocumenti(const []);
    expect(docs.length, 1);
    expect(docs.first.titolo, contains('Italiano'));
    expect(docs.first.url, startsWith(kUniumaAssetUrlPrefix));
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
    final offerte = uniumaOfferteAsFormative(partnerId: 1, partnerNome: 'UNIUMA');
    expect(offerte.length, uniumaOrientacionPrograms.length);
    expect(offerte.where((o) => isUniumaProgramHeader(o)).length, 3);
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
