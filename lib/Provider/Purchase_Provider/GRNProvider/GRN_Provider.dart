import 'dart:convert';
import 'package:demo_distribution/ApiLink/ApiEndpoint.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../model/Purchase_Model/GNRModel/GNR_Model.dart';
import 'GRN_services.dart';

class GRNProvider extends ChangeNotifier {

  List<GRNModel> grnList = [];
  bool isLoading = false;

  /// ✅ FETCH GRN DATA (This was missing)
  Future<void> getGRNData() async {
    isLoading = true;
    notifyListeners();

    try {
      grnList = await fetchGRN();
    } catch (e) {
      print("Error fetching GRN: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// ✅ API CALL
  Future<List<GRNModel>> fetchGRN() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse("${ApiEndpoints.baseUrl}/grns"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Cache-Control": "no-cache",
        },
      );

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        final List dataList = body["data"]["data"];

        return dataList
            .map((e) => GRNModel.fromJson(e))
            .toList();
      } else {
        throw Exception("Failed to load GRN data");
      }
    } catch (e) {
      print("Error in fetchGRN: $e");
      rethrow;
    }
  }
  Future<void>update()async{

  }

  /// ✅ DELETE RECORD (FIXED int TYPE)
  Future<void> deleteRecord(int id) async {
    bool success = await GRNApiService.deleteGRN(id.toString());

    if (success) {
      grnList.removeWhere((item) => item.id == id);
      notifyListeners();
    }
  }

  /// ✅ ADD NEW GRN
  Future<bool> addNewGRN({
    required String supplierId,
    required String grnDate,
    required List<Map<String, dynamic>> products,
    required double totalAmount,
  }) async {

    bool success = await GRNApiService.addGRN(
      supplierId: supplierId,
      grnDate: grnDate,
      products: products,
      totalAmount: totalAmount,
    );

    if (success) {
      await getGRNData(); // refresh after add
    }

    return success;
  }
}