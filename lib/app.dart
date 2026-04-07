import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wecoop_app/screens/auth_gate.dart';
import 'package:wecoop_app/screens/caf/compilazione_730_screen.dart';
import 'package:wecoop_app/screens/prenota_appuntamento/prenota_appuntamento_screen.dart';
import 'package:wecoop_app/screens/profilo/completa_profilo_screen.dart';
import 'package:wecoop_app/services/locale_provider.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/push_notification_service.dart';
import 'package:wecoop_app/services/deep_link_service.dart';
import 'package:wecoop_app/services/maintenance_handler.dart';
import 'package:wecoop_app/utils/deep_link_handler.dart';
import 'screens/main_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/login/forgot_password_screen.dart';
import 'screens/profilo/change_password_screen.dart';
import 'screens/calendar/calendar_screen.dart';

class WECOOPApp extends StatefulWidget {
  const WECOOPApp({super.key});

  @override
  State<WECOOPApp> createState() => _WECOOPAppState();
}

class _WECOOPAppState extends State<WECOOPApp> {
  final PushNotificationService _pushService = PushNotificationService();
  final DeepLinkService _deepLinkService = DeepLinkService();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    MaintenanceHandler.bindNavigatorKey(_navigatorKey);
    _initializePushNotifications();
    _initializeDeepLinks();
  }

  Future<void> _initializePushNotifications() async {
    await _pushService.initialize();

    // Configura callback per navigazione
    _pushService.onMessageTap = (RemoteMessage message) {
      _handleNotificationNavigation(message.data);
    };
  }

  Future<void> _initializeDeepLinks() async {
    await _deepLinkService.initialize((uri) {
      // Aspetta che il navigator sia pronto
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _navigatorKey.currentContext;
        if (context != null) {
          DeepLinkHandler.handleDeepLink(context, uri);
        } else {
          print('⚠️ Navigator context non disponibile per deep link');
        }
      });
    });
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final screen = data['screen'] as String?;
    final id = data['id'] as String?;

    print('📍 Navigazione richiesta: $data');
    print('Screen: $screen, ID: $id');

    if (screen == null) return;

    // Naviga alla schermata specificata
    switch (screen) {
      case 'EventDetail':
        if (id != null) {
          // TODO: Implementare navigazione a EventDetailScreen
          print('🔄 Navigazione a EventDetail: $id');
          // _navigatorKey.currentState?.pushNamed('/event/$id');
        }
        break;

      case 'ServiceDetail':
        if (id != null) {
          // TODO: Implementare navigazione a ServiceDetailScreen
          print('🔄 Navigazione a ServiceDetail: $id');
          // _navigatorKey.currentState?.pushNamed('/service/$id');
        }
        break;

      case 'Profile':
        print('🔄 Navigazione a Profile');
        _navigatorKey.currentState?.pushNamed('/home');
        break;

      case 'Notifications':
        print('🔄 Navigazione a Notifications');
        _navigatorKey.currentState?.pushNamed('/home');
        break;

      default:
        print('🔄 Schermata sconosciuta: $screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'WECOOP',
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('it'), Locale('en'), Locale('es')],
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: Color(0xFF1282A8),
              onPrimary: Colors.white,
              secondary: Color(0xFF59B575),
              onSecondary: Colors.white,
              error: Color(0xFFE6266B),
              onError: Colors.white,
              surface: Color(0xFFFFFFFF),
              onSurface: Color(0xFF1F2933),
            ),
            textTheme: GoogleFonts.poppinsTextTheme().apply(
              bodyColor: const Color(0xFF1F2933),
              displayColor: const Color(0xFF1F2933),
            ),
            scaffoldBackgroundColor: const Color(0xFFF8FBFD),
            appBarTheme: AppBarTheme(
              elevation: 0,
              centerTitle: false,
              backgroundColor: const Color(0xFF1282A8),
              foregroundColor: Colors.white,
              titleTextStyle: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              color: Colors.white,
              shadowColor: const Color(0xFF0F2430).withOpacity(0.08),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0x14000000)),
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(vertical: 6),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1282A8),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                minimumSize: const Size(132, 52),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0E6786),
                minimumSize: const Size(120, 50),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                side: const BorderSide(color: Color(0xFF1282A8), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1282A8),
                textStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              hintStyle: GoogleFonts.poppins(color: const Color(0xFF6F7782)),
              labelStyle: GoogleFonts.poppins(color: const Color(0xFF4D4C4C)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0x22000000)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0x22000000)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF1282A8),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            chipTheme: ChipThemeData(
              backgroundColor: const Color(0xFFEFF7FA),
              selectedColor: const Color(0xFF1282A8),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2933),
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF1282A8),
              foregroundColor: Colors.white,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF1282A8),
              unselectedItemColor: const Color(0xFF6F7782),
              selectedLabelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
              elevation: 10,
              type: BottomNavigationBarType.fixed,
            ),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return const Color(0xFFCBCED4);
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF59B575);
                }
                return const Color(0xFFCBCED4);
              }),
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const MainScreen(),
          routes: {
            '/home': (context) => const MainScreen(),
            '/calendar': (context) => const CalendarScreen(),
            '/login': (context) => const LoginScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/change-password': (context) => const ChangePasswordScreen(),
            '/complete-profile': (context) => const CompletaProfiloScreen(),
            '/prenotaAppuntamento': (context) => PrenotaAppuntamentoScreen(),
            '/compila730':
                (context) =>
                    AuthGate(protectedScreen: const Compilazione730Screen()),
            // '/assegnoUnico': (context) => AuthGate(protectedScreen: const AssegnoUnicoScreen()),
          },
        );
      },
    );
  }
}
