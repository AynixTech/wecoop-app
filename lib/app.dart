import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wecoop_app/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:wecoop_app/screens/prenota_appuntamento/prenota_appuntamento_screen.dart';
import 'package:wecoop_app/screens/profilo/completa_profilo_screen.dart';
import 'package:wecoop_app/services/locale_provider.dart';
import 'package:wecoop_app/services/app_localizations.dart';
import 'package:wecoop_app/services/push_notification_service.dart';
import 'package:wecoop_app/services/deep_link_service.dart';
import 'package:wecoop_app/services/maintenance_handler.dart';
import 'package:wecoop_app/services/in_app_update_service.dart';
import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/utils/deep_link_handler.dart';
import 'package:wecoop_app/theme/theme.dart';
import 'package:wecoop_app/widgets/mandatory_update_gate.dart';
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
    PushNotificationService.navigatorKey = _navigatorKey;
    _bindSessionExpiredHandler();
    _initializePushNotifications();
    _initializeDeepLinks();
    _checkForAppUpdate();
  }

  /// Quando il refresh token fallisce (sessione scaduta), riporta al login.
  void _bindSessionExpiredHandler() {
    HttpClientService.onSessionExpired = () async {
      _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
    };
  }

  void _checkForAppUpdate() {
    // Android: usa il flusso nativo di Google Play (In-App Updates).
    // Per iOS MandatoryUpdateGate verifica automaticamente App Store.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await InAppUpdateService.checkAndForceUpdate();
      }
    });
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
          AppLogger.d('⚠️ Navigator context non disponibile per deep link');
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

    AppLogger.d('📍 Navigazione richiesta: $data');
    AppLogger.d('Screen: $screen, ID: $id');

    if (screen == null) return;

    // Naviga alla schermata specificata
    switch (screen) {
      case 'EventDetail':
        // Eventi è un tab della MainScreen: entriamo dalla home.
        AppLogger.d('🔄 Deep link EventDetail: $id -> home');
        _navigatorKey.currentState?.pushNamed('/home');
        break;

      case 'ServiceDetail':
        // Servizi è un tab della MainScreen: entriamo dalla home.
        AppLogger.d('🔄 Deep link ServiceDetail: $id -> home');
        _navigatorKey.currentState?.pushNamed('/home');
        break;

      case 'Profile':
        AppLogger.d('🔄 Navigazione a Profile');
        _navigatorKey.currentState?.pushNamed('/home');
        break;

      case 'Notifications':
        AppLogger.d('🔄 Navigazione a Notifications');
        _navigatorKey.currentState?.pushNamed('/home');
        break;

      case 'AppointmentDetail':
        AppLogger.d('🔄 Navigazione a AppointmentDetail (richiesta $id)');
        if (id != null) {
          _navigatorKey.currentState?.pushNamed(
            '/calendar',
            arguments: {'richiesta_id': id},
          );
        } else {
          _navigatorKey.currentState?.pushNamed('/calendar');
        }
        break;

      default:
        AppLogger.d('🔄 Schermata sconosciuta: $screen');
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
          builder:
              (context, child) =>
                  MandatoryUpdateGate(child: child ?? const SizedBox.shrink()),
          supportedLocales: const [
            Locale('it'),
            Locale('en'),
            Locale('es'),
            Locale('ar'),
            Locale('zh'),
          ],
          theme: ThemeData(
            fontFamily: AppTypography.fontFamily,
            useMaterial3: true,
            colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              secondary: AppColors.secondary,
              onSecondary: AppColors.onSecondary,
              error: AppColors.error,
              onError: AppColors.onError,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
            textTheme: ThemeData.light().textTheme.apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
            ),
            scaffoldBackgroundColor: AppColors.background,
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: false,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              titleTextStyle: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 16,
                height: 1.2,
                fontWeight: AppTypography.semiBold,
                color: AppColors.onPrimary,
              ),
              iconTheme: IconThemeData(color: AppColors.onPrimary),
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              color: AppColors.surface,
              shadowColor: AppColors.shadowBranded.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shadowColor: Colors.transparent,
                minimumSize: const Size(132, 52),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.pillBr,
                ),
                textStyle: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 16,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryDark,
                minimumSize: const Size(120, 50),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.pillBr,
                ),
                textStyle: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 15,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.surface,
              hintStyle: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                color: AppColors.textMuted,
              ),
              labelStyle: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                color: AppColors.inputLabel,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.inputBr,
                borderSide: const BorderSide(color: AppColors.borderInput),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.inputBr,
                borderSide: const BorderSide(color: AppColors.borderInput),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.inputBr,
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 14,
              ),
            ),
            chipTheme: ChipThemeData(
              backgroundColor: AppColors.chipBg,
              selectedColor: AppColors.primary,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              labelStyle: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: AppTypography.medium,
                color: AppColors.textPrimary,
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: AppColors.surface,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              selectedLabelStyle: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: AppTypography.semiBold,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontWeight: AppTypography.medium,
              ),
              elevation: 10,
              type: BottomNavigationBarType.fixed,
            ),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.onPrimary;
                }
                return AppColors.disabled;
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.secondary;
                }
                return AppColors.disabled;
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
            // '/compila730': rimosso — schermata 730 non ancora collegata al backend.
            // '/assegnoUnico': (context) => AuthGate(protectedScreen: const AssegnoUnicoScreen()),
          },
        );
      },
    );
  }
}
