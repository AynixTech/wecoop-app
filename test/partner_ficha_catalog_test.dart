import 'package:flutter_test/flutter_test.dart';
import 'package:wecoop_app/data/partner_ficha_catalog.dart';

void main() {
  final ficha = fichaForPartnerName('Società Umanitaria');

  test('UNIUMA ficha matches Società Umanitaria', () {
    expect(ficha, isNotNull);
    expect(ficha!.slug, 'uniuma');
  });

  test('UNIUMA has no stats cards in any locale', () {
    for (final lang in ['es', 'it', 'en', 'fr', 'ar', 'zh']) {
      expect(ficha!.localeFor(lang).stats, isEmpty, reason: lang);
    }
  });

  test('ES detail description matches Lizandro brief', () {
    final es = ficha!.localeFor('es');
    expect(
      es.detailDescription,
      startsWith(
        'UNIUMA, la Escuela Superior de Mediadores Lingüísticos «P. M. Loria»',
      ),
    );
    expect(es.detailDescription, contains('Milán y Génova'));
    expect(es.detailDescription, contains('A través de WECOOP'));
  });

  test('IT detail description is translated, not the old short line', () {
    final it = ficha!.localeFor('it');
    expect(it.detailDescription, startsWith('UNIUMA, la Scuola Superiore'));
    expect(
      it.detailDescription,
      isNot(contains('nel cuore di Milano')),
    );
  });

  test('admission sections keep original how-to copy (not itinerary catalog)', () {
    expect(ficha, isNotNull);
    for (final lang in ['es', 'it', 'en', 'fr', 'ar', 'zh']) {
      final loc = ficha!.localeFor(lang);
      expect(loc.admissionSections, hasLength(3), reason: lang);
      expect(loc.admissionIntro, isNotEmpty, reason: lang);
    }
    expect(ficha!.localeFor('it').admissionSections.first.titleKey, 'Come iniziare');
    expect(ficha!.localeFor('es').admissionSections.first.titleKey, 'Cómo empezar');
    expect(
      ficha!.localeFor('it').admissionSections.any(
            (s) => (s.bodyKey ?? '').contains('DIPARTIMENTO UMANISTICO'),
          ),
      isFalse,
    );
  });
}
