// models/daybook_ledger_model.dart

class DaybookEntry {
  final int sr;
  final int id;
  final String voucherNo;
  final String voucherType;
  final DateTime voucherDate;
  final String coaCode;
  final String accountName;
  final String narration;
  final double receipt;
  final double payment;
  final double balance;

  const DaybookEntry({
    required this.sr,
    required this.id,
    required this.voucherNo,
    required this.voucherType,
    required this.voucherDate,
    required this.coaCode,
    required this.accountName,
    required this.narration,
    required this.receipt,
    required this.payment,
    required this.balance,
  });

  factory DaybookEntry.fromJson(Map<String, dynamic> json) {
    return DaybookEntry(
      sr: json['sr'] as int,
      id: json['id'] as int,
      voucherNo: json['voucher_no'] as String,
      voucherType: json['voucher_type'] as String,
      voucherDate: DateTime.parse(json['voucher_date'] as String),
      coaCode: json['coa_code'] as String,
      accountName: json['account_name'] as String,
      narration: json['narration'] as String? ?? '',
      receipt: (json['receipt'] as num).toDouble(),
      payment: (json['payment'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'sr': sr,
    'id': id,
    'voucher_no': voucherNo,
    'voucher_type': voucherType,
    'voucher_date': voucherDate.toIso8601String(),
    'coa_code': coaCode,
    'account_name': accountName,
    'narration': narration,
    'receipt': receipt,
    'payment': payment,
    'balance': balance,
  };
}

class DaybookSummary {
  final double totalReceipt;
  final double totalPayment;
  final double closingBalance;
  final int totalEntries;
  final String from;
  final String to;

  const DaybookSummary({
    required this.totalReceipt,
    required this.totalPayment,
    required this.closingBalance,
    required this.totalEntries,
    required this.from,
    required this.to,
  });

  factory DaybookSummary.fromJson(Map<String, dynamic> json) {
    return DaybookSummary(
      totalReceipt: (json['total_receipt'] as num).toDouble(),
      totalPayment: (json['total_payment'] as num).toDouble(),
      closingBalance: (json['closing_balance'] as num).toDouble(),
      totalEntries: json['total_entries'] as int,
      from: json['from'] as String,
      to: json['to'] as String,
    );
  }
}

class DaybookLedgerResponse {
  final bool success;
  final String message;
  final List<DaybookEntry> entries;
  final DaybookSummary summary;

  const DaybookLedgerResponse({
    required this.success,
    required this.message,
    required this.entries,
    required this.summary,
  });

  factory DaybookLedgerResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return DaybookLedgerResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      entries: (data['entries'] as List<dynamic>)
          .map((e) => DaybookEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: DaybookSummary.fromJson(data['summary'] as Map<String, dynamic>),
    );
  }
}