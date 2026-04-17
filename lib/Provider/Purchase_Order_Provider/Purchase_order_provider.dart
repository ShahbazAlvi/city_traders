
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../ApiLink/ApiEndpoint.dart';
import '../../model/Purchase_Order_Model/Purchase_order_Model.dart';
import '../../model/Purchase_Order_Model/purchaseOrderDetails.dart';

class PurchaseOrderProvider with ChangeNotifier {
  List<PurchaseOrder> _orders = [];
  bool _isLoading = false;
  String? _error;


  // Gets
  List<PurchaseOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;


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
    required List<Map<String, dynamic>> products, required DateTime selectedDate,
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


      final String poDate = selectedDate.toIso8601String().substring(0, 10);// "yyyy-MM-dd"

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

  // In Provider: add a separate flag
  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  Future<bool> deletePurchaseOrder(int orderId) async {
    _isDeleting = true;        // ← separate flag, NOT _isLoading
    _error = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        _error = 'Token is null, please login again';
        return false;
      }

      final response = await http.delete(
        Uri.parse('${ApiEndpoints.baseUrl}/purchase-orders/$orderId'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "x-company-id": "2",
        },
      );

      if (response.statusCode == 200) {
        // Remove locally instead of re-fetching to avoid _isLoading conflict
        _orders.removeWhere((o) => o.id == orderId);
        return true;
      } else {
        _error = "Failed to delete: ${response.statusCode}";
        return false;
      }

    } catch (e) {
      _error = "Error deleting order: $e";
      return false;
    } finally {
      _isDeleting = false;     // ← only this flag changes
      notifyListeners();
    }
  }
  // Add import at top


// Add inside the class
  PurchaseOrderDetailData? _selectedOrder;
  PurchaseOrderDetailData? get selectedOrder => _selectedOrder;

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  // Add this field
  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;

// Replace fetchSinglePurchaseOrder — use _isDetailLoading instead of _isLoading
  Future<void> fetchSinglePurchaseOrder(int orderId) async {
    _isDetailLoading = true;   // ✅ separate flag — does NOT affect list screen
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        _error = "Token not found!";
        _isDetailLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/purchase-orders/$orderId'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "x-company-id": "2",
          "Cache-Control": "no-cache",
          "Pragma": "no-cache",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _selectedOrder = PurchaseOrderDetailModel.fromJson(data).data;
        _error = null;
      } else if (response.statusCode == 304 && _selectedOrder != null) {
        // cached — do nothing
      } else {
        _error = "Failed to fetch order (${response.statusCode})";
      }
    } catch (e) {
      _error = "Error: $e";
    } finally {
      _isDetailLoading = false;  // ✅
      notifyListeners();
    }
  }

  // Replace updatePurchaseOrder — use _isDetailLoading instead of _isLoading
  Future<bool> updatePurchaseOrder({
    required int orderId,
    required String poNo,
    required int supplierId,
    required String status,
    required DateTime poDate,
    required double taxPercent,
    String? remarks,
    required List<Map<String, dynamic>> details,
  }) async {
    _isDetailLoading = true;   // ✅ won't freeze list screen
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        _error = "Token not found!";
        _isDetailLoading = false;
        notifyListeners();
        return false;
      }

      final body = {
        "po_no": poNo,
        "supplier_id": supplierId,
        "po_date": poDate.toIso8601String().substring(0, 10),
        "status": status,
        "tax_percent": taxPercent,
        "remarks": remarks,
        "details": details,
      };

      debugPrint("📦 Update PO Body: ${jsonEncode(body)}");

      final response = await http.put(
        Uri.parse('${ApiEndpoints.baseUrl}/purchase-orders/$orderId'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "x-company-id": "2",
        },
        body: jsonEncode(body),
      );

      debugPrint("📡 Status: ${response.statusCode}");
      debugPrint("📡 Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPurchaseOrder();
        return true;
      } else {
        final res = jsonDecode(response.body);
        _error = res["message"] ?? "Failed (${response.statusCode})";
        return false;
      }
    } catch (e) {
      _error = "Error: $e";
      return false;
    } finally {
      _isDetailLoading = false;  // ✅
      notifyListeners();
    }
  }
// In PurchaseOrderProvider — add separate edit state
  PurchaseOrderDetailData? _editOrder;
  PurchaseOrderDetailData? get editOrder => _editOrder;
  bool _isEditLoading = false;
  bool get isEditLoading => _isEditLoading;

  Future<void> fetchOrderForEdit(int orderId) async {
    _isEditLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) { _isEditLoading = false; notifyListeners(); return; }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/purchase-orders/$orderId'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "x-company-id": "2",
          "Cache-Control": "no-cache",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _editOrder = PurchaseOrderDetailModel.fromJson(data).data;
      } else {
        _error = "Failed (${response.statusCode})";
      }
    } catch (e) {
      _error = "Error: $e";
    } finally {
      _isEditLoading = false;
      notifyListeners();
    }
  }

  void clearEditOrder() {
    _editOrder = null;
  }


}