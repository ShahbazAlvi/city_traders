import 'dart:convert';

import 'package:demo_distribution/ApiLink/ApiEndpoint.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/setup/payroll/EmployeeSalemanModel.dart';



class EmployeeProvider with ChangeNotifier{
  bool _isLoading =false;
  String  _error = "";
  List<EmployeeSalesmanModel> _designation=[];

  // getx
  bool get  isLoading => _isLoading;
  String get error => _error;
  List<EmployeeSalesmanModel> get designation=> _designation;


  Future<void> fetchEmployee() async {
    bool isLoading = true;
    notifyListeners();
    try{
      final prefs= await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(Uri.parse("${ApiEndpoints.baseUrl}/employees"),
          headers:  {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          });
      if(response.statusCode==200){
        final jsonData = json.decode(response.body);
        final List list = jsonData['data']['data'];
        _designation = list.map((e)=>EmployeeSalesmanModel.fromJson(e)).toList();

      }
      else {
        _error = "Failed (${response.statusCode})";
      }

    }catch(e){
      _error= e.toString();
    }
    _isLoading = false; // ✅ IMPORTANT
    notifyListeners();  // ✅ IMPORTANT
  }
}