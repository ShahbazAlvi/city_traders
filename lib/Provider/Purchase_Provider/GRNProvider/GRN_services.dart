
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../ApiLink/ApiEndpoint.dart';
import '../../../model/Purchase_Model/GNRModel/GNR_Model.dart';

class GRNApiService {
  static final String baseUrl = "${ApiEndpoints.baseUrl}"; // from your ApiEndpoint.dart

  /// ✅ Fetch All GRN Records
  static Future<List<GRNModel>> fetchGRN() async {
    final response = await http.get(Uri.parse("$baseUrl/grn"));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (body["data"] as List)
          .map((e) => GRNModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to load GRN data");

    }
  }

  /// ✅ Delete GRN Record
  // static Future<bool> deleteGRN(String id) async {
  //   final response = await http.delete(Uri.parse("$baseUrl/deleteGRN/$id"));
  //   return response.statusCode == 200;
  // }
  static Future<bool> deleteGRN(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse("$baseUrl/grn/$id");

      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print("DELETE URL = $url");
      print("RESPONSE STATUS = ${response.statusCode}");
      print("RESPONSE BODY = ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Error in deleteGRN: $e");
      return false;
    }
  }


  /// ✅ Add New GRN Record
  static Future<bool> addGRN({
    required String grnNo,
    required int supplierId,
    required String grnDate,
    required int locationId,
    required String status,
    required double discount,
    required List<Map<String, dynamic>> details,
  }) async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final body = {
      "grn_no": grnNo,
      "supplier_id": supplierId,
      "grn_date": grnDate,
      "location_id": locationId,
      "status": status,
      "discount": discount,
      "details": details
    };

    print("REQUEST BODY: ${jsonEncode(body)}");

    final response = await http.post(
      Uri.parse("${ApiEndpoints.baseUrl}/grns"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: jsonEncode(body),
    );

    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    return false;
  }

  /// ✅ Fetch Single GRN Detail
  static Future<GRNDetailModel?> fetchSingleGRN(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/grns/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print("GET SINGLE GRN URL = ${ApiEndpoints.baseUrl}/grns/$id");
      print("RESPONSE STATUS = ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return GRNDetailModel.fromJson(body["data"]);
      }
    } catch (e) {
      print("Error in fetchSingleGRN: $e");
    }
    return null;
  }

  /// ✅ Update GRN Record
  static Future<bool> updateGRN(int id, Map<String, dynamic> body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      print("UPDATE GRN BODY: ${jsonEncode(body)}");

      final response = await http.put(
        Uri.parse("${ApiEndpoints.baseUrl}/grns/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode(body),
      );

      print("UPDATE STATUS CODE: ${response.statusCode}");
      print("UPDATE RESPONSE: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Error in updateGRN: $e");
      return false;
    }
  }

}
