

import 'dart:convert';

import 'package:demo_distribution/ApiLink/ApiEndpoint.dart';
import 'package:demo_distribution/model/setup/tax_Types_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;




  class TaxTypesProvider with ChangeNotifier {
  bool _isLoading = false;
  String _error = "";
  List<TaxModel> taxList = [];

  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchTax() async {
  try {
  _isLoading = true;
  notifyListeners();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  final response = await http.get(
  Uri.parse("${ApiEndpoints.baseUrl}/tax_types"),
  headers: {
  "Authorization": "$token",
  "Accept": "application/json"
  },
  );

  if (response.statusCode == 200) {
  final data = json.decode(response.body);

  List list = data['data']['data'];

  taxList = list.map((e) => TaxModel.fromJson(e)).toList();
  } else {
  _error = "Failed to fetch tax types";
  }
  } catch (e) {
  _error = e.toString();
  }

  _isLoading = false;
  notifyListeners();
  }
  }





