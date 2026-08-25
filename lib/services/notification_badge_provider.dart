import 'package:flutter/foundation.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:wecoop_app/services/notifications_service.dart';
import 'package:wecoop_app/utils/app_logger.dart';

/// Stato condiviso del conteggio notifiche non lette + sync badge icona.
class NotificationBadgeProvider extends ChangeNotifier {
  int _unreadCount = 0;
  bool _loading = false;

  int get unreadCount => _unreadCount;
  bool get loading => _loading;

  Future<void> refresh() async {
    if (_loading) return;
    _loading = true;
    try {
      final count = await NotificationsService.unreadCount();
      await setCount(count);
    } catch (e) {
      AppLogger.d('NotificationBadgeProvider.refresh: $e');
    } finally {
      _loading = false;
    }
  }

  Future<void> setCount(int count) async {
    final next = count < 0 ? 0 : count;
    if (_unreadCount != next) {
      _unreadCount = next;
      notifyListeners();
    }
    await _syncAppIconBadge(next);
  }

  Future<void> _syncAppIconBadge(int count) async {
    try {
      final supported = await AppBadgePlus.isSupported();
      if (!supported) return;
      if (count <= 0) {
        await AppBadgePlus.updateBadge(0);
      } else {
        await AppBadgePlus.updateBadge(count);
      }
    } catch (e) {
      AppLogger.d('Badge icon sync fallito: $e');
    }
  }
}
