import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/app_notification.dart';
import '../../services/app_localizations.dart';
import '../../services/notification_badge_provider.dart';
import '../../services/notifications_service.dart';
import '../../theme/theme.dart';
import '../calendar/calendar_screen.dart';
import '../profilo/documenti_screen.dart';
import '../profilo/mie_richieste_screen.dart';

/// Centro Notifiche: elenco lette/non lette con deep link agli oggetti.
class NotificheScreen extends StatefulWidget {
  const NotificheScreen({super.key});

  @override
  State<NotificheScreen> createState() => _NotificheScreenState();
}

class _NotificheScreenState extends State<NotificheScreen> {
  bool _loading = true;
  bool _error = false;
  String? _errorMessage;
  List<AppNotification> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = false;
      _errorMessage = null;
    });

    final result = await NotificationsService.list();
    if (!mounted) return;

    if (result['success'] == true) {
      final count = result['unread_count'] as int? ?? 0;
      await context.read<NotificationBadgeProvider>().setCount(count);
      setState(() {
        _items = (result['data'] as List<AppNotification>?) ?? [];
        _loading = false;
      });
    } else {
      setState(() {
        _error = true;
        _errorMessage = result['message'] as String?;
        _loading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    final result = await NotificationsService.markAllRead();
    if (!mounted) return;
    if (result['success'] == true) {
      final count = result['unread_count'] as int? ?? 0;
      await context.read<NotificationBadgeProvider>().setCount(count);
      await _load();
    }
  }

  Future<void> _onTap(AppNotification n) async {
    if (!n.read) {
      final result = await NotificationsService.markRead(n.id);
      if (mounted && result['success'] == true) {
        final count = result['unread_count'] as int? ?? 0;
        await context.read<NotificationBadgeProvider>().setCount(count);
        setState(() {
          final idx = _items.indexWhere((e) => e.id == n.id);
          if (idx >= 0) {
            _items[idx] = AppNotification(
              id: n.id,
              type: n.type,
              category: n.category,
              title: n.title,
              body: n.body,
              entityType: n.entityType,
              entityId: n.entityId,
              data: n.data,
              read: true,
              readAt: DateTime.now(),
              createdAt: n.createdAt,
            );
          }
        });
      }
    }
    if (!mounted) return;
    _navigateFor(n);
  }

  void _navigateFor(AppNotification n) {
    final type = n.type;
    final entityType = n.entityType ?? n.data['entity_type']?.toString();
    final entityId = n.entityId ?? n.data['entity_id']?.toString();
    final requestId =
        n.data['request_id']?.toString() ??
        (entityType == 'service_request' ? entityId : null);
    final screen = n.data['screen']?.toString();

    if (type == 'appuntamento' ||
        type == 'appuntamento_reminder' ||
        screen == 'calendar' ||
        entityType == 'appuntamento') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const CalendarScreen(),
          settings: RouteSettings(
            arguments: requestId != null ? {'richiesta_id': requestId} : null,
          ),
        ),
      );
      return;
    }

    if (type == 'support_reply' ||
        screen == 'support' ||
        entityType == 'support_ticket') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MieRichiesteScreen()),
      );
      return;
    }

    if (type == 'document_expiry' ||
        type == 'membership_expiry' ||
        screen == 'documenti' ||
        screen == 'profile' ||
        entityType == 'documento') {
      if (type == 'document_expiry' || entityType == 'documento') {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DocumentiScreen()),
        );
      } else {
        Navigator.of(context).pushNamed('/home');
      }
      return;
    }

    // Pratiche / status / integrazione / payment / document_ready / operator_message
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CalendarScreen(),
        settings: RouteSettings(
          arguments: requestId != null ? {'richiesta_id': requestId} : null,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return DateFormat.Hm().format(local);
    }
    return DateFormat('dd/MM/yyyy').format(local);
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'appuntamento':
      case 'appuntamento_reminder':
        return Icons.event_outlined;
      case 'integrazione':
      case 'document_ready':
      case 'document_expiry':
        return Icons.description_outlined;
      case 'support_reply':
        return Icons.support_agent_outlined;
      case 'payment':
        return Icons.payments_outlined;
      case 'membership_expiry':
        return Icons.badge_outlined;
      case 'operator_message':
        return Icons.mail_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          if (_items.any((e) => !e.read))
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Segna tutte',
                style: TextStyle(color: scheme.onPrimary),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_errorMessage ?? 'Errore di caricamento'),
                        const SizedBox(height: AppSpacing.md),
                        ElevatedButton(
                          onPressed: _load,
                          child: const Text('Riprova'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _items.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Center(
                                child: Text(
                                  'Nessuna notifica',
                                  style: TextStyle(
                                    color: scheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final n = _items[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: n.read
                                    ? scheme.surfaceContainerHighest
                                    : scheme.primary.withValues(alpha: 0.15),
                                child: Icon(
                                  _iconFor(n.type),
                                  color: n.read
                                      ? scheme.onSurface.withValues(alpha: 0.5)
                                      : scheme.primary,
                                ),
                              ),
                              title: Text(
                                n.title,
                                style: TextStyle(
                                  fontWeight: n.read
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                n.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatDate(n.createdAt),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  if (!n.read) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: scheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              onTap: () => _onTap(n),
                            );
                          },
                        ),
                ),
    );
  }
}
