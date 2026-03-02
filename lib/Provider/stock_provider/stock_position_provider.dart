// import 'dart:convert';
// import 'package:demo_distribution/ApiLink/ApiEndpoint.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../model/stock/stock_position.dart';
//
//
//
// class StockPositionProvider with ChangeNotifier {
//   bool loading = false;
//   String message = "";
//   List<StockItem> stockList = [];
//
//   Future<void> fetchStockPosition() async {
//     loading = true;
//     notifyListeners();
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString("token");
//
//       final response = await http.get(
//         Uri.parse("${ApiEndpoints.baseUrl}/stock-position"),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//           "x-company-id": "2",
//         },
//       );
//
//       final data = jsonDecode(response.body);
//
//       if (response.statusCode == 200 && data["success"] == true) {
//         // In fetchStockPosition(), replace:
//         final model = StockPositionModel.fromJson(data);
//         stockList = model.data.items;   // ← this breaks because data is null
//
// // With:
//         final model = StockPositionModel.fromJson(data);
//         stockList = model.items;
//
//       } else {
//         message = data["message"] ?? "Failed to fetch stock";
//       }
//     } catch (e) {
//       message = e.toString();
//     }
//
//     loading = false;
//     notifyListeners();
//   }
// }
//
import 'dart:convert';
import 'package:demo_distribution/ApiLink/ApiEndpoint.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/stock/stock_position.dart';

class StockPositionProvider with ChangeNotifier {
  bool loading = false;
  String message = "";
  List<StockItem> stockList = [];

  Future<void> fetchStockPosition() async {
    loading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/stock-position"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "x-company-id": "2",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        final model = StockPositionModel.fromJson(data);
        stockList = model.items;
        message = model.message;
      } else {
        message = data["message"] ?? "Failed to fetch stock";
      }
    } catch (e) {
      message = e.toString();
    }

    loading = false;
    notifyListeners();
  }
}