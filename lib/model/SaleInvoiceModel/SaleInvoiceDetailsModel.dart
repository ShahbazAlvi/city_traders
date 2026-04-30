class SaleInvoiceDetailModel {
  final bool success;
  final String message;
  final SaleInvoiceDetailData data;

  SaleInvoiceDetailModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SaleInvoiceDetailModel.fromJson(Map<String, dynamic> json) {
    return SaleInvoiceDetailModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: SaleInvoiceDetailData.fromJson(json['data'] ?? {}),
    );
  }
}

class SaleInvoiceDetailData {
  final int id;
  final int? salesOrderId;
  final String? salesOrderNo;
  final String invNo;
  final int customerId;
  final String customerName;
  final int salesmanId;
  final String salesmanName;
  final int? loadId;
  final String? loadNo;
  final int? salesAreaId;
  final String? salesAreaName;
  final int? deliveryBoyId;
  final String? deliveryBoyName;
  final DateTime invoiceDate;
  final int? locationId;
  final String? locationName;
  final String invoiceType;
  final double grossTotal;
  final double netTotal;
  final String status;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<InvoiceDetailItem> details;

  SaleInvoiceDetailData({
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
    this.locationId,
    this.locationName,
    required this.invoiceType,
    required this.grossTotal,
    required this.netTotal,
    required this.status,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    required this.details,
  });

  factory SaleInvoiceDetailData.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return SaleInvoiceDetailData(
      id: json['id'] ?? 0,
      salesOrderId: json['sales_order_id'],
      salesOrderNo: json['sales_order_no'],
      invNo: json['inv_no'] ?? '',
      customerId: json['customer_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      salesmanId: json['salesman_id'] ?? 0,
      salesmanName: json['salesman_name'] ?? '',
      loadId: json['load_id'],
      loadNo: json['load_no'],
      salesAreaId: json['sales_area_id'],
      salesAreaName: json['sales_area_name'],
      deliveryBoyId: json['delivery_boy_id'],
      deliveryBoyName: json['delivery_boy_name'],
      invoiceDate: DateTime.parse(
          json['invoice_date'] ?? DateTime.now().toIso8601String()),
      locationId: json['location_id'],
      locationName: json['location_name'],
      invoiceType: json['invoice_type'] ?? '',
      grossTotal: parseDouble(json['gross_total']),
      netTotal: parseDouble(json['net_total']),
      status: json['status'] ?? '',
      remarks: json['remarks'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      details: (json['details'] as List<dynamic>?)
          ?.map((e) => InvoiceDetailItem.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class InvoiceDetailItem {
  final int id;
  final int itemId;
  final String itemName;
  final String itemSku;
  final double qty;
  final double rate;
  final double lineTotal;
  final int unitId;
  final String unitName;

  InvoiceDetailItem({
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

  factory InvoiceDetailItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return InvoiceDetailItem(
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