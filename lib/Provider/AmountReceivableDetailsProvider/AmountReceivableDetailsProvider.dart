import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../ApiLink/ApiEndpoint.dart';
import '../../model/AmountReceivableDetailsModel/AmountReceivableDetailsModel.dart';

class ReceivableProvider extends ChangeNotifier {
  AmountReceivableModel? receivableModel;

  bool isLoading = false;
  bool? withZero = false; // default: show with balance only
  String searchText = '';
  String token = "";

  Future<void> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";
  }

  Future<void> fetchReceivables() async {
    await loadToken();
    try {
      isLoading = true;
      notifyListeners();

      final url = Uri.parse(
        "${ApiEndpoints.baseUrl}/amount-receivables?withZero=${withZero ?? false}",
      );

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
      }
    } catch (e) {
      print("Error fetching receivables: $e");
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
}