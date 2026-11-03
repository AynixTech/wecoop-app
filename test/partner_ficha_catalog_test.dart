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

  test('admission sections aligned across locales', () {
    expect(ficha, isNotNull);
    for (final lang in ['es', 'it', 'en', 'fr', 'ar', 'zh']) {
      final loc = ficha!.localeFor(lang);
      expect(loc.admissionSections, hasLength(1), reason: lang);
      expect(loc.admissionSections.first.bodyKey, isNotNull, reason: lang);
      expect(loc.admissionSections.first.bodyKey!, isNotEmpty, reason: lang);
      expect(loc.admissionIntro, isEmpty, reason: lang);
    }
    expect(
      ficha!.localeFor('es').admissionSections.first.titleKey,
      contains('MEDIACIÓN LINGÜÍSTICA'),
    );
    expect(
      ficha!.localeFor('es').admissionSections.first.bodyKey,
      contains('DEPARTAMENTO DE HUMANIDADES'),
    );
    expect(
      ficha!.localeFor('es').admissionSections.first.bodyKey,
      contains('CRIMINOLOGÍA E PSICO-SOCIOLOGÍA'),
    );
  });
}
