import '../services/http_client_service.dart';
import '../services/secure_storage_service.dart';
import '../config/api_config.dart';

class AccountService {
  static Future<bool> deleteCurrentUser() async {
    final storage = SecureStorageService();
    final token = await storage.read(key: 'jwt_token');
    if (token == null) return false;
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/me');
    final res = await HttpClientService.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    return res.statusCode == 200 || res.statusCode == 204;
  }
}