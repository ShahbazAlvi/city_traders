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
    // Some APIs wrap the actual result in another 'data' key, some don't.
    // Based on the snippet, the top level has 'data' (list) and 'summary'.
    // If 'success' is missing, default to true if data is present.
    
    final bool success = json['success'] ?? true;
    final String message = json['message'] ?? "";
    
    // Check if the data is at the root or nested
    dynamic dataPart = json['data'];
    dynamic summaryPart = json['summary'];
    
    List<PendingInvoice> invoices = [];
    if (dataPart is List) {
      invoices = dataPart.map((e) => PendingInvoice.fromJson(e)).toList();
    } else if (dataPart is Map && dataPart['data'] is List) {
      // Handle double nesting if it exists
      invoices = (dataPart['data'] as List).map((e) => PendingInvoice.fromJson(e)).toList();
      summaryPart ??= dataPart['summary'];
    }

    return PendingReportDoc(
      success: success,
      message: message,
      data: invoices,
      summary: PendingSummary.fromJson(summaryPart ?? {}),
    );
  }
}

class PendingInvoice {
  final int? invoiceId;
  final String invNo;
  final String? invoiceDate;
  final String invoiceType;
  final int? customerId;
  final String customerName;
  final String? customerPhone;
  final double netTotal;
  final double paidAmount;
  final double pendingAmount;

  PendingInvoice({
    this.invoiceId,
    required this.invNo,
    this.invoiceDate,
    required this.invoiceType,
    this.customerId,
    required this.customerName,
    this.customerPhone,
    required this.netTotal,
    required this.paidAmount,
    required this.pendingAmount,
  });

  factory PendingInvoice.fromJson(Map<String, dynamic> json) {
    return PendingInvoice(
      invoiceId: json['invoice_id'],
      invNo: json['inv_no'] ?? "",
      invoiceDate: json['invoice_date'],
      invoiceType: json['invoice_type'] ?? "",
      customerId: json['customer_id'],
      customerName: json['customer_name'] ?? "",
      customerPhone: json['customer_phone'],
      netTotal: double.tryParse(json['net_total']?.toString() ?? "0") ?? 0.0,
      paidAmount: double.tryParse(json['paid_amount']?.toString() ?? "0") ?? 0.0,
      pendingAmount: double.tryParse(json['pending_amount']?.toString() ?? "0") ?? 0.0,
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
      pendingInvoiceCount: json['pending_invoice_count'] ?? 0,
      totalNetAmount: double.tryParse(json['total_net_amount']?.toString() ?? "0") ?? 0.0,
      totalPaidAmount: double.tryParse(json['total_paid_amount']?.toString() ?? "0") ?? 0.0,
      totalPendingAmount: double.tryParse(json['total_pending_amount']?.toString() ?? "0") ?? 0.0,
    );
  }
}