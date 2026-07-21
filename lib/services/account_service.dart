import 'package:http/http.dart' as http;
import '../services/secure_storage_service.dart';

class AccountService {
  static Future<bool> deleteCurrentUser() async {
    final storage = SecureStorageService();
    final token = await storage.read(key: 'jwt_token');
    if (token == null) return false;
    final url = Uri.parse('https://www.wecoop.org/wp-json/wecoop/v1/users/me');
    final res = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
    return res.statusCode == 200 || res.statusCode == 204;
  }
}