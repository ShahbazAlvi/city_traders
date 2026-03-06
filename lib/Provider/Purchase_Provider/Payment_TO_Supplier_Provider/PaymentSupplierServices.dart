import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../ApiLink/ApiEndpoint.dart';
import '../../../model/Purchase_Model/paymentToSupplierModel/PaymentSupplierModel.dart';

class PaymentToSupplierApi {

  /// ✅ Fetch all payments
  static Future<List<PaymentToSupplierModel>> fetchPayments() async {
    final prefs= await SharedPreferences.getInstance();
    final token= prefs.getString("token");


    final response = await http.get(
      Uri.parse("${ApiEndpoints.baseUrl}/supplier-payments"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {

      final body = jsonDecode(response.body);

      /// ⚡ API structure: data → data
      List list = body["data"]["data"] ?? [];

      return list
          .map((e) => PaymentToSupplierModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to load payments");
    }
  }

  /// ✅ Delete payment
  static Future<bool> deletePayment(int id) async {

    final response = await http.delete(
      Uri.parse("${ApiEndpoints.baseUrl}/deleteSupplierPayment/$id"),
    );

    return response.statusCode == 200;
  }
}