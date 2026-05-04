import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../ApiLink/ApiEndpoint.dart';
import '../../model/AmountReceivableDetailsModel/AmountReceivableDetailsModel.dart';
import '../../utils/access_control.dart';

class ReceivableProvider extends ChangeNotifier {
  AmountReceivableModel? receivableModel;

  bool isLoading = false;
  bool? withZero = false; // default: show with balance only
  String searchText = '';
  String token = "";
  int? salesmanId;
  bool isAdmin = false;
  String? errorMessage;

  Future<void> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";
    
    // Use AccessControl to check if user is admin/owner
    isAdmin = await AccessControl.isAdmin();
    
    // Only set salesmanId from prefs if not an admin
    // For admins, we keep whatever is in salesmanId (allowing manual selection)
    if (!isAdmin) {
      salesmanId = prefs.getInt("salesman_id");
    }
  }

  Future<void> fetchReceivables() async {
    await loadToken();
    try {
      isLoading = true;
      notifyListeners();

      String urlStr = "${ApiEndpoints.baseUrl}/amount-receivables?withZero=${withZero ?? false}";
      
      if (salesmanId != null) {
        urlStr += "&salesman_id=$salesmanId";
      }
      
      print("Fetching receivables from: $urlStr"); // Debugging

      final url = Uri.parse(urlStr);

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        receivableModel =
            AmountReceivableModel.fromJson(json.decode(response.body));
        errorMessage = null;
      } else {
        errorMessage = "Server Error: ${response.statusCode}";
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error fetching receivables: $e");
      errorMessage = "Connection Error: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  /// ✅ Returns CustomerReceivable list (not invoices)
  List<CustomerReceivable> get filteredList {
    if (receivableModel == null) return [];

    return receivableModel!.data.customers.where((customer) {
      final matchSearch = customer.customerName
          .toLowerCase()
          .contains(searchText.toLowerCase());

      final matchZero = withZero == true
          ? true
          : customer.grandBalance > 0;

      return matchSearch && matchZero;
    }).toList();
  }

  /// ✅ Summary from API
  ReceivableSummary? get summary => receivableModel?.data.summary;

  void updateSearch(String value) {
    searchText = value;
    notifyListeners();
  }

  void updateWithZero(bool? value) {
    withZero = value;
    fetchReceivables();
  }

  void updateSalesmanId(int? id) {
    salesmanId = id;
    fetchReceivables();
  }
}