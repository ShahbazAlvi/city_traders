import 'package:shared_preferences/shared_preferences.dart';

class AccessControl {

  /// True if user is owner OR has "Admin Role", or if salesman_id is null
  static Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    
    // As per user requirement: if salesman_id is null, it's admin (can show all data)
    if (!prefs.containsKey('salesman_id')) {
      return true;
    }

    final isOwner = prefs.getBool('is_owner') ?? false;
    if (isOwner) return true;

    // Also treat users with "Admin Role" or "Admin" as admin
    final roles = prefs.getStringList('roles') ?? [];
    return roles.contains('Admin Role') || roles.contains('Admin');
  }

  static Future<bool> hasRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    final roles = prefs.getStringList('roles') ?? [];
    return roles.contains(role);
  }

  static Future<bool> hasPermission(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final permissions = prefs.getStringList('permission_codes') ?? [];
    return permissions.contains(code);
  }

  /// Convenience: true if admin OR has the given permission
  static Future<bool> canDo(String permissionCode) async {
    if (await isAdmin()) return true;
    return hasPermission(permissionCode);
  }
}