import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../ApiLink/ApiEndpoint.dart';
import '../../model/stock/low_level_stock_model.dart';


class LowLevelStockProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  LowLevelStockModel? _stockData;

  // Filter state
  String _filter = 'ALL'; // 'ALL' | 'LOW' | 'OK'
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  LowLevelStockModel? get stockData => _stockData;
  String get filter => _filter;
  String get searchQuery => _searchQuery;

  void setFilter(String f) {
    _filter = f;
    notifyListeners();
  }

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  List<LowStockItem> get filteredItems {
    if (_stockData == null) return [];
    return _stockData!.data.where((item) {
      final matchFilter = _filter == 'ALL' || item.status.toUpperCase() == _filter;
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          item.itemName.toLowerCase().contains(q) ||
          item.sku.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q);
      return matchFilter && matchSearch;
    }).toList();
  }

  int get lowCount  => _stockData?.data.where((i) => i.isLow).length ?? 0;
  int get okCount   => _stockData?.data.where((i) => !i.isLow).length ?? 0;
  int get totalCount => _stockData?.data.length ?? 0;

  Future<void> fetchLowLevelStock() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/low-level-stock'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Cache-Control': 'no-cache',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        if (response.body.isNotEmpty) {
          _stockData = LowLevelStockModel.fromJson(json.decode(response.body));
        }
      } else {
        _error = 'Failed to load stock (${response.statusCode})';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => fetchLowLevelStock();
}