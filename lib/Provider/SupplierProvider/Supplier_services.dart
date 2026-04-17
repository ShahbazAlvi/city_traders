import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../ApiLink/ApiEndpoint.dart';
import '../../model/SupplierModel/SupplierModel.dart';


class SupplierApi {
  static final String baseUrl = "${ApiEndpoints.baseUrl}"; // example: https://yourapi.com/api

  /// ✅ Fetch Supplier List
  static Future<List<SupplierModel>> fetchSuppliers() async {
    final response = await http.get(Uri.parse("${ApiEndpoints.baseUrl}/suppliers"));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final List suppliersJson = body["data"]["data"] ?? [];
      print("Suppliers JSON: $suppliersJson");

      return suppliersJson.map((e) => SupplierModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load suppliers");
    }
  }


  /// ✅ Delete Supplier

  static Future<bool> deleteSupplier(String id) async {
    String? token = await TokenStorage.getToken();

    final response = await http.delete(
      Uri.parse("$baseUrl/suppliers/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("🟢 DELETE Status: ${response.statusCode}");
    print("🟡 DELETE Response: ${response.body}");

    return response.statusCode == 200;
  }

  /// ✅ Update Supplier
  static Future<bool> updateSupplier({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String paymentTerms,
  }) async {
    String? token = await TokenStorage.getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/suppliers/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "supplierName": name,
        "email": email,
        "contactNumber": phone,
        "address": address,
        "paymentTerms": paymentTerms,
      }),
    );

    return response.statusCode == 200;
  }



  static Future<int> fetchSupplierAging(int supplierId) async {
    try {
      String? token = await TokenStorage.getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/suppliers/$supplierId/aging"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return int.tryParse(body["data"]["aging_days"].toString()) ?? 0;
      }
    } catch (e) {
      print("Error in fetchSupplierAging: $e");
    }
    return 0;
  }

}



class TokenStorage {
  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    print("🔐 Token Saved: $token");
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }
}

