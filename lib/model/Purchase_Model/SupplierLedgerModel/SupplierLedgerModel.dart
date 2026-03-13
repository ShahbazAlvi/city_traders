class SupplierLedgerDetailModel {
  final bool success;
  final String message;
  final SupplierLedgerData data;

  SupplierLedgerDetailModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SupplierLedgerDetailModel.fromJson(Map<String, dynamic> json) {
    return SupplierLedgerDetailModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: SupplierLedgerData.fromJson(json['data'] ?? {}),
    );
  }
}

class SupplierLedgerData {
  final int supplierId;
  final String supplierName;
  final String fromDate;
  final String toDate;
  final double openingBalance;
  final double closingBalance;
  final double totalDebit;
  final double totalCredit;
  final List<SupplierLedgerEntry> entries;

  SupplierLedgerData({
    required this.supplierId,
    required this.supplierName,
    required this.fromDate,
    required this.toDate,
    required this.openingBalance,
    required this.closingBalance,
    required this.totalDebit,
    required this.totalCredit,
    required this.entries,
  });

  factory SupplierLedgerData.fromJson(Map<String, dynamic> json) {
    return SupplierLedgerData(
      supplierId: json['supplier_id'] ?? 0,
      supplierName: json['supplier_name'] ?? '',
      fromDate: json['from_date'] ?? '',
      toDate: json['to_date'] ?? '',
      openingBalance: (json['opening_balance'] ?? 0).toDouble(),
      closingBalance: (json['closing_balance'] ?? 0).toDouble(),
      totalDebit: (json['total_debit'] ?? 0).toDouble(),
      totalCredit: (json['total_credit'] ?? 0).toDouble(),
      entries: (json['entries'] as List<dynamic>? ?? [])
          .map((e) => SupplierLedgerEntry.fromJson(e))
          .toList(),
    );
  }
}

class SupplierLedgerEntry {
  final int id;
  final String date;
  final String type;
  final String refNo;
  final double debit;
  final double credit;
  final double balance;
  final String remarks;
  final bool isOpening;

  SupplierLedgerEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.refNo,
    required this.debit,
    required this.credit,
    required this.balance,
    required this.remarks,
    required this.isOpening,
  });

  factory SupplierLedgerEntry.fromJson(Map<String, dynamic> json) {
    return SupplierLedgerEntry(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      type: json['type'] ?? '',
      refNo: json['ref_no'] ?? '',
      debit: (json['debit'] ?? 0).toDouble(),
      credit: (json['credit'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      remarks: json['remarks'] ?? '',
      isOpening: json['is_opening'] ?? false,
    );
  }
}