class OrderTakingModel {
  final bool success;
  final String message;
  final List<OrderData> data;

  OrderTakingModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory OrderTakingModel.fromJson(Map<String, dynamic> json) {
    return OrderTakingModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data']['data'] as List<dynamic>?)
          ?.map((e) => OrderData.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': {'data': data.map((e) => e.toJson()).toList()},
  };
}

class OrderData {
  final String id;
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
  final int totalItems;
  final double totalQty;
  final double totalAmount;

  OrderData({
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
    required this.totalItems,
    required this.totalQty,
    required this.totalAmount,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    return OrderData(
      id: json['id'].toString(),
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
      totalItems: json['total_items'] ?? 0,
      totalQty: parseDouble(json['total_qty']),
      totalAmount: parseDouble(json['total_amount']),
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
    'total_items': totalItems,
    'total_qty': totalQty,
    'total_amount': totalAmount,
  };
}
