// providers/daybook_ledger_provider.dart

import 'dart:convert';
import 'package:demo_distribution/ApiLink/ApiEndpoint.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/BankModel/DayBookmodel.dart';

enum DaybookState { initial, loading, loaded, error }

class DaybookLedgerProvider extends ChangeNotifier {
  DaybookState _state = DaybookState.initial;
  DaybookLedgerResponse? _ledgerData;
  String _errorMessage = '';
  DateTime _selectedDate = DateTime.now();

  DaybookState get state => _state;
  DaybookLedgerResponse? get ledgerData => _ledgerData;
  String get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;
  List<DaybookEntry> get entries => _ledgerData?.entries ?? [];
  DaybookSummary? get summary => _ledgerData?.summary;
  bool get isLoading => _state == DaybookState.loading;
  bool get hasData => _state == DaybookState.loaded && _ledgerData != null;
  bool get hasError => _state == DaybookState.error;

  // ── Get token from SharedPreferences ──────────────────────────────────────
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // change key to match what you store at login
  }

  // ── Fetch ledger for a given date ─────────────────────────────────────────
  Future<void> fetchLedger({DateTime? date}) async {
    final targetDate = date ?? _selectedDate;
    _selectedDate = targetDate;

    _setState(DaybookState.loading);

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        _errorMessage = 'Session expired. Please login again.';
        _setState(DaybookState.error);
        return;
      }

      final formattedDate =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

      final uri = Uri.parse('${ApiEndpoints.baseUrl}/daybook-ledger?date=$formattedDate');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',   // ← token attached here
        },
      );

      debugPrint('Daybook status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 304) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        _ledgerData = DaybookLedgerResponse.fromJson(json);
        _setState(DaybookState.loaded);
      } else if (response.statusCode == 401) {
        _errorMessage = 'Session expired. Please login again.';
        _setState(DaybookState.error);
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        _setState(DaybookState.error);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setState(DaybookState.error);
    }
  }

  Future<void> changeDate(DateTime newDate) async {
    if (_selectedDate == newDate) return;
    await fetchLedger(date: newDate);
  }

  Future<void> refresh() => fetchLedger(date: _selectedDate);

  void _setState(DaybookState newState) {
    _state = newState;
    notifyListeners();
  }
}