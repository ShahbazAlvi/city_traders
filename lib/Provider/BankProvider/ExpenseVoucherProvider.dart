// Provider/ExpenseProvider/ExpenseVoucherProvider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../ApiLink/ApiEndpoint.dart';
import '../../model/BankModel/ExpenseModel.dart';


enum ExpenseVoucherState { initial, loading, loaded, error }
enum ExpenseSubmitState { idle, submitting, success, error }

class ExpenseVoucherProvider extends ChangeNotifier {
  // ── List state ─────────────────────────────────────────────────────────────
  ExpenseVoucherState _listState = ExpenseVoucherState.initial;
  List<ExpenseVoucher> _vouchers = [];
  String _listError = '';

  // ── Submit state ───────────────────────────────────────────────────────────
  ExpenseSubmitState _submitState = ExpenseSubmitState.idle;
  String _submitError = '';

  // ── Next EV number (auto-incremented from last fetched) ───────────────────
  String _nextEvNo = 'EV-0001';

  // ── Expense heads (for dropdown) ──────────────────────────────────────────
  List<ExpenseHead> _expenseHeads = [];

  // ── Getters ────────────────────────────────────────────────────────────────
  ExpenseVoucherState get listState => _listState;
  List<ExpenseVoucher> get vouchers => _vouchers;
  String get listError => _listError;
  bool get isListLoading => _listState == ExpenseVoucherState.loading;
  bool get hasListData => _listState == ExpenseVoucherState.loaded;
  bool get hasListError => _listState == ExpenseVoucherState.error;

  ExpenseSubmitState get submitState => _submitState;
  String get submitError => _submitError;
  bool get isSubmitting => _submitState == ExpenseSubmitState.submitting;
  bool get submitSuccess => _submitState == ExpenseSubmitState.success;

  String get nextEvNo => _nextEvNo;
  List<ExpenseHead> get expenseHeads => _expenseHeads;

  // ── Token helper ───────────────────────────────────────────────────────────
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Map<String, String> get _headers => {'Content-Type': 'application/json'};
  Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Fetch all expense vouchers ─────────────────────────────────────────────
  Future<void> fetchVouchers() async {
    _listState = ExpenseVoucherState.loading;
    notifyListeners();

    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/expense-vouchers');
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 304) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (json['data']['data'] as List<dynamic>)
            .map((e) => ExpenseVoucher.fromJson(e as Map<String, dynamic>))
            .toList();

        _vouchers = list;
        _computeNextEvNo();
        _listState = ExpenseVoucherState.loaded;
      } else if (response.statusCode == 401) {
        _listError = 'Session expired. Please login again.';
        _listState = ExpenseVoucherState.error;
      } else {
        _listError = 'Server error: ${response.statusCode}';
        _listState = ExpenseVoucherState.error;
      }
    } catch (e) {
      _listError = e.toString();
      _listState = ExpenseVoucherState.error;
    }

    notifyListeners();
  }

  // ── Auto-compute next EV number from last record ───────────────────────────
  void _computeNextEvNo() {
    if (_vouchers.isEmpty) {
      _nextEvNo = 'EV-0001';
      return;
    }

    // vouchers come in DESC order — first item has the highest ev_no
    final lastNo = _vouchers.first.evNo; // e.g. "EV-0004"
    final parts = lastNo.split('-');
    if (parts.length == 2) {
      final num = int.tryParse(parts[1]) ?? 0;
      _nextEvNo = 'EV-${(num + 1).toString().padLeft(4, '0')}';
    } else {
      _nextEvNo = 'EV-0001';
    }
  }

  // ── Fetch expense heads ────────────────────────────────────────────────────
  Future<void> fetchExpenseHeads() async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/expense-heads');
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        // adjust key path to your actual response shape
        final list = (json['data'] as List<dynamic>)
            .map((e) => ExpenseHead.fromJson(e as Map<String, dynamic>))
            .toList();
        _expenseHeads = list;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('fetchExpenseHeads error: $e');
    }
  }

  // ── Add expense voucher ────────────────────────────────────────────────────
  Future<bool> addVoucher(ExpenseVoucherRequest request) async {
    _submitState = ExpenseSubmitState.submitting;
    _submitError = '';
    notifyListeners();

    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/expense-vouchers');
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      debugPrint('Add expense status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _submitState = ExpenseSubmitState.success;
        notifyListeners();
        // refresh list so next ev_no updates
        await fetchVouchers();
        return true;
      } else if (response.statusCode == 401) {
        _submitError = 'Session expired. Please login again.';
      } else {
        final body = jsonDecode(response.body);
        _submitError = body['message'] ?? 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _submitError = e.toString();
    }

    _submitState = ExpenseSubmitState.error;
    notifyListeners();
    return false;
  }

  // ── Reset submit state (call before opening add form again) ───────────────
  void resetSubmitState() {
    _submitState = ExpenseSubmitState.idle;
    _submitError = '';
    notifyListeners();
  }

  Future<void> refresh() => fetchVouchers();
}