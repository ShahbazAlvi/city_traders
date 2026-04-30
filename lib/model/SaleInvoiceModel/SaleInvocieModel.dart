class SaleInvoiceModel {
  final bool success;
  final String message;
  final List<SaleInvoiceData> invoices;

  SaleInvoiceModel({
    required this.success,
    required this.message,
    required this.invoices,
  });

  factory SaleInvoiceModel.fromJson(Map<String, dynamic> json) {
    final invoiceList = json["data"]?["data"] as List? ?? [];

    return SaleInvoiceModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      invoices: invoiceList
          .map((e) => SaleInvoiceData.fromJson(e))
          .toList(),
    );
  }

}

class SaleInvoiceData {
  final int id;

  final int? salesOrderId;        // ✅ nullable
  final String? salesOrderNo;     // ✅ nullable

  final String invNo;

  final int customerId;
  final String customerName;

  final int salesmanId;
  final String salesmanName;

  final int? loadId;
  final String? loadNo;

  final int? salesAreaId;         // ✅ Added
  final String? salesAreaName;

  final int? deliveryBoyId;       // ✅ Added
  final String? deliveryBoyName;

  final DateTime invoiceDate;

  final int locationId;
  final String locationName;

  final String invoiceType;

  final double grossTotal;
  final double netTotal;

  final String status;
  final String? remarks;

  final DateTime createdAt;
  final DateTime updatedAt;

  final int totalItems;
  final double totalQty;

  SaleInvoiceData({
    required this.id,
    this.salesOrderId,
    this.salesOrderNo,
    required this.invNo,
    required this.customerId,
    required this.customerName,
    required this.salesmanId,
    required this.salesmanName,
    this.loadId,
    this.loadNo,
    this.salesAreaId,
    this.salesAreaName,
    this.deliveryBoyId,
    this.deliveryBoyName,
    required this.invoiceDate,
    required this.locationId,
    required this.locationName,
    required this.invoiceType,
    required this.grossTotal,
    required this.netTotal,
    required this.status,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    required this.totalItems,
    required this.totalQty,
  });

  factory SaleInvoiceData.fromJson(Map<String, dynamic> json) {
    return SaleInvoiceData(
      id: json["id"] ?? 0,
      salesOrderId: json["sales_order_id"],       // ✅ no crash
      salesOrderNo: json["sales_order_no"],

      invNo: json["inv_no"] ?? "",

      customerId: json["customer_id"] ?? 0,
      customerName: json["customer_name"] ?? "",

      salesmanId: json["salesman_id"] ?? 0,
      salesmanName: json["salesman_name"] ?? "",

      loadId: json["load_id"],
      loadNo: json["load_no"],

      salesAreaId: json["sales_area_id"],
      salesAreaName: json["sales_area_name"],

      deliveryBoyId: json["delivery_boy_id"],
      deliveryBoyName: json["delivery_boy_name"],

      invoiceDate: DateTime.tryParse(json["invoice_date"] ?? "") ?? DateTime.now(),

      locationId: json["location_id"] ?? 0,
      locationName: json["location_name"] ?? "",

      invoiceType: json["invoice_type"] ?? "",

      grossTotal: _toDouble(json["gross_total"]),
      netTotal: _toDouble(json["net_total"]),

      status: json["status"] ?? "",
      remarks: json["remarks"],

      createdAt: DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? "") ?? DateTime.now(),

      totalItems: json["total_items"] ?? 0,
      totalQty: _toDouble(json["total_qty"]),
    );
  }
}


double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is int) return value.toDouble();
  if (value is double) return value;
  return double.parse(value.toString());
}
