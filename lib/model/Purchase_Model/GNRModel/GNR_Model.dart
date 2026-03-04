class GRNResponseModel {
  final bool success;
  final String message;
  final List<GRNModel> grnList;

  GRNResponseModel({
    required this.success,
    required this.message,
    required this.grnList,
  });

  factory GRNResponseModel.fromJson(Map<String, dynamic> json) {
    return GRNResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      grnList: (json['data']['data'] as List)
          .map((e) => GRNModel.fromJson(e))
          .toList(),
    );
  }
}
class GRNModel {
  final int id;
  final String grnNo;
  final int supplierId;
  final String supplierName;
  final int? poId;
  final String? poNo;
  final DateTime grnDate;
  final int locationId;
  final String locationName;
  final String status;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalItems;
  final double totalQty;
  final double totalAmount;

  GRNModel({
    required this.id,
    required this.grnNo,
    required this.supplierId,
    required this.supplierName,
    this.poId,
    this.poNo,
    required this.grnDate,
    required this.locationId,
    required this.locationName,
    required this.status,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    required this.totalItems,
    required this.totalQty,
    required this.totalAmount,
  });

  factory GRNModel.fromJson(Map<String, dynamic> json) {
    return GRNModel(
      id: json['id'],
      grnNo: json['grn_no'] ?? '',
      supplierId: json['supplier_id'] ?? 0,
      supplierName: json['supplier_name'] ?? '',
      poId: json['po_id'],
      poNo: json['po_no'],
      grnDate: DateTime.parse(json['grn_date']),
      locationId: json['location_id'] ?? 0,
      locationName: json['location_name'] ?? '',
      status: json['status'] ?? '',
      remarks: json['remarks'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      totalItems: json['total_items'] ?? 0,
      totalQty: double.tryParse(json['total_qty'].toString()) ?? 0.0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
    );
  }
}