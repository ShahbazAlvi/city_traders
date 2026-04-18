


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../ApiLink/ApiEndpoint.dart';
import '../model/load_sheet_model/Loading_sheet_model.dart';

class LoadSheetProvider with ChangeNotifier {
  List<Map<String, dynamic>> _loadSheets = [];
  List<Map<String, dynamic>> _unfilteredSheets = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  // ── Sales Orders by Salesman ──
  List<Map<String, dynamic>> _salesOrders = [];
  bool _isLoadingSO = false;
  String? _soError;

  // ── SO Items (aggregated from selected orders) ──
  List<Map<String, dynamic>> _soItems = [];
  bool _isLoadingItems = false;
  String? _itemsError;

  List<Map<String, dynamic>> get loadSheets => _loadSheets;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  List<Map<String, dynamic>> get salesOrders => _salesOrders;
  bool get isLoadingSO => _isLoadingSO;
  String? get soError => _soError;

  List<Map<String, dynamic>> get soItems => _soItems;
  bool get isLoadingItems => _isLoadingItems;
  String? get itemsError => _itemsError;

  /// Returns the next auto-incremented load number like LO-0003
  String get nextLoadNo {
    int maxNum = 0;
    // Use unfiltered list for collective/global ID generation
    for (final sheet in _unfilteredSheets) {
      final loadNo = sheet['load_no'] as String? ?? '';
      final match = RegExp(r'(?:LS|LO|Lo)-(\d+)$').firstMatch(loadNo);
      if (match != null) {
        final num = int.tryParse(match.group(1)!) ?? 0;
        if (num > maxNum) maxNum = num;
      }
    }
    return 'LO-${(maxNum + 1).toString().padLeft(4, '0')}';
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FETCH LOAD SHEETS (existing)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> fetchLoadSheets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final int? salesmanId = prefs.containsKey('salesman_id')
          ? prefs.getInt('salesman_id')
          : null;

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

        _unfilteredSheets = list; // Keep full list for ID generation

        if (salesmanId != null) {
          _loadSheets = list
              .where((sheet) => sheet['salesman_id'] == salesmanId)
              .toList();
        } else {
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

  // ─────────────────────────────────────────────────────────────────────────
  //  FETCH SALES ORDERS BY SALESMAN
  //  GET /api/load-sheets/sales-orders/by-salesman/{salesmanId}
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> fetchSalesOrdersBySalesman(int salesmanId) async {
    _isLoadingSO = true;
    _soError = null;
    _salesOrders = [];
    notifyListeners();

    try {
      final token = await _getToken();
      final uri = Uri.parse(
          '${ApiEndpoints.baseUrl}/load-sheets/sales-orders/by-salesman/$salesmanId');

      final res = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200 || res.statusCode == 304) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          _salesOrders = (json['data']['data'] as List? ?? [])
              .cast<Map<String, dynamic>>();
        } else {
          _soError = json['message'] ?? 'Failed to fetch sales orders';
        }
      } else {
        _soError = 'Error ${res.statusCode}';
      }
    } catch (e) {
      _soError = 'Error: $e';
    }

    _isLoadingSO = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FETCH SO ITEMS FOR MULTIPLE SELECTED ORDERS
  //  GET /api/load-sheets/so-items/{soId}  (called for each selected SO)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> fetchSOItems(List<int> soIds) async {
    _isLoadingItems = true;
    _itemsError = null;
    _soItems = [];
    notifyListeners();

    try {
      final token = await _getToken();
      final List<Map<String, dynamic>> allItems = [];

      for (final soId in soIds) {
        final uri = Uri.parse(
            '${ApiEndpoints.baseUrl}/load-sheets/so-items/$soId');

        final res = await http.get(uri, headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        }).timeout(const Duration(seconds: 15));

        if (res.statusCode == 200 || res.statusCode == 304) {
          final json = jsonDecode(res.body) as Map<String, dynamic>;
          if (json['success'] == true) {
            final items = (json['data']['data'] as List? ?? [])
                .cast<Map<String, dynamic>>();
            allItems.addAll(items);
          }
        }
      }

      // Aggregate: group by item_id and sum qty
      final Map<int, Map<String, dynamic>> aggregated = {};
      for (final item in allItems) {
        final itemId = item['item_id'] as int;
        final qty = double.tryParse(item['so_qty']?.toString() ?? '0') ?? 0;

        if (aggregated.containsKey(itemId)) {
          aggregated[itemId]!['so_qty'] =
              (aggregated[itemId]!['so_qty'] as double) + qty;
        } else {
          aggregated[itemId] = {
            ...item,
            'so_qty': qty,
          };
        }
      }

      _soItems = aggregated.values.toList();
    } catch (e) {
      _itemsError = 'Error: $e';
    }

    _isLoadingItems = false;
    notifyListeners();
  }

  void clearSalesOrders() {
    _salesOrders = [];
    _soItems = [];
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  CREATE LOAD SHEET (updated to include selected_so_ids)
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> createLoadSheet({
    required String loadNo,
    required String loadDate,
    required int salesmanId,
    int? vehicleId,
    required List<LoadSheetDetail> details,
    List<int>? selectedSoIds,
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
        if (selectedSoIds != null && selectedSoIds.isNotEmpty)
          'selected_so_ids': selectedSoIds,
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
        await fetchLoadSheets();
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
  // delete it
  Future<bool> deleteLoadSheet(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('${ApiEndpoints.baseUrl}/load-sheets/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _loadSheets.removeWhere((s) => s['id'] == id);
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to delete';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      notifyListeners();
      return false;
    }
  }


}