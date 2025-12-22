import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wecoop_app/screens/auth_gate.dart';
import 'package:wecoop_app/screens/caf/compilazione_730_screen.dart';
import 'package:wecoop_app/screens/prenota_appuntamento/prenota_appuntamento_screen.dart';
import 'package:wecoop_app/services/locale_provider.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'screens/main_screen.dart';
import 'screens/login/login_screen.dart';

class WECOOPApp extends StatelessWidget {
  const WECOOPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
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
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2196F3), // Azzurro moderno
              primary: const Color(0xFF2196F3),
              secondary: const Color(0xFF1976D2),
              surface: Colors.white,
              background: const Color(0xFFF5F9FF),
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F9FF),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: false,
              backgroundColor: Color(0xFF2196F3),
              foregroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFF2196F3),
              unselectedItemColor: Color(0xFF9E9E9E),
              elevation: 8,
              type: BottomNavigationBarType.fixed,
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const MainScreen(),
          routes: {
            '/home': (context) => const MainScreen(),
            '/login': (context) => const LoginScreen(),
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
