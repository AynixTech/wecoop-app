import 'package:shared_preferences/shared_preferences.dart';
import 'package:wecoop_app/services/http_client_service.dart';
import 'package:wecoop_app/utils/app_logger.dart';
import '../config/api_config.dart';

/// Servizio in evidenza sulla home (configurato da cloud → Visibilità servizi).
class ServiceSpotlightItem {
  final int? id;
  final String code;
  final String label;
  final String? macro;
  final String? description;
  final String? icon;
  final int sortOrder;
  final String? updatedAt;

  const ServiceSpotlightItem({
    this.id,
    required this.code,
    required this.label,
    this.macro,
    this.description,
    this.icon,
    this.sortOrder = 0,
    this.updatedAt,
  });

  factory ServiceSpotlightItem.fromJson(Map<String, dynamic> json) {
    return ServiceSpotlightItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id'] ?? ''}'),
      code: (json['code'] as String? ?? '').trim(),
      label: (json['label'] as String? ?? '').trim(),
      macro: (json['macro'] as String?)?.trim(),
      description: (json['description'] as String?)?.trim(),
      icon: (json['icon'] as String?)?.trim(),
      sortOrder: json['sort_order'] is int
          ? json['sort_order'] as int
          : int.tryParse('${json['sort_order'] ?? 0}') ?? 0,
      updatedAt: json['updated_at']?.toString(),
    );
  }

  /// Chiave dismiss: cambia se cloud ri-attiva / aggiorna il servizio.
  String get dismissKey =>
      'home_spotlight_dismissed_${code}_${updatedAt ?? '0'}';
}

/// GET /api/service-catalog/spotlight — pubblico, senza auth.
class ServiceSpotlightService {
  static List<ServiceSpotlightItem>? _cache;

  static Future<List<ServiceSpotlightItem>> fetch({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/service-catalog/spotlight');
      final response = await HttpClientService.get(uri);
      if (response.statusCode == 200) {
        final body = HttpClientService.decodeJsonResponse(response);
        final raw = body is Map ? body['items'] : null;
        if (raw is List) {
          final items = raw
              .whereType<Map>()
              .map((e) => ServiceSpotlightItem.fromJson(e.cast<String, dynamic>()))
              .where((e) => e.code.isNotEmpty)
              .toList();
          _cache = items;
          return items;
        }
      }
    } catch (e) {
      AppLogger.d('⚠️ ServiceSpotlightService.fetch error: $e');
    }
    return _cache ?? const [];
  }

  /// Primo spotlight non ancora chiuso dall'utente (SharedPreferences).
  static Future<ServiceSpotlightItem?> nextUndismissed({
    bool forceRefresh = false,
  }) async {
    final items = await fetch(forceRefresh: forceRefresh);
    if (items.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    for (final item in items) {
      if (prefs.getBool(item.dismissKey) != true) return item;
    }
    return null;
  }

  static Future<void> dismiss(ServiceSpotlightItem item) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(item.dismissKey, true);
  }
}
