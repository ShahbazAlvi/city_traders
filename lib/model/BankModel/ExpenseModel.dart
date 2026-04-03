// model/ExpenseModel/ExpenseVoucherModel.dart

class ExpenseVoucher {
  final int id;
  final String evNo;
  final DateTime voucherDate;
  final int expenseHeadId;
  final String expenseHeadName;
  final int? accountId;
  final String? accountName;
  final String? accountCode;
  final String mode; // "CASH" | "BANK"
  final int? bankId;
  final String? bankName;
  final double amount;
  final String? remarks;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseVoucher({
    required this.id,
    required this.evNo,
    required this.voucherDate,
    required this.expenseHeadId,
    required this.expenseHeadName,
    this.accountId,
    this.accountName,
    this.accountCode,
    required this.mode,
    this.bankId,
    this.bankName,
    required this.amount,
    this.remarks,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseVoucher.fromJson(Map<String, dynamic> json) {
    return ExpenseVoucher(
      id: json['id'] as int,
      evNo: json['ev_no'] as String,
      voucherDate: DateTime.parse(json['voucher_date'] as String),
      expenseHeadId: json['expense_head_id'] as int,
      expenseHeadName: json['expense_head_name'] as String,
      accountId: json['account_id'] as int?,
      accountName: json['account_name'] as String?,
      accountCode: json['account_code'] as String?,
      mode: json['mode'] as String,
      bankId: json['bank_id'] as int?,
      bankName: json['bank_name'] as String?,
      amount: double.parse(json['amount'].toString()),
      remarks: json['remarks'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ev_no': evNo,
    'voucher_date': voucherDate.toIso8601String(),
    'expense_head_id': expenseHeadId,
    'expense_head_name': expenseHeadName,
    'account_id': accountId,
    'account_name': accountName,
    'account_code': accountCode,
    'mode': mode,
    'bank_id': bankId,
    'bank_name': bankName,
    'amount': amount,
    'remarks': remarks,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

// ── POST body model ────────────────────────────────────────────────────────────
class ExpenseVoucherRequest {
  final String evNo;
  final String voucherDate;
  final int expenseHeadId;
  final String mode;
  final int? bankId;
  final double amount;
  final String? remarks;
  final String status;

  const ExpenseVoucherRequest({
    required this.evNo,
    required this.voucherDate,
    required this.expenseHeadId,
    required this.mode,
    this.bankId,
    required this.amount,
    this.remarks,
    this.status = 'POSTED',
  });

  Map<String, dynamic> toJson() => {
    'ev_no': evNo,
    'voucher_date': voucherDate,
    'expense_head_id': expenseHeadId,
    'mode': mode,
    'bank_id': bankId,
    'amount': amount,
    if (remarks != null && remarks!.isNotEmpty) 'remarks': remarks,
    'status': status,
  };
}

// ── Expense head model (for dropdown) ─────────────────────────────────────────
class ExpenseHead {
  final int id;
  final String name;

  const ExpenseHead({required this.id, required this.name});

  factory ExpenseHead.fromJson(Map<String, dynamic> json) => ExpenseHead(
    id: json['id'] as int,
    name: json['name'] as String,
  );
}