import 'dart:convert';

import 'package:demo_distribution/ApiLink/ApiEndpoint.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/setup/payroll/Department.dart';

class DepartmentProvider with ChangeNotifier {
  bool _isLoading = false;
  String _error = "";
  List<DepartmentModel> _department= [];

  // getx
 bool get isLoading => _isLoading;
 String get error => _error;
 List<DepartmentModel> get department=>_department;

 Future<void>FetchDepartment()async{
   _isLoading= true;
   notifyListeners();
   try{
     final prefs= await SharedPreferences.getInstance();
     final token = prefs.getString('token');
     final response = await http.get(Uri.parse("${ApiEndpoints.baseUrl}/departments"),
     headers: {
       "Authorization": "$token",
       "Accept": "application/json"
     }
     );
     if(response.statusCode==200){
       final jsonData = json.decode(response.body);
       final List list = jsonData['data']['data'];
       _department =list.map((e)=>DepartmentModel.fromJson(e)).toList();
     }
     else{
       _error = "Failed to fetch data";
     }

   }catch(e){
     _error=e.toString();
   }
   _isLoading = false; // ✅ IMPORTANT
   notifyListeners(); // ✅ IMPORTANT

 }
}