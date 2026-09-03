import 'package:flutter_test/flutter_test.dart';
import 'package:wecoop_app/utils/countries.dart';
import 'package:wecoop_app/utils/phone_prefixes.dart';

void main() {
  group('Countries world list', () {
    test('contiene almeno 190 paesi ISO', () {
      expect(Countries.all.length, greaterThanOrEqualTo(190));
      final codes = Countries.all.map((c) => c.code).toSet();
      expect(codes.length, Countries.all.length); // no duplicate ISO
    });

    test('include Mauritius e Italia', () {
      expect(Countries.byCode('MU')?.name, 'Mauritius');
      expect(Countries.byCode('IT')?.name, 'Italia');
      expect(Countries.nameFor('mu'), 'Mauritius');
    });

    test('search filtra per nome e codice', () {
      final byName = Countries.search('mauri');
      expect(byName.map((c) => c.code), contains('MU'));

      final byCode = Countries.search('ec');
      expect(byCode.map((c) => c.code), contains('EC'));
    });

    test('phone prefix +230 is available with flag', () {
      expect(PhonePrefixes.prefixes, contains('+230'));
      expect(PhonePrefixes.flagFor('+230'), '🇲🇺');
    });
  });
}
