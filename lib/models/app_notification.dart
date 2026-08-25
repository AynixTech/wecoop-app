/// Modello notifica inbox (Centro Notifiche).
class AppNotification {
  final int id;
  final String type;
  final String category;
  final String title;
  final String body;
  final String? entityType;
  final String? entityId;
  final Map<String, dynamic> data;
  final bool read;
  final DateTime? readAt;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.body,
    this.entityType,
    this.entityId,
    this.data = const {},
    required this.read,
    this.readAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    final dataRaw = json['data'];
    Map<String, dynamic> data = {};
    if (dataRaw is Map) {
      data = Map<String, dynamic>.from(dataRaw);
    }

    return AppNotification(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      type: (json['type'] ?? '').toString(),
      category: (json['category'] ?? 'operational').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      entityType: json['entity_type']?.toString(),
      entityId: json['entity_id']?.toString(),
      data: data,
      read: json['read'] == true || json['read_at'] != null,
      readAt: parseDate(json['read_at']),
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  bool get isOperational => category == 'operational';
}
