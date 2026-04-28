import 'dart:convert';

import 'package:flutter/cupertino.dart';
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
  // static Future<bool> isSalesman() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.containsKey('salesman_id');
  // }
  // ❌ This returns true for admin too if salesman_id is saved
  // static Future<bool> isSalesman() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.containsKey('salesman_id');
  // }

// ✅ Use user_type instead
  static Future<bool> isSalesman() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_type') == 'salesman';
  }

// Also add delivery boy check
  static Future<bool> isDeliveryBoy() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_type') == 'deliveryboy';
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
  // delivery boy

  /// Returns assigned area IDs for salesman/delivery boy.
  /// Returns empty list for admin (means "show all").
  static Future<List<int>> getAssignedAreaIds() async {
    final prefs = await SharedPreferences.getInstance();

    // Admins have no area restriction — return empty = show all
    final userType = prefs.getString('user_type');
    if (userType == 'admin') return [];

    final user = prefs.getString('user');
    if (user == null) return [];

    try {
      final data = jsonDecode(user);
      final ids = data['assigned_area_ids'] as List?;
      return ids?.map<int>((e) => e as int).toList() ?? [];
    } catch (e) {
      debugPrint('getAssignedAreaIds error: $e');
      return [];
    }
  }

  /// Returns the salesman_id if logged-in user is a salesman, null if admin
  static Future<int?> getSalesmanId() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('salesman_id')) return null;
    return prefs.getInt('salesman_id');
  }
}