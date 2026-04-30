import 'dart:convert';
import 'package:demo_distribution/ApiLink/ApiEndpoint.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/setup/Delivery_boy_model.dart';


enum DeliveryBoyStatus { initial, loading, success, error }

class DeliveryBoyProvider extends ChangeNotifier {
  static  final String _baseUrl = '${ApiEndpoints.baseUrl}';

  DeliveryBoyStatus _status = DeliveryBoyStatus.initial;
  List<DeliveryBoy> _deliveryBoys = [];
  String _errorMessage = '';

  // ─── Getters ──────────────────────────────────────────────────
  DeliveryBoyStatus get status => _status;
  List<DeliveryBoy> get deliveryBoys => _deliveryBoys;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == DeliveryBoyStatus.loading;

  // ─── Fetch Delivery Boys ──────────────────────────────────────
  Future<void> fetchDeliveryBoys() async {
    _status = DeliveryBoyStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
     // final token = await TokenService.getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/delivery-boys'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 304) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final deliveryBoyResponse = DeliveryBoyResponse.fromJson(jsonData);

        if (deliveryBoyResponse.success) {
          _deliveryBoys = deliveryBoyResponse.data.data;
          _status = DeliveryBoyStatus.success;
        } else {
          _errorMessage = deliveryBoyResponse.message;
          _status = DeliveryBoyStatus.error;
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Unauthorized. Please login again.';
        _status = DeliveryBoyStatus.error;
       // await TokenService.clearAll();
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        _status = DeliveryBoyStatus.error;
      }
    } catch (e) {
      _errorMessage = 'Something went wrong: ${e.toString()}';
      _status = DeliveryBoyStatus.error;
    }

    notifyListeners();
  }

  // ─── Reset ────────────────────────────────────────────────────
  void reset() {
    _status = DeliveryBoyStatus.initial;
    _deliveryBoys = [];
    _errorMessage = '';
    notifyListeners();
  }
}