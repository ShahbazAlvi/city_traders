import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ApiLink/ApiEndpoint.dart';
import '../../model/OrderTakingModel/DetailsOrderModel.dart';
import '../../model/OrderTakingModel/OrderTakingModel.dart';
import 'package:http/http.dart'as http;



class OrderTakingProvider with ChangeNotifier{
  bool _isFetched = false;
  bool _isLoading = false;
  OrderTakingModel? _orderData;
  String? _error;
  bool _isCreatingOrder = false;
  bool get isCreatingOrder => _isCreatingOrder;


  // gets

  bool get isLoading => _isLoading;
  OrderTakingModel? get orderData => _orderData;
  String? get error => _error;


  // Filtered orders for salesman
  List<dynamic> getFilteredOrders(String? salesmanId) {
    if (_orderData == null) return [];
    if (salesmanId == null) return _orderData!.data; // Admin: sab dikho

    return _orderData!.data.where((order) {
      return order.salesmanId?.toString() == salesmanId;
    }).toList();
  }


  Future<void> FetchOrderTaking() async {
    if (_isFetched) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        _error = "Token not found. Please login again.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Build URL with salesman_id filter if user is a salesman
      final salesmanId = prefs.getInt('salesman_id');
      String url = '${ApiEndpoints.baseUrl}/sales-orders';
      if (salesmanId != null) {
        url += '?salesman_id=$salesmanId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "x-company-id": "2",
          "Cache-Control": "no-cache",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _orderData = OrderTakingModel.fromJson(data);
        _isFetched = true;
        _error = null;
      }
      else if (response.statusCode == 304) {
        debugPrint("Data not modified (304)");
      }
      else {
        _error = "Failed to load orders (${response.statusCode})";
        debugPrint(response.body);
      }
    } catch (e) {
      _error = "Error fetching orders: $e";
    }

    _isLoading = false;
    notifyListeners();
  }


  Future<void> createOrder({
    required String orderId,
    required String salesmanId,
    required String customerId,
    required List<Map<String, dynamic>> products, required String status,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _error = "Token not found!";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse('${ApiEndpoints.baseUrl}/sales-orders');

      final body = jsonEncode({
        "so_no": orderId,
        "salesman_id": int.parse(salesmanId),
        "customer_id": int.parse(customerId),
        "status": status,
        "order_date": DateTime.now().toIso8601String().split('T').first,
        "details": products.map((item) => {
          "item_id": int.parse(item["product"].id.toString()),
          "qty": (item["qty"] as num).toDouble(),
          "rate": (item["price"] as num).toDouble(),
        }).toList(),
      });


      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,

      );
      print(body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Order created: ${response.body}");
        _isFetched = false;
        await FetchOrderTaking();
      } else {
        _error = "❌ Failed: ${response.statusCode} - ${response.body}";
        print(_error);
      }
    } catch (e) {
      _error = "Error: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Returns null on success, or an error message string on failure.
  Future<String?> deleteOrder(String orderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final url = Uri.parse("${ApiEndpoints.baseUrl}/sales-orders/$orderId");

      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Order deleted successfully");

        // Remove from local list immediately for instant UI refresh
        _orderData?.data.removeWhere((o) => o.id.toString() == orderId);

        _isLoading = false;
        notifyListeners();
        return null; // success
      } else {
        final errMsg = "Failed to delete: ${response.statusCode} - ${response.body}";
        debugPrint(errMsg);
        _isLoading = false;
        notifyListeners();
        return errMsg;
      }
    } catch (e) {
      final errMsg = "Error deleting: $e";
      debugPrint(errMsg);
      _isLoading = false;
      notifyListeners();
      return errMsg;
    }
  }

  Future<void> updateOrder(String orderId, Map<String, dynamic> body) async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final url = Uri.parse("${ApiEndpoints.baseUrl}/order-taker/$orderId");

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Order updated successfully");

        _isFetched = false;
        await FetchOrderTaking();
      } else {
        _error = "Failed to update: ${response.statusCode}";
      }
    } catch (e) {
      _error = "Error updating: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Single order detail ──────────────────────
  DetailsOrderData? _selectedOrder;
  DetailsOrderData? get selectedOrder => _selectedOrder;

  Future<void> fetchSingleOrder(int orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        _error = "Token not found!";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/sales-orders/$orderId'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "x-company-id": "2",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _selectedOrder = DetailsOrderModel.fromJson(data).data;
        _error = null;
      } else {
        _error = "Failed to fetch order (${response.statusCode})";
      }
    } catch (e) {
      _error = "Error: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }


  // Add this to OrderTakingProvider
  void resetFetch() {
    _isFetched = false;
  }







}