import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../ApiLink/ApiEndpoint.dart';
import '../../../model/PayableAmountModel/PayaAmountModel.dart';

class PayableAmountProvider extends ChangeNotifier {

  bool isLoading = false;

  List<PayableAmountModel> payables = [];

  double totalGrandBalance = 0.0;

  Future<void> fetchPayables() async {
    final prefs= await SharedPreferences.getInstance();
    final token= prefs.getString("token");

    isLoading = true;
    notifyListeners();

    final url = "${ApiEndpoints.baseUrl}/amount-payables";

    try {

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Cache-Control": "no-cache"
        },
      );

      if (response.statusCode == 200) {

        final decoded = jsonDecode(response.body);

        final parsed = PayableAmountResponse.fromJson(decoded);

        payables = parsed.data;

        totalGrandBalance =
            decoded["data"]["summary"]["total_grand_balance"].toDouble();

      } else {
        debugPrint("API Error ${response.statusCode}");
      }

    } catch (e) {

      debugPrint("Error fetching payables: $e");

    }

    isLoading = false;
    notifyListeners();
  }
}