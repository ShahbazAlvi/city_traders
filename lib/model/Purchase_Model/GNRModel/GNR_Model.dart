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

class GRNDetailModel {
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
  final double discount;
  final double taxPercent;
  final double taxAmount;
  final double netAmount;
  final DateTime? agingDueDate;
  final List<GRNDetailItem> details;

  GRNDetailModel({
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
    required this.discount,
    required this.taxPercent,
    required this.taxAmount,
    required this.netAmount,
    this.agingDueDate,
    required this.details,
  });

  factory GRNDetailModel.fromJson(Map<String, dynamic> json) {
    return GRNDetailModel(
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
      discount: double.tryParse(json['discount'].toString()) ?? 0.0,
      taxPercent: double.tryParse(json['tax_percent'].toString()) ?? 0.0,
      taxAmount: double.tryParse(json['tax_amount'].toString()) ?? 0.0,
      netAmount: double.tryParse(json['net_amount'].toString()) ?? 0.0,
      agingDueDate: json['aging_due_date'] != null ? DateTime.parse(json['aging_due_date']) : null,
      details: (json['details'] as List? ?? [])
          .map((e) => GRNDetailItem.fromJson(e))
          .toList(),
    );
  }
}

class GRNDetailItem {
  final int id;
  final int itemId;
  final String itemName;
  final String itemSku;
  final double qtyReceived;
  final double unitCost;
  final double lineTotal;
  final int unitId;
  final String unitName;

  GRNDetailItem({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.itemSku,
    required this.qtyReceived,
    required this.unitCost,
    required this.lineTotal,
    required this.unitId,
    required this.unitName,
  });

  factory GRNDetailItem.fromJson(Map<String, dynamic> json) {
    return GRNDetailItem(
      id: json['id'],
      itemId: json['item_id'],
      itemName: json['item_name'] ?? '',
      itemSku: json['item_sku'] ?? '',
      qtyReceived: double.tryParse(json['qty_received'].toString()) ?? 0.0,
      unitCost: double.tryParse(json['unit_cost'].toString()) ?? 0.0,
      lineTotal: double.tryParse(json['line_total'].toString()) ?? 0.0,
      unitId: json['unit_id'] ?? 0,
      unitName: json['unit_name'] ?? '',
    );
  }
}