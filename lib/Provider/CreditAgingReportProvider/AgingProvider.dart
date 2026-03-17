import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../ApiLink/ApiEndpoint.dart';
import '../../model/CreditAgingReport/AgingReportModel.dart';

class CreditAgingProvider with ChangeNotifier {
  CreditAgingReportModel? _report;
  bool _isLoading = false;
  String? _errorMessage;

  CreditAgingReportModel? get report => _report;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCreditAging({
    int? salesmanId,
    String? asOfDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        _errorMessage = 'Token is null, please login again';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final date = asOfDate ??
          DateTime.now().toIso8601String().substring(0, 10);

      // ✅ Build query params
      final Map<String, String> queryParams = {
        'as_of_date': date,
        // ✅ Cache buster — forces server to return 200 instead of 304
        '_t': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      if (salesmanId != null) {
        queryParams['salesman_id'] = salesmanId.toString();
      }

      final uri = Uri.parse(
        '${ApiEndpoints.baseUrl}/reports/credit-aging',
      ).replace(queryParameters: queryParams);

      print("Fetching URL: $uri");

      final response = await http.get(uri, headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "x-company-id": "2",
        "Cache-Control": "no-cache, no-store, must-revalidate",
        "Pragma": "no-cache",
        "Expires": "0",
      });

      print("Status: ${response.statusCode}");
      print("Body length: ${response.body.length}");

      if (response.statusCode == 200) {
        // ✅ 200 — parse normally
        final data = jsonDecode(response.body);
        _report = CreditAgingReportModel.fromJson(data);
        print("Parsed ${_report!.data.length} records");

      } else if (response.statusCode == 304) {
        // ✅ 304 — body is empty, try to parse if body exists
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          _report = CreditAgingReportModel.fromJson(data);
          print("304 with body — Parsed ${_report!.data.length} records");
        } else {
          // ✅ Keep previous _report if exists, else set error
          if (_report == null) {
            _errorMessage = "No data received (304). Please retry.";
          }
          print("304 empty body — keeping previous report");
        }

      } else {
        _errorMessage = "Failed: ${response.statusCode} - ${response.body}";
      }

    } catch (e) {
      _errorMessage = "Error: $e";
      print("Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}