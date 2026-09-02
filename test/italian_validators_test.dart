import 'package:flutter_test/flutter_test.dart';
import 'package:wecoop_app/utils/italian_validators.dart';

void main() {
  group('isValidCodiceFiscale', () {
    test('accetta CF italiano e ID fiscali stranieri (testo libero)', () {
      expect(ItalianValidators.isValidCodiceFiscale('SPNNRY79S58Z605Z'), isTrue);
      expect(ItalianValidators.isValidCodiceFiscale('SPNNRY79S58Z605N'), isTrue);
      expect(ItalianValidators.isValidCodiceFiscale('ABC123'), isTrue);
      expect(ItalianValidators.isValidCodiceFiscale('12.345.678-9'), isTrue);
    });

    test('normalizza spazi e minuscole', () {
      expect(ItalianValidators.isValidCodiceFiscale(' spnnry79s58z605z '), isTrue);
      expect(
        ItalianValidators.normalizeCodiceFiscale(' ab cd '),
        'ABCD',
      );
    });

    test('rifiuta solo vuoto o oltre il max length', () {
      expect(ItalianValidators.isValidCodiceFiscale(''), isFalse);
      expect(ItalianValidators.isValidCodiceFiscale('   '), isFalse);
      expect(
        ItalianValidators.isValidCodiceFiscale('A' * 33),
        isFalse,
      );
    });
  });
}
