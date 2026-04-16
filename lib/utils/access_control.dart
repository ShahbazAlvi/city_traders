import 'package:shared_preferences/shared_preferences.dart';

class AccessControl {

  /// True if user is owner OR has an admin role
  static Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();

    final isOwner = prefs.getBool('is_owner') ?? false;
    if (isOwner) return true;

    // Treat users with "Admin Role" or "Admin" as admin
    final roles = prefs.getStringList('roles') ?? [];
    return roles.contains('Admin Role') || roles.contains('Admin');
  }

  /// True if the user is a salesman
  static Future<bool> isSalesman() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('salesman_id');
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

  /// Returns the salesman_id if logged-in user is a salesman, null if admin
  static Future<int?> getSalesmanId() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('salesman_id')) return null;
    return prefs.getInt('salesman_id');
  }
}