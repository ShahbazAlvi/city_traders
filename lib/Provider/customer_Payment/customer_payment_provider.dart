

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../ApiLink/ApiEndpoint.dart';
import '../../model/customer_payment_model/InvoicePaymentModel.dart';
import '../../model/customer_payment_model/customer_payment_model.dart';

class CustomerPaymentProvider with ChangeNotifier {
  bool _isLoading = false;
  String _error = "";

  bool get isLoading => _isLoading;
  String get error => _error;

  CustomerPaymentModel? paymentModel;
  List<CustomerInvoice> customerInvoices = [];
  bool invoiceLoading = false;

  Future<void> fetchCustomerPayments() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    // Build URL with salesman_id filter if user is a salesman
    final salesmanId = prefs.getInt('salesman_id');
    String url = '${ApiEndpoints.baseUrl}/customer-payments';
    if (salesmanId != null) {
      url += '?salesman_id=$salesmanId';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      paymentModel = CustomerPaymentModel.fromJson(jsonData);
    }

    _isLoading = false;
    notifyListeners();
  }

  String getNextPaymentNumber() {
    final list = paymentModel?.data.payments ?? [];
    if (list.isEmpty) return "CP-0001";
    final last = list.first.paymentNo;
    final number = int.parse(last.split('-').last);
    return "CP-${(number + 1).toString().padLeft(4, '0')}";
  }

  Future<void> fetchCustomerInvoices(int customerId) async {
    invoiceLoading = true;
    customerInvoices = [];
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse(
            "${ApiEndpoints.baseUrl}/customer-payments/customer-invoices/$customerId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        customerInvoices = CustomerInvoiceModel.fromJson(data).invoices;
      }
    } catch (e) {
      print("fetchCustomerInvoices error: $e");
    }

    invoiceLoading = false;
    notifyListeners();
  }

  Future<bool> submitCustomerPayment({
    required String paymentNo,
    required String paymentDate,
    required int customerId,
    required CustomerInvoice invoice,
    required double paymentAmount,
    required String status,
    required String paymentMode,
    int? bankId,
  }) async {
    _isLoading = true;
    _error = "";
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      // payment_balance = netTotal - paymentAmount
      final double balance = invoice.netTotal - paymentAmount;

      // Include salesman_id if user is a salesman
      final salesmanId = prefs.getInt('salesman_id');

      final Map<String, dynamic> body = {
        "payment_no": paymentNo,
        "payment_date": paymentDate,
        "customer_id": customerId,
        "invoice_id": invoice.id,
        "invoice_no": invoice.invNo,
        "invoice_type": invoice.sourceTable,
        "invoice_amount": invoice.netTotal,
        "payment_amount": paymentAmount,
        "payment_balance": balance,
        "payment_mode": paymentMode,
        "bank_id": bankId,
        "status": status,
        if (salesmanId != null) "salesman_id": salesmanId,
      };

      print("Submit Payment Body: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse("${ApiEndpoints.baseUrl}/customer-payments"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      print("Submit Response: $data");

      if (response.statusCode == 200 && data["success"] == true) {
        fetchCustomerPayments();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = data["message"] ?? "Payment failed";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Error: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}