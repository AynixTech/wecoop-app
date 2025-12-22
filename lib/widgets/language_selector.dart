import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/locale_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale.languageCode;

    // Mappa le lingue alle loro icone
    String getLanguageIcon(String code) {
      switch (code) {
        case 'it':
          return '🇮🇹';
        case 'en':
          return '🇬🇧';
        case 'es':
          return '🇪🇸';
        default:
          return '🌐';
      }
    }

    return PopupMenuButton<String>(
      icon: Text(
        getLanguageIcon(currentLocale),
        style: const TextStyle(fontSize: 24),
      ),
      tooltip: 'Cambia lingua',
      onSelected: (String languageCode) {
        localeProvider.setLocale(Locale(languageCode));
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'it',
          child: Row(
            children: [
              Text('🇮🇹', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text('Italiano'),
              if (currentLocale == 'it') ...[
                const Spacer(),
                const Icon(Icons.check, color: Color(0xFF2196F3)),
              ],
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              Text('🇬🇧', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text('English'),
              if (currentLocale == 'en') ...[
                const Spacer(),
                const Icon(Icons.check, color: Color(0xFF2196F3)),
              ],
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'es',
          child: Row(
            children: [
              Text('🇪🇸', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text('Español'),
              if (currentLocale == 'es') ...[
                const Spacer(),
                const Icon(Icons.check, color: Color(0xFF2196F3)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
