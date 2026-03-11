import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/DashBoardModel.dart';


enum LoadState { idle, loading, loaded, error }

class DashboardProvider extends ChangeNotifier {
  LoadState state = LoadState.idle;
  DashboardData? data;
  String errorMsg = '';

  static const _mockJson = {
    "kpi_cards": {
      "total_sales": 253200,
      "total_purchases": 628894.8,
      "total_payments_in": 9200,
      "total_payments_out": 840000,
      "total_recoveries": 3400,
      "total_customer_payments": 5800,
      "gross_profit": -375694.80000000005,
      "net_cash": -830800
    },
    "monthly_trend": [
      {"month": "2026-03-04", "sales": 0, "purchases": 0, "paymentsIn": 0, "paymentsOut": 840000, "recoveries": 0},
      {"month": "2026-03-05", "sales": 0, "purchases": 622894.8, "paymentsIn": 0, "paymentsOut": 0, "recoveries": 0},
      {"month": "2026-03-06", "sales": 0, "purchases": 6000, "paymentsIn": 0, "paymentsOut": 0, "recoveries": 0},
      {"month": "2026-03-07", "sales": 85000, "purchases": 0, "paymentsIn": 1200, "paymentsOut": 0, "recoveries": 400},
      {"month": "2026-03-09", "sales": 133200, "purchases": 0, "paymentsIn": 0, "paymentsOut": 0, "recoveries": 0},
      {"month": "2026-03-10", "sales": 35000, "purchases": 0, "paymentsIn": 8000, "paymentsOut": 0, "recoveries": 3000}
    ],
    "invoice_status": {
      "paid": {"count": 0, "amount": 0},
      "receivable": {"count": 3, "amount": 248200},
      "overdue": {"count": 0, "amount": 0}
    },
    "top_products": [
      {"item_id": 30, "name": "kamyab cooking oil 1kg", "sold": 120},
      {"item_id": 33, "name": "Special Ghee", "sold": 84}
    ],
    "recent_activity": [
      {"id": 7, "type": "Payment Out", "who": "Qasim Umer", "amount": 540000, "date": "2026-03-04T00:00:00.000Z", "ref_no": "SP-0002"},
      {"id": 6, "type": "Payment Out", "who": "zubair sons", "amount": 300000, "date": "2026-03-04T00:00:00.000Z", "ref_no": "SP-0001"},
      {"id": 34, "type": "Sale", "who": "nadir ali lohari gate", "amount": 35000, "date": "2026-03-10T00:00:00.000Z", "ref_no": "INV-0004"},
      {"id": 19, "type": "Payment In", "who": "nadir ali lohari gate", "amount": 5000, "date": "2026-03-10T00:00:00.000Z", "ref_no": "CP-0002"},
      {"id": 11, "type": "Recovery", "who": "nadir ali lohari gate", "amount": 3000, "date": "2026-03-10T00:00:00.000Z", "ref_no": "RV-0002"},
      {"id": 21, "type": "Purchase", "who": "zubair sons", "amount": 3096, "date": "2026-03-05T00:00:00.000Z", "ref_no": "GRN-0004"},
      {"id": 20, "type": "Purchase", "who": "olympia mills", "amount": 73798.8, "date": "2026-03-05T00:00:00.000Z", "ref_no": "GRN-0003"},
      {"id": 18, "type": "Purchase", "who": "Qasim Umer", "amount": 540000, "date": "2026-03-05T00:00:00.000Z", "ref_no": "GRN-0001"},
      {"id": 18, "type": "Payment In", "who": "nadir ali lohari gate", "amount": 800, "date": "2026-03-07T00:00:00.000Z", "ref_no": "CP-0001"},
      {"id": 10, "type": "Recovery", "who": "nadir ali lohari gate", "amount": 400, "date": "2026-03-07T00:00:00.000Z", "ref_no": "RV-0001"},
      {"id": 7, "type": "Sale", "who": "nadir ali lohari gate", "amount": 85000, "date": "2026-03-07T00:00:00.000Z", "ref_no": "TINV-0001"}
    ],
    "recoveries": {
      "summary": {
        "total_amount": 3400,
        "total_count": 2,
        "cash_amount": 3000,
        "bank_amount": 400
      }
    }
  };

  Future<void> fetch({
    String baseUrl = 'http://localhost:5000',
    String from = '2026-02-28',
    String to = '2026-03-30',
  }) async {
    state = LoadState.loading;
    notifyListeners();

    try {
      final uri = Uri.parse('$baseUrl/api/dashboard?from=$from&to=$to');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200 || res.statusCode == 304) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        data = DashboardData.fromJson(json['data']);
      } else {
        throw Exception('HTTP ${res.statusCode}');
      }
    } catch (_) {
      data = DashboardData.fromJson(_mockJson);
    }

    state = LoadState.loaded;
    notifyListeners();
  }

  void refresh() => fetch();
}