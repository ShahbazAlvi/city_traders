// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
//
// import '../ApiLink/ApiEndpoint.dart';
// import '../model/load_sheet_model/Loading_sheet_model.dart';
//
// // ── Import your existing widgets & providers ──────────────────────────────────
// // import '../../Widgets/SalesmanDropdown.dart';
// // import '../../Widgets/ItemDetailsDropdown.dart';
// // import '../../Provider/SaleManProvider/SaleManProvider.dart';
// // import '../../Provider/ProductProvider/ItemListsProvider.dart';
// // import '../../ApiLink/ApiEndpoint.dart';
//
// // ─────────────────────────────────────────────────────────────────────────────
// //  DATA MODELS
// // ─────────────────────────────────────────────────────────────────────────────
//
//
//
// // ─────────────────────────────────────────────────────────────────────────────
// //  LOAD SHEET PROVIDER
// // ─────────────────────────────────────────────────────────────────────────────
//
// class LoadSheetProvider with ChangeNotifier {
//   List<Map<String, dynamic>> _loadSheets = [];
//   bool _isLoading = false;
//   bool _isSubmitting = false;
//   String? _error;
//
//   List<Map<String, dynamic>> get loadSheets => _loadSheets;
//   bool get isLoading => _isLoading;
//   bool get isSubmitting => _isSubmitting;
//   String? get error => _error;
//
//   /// Returns the next auto-incremented load number like LS-0003
//   String get nextLoadNo {
//     int maxNum = 0;
//     for (final sheet in _loadSheets) {
//       final loadNo = sheet['load_no'] as String? ?? '';
//       // Extract the number part from "LS-XXXX"
//       final match = RegExp(r'LS-(\d+)').firstMatch(loadNo);
//       if (match != null) {
//         final num = int.tryParse(match.group(1)!) ?? 0;
//         if (num > maxNum) maxNum = num;
//       }
//     }
//     return 'LS-${(maxNum + 1).toString().padLeft(4, '0')}';
//   }
//
//   Future<void> fetchLoadSheets() async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//       final response = await http.get(
//         Uri.parse('${ApiEndpoints.baseUrl}/load-sheets'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200 && data['success'] == true) {
//         final list = data['data']['data'] as List? ?? [];
//         _loadSheets = list.cast<Map<String, dynamic>>();
//       } else {
//         _error = data['message'] ?? 'Failed to load sheets';
//       }
//     } catch (e) {
//       _error = 'Error: $e';
//     }
//
//     _isLoading = false;
//     notifyListeners();
//   }
//
//   Future<bool> createLoadSheet({
//     required String loadNo,
//     required String loadDate,
//     required int salesmanId,
//     int? vehicleId,
//     required List<LoadSheetDetail> details,
//   }) async {
//     _isSubmitting = true;
//     _error = null;
//     notifyListeners();
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//
//       final body = {
//         'load_no': loadNo,
//         'load_date': loadDate,
//         'salesman_id': salesmanId,
//         if (vehicleId != null) 'vehicle_id': vehicleId,
//         'details': details.map((d) => d.toJson()).toList(),
//       };
//
//       final response = await http.post(
//         Uri.parse('${ApiEndpoints.baseUrl}/load-sheets'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode(body),
//       );
//
//       _isSubmitting = false;
//       notifyListeners();
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         await fetchLoadSheets();
//         return true;
//       } else {
//         final data = jsonDecode(response.body);
//         _error = data['message'] ?? 'Failed to create load sheet';
//         return false;
//       }
//     } catch (e) {
//       _isSubmitting = false;
//       _error = 'Error: $e';
//       notifyListeners();
//       return false;
//     }
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// //  LOAD SHEET LIST SCREEN
// // ─────────────────────────────────────────────────────────────────────────────


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../ApiLink/ApiEndpoint.dart';
import '../model/load_sheet_model/Loading_sheet_model.dart';

class LoadSheetProvider with ChangeNotifier {
  List<Map<String, dynamic>> _loadSheets = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  List<Map<String, dynamic>> get loadSheets => _loadSheets;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  /// Returns the next auto-incremented load number like LS-0003
  String get nextLoadNo {
    int maxNum = 0;
    for (final sheet in _loadSheets) {
      final loadNo = sheet['load_no'] as String? ?? '';
      final match = RegExp(r'LS-(\d+)').firstMatch(loadNo);
      if (match != null) {
        final num = int.tryParse(match.group(1)!) ?? 0;
        if (num > maxNum) maxNum = num;
      }
    }
    return 'LS-${(maxNum + 1).toString().padLeft(4, '0')}';
  }

  Future<void> fetchLoadSheets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // ── Salesman filter ────────────────────────────────────────────────────
      // If salesman_id exists in prefs → logged-in user is a salesman,
      // show only their load sheets.
      // If salesman_id is absent → admin/owner, show everything.
      final int? salesmanId = prefs.containsKey('salesman_id')
          ? prefs.getInt('salesman_id')
          : null;
      // ──────────────────────────────────────────────────────────────────────

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/load-sheets'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final list = (data['data']['data'] as List? ?? [])
            .cast<Map<String, dynamic>>();

        // Apply salesman filter on the client side
        if (salesmanId != null) {
          _loadSheets = list
              .where((sheet) => sheet['salesman_id'] == salesmanId)
              .toList();
        } else {
          // Admin — show all
          _loadSheets = list;
        }
      } else {
        _error = data['message'] ?? 'Failed to load sheets';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createLoadSheet({
    required String loadNo,
    required String loadDate,
    required int salesmanId,
    int? vehicleId,
    required List<LoadSheetDetail> details,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final body = {
        'load_no': loadNo,
        'load_date': loadDate,
        'salesman_id': salesmanId,
        if (vehicleId != null) 'vehicle_id': vehicleId,
        'details': details.map((d) => d.toJson()).toList(),
      };

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/load-sheets'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      _isSubmitting = false;
      notifyListeners();

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchLoadSheets(); // re-fetch (filter is re-applied automatically)
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to create load sheet';
        return false;
      }
    } catch (e) {
      _isSubmitting = false;
      _error = 'Error: $e';
      notifyListeners();
      return false;
    }
  }
}