
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../ApiLink/ApiEndpoint.dart';
import '../../model/Purchase_Order_Model/Purchase_order_Model.dart';

class PurchaseOrderProvider with ChangeNotifier {
  List<PurchaseOrder> _orders = [];
  bool _isLoading = false;
  String _error = '';

  // Gets
  List<PurchaseOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchPurchaseOrder() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) {
        _error = 'token is null';
        _isLoading = false;
        notifyListeners();
        return;
      }
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/purchase-orders'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "x-company-id": "2",
          "Cache-Control": "no-cache",
        },
      );
      final data = jsonDecode(response.body);
      print(data);

      PurchaseOrderResponse poResponse = PurchaseOrderResponse.fromJson(data);
      _orders = poResponse.orders;
    } catch (e) {
      _error = "Error fetching orders: $e";
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addPurchaseOrder({
    required String poNo,
    required int supplierId,
    required String status,
    required List<Map<String, dynamic>> products,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        _error = 'Token is null, please login again';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final String poDate =
      DateTime.now().toIso8601String().substring(0, 10); // "yyyy-MM-dd"

      /// BUILD BODY matching API format:
      /// { po_no, supplier_id, po_date, status, details: [{item_id, qty, rate}] }
      final Map<String, dynamic> body = {
        "po_no": poNo,
        "supplier_id": supplierId,
        "po_date": poDate,
        "status": status,
        "details": products, // [{"item_id": 33, "qty": 12, "rate": 1200}]
      };

      print("PO Body: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/purchase-orders'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "x-company-id": "2",
        },
        body: jsonEncode(body),
      );

      print("PO Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPurchaseOrder(); // refresh list
        return true;
      } else {
        _error = "Failed: ${response.statusCode} - ${response.body}";
        return false;
      }
    } catch (e) {
      _error = "Error adding order: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}