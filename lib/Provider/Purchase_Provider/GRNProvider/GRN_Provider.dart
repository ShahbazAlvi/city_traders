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
  GRNDetailModel? selectedGrnDetails;

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

  /// ✅ FETCH SINGLE GRN DETAIL
  Future<void> fetchGrnDetails(int id) async {
    isLoading = true;
    notifyListeners();

    selectedGrnDetails = await GRNApiService.fetchSingleGRN(id);

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

  Future<void> update() async {}

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
    required String grnNo,
    required int supplierId,
    required String grnDate,
    required int locationId,
    required List<Map<String, dynamic>> details,
    required double totalAmount,
    required List<Map<String, dynamic>> products,
  }) async {
    bool success = await GRNApiService.addGRN(
      grnNo: grnNo,
      supplierId: supplierId,
      grnDate: grnDate,
      locationId: locationId,
      status: "POSTED",
      discount: 0,
      details: details,
    );

    if (success) {
      await getGRNData();
    }

    return success;
  }

  /// ✅ UPDATE GRN
  Future<bool> updateGRN({
    required int id,
    required String grnNo,
    required int supplierId,
    required String grnDate,
    required int locationId,
    required String status,
    required String agingDueDate,
    required double discount,
    required double taxPercent,
    required List<Map<String, dynamic>> details,
  }) async {
    final body = {
      "grn_no": grnNo,
      "supplier_id": supplierId,
      "grn_date": grnDate,
      "location_id": locationId,
      "status": status,
      "aging_due_date": agingDueDate,
      "details": details,
      "discount": discount,
      "tax_percent": taxPercent,
    };

    bool success = await GRNApiService.updateGRN(id, body);

    if (success) {
      await getGRNData();
    }

    return success;
  }
}