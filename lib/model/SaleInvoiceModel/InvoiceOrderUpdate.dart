class SingleOrderModel {
  final bool success;
  final String message;
  final SingleOrderData data;

  SingleOrderModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SingleOrderModel.fromJson(Map<String, dynamic> json) {
    return SingleOrderModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: SingleOrderData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data.toJson(),
  };
}

class SingleOrderData {
  final int id;
  final String soNo;
  final int customerId;
  final String customerName;
  final int salesmanId;
  final String salesmanName;
  final int? salesAreaId; // ✅ Added field
  final DateTime orderDate;
  final String status;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderDetail> details;

  SingleOrderData({
    required this.id,
    required this.soNo,
    required this.customerId,
    required this.customerName,
    required this.salesmanId,
    required this.salesmanName,
    this.salesAreaId, // ✅ Added to constructor
    required this.orderDate,
    required this.status,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    required this.details,
  });

  factory SingleOrderData.fromJson(Map<String, dynamic> json) {
    return SingleOrderData(
      id: json['id'] ?? 0,
      soNo: json['so_no'] ?? '',
      customerId: json['customer_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      salesmanId: json['salesman_id'] ?? 0,
      salesmanName: json['salesman_name'] ?? '',
      salesAreaId: json['sales_area_id'], // ✅ Map from JSON
      orderDate: DateTime.parse(json['order_date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
      remarks: json['remarks'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      details: (json['details'] as List<dynamic>?)
          ?.map((e) => OrderDetail.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'so_no': soNo,
    'customer_id': customerId,
    'customer_name': customerName,
    'salesman_id': salesmanId,
    'salesman_name': salesmanName,
    'sales_area_id': salesAreaId, // ✅ Include in JSON
    'order_date': orderDate.toIso8601String(),
    'status': status,
    'remarks': remarks,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'details': details.map((e) => e.toJson()).toList(),
  };
}

class OrderDetail {
  final int id;
  final int itemId;
  final String itemName;
  final String itemSku;
  double qty;
  double rate;
  double lineTotal;
  final int unitId;
  final String unitName;

  OrderDetail({
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

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    return OrderDetail(
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'item_id': itemId,
    'item_name': itemName,
    'item_sku': itemSku,
    'qty': qty,
    'rate': rate,
    'line_total': lineTotal,
    'unit_id': unitId,
    'unit_name': unitName,
  };
}
