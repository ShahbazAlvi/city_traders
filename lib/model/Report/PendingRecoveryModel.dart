// class RecoveryPendingReport {
//   final bool success;
//   final String message;
//   final List<RecoveryData> data;
//   final RecoverySummary summary;
//
//   RecoveryPendingReport({
//     required this.success,
//     required this.message,
//     required this.data,
//     required this.summary,
//   });
//
//   factory RecoveryPendingReport.fromJson(Map<String, dynamic> json) {
//     final innerData = json['data'];
//
//     return RecoveryPendingReport(
//       success: json['success'],
//       message: json['message'],
//       data: (innerData['data'] as List)
//           .map((e) => RecoveryData.fromJson(e))
//           .toList(),
//       summary: RecoverySummary.fromJson(innerData['summary']),
//     );
//   }
// }
// class RecoveryData {
//   final int salesmanId;
//   final String salesmanName;
//   final int pendingInvoiceCount;
//   final double totalPendingAmount;
//
//   RecoveryData({
//     required this.salesmanId,
//     required this.salesmanName,
//     required this.pendingInvoiceCount,
//     required this.totalPendingAmount,
//   });
//
//   factory RecoveryData.fromJson(Map<String, dynamic> json) {
//     return RecoveryData(
//       salesmanId: json['salesman_id'],
//       salesmanName: json['salesman_name'],
//       pendingInvoiceCount: json['pending_invoice_count'],
//       totalPendingAmount:
//       double.parse(json['total_pending_amount'].toString()),
//     );
//   }
// }
// class RecoverySummary {
//   final int totalSalesmen;
//   final int totalPendingInvoiceCount;
//   final int totalPendingAmount;
//
//   RecoverySummary({
//     required this.totalSalesmen,
//     required this.totalPendingInvoiceCount,
//     required this.totalPendingAmount,
//   });
//
//   factory RecoverySummary.fromJson(Map<String, dynamic> json) {
//     return RecoverySummary(
//       totalSalesmen: json['total_salesmen'],
//       totalPendingInvoiceCount: json['total_pending_invoice_count'],
//       totalPendingAmount: json['total_pending_amount'],
//     );
//   }
// }

class RecoveryPendingReport {
  final bool success;
  final String message;
  final List<RecoveryData> data;
  final RecoverySummary summary;

  RecoveryPendingReport({
    required this.success,
    required this.message,
    required this.data,
    required this.summary,
  });

  factory RecoveryPendingReport.fromJson(Map<String, dynamic> json) {
    final innerData = json['data'];

    return RecoveryPendingReport(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (innerData['data'] as List)
          .map((e) => RecoveryData.fromJson(e))
          .toList(),
      summary: RecoverySummary.fromJson(innerData['summary']),
    );
  }
}

class RecoveryData {
  final int salesmanId;
  final String salesmanName;
  final int pendingInvoiceCount;
  final double totalPendingAmount;

  RecoveryData({
    required this.salesmanId,
    required this.salesmanName,
    required this.pendingInvoiceCount,
    required this.totalPendingAmount,
  });

  factory RecoveryData.fromJson(Map<String, dynamic> json) {
    return RecoveryData(
      salesmanId: json['salesman_id'] ?? 0,
      salesmanName: json['salesman_name'] ?? '',
      pendingInvoiceCount: json['pending_invoice_count'] ?? 0,
      totalPendingAmount: _toDouble(json['total_pending_amount']),
    );
  }
}

class RecoverySummary {
  final int totalSalesmen;
  final int totalPendingInvoiceCount;
  final double totalPendingAmount; // ✅ was int — API returns 728572.5 (double)

  RecoverySummary({
    required this.totalSalesmen,
    required this.totalPendingInvoiceCount,
    required this.totalPendingAmount,
  });

  factory RecoverySummary.fromJson(Map<String, dynamic> json) {
    return RecoverySummary(
      totalSalesmen: json['total_salesmen'] ?? 0,
      totalPendingInvoiceCount: json['total_pending_invoice_count'] ?? 0,
      totalPendingAmount: _toDouble(json['total_pending_amount']), // ✅ safe parse
    );
  }
}

// Safely converts int, double, or String → double
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}