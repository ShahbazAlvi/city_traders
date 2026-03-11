import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ApiLink/ApiEndpoint.dart';
import '../../model/SaleManModel/EmployeesModel.dart';
import '../../model/SaleManModel/SaleManModel.dart';
import '../DashBoardProvider.dart';

class SaleManProvider with ChangeNotifier {
  List<SaleManModel> _salesmen = [];
  List<EmployeeData> _employees = [];
  bool _isLoading = false;
  String? _error;
  String? gender;


  List<SaleManModel> get salesmen => _salesmen;
  List<EmployeeData>get employees=>_employees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final TextEditingController nameController=TextEditingController();
  final TextEditingController phoneController=TextEditingController();

  Future<void> fetchEmployees() async {
    _isLoading = true;
    _error = "";
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final url = Uri.parse("${ApiEndpoints.baseUrl}/salesmen");
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "Cache-Control": "no-cache",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        if (response.body.isNotEmpty) {
          final dataJson = jsonDecode(response.body);
          final List<dynamic> jsonList = dataJson['data']['data'];
          _employees = jsonList.map((e) => EmployeeData.fromJson(e)).toList();
        }
      } else {
        _error = "Error Code: ${response.statusCode}";
      }
    } catch (e) {
      _error = "Error: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  // Future<void> fetchEmployees({bool refresh = false}) async {
  //   if (refresh) {
  //     _currentPage = 1;
  //     _employees.clear();
  //     _hasMore = true;
  //   }
  //
  //   if (!_hasMore || _isLoading) return;
  //
  //   _isLoading = true;
  //   _error = null;
  //   notifyListeners();
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString("token") ?? "";
  //
  //     final url = Uri.parse(
  //       "${ApiEndpoints.baseUrl}/salesmen?page=$_currentPage",
  //     );
  //
  //     final response = await http.get(
  //       url,
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer $token",
  //         "Cache-Control": "no-cache",
  //       },
  //     );
  //
  //     if (response.statusCode == 200 || response.statusCode == 304) {
  //       if (response.body.isNotEmpty) {
  //         final dataJson = jsonDecode(response.body);
  //
  //         // Handle pagination if available
  //         if (dataJson['data'] != null) {
  //           final List<dynamic> jsonList = dataJson['data']['data'] ?? [];
  //           final newEmployees = jsonList.map((e) => EmployeeData.fromJson(e)).toList();
  //
  //           _employees.addAll(newEmployees);
  //
  //           // Update pagination info if available
  //           if (dataJson['data']['total'] != null) {
  //             _totalCount = dataJson['data']['total'];
  //             _hasMore = _employees.length < _totalCount!;
  //           }
  //
  //           _currentPage++;
  //         }
  //       }
  //     } else {
  //       _error = "Failed to load employees: ${response.statusCode}";
  //     }
  //   } catch (e) {
  //     _error = "Connection error: $e";
  //   }
  //
  //   _isLoading = false;
  //   notifyListeners();
  // }
  //
  // Future<void> refreshEmployees() async {
  //   await fetchEmployees(refresh: true);
  // }
  //
  // @override
  // void dispose() {
  //   nameController.dispose();
  //   phoneController.dispose();
  //   super.dispose();
  // }


  /// ✅ Delete (You can plug API later)




  Future<void> deleteEmployee(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null) {
        _error = "No token found. Please login again.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse("${ApiEndpoints.baseUrl}/employees/$id");

      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        // Remove from list
        _employees.removeWhere((e) => e.id == id);

        // Refresh server list
        await fetchEmployees();
      } else {
        _error = "Delete failed: ${response.body}";
      }
    } catch (e) {
      _error = "Error: $e";
    }

    _isLoading = false;
    notifyListeners();
  }



  Future<void> createEmployee(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Get the token
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Token not found! Please login again.")),
      );
      return;
    }
    final url = Uri.parse("${ApiEndpoints.baseUrl}/salesmen");

    try {

      final body = {
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "is_active": 1
      };


      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Employee added successfully!")),
        );

        // Clear fields
        clearFields();
        fetchEmployees();
        final dashboardProvider =
        Provider.of<DashboardProvider>(context, listen: false);
        await dashboardProvider.fetch();// refresh list
        notifyListeners();
      } else {
        print("${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: ${response.body}")),
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error: $e")),
      );
    }
  }

  void clearFields() {
    nameController.clear();
    phoneController.clear();
    gender = "";
    notifyListeners();
  }
  Future<void> updateEmployee(String id, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token missing! Please login.")),
      );
      return;
    }

    final url = Uri.parse("${ApiEndpoints.baseUrl}/employees/$id");

    final body = {

      "employeeName": nameController.text.trim(),
      "mobile": phoneController.text.trim(),


      "isEnable": true
    };

    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Employee updated successfully!")),
        );

        fetchEmployees();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.body}")),
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
  void resetFields() {
    nameController.clear();
    phoneController.clear();
    notifyListeners();
  }


}
