import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const List<String> sessionKeys = [
    'token',
    'user',
    'companies',
    'salesman_id',
    'delivery_boy_id',
    'is_owner',
    'roles',
    'permission_codes',
    'user_type',
    'assigned_area_ids',
  ];

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token')?.trim();
    return token == null || token.isEmpty ? null : token;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in sessionKeys) {
      await prefs.remove(key);
    }
  }
}
