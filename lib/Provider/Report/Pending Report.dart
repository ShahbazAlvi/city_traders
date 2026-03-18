import 'dart:convert';
import 'package:demo_distribution/ApiLink/ApiEndpoint.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/Report/PendingRecoveryModel.dart';
import '../../model/Report/PendingReportDoc.dart';

class RecoveryPendingReportProvider extends ChangeNotifier {

  bool isLoading       = false;
  bool isDetailLoading = false;
  String? error;
  String? detailError;
  RecoveryPendingReport? recoveryReport;
  PendingReportDoc?      pendingReportDoc;

  // ── Main List ─────────────────────────────────────────────────────
  Future<void> fetchRecoveryReport({
    int?    salesmanId,
    String? date,
  }) async {
    try {
      isLoading = true;
      error     = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        error     = 'Token not found. Please login again.';
        isLoading = false;
        notifyListeners();
        return;
      }

      Uri uri;

      // ✅ Case 1: No filters → plain URL
      // ✅ Case 2: With filters → add query params
      if (salesmanId == null && date == null) {
        uri = Uri.parse(
          '${ApiEndpoints.baseUrl}/reports/pending-recoveries',
        );
      } else {
        final Map<String, String> queryParams = {};

        if (salesmanId != null) {
          queryParams['salesman_id'] = salesmanId.toString();
        }
        if (date != null) {
          queryParams['date'] = date;
        }

        uri = Uri.parse(
          '${ApiEndpoints.baseUrl}/reports/pending-recoveries',
        ).replace(queryParameters: queryParams);
      }

      print("Fetching list: $uri");

      final response = await http.get(uri, headers: {
        "Authorization": "Bearer $token",
        "Accept":        "application/json",
        "x-company-id":  "2",
        "Cache-Control": "no-cache, no-store, must-revalidate",
        "Pragma":        "no-cache",
        "Expires":       "0",
      });

      print("List status: ${response.statusCode}");
      print("List body:   ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        recoveryReport = RecoveryPendingReport.fromJson(jsonData);
        print("List records: ${recoveryReport!.data.length}");
      } else {
        error = "Failed: ${response.statusCode}";
      }
    } catch (e) {
      error = "Error: $e";
      print("fetchRecoveryReport error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Detail for one Salesman ───────────────────────────────────────
  Future<void> fetchPendingReportDetail({
    required int salesmanId,
    String?      date,
  }) async {
    try {
      isDetailLoading  = true;
      detailError      = null;
      pendingReportDoc = null;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        detailError     = 'Token not found. Please login again.';
        isDetailLoading = false;
        notifyListeners();
        return;
      }

      // ✅ Detail always needs salesmanId in path
      // ✅ date is optional query param
      Uri uri;

      if (date == null) {
        uri = Uri.parse(
          '${ApiEndpoints.baseUrl}/reports/pending-recoveries/detail/$salesmanId',
        );
      } else {
        uri = Uri.parse(
          '${ApiEndpoints.baseUrl}/reports/pending-recoveries/detail/$salesmanId',
        ).replace(queryParameters: {'date': date});
      }

      print("Fetching detail: $uri");

      final response = await http.get(uri, headers: {
        "Authorization": "Bearer $token",
        "Accept":        "application/json",
        "x-company-id":  "2",
        "Cache-Control": "no-cache, no-store, must-revalidate",
        "Pragma":        "no-cache",
        "Expires":       "0",
      });

      print("Detail status: ${response.statusCode}");
      print("Detail body:   ${response.body}");

      if (response.statusCode == 200) {
        final jsonData   = json.decode(response.body);
        pendingReportDoc = PendingReportDoc.fromJson(jsonData);
        print("Detail records: ${pendingReportDoc!.data.length}");
      } else {
        detailError = "Failed: ${response.statusCode}";
      }
    } catch (e) {
      detailError = "Error: $e";
      print("fetchPendingReportDetail error: $e");
    } finally {
      isDetailLoading = false;
      notifyListeners();
    }
  }
}