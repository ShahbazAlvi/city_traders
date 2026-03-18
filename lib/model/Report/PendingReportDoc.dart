class PendingReportDoc {
  final bool success;
  final String message;
  final List<PendingInvoice> data;
  final PendingSummary summary;

  PendingReportDoc({
    required this.success,
    required this.message,
    required this.data,
    required this.summary,
  });

  factory PendingReportDoc.fromJson(Map<String, dynamic> json) {
    final innerData = json['data'];

    return PendingReportDoc(
      success: json['success'],
      message: json['message'],
      data: (innerData['data'] as List)
          .map((e) => PendingInvoice.fromJson(e))
          .toList(),
      summary: PendingSummary.fromJson(innerData['summary']),
    );
  }
}
class PendingInvoice {
  final int invoiceId;
  final String invNo;
  final String invoiceDate;
  final String invoiceType;
  final int customerId;
  final String customerName;
  final String? customerPhone;
  final double netTotal;
  final double paidAmount;
  final double pendingAmount;

  PendingInvoice({
    required this.invoiceId,
    required this.invNo,
    required this.invoiceDate,
    required this.invoiceType,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    required this.netTotal,
    required this.paidAmount,
    required this.pendingAmount,
  });

  factory PendingInvoice.fromJson(Map<String, dynamic> json) {
    return PendingInvoice(
      invoiceId: json['invoice_id'],
      invNo: json['inv_no'],
      invoiceDate: json['invoice_date'],
      invoiceType: json['invoice_type'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      netTotal: double.parse(json['net_total'].toString()),
      paidAmount: double.parse(json['paid_amount'].toString()),
      pendingAmount: double.parse(json['pending_amount'].toString()),
    );
  }
}
class PendingSummary {
  final int pendingInvoiceCount;
  final double totalNetAmount;
  final double totalPaidAmount;
  final double totalPendingAmount;

  PendingSummary({
    required this.pendingInvoiceCount,
    required this.totalNetAmount,
    required this.totalPaidAmount,
    required this.totalPendingAmount,
  });

  factory PendingSummary.fromJson(Map<String, dynamic> json) {
    return PendingSummary(
      pendingInvoiceCount: json['pending_invoice_count'],
      totalNetAmount:
      double.parse(json['total_net_amount'].toString()),
      totalPaidAmount:
      double.parse(json['total_paid_amount'].toString()),
      totalPendingAmount:
      double.parse(json['total_pending_amount'].toString()),
    );
  }
}