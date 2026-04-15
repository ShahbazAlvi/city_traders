import 'dart:convert';

import 'package:demo_distribution/ApiLink/ApiEndpoint.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/setup/SalesAreasModel/SalesAreasModel.dart';

class SalesAreasProvider with ChangeNotifier {
  bool _isLoading= false;
  String _error= "";
  List<SalesAreaModel> _areas = [];
  
  //getx

bool get  isLoading => _isLoading;
String get error => _error;
  List<SalesAreaModel> get areas => _areas;

Future<void> fetchSalesAreas()async {
  _isLoading = true;
  notifyListeners();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");
  try{
    final response = await http.get(Uri.parse("${ApiEndpoints.baseUrl}/sales_areas"),
    headers: {
      "Authorization": "$token",
      "Accept": "application/json"
    });
    if(response.statusCode==200){
      final jsonData = json.decode(response.body);

      final List list = jsonData['data']['data'];
      _areas = list.map((e) => SalesAreaModel.fromJson(e)).toList();

    }else {
      _error = "Failed to fetch data";
    }
    
  }catch(e){
    _error = e.toString();
  }
  _isLoading = false;
  notifyListeners();
  
} 
  
  
}