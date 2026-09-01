import 'secure_storage_service.dart';

/// Helper leggero per verifiche di sessione (guest vs socio loggato).
abstract final class AuthHelper {
  static final SecureStorageService _storage = SecureStorageService();

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null && token.isNotEmpty;
  }

  static Future<bool> hasJwtToken() => isLoggedIn();
}
