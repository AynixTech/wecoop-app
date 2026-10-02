import 'package:flutter_test/flutter_test.dart';
import 'package:wecoop_app/services/auth_helper.dart';
import 'package:wecoop_app/utils/app_navigation.dart';
import 'package:wecoop_app/utils/parse_helpers.dart';

void main() {
  group('parseIntOrNull', () {
    test('parses int, string and num', () {
      expect(parseIntOrNull(42), 42);
      expect(parseIntOrNull('405'), 405);
      expect(parseIntOrNull(7.0), 7);
    });

    test('returns null for invalid values', () {
      expect(parseIntOrNull(null), isNull);
      expect(parseIntOrNull(''), isNull);
      expect(parseIntOrNull('abc'), isNull);
    });
  });

  group('AuthHelper.isJwtExpired', () {
    test('detects expired JWT', () {
      // header.payload.sig — payload {"exp":1}
      const token = 'eyJhbGciOiJub25lIn0.eyJleHAiOjF9.signature';
      expect(AuthHelper.isJwtExpired(token), isTrue);
    });

    test('accepts JWT with future exp', () {
      // exp far in the future
      const token =
          'eyJhbGciOiJub25lIn0.eyJleHAiOjk5OTk5OTk5OTl9.signature';
      expect(AuthHelper.isJwtExpired(token), isFalse);
    });
  });

  group('MainTab', () {
    test('richieste aliases calendar index', () {
      expect(MainTab.richieste, MainTab.calendar);
      expect(MainTab.richieste, 3);
    });
  });
}
