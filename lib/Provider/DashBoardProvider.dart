import 'dart:convert';
import 'package:demo_distribution/ApiLink/ApiEndpoint.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/DashBoardModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LoadState { idle, loading, loaded, error }

class DashboardProvider extends ChangeNotifier {
  LoadState state = LoadState.idle;
  DashboardData? data;
  String errorMsg = '';

  // Default to "This Month"
  late String fromDate = _firstOfMonth();
  late String toDate = _lastOfMonth();

  static String _firstOfMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
  }

  static String _lastOfMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0).toIso8601String().split('T')[0];
  }

  static const _mockJson = {
    // ... (keep this as fallback if needed for dev, but we are fixing API)
  };

  Future<void> fetch({
    String? from,
    String? to,
  }) async {
    final start = from ?? fromDate;
    final end = to ?? toDate;
    
    // Update internal state if explicit dates are provided
    if (from != null) fromDate = from;
    if (to != null) toDate = to;

    if (state == LoadState.loading) return;

    state = LoadState.loading;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final uri = Uri.parse('${ApiEndpoints.baseUrl}/dashboard?from=$start&to=$end');
      if (kDebugMode) print('Dashboard API Request: $uri');

      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200 || res.statusCode == 304) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;

        // Check for 'data' key or use the root object
        final dashboardMap = json.containsKey('data') ? json['data'] : json;

        if (dashboardMap == null) {
          throw Exception('API returned null data');
        }

        data = DashboardData.fromJson(dashboardMap as Map<String, dynamic>);
        state = LoadState.loaded;
      } else {
        errorMsg = 'Error ${res.statusCode}: ${res.reasonPhrase}';
        state = LoadState.error;
      }
    } catch (e) {
      if (kDebugMode) print('Dashboard API Error: $e');
      errorMsg = e.toString().replaceFirst('Exception: ', '');
      state = LoadState.error;
    }

    notifyListeners();
  }

  void refresh() => fetch();
}