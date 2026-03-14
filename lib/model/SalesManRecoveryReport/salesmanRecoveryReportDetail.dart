// model/Recovery_Model/SalesmanRecoveryDetailModel.dart

class SalesmanRecoveryDetailResponse {
  final bool success;
  final String message;
  final SalesmanRecoveryDetailData data;

  SalesmanRecoveryDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SalesmanRecoveryDetailResponse.fromJson(Map<String, dynamic> json) {
    return SalesmanRecoveryDetailResponse(
      success: json['success'],
      message: json['message'],
      data: SalesmanRecoveryDetailData.fromJson(json['data']),
    );
  }
}

class SalesmanRecoveryDetailData {
  final List<SalesmanRecoveryDetailEntry> data;
  final SalesmanRecoveryDetailSummary summary;

  SalesmanRecoveryDetailData({required this.data, required this.summary});

  factory SalesmanRecoveryDetailData.fromJson(Map<String, dynamic> json) {
    return SalesmanRecoveryDetailData(
      data: (json['data'] as List)
          .map((e) => SalesmanRecoveryDetailEntry.fromJson(e))
          .toList(),
      summary: SalesmanRecoveryDetailSummary.fromJson(json['summary']),
    );
  }
}

class SalesmanRecoveryDetailEntry {
  final int recoveryId;
  final String recoveryDate;
  final String voucherNo;
  final double amount;
  final String mode;
  final String? remarks;
  final int customerId;
  final String customerName;
  final String customerPhone;
  final int invoiceCount;
  final String invoiceNumbers;
  final double totalInvoiceAmt;

  SalesmanRecoveryDetailEntry({
    required this.recoveryId,
    required this.recoveryDate,
    required this.voucherNo,
    required this.amount,
    required this.mode,
    this.remarks,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.invoiceCount,
    required this.invoiceNumbers,
    required this.totalInvoiceAmt,
  });

  factory SalesmanRecoveryDetailEntry.fromJson(Map<String, dynamic> json) {
    return SalesmanRecoveryDetailEntry(
      recoveryId: json['recovery_id'],
      recoveryDate: json['recovery_date'],
      voucherNo: json['voucher_no'],
      amount: double.parse(json['amount'].toString()),
      mode: json['mode'],
      remarks: json['remarks'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      invoiceCount: json['invoice_count'],
      invoiceNumbers: json['invoice_numbers'],
      totalInvoiceAmt: double.parse(json['total_invoice_amt'].toString()),
    );
  }
}

class SalesmanRecoveryDetailSummary {
  final int recoveryCount;
  final double totalRecovered;
  final int customerCount;

  SalesmanRecoveryDetailSummary({
    required this.recoveryCount,
    required this.totalRecovered,
    required this.customerCount,
  });

  factory SalesmanRecoveryDetailSummary.fromJson(Map<String, dynamic> json) {
    return SalesmanRecoveryDetailSummary(
      recoveryCount: json['recovery_count'],
      totalRecovered: json['total_recovered'].toDouble(),
      customerCount: json['customer_count'],
    );
  }
}
