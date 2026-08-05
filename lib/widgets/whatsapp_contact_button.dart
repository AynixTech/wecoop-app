import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_settings_service.dart';
import '../services/app_localizations.dart';

/// Colore ufficiale WhatsApp.
const Color kWhatsappGreen = Color(0xFF25D366);

/// Bottone "Contatta su WhatsApp" a larghezza piena. Carica il numero da
/// /settings/public; se non configurato, non mostra nulla.
class WhatsappContactButton extends StatefulWidget {
  const WhatsappContactButton({super.key, this.margin});

  final EdgeInsetsGeometry? margin;

  @override
  State<WhatsappContactButton> createState() => _WhatsappContactButtonState();
}

class _WhatsappContactButtonState extends State<WhatsappContactButton> {
  WhatsappContact? _contact;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await AppSettingsService.getWhatsappContact();
    if (!mounted) return;
    setState(() => _contact = c);
  }

  Future<void> _open() async {
    final uri = _contact?.waUri;
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.translate('whatsappNotAvailable') ??
                'WhatsApp non disponibile su questo dispositivo',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final contact = _contact;
    if (contact == null || !contact.isConfigured) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final label = l10n?.translate('contactWhatsapp') ?? 'Contatta su WhatsApp';

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _open,
          icon: const Icon(Icons.chat, size: 20, color: Colors.white),
          label: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: kWhatsappGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
