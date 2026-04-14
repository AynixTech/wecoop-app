import 'package:flutter/foundation.dart';

import 'secure_storage_service.dart';

class UserAvatarStore {
  UserAvatarStore._();

  static final SecureStorageService _storage = SecureStorageService();
  static final ValueNotifier<String?> avatarUrl = ValueNotifier<String?>(null);

  static String? normalize(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  static Future<void> hydrate() async {
    avatarUrl.value = normalize(await _storage.read(key: 'avatar_url'));
  }

  static Future<void> setAvatarUrl(String? value) async {
    final normalized = normalize(value);
    if (normalized == null) {
      await _storage.delete(key: 'avatar_url');
    } else {
      await _storage.write(key: 'avatar_url', value: normalized);
    }
    avatarUrl.value = normalized;
  }

  static Future<void> clear() async {
    await _storage.delete(key: 'avatar_url');
    avatarUrl.value = null;
  }
}