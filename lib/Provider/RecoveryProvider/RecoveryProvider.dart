// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../ApiLink/ApiEndpoint.dart';
// import '../../model/SaleRecoveryModel/RecoveryCustomerInvoice.dart';
// import '../../model/SaleRecoveryModel/SaleRecoveryModel.dart';
//
//
//
// class RecoveryProvider extends ChangeNotifier {
//   bool isLoading = false;
//   bool isUpdating = false;
//
//   RecoveryReport? recoveryReport;
//
//   RecoveryReport? recoveryData;
//   String token = "";
//
//   String baseUrl = "${ApiEndpoints.baseUrl}";
//
//   /// ✅ Load Token Automatically
//   Future<void> loadToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     token = prefs.getString("token") ?? "";
//   }
//
//   /// ✅ Fetch Recovery Report
//   Future<void> fetchRecoveryReport() async {
//     await loadToken(); // ✅ Auto load token
//
//     try {
//       isLoading = true;
//       notifyListeners();
//
//       final url = Uri.parse(
//           //"$baseUrl/sales-invoice/recovery-report?salesmanId=$salesmanId&recoveryDate=$date");
//         "$baseUrl/recovery-vouchers");
//
//       final response = await http.get(
//         url,
//         headers: {"Authorization": "Bearer $token"},
//       );
//
//       if (response.statusCode == 200) {
//         print(response.body);
//         final jsonData = json.decode(response.body);
//         recoveryReport = RecoveryReport.fromJson(jsonData);
//       }
//
//       isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       print(e);
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   /// ✅ Update Received Amount (PATCH)
//
//
//
//
//   Future<String?> updateReceivedAmount(String invoiceId, String receivedAmount) async {
//     await loadToken();
//
//     try {
//       isUpdating = true;
//       notifyListeners();
//
//       var url = Uri.parse("$baseUrl/recovery");
//
//       var body = jsonEncode({
//         "invoiceId": invoiceId,
//         "amount": double.parse(receivedAmount),
//       });
//
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//         body: body,
//       );
//
//       print("Response body: ${response.body}");
//
//       isUpdating = false;
//       notifyListeners();
//
//       if (response.statusCode == 201 || response.statusCode == 200) {
//         final json = jsonDecode(response.body);
//         return json["message"]; // <-- return success message
//       }
//
//       return null;
//     } catch (e) {
//       isUpdating = false;
//       notifyListeners();
//       return null;
//     }
//   }
//
//
//   Future<String?> addRecovery({
//     required String orderId,
//     required String salesmanId,
//     required String customerId,
//     required String bankId,
//     required String amount,
//     required String recoveryDate, // Pass date in "YYYY-MM-DD"
//     required String mode,         // e.g., "BANK"
//   }) async {
//     await loadToken();
//
//     try {
//       isLoading = true;
//       notifyListeners();
//
//       final url = Uri.parse("$baseUrl/recovery-vouchers");
//
//       final body = jsonEncode({
//         "rv_no": orderId,
//         "salesman_id": int.parse(salesmanId),
//         "customer_id": int.parse(customerId),
//         "bank_id": int.parse(bankId),
//         "amount": double.parse(amount),
//         "recovery_date": recoveryDate,
//         "mode": mode,
//         "status": "DRAFT",
//       });
//
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//         body: body,
//       );
//
//       print("Add Recovery Response: ${response.body}");
//
//       isLoading = false;
//       notifyListeners();
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final jsonData = jsonDecode(response.body);
//         return jsonData["message"] ?? "Recovery added successfully";
//       } else {
//         return "Failed to add recovery: ${response.statusCode}";
//       }
//     } catch (e) {
//       isLoading = false;
//       notifyListeners();
//       return "Error: $e";
//     }
//   }
//
//
//
//   // In CustomerPaymentProvider
//
//   List<CustomerInvoice> customerInvoices = [];
//
//   Future<void> fetchCustomerInvoices(int customerId) async {
//     isLoading = true;
//     customerInvoices = [];
//     notifyListeners();
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString("token");
//
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//
//       final response = await http.get(
//         Uri.parse(
//           "${ApiEndpoints.baseUrl}/recovery-vouchers/customer-invoices/$customerId?recovery_date=$today",
//         ),
//         headers: {
//           "Authorization": "Bearer $token",
//           "Content-Type": "application/json",
//         },
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 304) {
//         final data = jsonDecode(response.body);
//         final List list = data['data']['data'];
//         customerInvoices = list.map((e) => CustomerInvoice.fromJson(e)).toList();
//       }
//     } catch (e) {
//       print("fetchCustomerInvoices error: $e");
//     }
//
//     isLoading = false;
//     notifyListeners();
//   }
//
//
// }


// Provider/RecoveryProvider/RecoveryProvider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ApiLink/ApiEndpoint.dart';
import '../../model/SaleRecoveryModel/RecoveryCustomerInvoice.dart';
import '../../model/SaleRecoveryModel/SaleRecoveryModel.dart';

class RecoveryProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isUpdating = false;

  RecoveryReport? recoveryReport;
  RecoveryReport? recoveryData;
  String token = "";
  String baseUrl = ApiEndpoints.baseUrl;

  List<CustomerInvoice> customerInvoices = [];

  Future<void> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";
  }

  Future<void> fetchRecoveryReport() async {
    await loadToken();
    try {
      isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse("$baseUrl/recovery-vouchers"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        recoveryReport = RecoveryReport.fromJson(jsonData);
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCustomerInvoices(int customerId) async {
    await loadToken();
    isLoading = true;
    customerInvoices = [];
    notifyListeners();

    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await http.get(
        Uri.parse(
          "$baseUrl/recovery-vouchers/customer-invoices/$customerId?recovery_date=$today",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        final data = jsonDecode(response.body);
        final List list = data['data']['data'];
        customerInvoices = list.map((e) => CustomerInvoice.fromJson(e)).toList();
      }
    } catch (e) {
      print("fetchCustomerInvoices error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ CASH: bank_id = null
  /// ✅ BANK: bank_id = selected bank id
  Future<String?> addRecovery({
    required String rvNo,
    required String salesmanId,
    required String customerId,
    required String? bankId,        // null when mode = CASH
    required String amount,
    required String recoveryDate,
    required String mode,           // "CASH" or "BANK"
    required String invoiceId,
    required String invoiceNo,
    required String invoiceType,    // "NOTAX" or "TAX"
    required String invoiceAmount,
    required String paymentBalance,
    required String? paymentDueDate,
  }) async {
    await loadToken();

    try {
      isLoading = true;
      notifyListeners();

      // ✅ Build body — bank_id only added when mode is BANK
      final Map<String, dynamic> body = {
        "rv_no": rvNo,
        "customer_id": int.parse(customerId),
        "salesman_id": int.parse(salesmanId),
        "recovery_date": recoveryDate,
        "mode": mode,
        "amount": double.parse(amount),
        "invoice_id": int.parse(invoiceId),
        "invoice_no": invoiceNo,
        "invoice_type": invoiceType,
        "invoice_amount": double.parse(invoiceAmount),
        "payment_balance": double.parse(paymentBalance),
        "status": "POSTED",
        // null fields — always send, backend handles null
        "bank_id": mode == "BANK" && bankId != null ? int.parse(bankId) : null,
        "payment_due_date": paymentDueDate,
      };

      print("Sending Recovery Body: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse("$baseUrl/recovery-vouchers"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      print("Add Recovery Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return jsonData["message"] ?? "Recovery added successfully";
      } else {
        return "Failed: ${response.statusCode} — ${response.body}";
      }
    } catch (e) {
      return "Error: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateReceivedAmount(String invoiceId, String receivedAmount) async {
    await loadToken();
    try {
      isUpdating = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse("$baseUrl/recovery"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "invoiceId": invoiceId,
          "amount": double.parse(receivedAmount),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)["message"];
      }
      return null;
    } catch (e) {
      return null;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }
}