import 'package:flutter_test/flutter_test.dart';
import 'package:wecoop_app/utils/phone_prefixes.dart';

void main() {
  group('PhonePrefixes.normalizeForLogin', () {
    test('combines prefix and local number', () {
      expect(
        PhonePrefixes.normalizeForLogin(prefix: '+39', phone: '3331234567'),
        '393331234567',
      );
    });

    test('strips national trunk zero before prefix', () {
      expect(
        PhonePrefixes.normalizeForLogin(prefix: '+39', phone: '03331234567'),
        '393331234567',
      );
    });

    test('does not double-prefix full international number', () {
      expect(
        PhonePrefixes.normalizeForLogin(
          prefix: '+39',
          phone: '393331234567',
        ),
        '393331234567',
      );
    });

    test('strips non-digits from input', () {
      expect(
        PhonePrefixes.normalizeForLogin(
          prefix: '+39',
          phone: '333 123 4567',
        ),
        '393331234567',
      );
    });
  });
}
