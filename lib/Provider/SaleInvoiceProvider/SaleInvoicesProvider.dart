import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ApiLink/ApiEndpoint.dart';
import '../../model/SaleInvoiceModel/InvoiceOrderUpdate.dart';
import '../../model/SaleInvoiceModel/SaleInvocieModel.dart';
import '../../model/SaleInvoiceModel/SaleInvoiceDetailsModel.dart';

class SaleInvoicesProvider with ChangeNotifier {
  bool isLoading = false;
  String? error;
  SaleInvoiceModel? orderData;

  String? token;

  // ✅ Load token from SharedPreferences
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
  }

// SaleInvoicesProvider.dart mein yeh getter add karo
  List<dynamic> getFilteredInvoices(String? salesmanId) {
    if (orderData == null) return [];
    if (salesmanId == null) return orderData!.invoices; // Admin: sab

    return orderData!.invoices.where((invoice) {
      return invoice.salesmanId?.toString() == salesmanId;
    }).toList();
  }



  Future<void> fetchOrders({String? date, String? salesmanId}) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await loadToken();

      if (token == null) {
        error = "Token not found";
        return;
      }

      String url = "${ApiEndpoints.baseUrl}/sales-invoices-notax";

      Map<String, String> params = {};
      if (date != null && date.isNotEmpty) params['date'] = date;
      if (salesmanId != null && salesmanId.isNotEmpty) {
        params['salesmanId'] = salesmanId;
      }

      if (params.isNotEmpty) {
        url += "?" + Uri(queryParameters: params).query;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "x-company-id": "2",
          "Cache-Control": "no-cache",
          "Pragma": "no-cache",
        },
      );

      if (response.statusCode == 200) {
        orderData = SaleInvoiceModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode != 304) {
        error = "Server Error: ${response.statusCode}";
      }

    } catch (e) {
      error = "Exception: $e";
    }

    isLoading = false;
    notifyListeners();
  }



  SingleOrderData? _selectedOrder;
  SingleOrderData? get selectedOrder => _selectedOrder;

  Future<void> fetchSingleOrder(int orderId) async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        error = "Token not found!";
        isLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse('${ApiEndpoints.baseUrl}/sales-orders/$orderId');
      final response = await http.get(url, headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "x-company-id": "2",
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _selectedOrder = SingleOrderModel.fromJson(data).data;
        error = null;
      } else {
        error = "Failed to fetch order (${response.statusCode})";
      }
    } catch (e) {
      error = "Error: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

// Function to update order (send edited details)
  Future<void> updateSelectedOrder() async {
    if (_selectedOrder == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final url = Uri.parse("${ApiEndpoints.baseUrl}/sales-orders/${_selectedOrder!.id}");

      // Map details
      final details = _selectedOrder!.details.map((e) => {
        "id": e.id,
        "qty": e.qty,
        "rate": e.rate,
      }).toList();

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"details": details}),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Order updated successfully");
        error = null;
        await fetchSingleOrder(_selectedOrder!.id); // refresh
      } else {
        error = "Failed to update: ${response.statusCode}";
      }
    } catch (e) {
      error = "Error updating: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  // Add import at top


// Add inside the class
  SaleInvoiceDetailData? _selectedInvoice;
  SaleInvoiceDetailData? get selectedInvoice => _selectedInvoice;

  void clearSelectedInvoice() {
    _selectedInvoice = null;
    notifyListeners();
  }

  Future<void> fetchSingleInvoice(int invoiceId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        error = "Token not found!";
        isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/sales-invoices-notax/$invoiceId'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "x-company-id": "2",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _selectedInvoice = SaleInvoiceDetailModel.fromJson(data).data;
        error = null;
      } else {
        error = "Failed to fetch invoice (${response.statusCode})";
      }
    } catch (e) {
      error = "Error: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<void> deleteInvoice(int invoiceId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.delete(
        Uri.parse("${ApiEndpoints.baseUrl}/sales-invoices-notax/$invoiceId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "x-company-id": "2",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint("✅ Invoice deleted");
        await fetchOrders(); // refresh list
      } else {
        final res = jsonDecode(response.body);
        error = res["message"] ?? "Failed to delete (${response.statusCode})";
      }
    } catch (e) {
      error = "Error deleting: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }








}
