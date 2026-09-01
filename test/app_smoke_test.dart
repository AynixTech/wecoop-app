import 'package:flutter_test/flutter_test.dart';
import 'package:wecoop_app/services/auth_helper.dart';
import 'package:wecoop_app/utils/app_navigation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MainScreenRouteArgs', () {
    test('parses map arguments', () {
      final args = parseMainScreenRouteArgs({
        'initialIndex': 3,
        'richiesta_id': '405',
      });

      expect(args.initialIndex, 3);
      expect(args.initialRichiestaId, '405');
    });

    test('defaults when arguments are null', () {
      const args = MainScreenRouteArgs();
      expect(args.initialIndex, 0);
      expect(args.initialRichiestaId, isNull);
    });
  });

  group('MainTab', () {
    test('calendar tab index is 3', () {
      expect(MainTab.calendar, 3);
    });

    test('profile tab index is 6', () {
      expect(MainTab.profilo, 6);
    });
  });

  group('AuthHelper', () {
    test('isLoggedIn returns false without token', () async {
      final loggedIn = await AuthHelper.isLoggedIn();
      expect(loggedIn, isFalse);
    });
  });
}
