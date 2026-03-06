class PaymentToSupplierModel {
  final int id;
  final String paymentNo;
  final int supplierId;
  final String supplierName;
  final String paymentDate;
  final String paymentMode;
  final String? bankName;
  final String? grnNo;
  final double invoiceAmount;
  final double amount;
  final double paymentBalance;
  final String status;
  final String? remarks;
  final String createdAt;
  final String updatedAt;

  PaymentToSupplierModel({
    required this.id,
    required this.paymentNo,
    required this.supplierId,
    required this.supplierName,
    required this.paymentDate,
    required this.paymentMode,
    this.bankName,
    this.grnNo,
    required this.invoiceAmount,
    required this.amount,
    required this.paymentBalance,
    required this.status,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentToSupplierModel.fromJson(Map<String, dynamic> json) {
    return PaymentToSupplierModel(
      id: json["id"] ?? 0,
      paymentNo: json["payment_no"] ?? "",
      supplierId: json["supplier_id"] ?? 0,
      supplierName: json["supplier_name"] ?? "",
      paymentDate: json["payment_date"] ?? "",
      paymentMode: json["payment_mode"] ?? "",
      bankName: json["bank_name"],
      grnNo: json["grn_no"],
      invoiceAmount: double.tryParse(json["invoice_amount"].toString()) ?? 0,
      amount: double.tryParse(json["amount"].toString()) ?? 0,
      paymentBalance: double.tryParse(json["payment_balance"].toString()) ?? 0,
      status: json["status"] ?? "",
      remarks: json["remarks"],
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
    );
  }
}
class PaymentToSupplierResponse {
  final bool success;
  final String message;
  final List<PaymentToSupplierModel> data;

  PaymentToSupplierResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PaymentToSupplierResponse.fromJson(Map<String, dynamic> json) {
    List list = json["data"]?["data"] ?? [];

    return PaymentToSupplierResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: list.map((e) => PaymentToSupplierModel.fromJson(e)).toList(),
    );
  }
}