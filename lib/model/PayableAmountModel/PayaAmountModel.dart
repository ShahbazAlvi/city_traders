class PayableAmountModel {
  final int supplierId;
  final String supplierName;
  final double openingBalance;
  final double totalGrn;
  final double totalPaid;
  final double totalDiscount;
  final double totalReturns;
  final double totalPayable;
  final double totalBalance;
  final double grandBalance;

  PayableAmountModel({
    required this.supplierId,
    required this.supplierName,
    required this.openingBalance,
    required this.totalGrn,
    required this.totalPaid,
    required this.totalDiscount,
    required this.totalReturns,
    required this.totalPayable,
    required this.totalBalance,
    required this.grandBalance,
  });

  factory PayableAmountModel.fromJson(Map<String, dynamic> json) {
    return PayableAmountModel(
      supplierId: json['supplier_id'] ?? 0,
      supplierName: json['supplier_name'] ?? '',
      openingBalance: (json['opening_balance'] ?? 0).toDouble(),
      totalGrn: (json['total_grn'] ?? 0).toDouble(),
      totalPaid: (json['total_paid'] ?? 0).toDouble(),
      totalDiscount: (json['total_discount'] ?? 0).toDouble(),
      totalReturns: (json['total_returns'] ?? 0).toDouble(),
      totalPayable: (json['total_payable'] ?? 0).toDouble(),
      totalBalance: (json['total_balance'] ?? 0).toDouble(),
      grandBalance: (json['grand_balance'] ?? 0).toDouble(),
    );
  }
}

class PayableAmountResponse {
  final bool success;
  final String message;
  final List<PayableAmountModel> data;

  PayableAmountResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PayableAmountResponse.fromJson(Map<String, dynamic> json) {

    List list = json["data"]?["data"] ?? [];

    return PayableAmountResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: list.map((e) => PayableAmountModel.fromJson(e)).toList(),
    );
  }
}