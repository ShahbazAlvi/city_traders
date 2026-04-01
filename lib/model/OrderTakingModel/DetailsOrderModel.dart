// lib/model/OrderTakingModel/detailsOrderModel.dart

class DetailsOrderModel {
  final bool success;
  final String message;
  final DetailsOrderData data;

  DetailsOrderModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DetailsOrderModel.fromJson(Map<String, dynamic> json) {
    return DetailsOrderModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: DetailsOrderData.fromJson(json['data']),
    );
  }
}

class DetailsOrderData {
  final int id;
  final String soNo;
  final int customerId;
  final String customerName;
  final int salesmanId;
  final String salesmanName;
  final DateTime orderDate;
  final String status;
  final String? remarks;
  final List<DetailsOrderItem> details;

  DetailsOrderData({
    required this.id,
    required this.soNo,
    required this.customerId,
    required this.customerName,
    required this.salesmanId,
    required this.salesmanName,
    required this.orderDate,
    required this.status,
    this.remarks,
    required this.details,
  });

  factory DetailsOrderData.fromJson(Map<String, dynamic> json) {
    return DetailsOrderData(
      id: json['id'],
      soNo: json['so_no'] ?? '',
      customerId: json['customer_id'],
      customerName: json['customer_name'] ?? '',
      salesmanId: json['salesman_id'],
      salesmanName: json['salesman_name'] ?? '',
      orderDate: DateTime.parse(json['order_date']),
      status: json['status'] ?? '',
      remarks: json['remarks'],
      details: (json['details'] as List<dynamic>)
          .map((e) => DetailsOrderItem.fromJson(e))
          .toList(),
    );
  }

  double get grandTotal =>
      details.fold(0.0, (sum, d) => sum + d.lineTotal);
}

class DetailsOrderItem {
  final int id;
  final int itemId;
  final String itemName;
  final String itemSku;
  double qty;
  double rate;
  double lineTotal;
  final int unitId;
  final String unitName;
  final double remainingQty;
  final double salePrice;

  DetailsOrderItem({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.itemSku,
    required this.qty,
    required this.rate,
    required this.lineTotal,
    required this.unitId,
    required this.unitName,
    required this.remainingQty,
    required this.salePrice,
  });

  factory DetailsOrderItem.fromJson(Map<String, dynamic> json) {
    return DetailsOrderItem(
      id: json['id'],
      itemId: json['item_id'],
      itemName: json['item_name'] ?? '',
      itemSku: json['item_sku'] ?? '',
      qty: double.tryParse(json['qty'].toString()) ?? 0,
      rate: double.tryParse(json['rate'].toString()) ?? 0,
      lineTotal: double.tryParse(json['line_total'].toString()) ?? 0,
      unitId: json['unit_id'] ?? 0,
      unitName: json['unit_name'] ?? '',
      remainingQty: double.tryParse(json['remaining_qty'].toString()) ?? 0,
      salePrice: double.tryParse(json['sale_price'].toString()) ?? 0,
    );
  }
}