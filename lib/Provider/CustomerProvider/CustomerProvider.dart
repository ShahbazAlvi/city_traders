import 'dart:convert';

import 'package:demo_distribution/model/CustomerModel/CustomerModel.dart';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart'as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ApiLink/ApiEndpoint.dart';
import '../../model/AmountReceivableDetailsModel/AmountReceivableDetailsModel.dart';
import '../../model/CustomerModel/CustomersDefineModel.dart';
import '../DashBoardProvider.dart';

 class CustomerProvider with ChangeNotifier{


  List<CustomerModel>_customer=[];

  List<CustomerData> _customers = [];
  String searchText = '';


  bool _isLoading=false;
  String? _error;

  // gets
List<CustomerModel> get customer=>_customer;
  List<CustomerData> get customers => _customers;
bool get isLoading=>_isLoading;
  String? get error => _error;



  final TextEditingController AreaNameController=TextEditingController();
  final TextEditingController CustomerNameController=TextEditingController();
  final TextEditingController ContactNumberController=TextEditingController();
  final TextEditingController AddressController=TextEditingController();
  final TextEditingController OpeningBalanceController=TextEditingController();
  final TextEditingController CreditDaysLimitController=TextEditingController();
  final TextEditingController CreditCashLimitController=TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController EmailController=TextEditingController();
  final TextEditingController SubAreaController=TextEditingController();





// Add this getter inside CustomerProvider class:

   List<CustomerData> _salesmanFilteredCustomers = [];

   /// Call this once after fetchCustomers() to apply salesman filter.
   Future<void> applyAccessFilter() async {
     final prefs = await SharedPreferences.getInstance();
     final salesmanId = prefs.containsKey('salesman_id')
         ? prefs.getInt('salesman_id')
         : null;

     if (salesmanId == null) {
       // Admin: show all customers
       _salesmanFilteredCustomers = List.from(_customers);
     } else {
       // Salesman: show only their assigned customers
       _salesmanFilteredCustomers = _customers
           .where((c) => c.salesmanId == salesmanId)
           .toList();
     }
     notifyListeners();
   }

   List<CustomerData> get accessFilteredCustomers => _salesmanFilteredCustomers;







  Future<void> fetchCustomers() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final salesmanId = prefs.getInt('salesman_id');
      final assignedAreaIds = prefs.getStringList('assigned_area_ids');

      if (token == null) {
        _error = "Token not found. Please login again.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Build URL with salesman_id and assigned areas filter (Server-side filtering)
      String url = '${ApiEndpoints.baseUrl}/customers';
      List<String> queryParams = [];

      // Add params only if they have values
      if (salesmanId != null) {
        queryParams.add('salesman_id=$salesmanId');
      }

      if (assignedAreaIds != null && assignedAreaIds.isNotEmpty) {
        queryParams.add('sales_area_ids=${assignedAreaIds.join(',')}');
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      print("CUSTOMERS API => $jsonData");

      if (response.statusCode == 200 && jsonData["success"] == true) {
        final List list = jsonData["data"]["data"] ?? [];
        _customers = list.map((e) => CustomerData.fromJson(e)).toList();
        
        // Update filtered list for UI (No notifyListeners inside _applyInternalAccessFilter for now)
        await _applyInternalAccessFilter(); 
      } else {
        _error = jsonData["message"] ?? "Failed to load customers";
      }
    } catch (e) {
      _error = "Error: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Internal filter application without notifyListeners
  Future<void> _applyInternalAccessFilter() async {
    final prefs = await SharedPreferences.getInstance();
    final salesmanId = prefs.getInt('salesman_id');

    if (salesmanId == null) {
      _salesmanFilteredCustomers = List.from(_customers);
    } else {
      _salesmanFilteredCustomers = _customers
          .where((c) => c.salesmanId == salesmanId)
          .toList();
    }
  }



  // get token sharePerference
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("auth_token");
    print("TOKEN => $token");

  }



  /// Compute the next auto-incremented customer code from the existing list.
  String _getNextCustomerCode() {
    int maxCode = 0;
    for (final c in _customers) {
      final parsed = int.tryParse(c.code ?? '0') ?? 0;
      // Only consider valid 4-digit codes (0001 - 9999)
      if (parsed > maxCode && parsed <= 9999) {
        maxCode = parsed;
      }
    }
    final nextCode = maxCode + 1;
    final result = nextCode.toString().padLeft(4, '0');
    print("AUTO CODE => maxCode: $maxCode, nextCode: $result");
    return result;
  }

  // Customers add
  Future<bool> addCustomer({
    required BuildContext context,
    required String paymentType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _error = "Token not found!";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Ensure customers are loaded so we can compute the next code
    if (_customers.isEmpty) {
      await fetchCustomers();
    }

    final nextCode = _getNextCustomerCode();
    final nextCoaCode = "01-01-01-$nextCode";

    final url = Uri.parse("${ApiEndpoints.baseUrl}/customers");

    final body = {
      "code": nextCode,
      "coa_code": nextCoaCode,
      "name": CustomerNameController.text.trim(),
      "phone": ContactNumberController.text.trim(),
      "email": EmailController.text.trim(), // add EmailController to form
      "address": AddressController.text.trim(),
      "paymentTerms": paymentType == "credit" ? "Credit" : "Cash",
      "aging_days": int.tryParse(CreditDaysLimitController.text) ?? 0,
      "credit_limit": int.tryParse(CreditCashLimitController.text) ?? 0,
      "opening_balance": int.tryParse(OpeningBalanceController.text) ?? 0,
      "opening_date": DateTime.now().toIso8601String().split('T').first,
      "is_active": 1,
      "sales_area_id": int.tryParse(AreaNameController.text) ?? 0,
      "sales_sub_area_id": int.tryParse(SubAreaController.text) ?? 0, // add SubAreaController to form
    };

    print("SEND BODY => $body"); // Debug

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      print("API RESPONSE => ${response.body}"); // Debug

      if (response.statusCode == 201 || response.statusCode == 200) {
        clearForm();
        fetchCustomers();

        final dashboardProvider =
        Provider.of<DashboardProvider>(context, listen: false);
        await dashboardProvider.fetch();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = "Failed: ${response.body}";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearForm() {
    AreaNameController.clear();
    CustomerNameController.clear();
    ContactNumberController.clear();
    AddressController.clear();
    OpeningBalanceController.clear();
    CreditDaysLimitController.clear();
    CreditCashLimitController.clear();
    dateController.clear();
    EmailController.clear();

    notifyListeners();
  }



  Future<bool> DeleteCustomer(String idCustomer, DashboardProvider dashProvider) async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final url = Uri.parse("${ApiEndpoints.baseUrl}/customers/$idCustomer");
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Customer deleted successfully");

        // Re-fetch customers
        await fetchCustomers();

        // ⭐ Refresh dashboard immediately
        await dashProvider.fetch();
  
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = "Failed to delete: ${response.statusCode} - ${response.body}";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Error deleting: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }



  Future<bool> updateCustomer({
    required String id,
    required String salesmanId,
    required String paymentType,
    required String openingBalanceDate,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final url = Uri.parse("${ApiEndpoints.baseUrl}/customers/$id");

      final body = {
        "salesArea": AreaNameController.text,
        "customerName": CustomerNameController.text,
        "address": AddressController.text,
        "creditLimit": CreditCashLimitController.text,
        "creditTime": CreditDaysLimitController.text,
        "openingBalanceDate": openingBalanceDate,
        "paymentTerms": paymentType,
        "phoneNumber": ContactNumberController.text,
        "salesBalance": OpeningBalanceController.text,
        "salesman": salesmanId,
      };

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
        fetchCustomers();
        notifyListeners();
        return true;
      } else {
        _error = response.body;
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void updateSearch(String value) {
    searchText = value;
    notifyListeners();
  }

  // Add this getter to CustomerProvider

  List<CustomerData> get filteredCustomers {
    if (searchText.isEmpty) return _customers;
    return _customers
        .where((c) =>
    c.name.toLowerCase().contains(searchText.toLowerCase()) ||
        c.phone.contains(searchText))
        .toList();
  }





}
