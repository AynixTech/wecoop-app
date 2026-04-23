import 'package:flutter/material.dart';
import '../../services/app_localizations.dart';
import 'richiesta_form_screen.dart';

class MediazioneLinguisticaScreen extends StatelessWidget {
  const MediazioneLinguisticaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('mediazioneLinguistica')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primary,
                      scheme.primary.withOpacity(0.75),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.translate,
                      color: scheme.onPrimary,
                      size: 36,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.translate('mediazioneLinguistica'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.translate('mediazioneLinguisticaSubtitle'),
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                l10n.translate('mediazioneLinguisticaTipoRichiesta'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.translate('mediazioneLinguisticaScegli'),
                style: TextStyle(
                  fontSize: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              _TipoRichiestaCard(
                icon: Icons.event,
                title: l10n.translate('mediazioneLinguisticaAccompagnamento'),
                description: l10n.translate('mediazioneLinguisticaAccompagnamentoDesc'),
                onTap: () => _openForm(context, l10n, 'mediazioneLinguisticaAccompagnamento'),
              ),
              const SizedBox(height: 12),
              _TipoRichiestaCard(
                icon: Icons.description,
                title: l10n.translate('mediazioneLinguisticaTraduzioneDoc'),
                description: l10n.translate('mediazioneLinguisticaTraduzioneDocDesc'),
                onTap: () => _openForm(context, l10n, 'mediazioneLinguisticaTraduzioneDoc'),
              ),
              const SizedBox(height: 12),
              _TipoRichiestaCard(
                icon: Icons.phone_in_talk,
                title: l10n.translate('mediazioneLinguisticaSupportoTel'),
                description: l10n.translate('mediazioneLinguisticaSupportoTelDesc'),
                onTap: () => _openForm(context, l10n, 'mediazioneLinguisticaSupportoTel'),
              ),
              const SizedBox(height: 12),
              _TipoRichiestaCard(
                icon: Icons.more_horiz,
                title: l10n.translate('mediazioneLinguisticaAltro'),
                description: l10n.translate('mediazioneLinguisticaAltroDesc'),
                onTap: () => _openForm(context, l10n, 'mediazioneLinguisticaAltro'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _openForm(BuildContext context, AppLocalizations l10n, String tipoKey) {
    final tipoLabel = l10n.translate(tipoKey);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RichiestaFormScreen(
          servizio: l10n.translate('mediazioneLinguistica'),
          categoria: tipoLabel,
          campi: [
            {
              'label': l10n.translate('mediazioneLinguisticaLingua'),
              'type': 'text',
              'required': true,
            },
            if (tipoKey != 'mediazioneLinguisticaSupportoTel') ...[
              {
                'label': l10n.translate('mediazioneLinguisticaDataAppuntamento'),
                'type': 'date',
                'required': tipoKey == 'mediazioneLinguisticaAccompagnamento',
              },
              {
                'label': l10n.translate('mediazioneLinguisticaLuogo'),
                'type': 'text',
                'required': tipoKey == 'mediazioneLinguisticaAccompagnamento',
              },
            ],
            {
              'label': l10n.translate('mediazioneLinguisticaDescrizione'),
              'type': 'textarea',
              'required': true,
            },
          ],
          documentiRichiesti: const [],
          modalitaConsegna: (tipoKey == 'mediazioneLinguisticaTraduzioneDoc' ||
                  tipoKey == 'mediazioneLinguisticaAltro')
              ? const ['email', 'pickup']
              : const [],
        ),
      ),
    );
  }
}

class _TipoRichiestaCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _TipoRichiestaCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: scheme.onSurface.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: scheme.onPrimaryContainer, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: scheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
