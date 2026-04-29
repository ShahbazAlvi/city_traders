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

      final prefs = await SharedPreferences.getInstance();
      await loadToken();

      if (token == null) {
        error = "Token not found";
        isLoading = false;
        notifyListeners();
        return;
      }

      // Build URL with salesman_id and assigned areas filter (Server-side filtering)
      String url = "${ApiEndpoints.baseUrl}/sales-invoices-notax";
      List<String> queryParams = [];

      if (date != null && date.isNotEmpty) {
        queryParams.add('date=$date');
      }

      // Use provided salesmanId (from UI filter) OR from prefs (from login)
      final String? effectiveSalesmanId = salesmanId ?? prefs.getInt('salesman_id')?.toString();
      final List<String>? assignedAreaIds = prefs.getStringList('assigned_area_ids');

      if (effectiveSalesmanId != null && effectiveSalesmanId.isNotEmpty) {
        queryParams.add('salesman_id=$effectiveSalesmanId');
      }

      // Only apply area filters if using the logged-in user's context (i.e. not an admin override)
      if (salesmanId == null && assignedAreaIds != null && assignedAreaIds.isNotEmpty) {
        queryParams.add('sales_area_ids=${assignedAreaIds.join(',')}');
      }

      if (queryParams.isNotEmpty) {
        url += "?${queryParams.join('&')}";
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

      print("INVOICES API => $url");

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

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

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








  Future<void> fetchSingleLoadSheet(int loadId) async {
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

      final url = Uri.parse('${ApiEndpoints.baseUrl}/load-sheets/$loadId');
      final response = await http.get(url, headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "x-company-id": "2",
      });

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        final data = resData['data'];
        
        // Map Load Sheet to SingleOrderData format
        // Note: Load sheet might have multiple SOs, we take the first customer info if available
        int customerId = 0;
        String customerName = '';
        if (data['selected_sales_orders'] != null && (data['selected_sales_orders'] as List).isNotEmpty) {
          customerId = data['selected_sales_orders'][0]['customer_id'] ?? 0;
          customerName = data['selected_sales_orders'][0]['customer_name'] ?? '';
        }

        List<OrderDetail> details = (data['details'] as List? ?? []).map((item) {
          return OrderDetail(
            id: item['id'] ?? 0,
            itemId: item['item_id'] ?? 0,
            itemName: item['item_name'] ?? '',
            itemSku: item['item_sku'] ?? '',
            qty: double.tryParse(item['qty_loaded']?.toString() ?? '0') ?? 0,
            rate: 0.0, // Load sheet doesn't have rate, will be set in UI or fetched
            lineTotal: 0.0,
            unitId: item['unit_id'] ?? 0,
            unitName: item['unit_name'] ?? '',
          );
        }).toList();

        _selectedOrder = SingleOrderData(
          id: data['id'] ?? 0,
          soNo: data['load_no'] ?? '',
          customerId: customerId,
          customerName: customerName,
          salesmanId: data['salesman_id'] ?? 0,
          salesmanName: data['salesman_name'] ?? '',
          salesAreaId: data['sales_area_id'],
          orderDate: DateTime.parse(data['load_date'] ?? DateTime.now().toIso8601String()),
          status: data['status'] ?? '',
          createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String()),
          updatedAt: DateTime.parse(data['updated_at'] ?? DateTime.now().toIso8601String()),
          details: details,
        );
        error = null;
      } else {
        error = "Failed to fetch load sheet (${response.statusCode})";
      }
    } catch (e) {
      error = "Error: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> fetchNextInvoiceNo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/sales-invoices-notax/next-invoice-no"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "x-company-id": "2",
        },
      );

      debugPrint("📡 Next Invoice No Status: ${response.statusCode}");
      debugPrint("📡 Next Invoice No Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data']['next_invoice_no']?.toString();
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching next invoice no: $e");
    }
    return null;
  }
}
