// Provider/Recovery_Provider/RecoveryProvider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../ApiLink/ApiEndpoint.dart';
import '../../model/SalesManRecoveryReport/SalesmanReport.dart';
import '../../model/SalesManRecoveryReport/salesmanRecoveryReportDetail.dart';


class SaleManRecoveryProvider extends ChangeNotifier {
  bool isLoading = false;
  String error = '';
  List<RecoveryEntry> recoveries = [];
  RecoverySummary? summary;

  Future<void> fetchRecoveries({String? date}) async {
    isLoading = true;
    error = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final selectedDate = date ??
          DateTime.now().toIso8601String().split('T').first;

      final url = Uri.parse(
          '${ApiEndpoints.baseUrl}/recoveries?date=$selectedDate');

      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "x-company-id": "2",
        "Cache-Control": "no-cache",
      });

      if (response.statusCode == 200 || response.statusCode == 304) {
        final json = jsonDecode(response.body);
        final result = RecoveryResponse.fromJson(json);
        recoveries = result.data.data;
        summary = result.data.summary;
      } else {
        error = "Failed: ${response.statusCode}";
      }
    } catch (e) {
      error = "Error: $e";
    }

    isLoading = false;
    notifyListeners();
  }
  // Add these inside SaleManRecoveryProvider

  List<SalesmanRecoveryDetailEntry> detailList = [];
  SalesmanRecoveryDetailSummary? detailSummary;
  bool isDetailLoading = false;

  Future<void> fetchSalesmanDetail({
    required int salesmanId,
    required String date,
  }) async {
    isDetailLoading = true;
    detailList = [];
    detailSummary = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse(
          '${ApiEndpoints.baseUrl}/recoveries/detail/$salesmanId?date=$date');

      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "x-company-id": "2",
        "Cache-Control": "no-cache",
      });

      if (response.statusCode == 200 || response.statusCode == 304) {
        final json = jsonDecode(response.body);
        final result = SalesmanRecoveryDetailResponse.fromJson(json);
        detailList = result.data.data;
        detailSummary = result.data.summary;
      } else {
        print("❌ Detail Failed: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Detail Error: $e");
    }

    isDetailLoading = false;
    notifyListeners();
  }
}