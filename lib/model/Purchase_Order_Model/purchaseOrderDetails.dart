class PurchaseOrderDetailModel {
  final bool success;
  final String message;
  final PurchaseOrderDetailData data;

  PurchaseOrderDetailModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PurchaseOrderDetailModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderDetailModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: PurchaseOrderDetailData.fromJson(json['data'] ?? {}),
    );
  }
}

class PurchaseOrderDetailData {
  final int id;
  final String poNo;
  final int supplierId;
  final String supplierName;
  final DateTime poDate;
  final String status;
  final String? remarks;
  final double taxPercent;
  final double taxAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PurchaseOrderDetailItem> details;

  PurchaseOrderDetailData({
    required this.id,
    required this.poNo,
    required this.supplierId,
    required this.supplierName,
    required this.poDate,
    required this.status,
    this.remarks,
    required this.taxPercent,
    required this.taxAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.details,
  });

  factory PurchaseOrderDetailData.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return PurchaseOrderDetailData(
      id: json['id'] ?? 0,
      poNo: json['po_no'] ?? '',
      supplierId: json['supplier_id'] ?? 0,
      supplierName: json['supplier_name'] ?? '',
      poDate: DateTime.parse(
          json['po_date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
      remarks: json['remarks'],
      taxPercent: parseDouble(json['tax_percent']),
      taxAmount: parseDouble(json['tax_amount']),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      details: (json['details'] as List<dynamic>?)
          ?.map((e) => PurchaseOrderDetailItem.fromJson(e))
          .toList() ??
          [],
    );
  }

  double get subTotal =>
      details.fold(0.0, (sum, d) => sum + d.lineTotal);

  double get grandTotal => subTotal + taxAmount;
}

class PurchaseOrderDetailItem {
  final int id;
  final int itemId;
  final String itemName;
  final String itemSku;
  final double qty;
  final double rate;
  final double lineTotal;
  final int unitId;
  final String unitName;

  PurchaseOrderDetailItem({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.itemSku,
    required this.qty,
    required this.rate,
    required this.lineTotal,
    required this.unitId,
    required this.unitName,
  });

  factory PurchaseOrderDetailItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return PurchaseOrderDetailItem(
      id: json['id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      itemName: json['item_name'] ?? '',
      itemSku: json['item_sku'] ?? '',
      qty: parseDouble(json['qty']),
      rate: parseDouble(json['rate']),
      lineTotal: parseDouble(json['line_total']),
      unitId: json['unit_id'] ?? 0,
      unitName: json['unit_name'] ?? '',
    );
  }
}