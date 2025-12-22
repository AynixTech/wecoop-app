import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:ui' as ui;

class LocaleProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Locale _locale = const Locale('it');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final languageCode = await _storage.read(key: 'language_code');
    
    if (languageCode != null) {
      _locale = Locale(languageCode);
    } else {
      // Rileva la lingua del sistema
      final systemLocale = ui.PlatformDispatcher.instance.locale;
      final supportedLanguages = ['it', 'en', 'es'];
      
      if (supportedLanguages.contains(systemLocale.languageCode)) {
        _locale = Locale(systemLocale.languageCode);
      } else {
        // Default a italiano se la lingua del sistema non è supportata
        _locale = const Locale('it');
      }
      
      // Salva la lingua rilevata
      await _storage.write(key: 'language_code', value: _locale.languageCode);
    }
    
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    await _storage.write(key: 'language_code', value: locale.languageCode);
    notifyListeners();
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'it':
        return 'Italiano';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Italiano';
    }
  }
}
