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
      success: json['success'],
      message: json['message'],
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
      salesmanId: json['salesman_id'],
      salesmanName: json['salesman_name'],
      pendingInvoiceCount: json['pending_invoice_count'],
      totalPendingAmount:
      double.parse(json['total_pending_amount'].toString()),
    );
  }
}
class RecoverySummary {
  final int totalSalesmen;
  final int totalPendingInvoiceCount;
  final int totalPendingAmount;

  RecoverySummary({
    required this.totalSalesmen,
    required this.totalPendingInvoiceCount,
    required this.totalPendingAmount,
  });

  factory RecoverySummary.fromJson(Map<String, dynamic> json) {
    return RecoverySummary(
      totalSalesmen: json['total_salesmen'],
      totalPendingInvoiceCount: json['total_pending_invoice_count'],
      totalPendingAmount: json['total_pending_amount'],
    );
  }
}