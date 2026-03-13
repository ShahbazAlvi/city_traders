import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


import '../../../ApiLink/ApiEndpoint.dart';
import '../../../model/Purchase_Model/SupplierLedgerModel/SupplierLedgerModel.dart';

class SupplierLedgerProvider extends ChangeNotifier {
  bool loading = false;
  List<SupplierLedgerEntry> ledgerList = [];

  Future<void> fetchSupplierLedger({
    required String supplierId,
    required String fromDate,
    required String toDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    loading = true;
    ledgerList.clear();
    notifyListeners();

    try {

      final url = Uri.parse(
          "${ApiEndpoints.baseUrl}/supplier-ledger?supplier_id=$supplierId&from=$fromDate&to=$toDate");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Cache-Control": "no-cache",
        },
      );

      if (response.statusCode == 200) {

        final jsonData = jsonDecode(response.body);

        final data = SupplierLedgerDetailModel.fromJson(jsonData);

        ledgerList = data.data.entries;

      } else {
        print("❌ Failed: ${response.statusCode}");
      }

    } catch (e) {
      print("❌ Error fetching ledger: $e");
    }

    loading = false;
    notifyListeners();
  }
}
