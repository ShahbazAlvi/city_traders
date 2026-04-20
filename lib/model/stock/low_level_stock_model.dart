class LowLevelStockModel {
  final bool success;
  final String message;
  final List<LowStockItem> data;

  LowLevelStockModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LowLevelStockModel.fromJson(Map<String, dynamic> json) {
    final list = (json['data']['data'] as List<dynamic>? ?? [])
        .map((e) => LowStockItem.fromJson(e))
        .toList();
    return LowLevelStockModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: list,
    );
  }
}

class LowStockItem {
  final int id;
  final String sku;
  final String itemName;
  final String category;
  final String subcategory;
  final String manufacturer;
  final String unit;
  final String unitShort;
  final String location;
  final double minLevelQty;
  final double inStock;
  final double shortage;
  final String status;
  final bool isActive;
  final DateTime updatedAt;

  LowStockItem({
    required this.id,
    required this.sku,
    required this.itemName,
    required this.category,
    required this.subcategory,
    required this.manufacturer,
    required this.unit,
    required this.unitShort,
    required this.location,
    required this.minLevelQty,
    required this.inStock,
    required this.shortage,
    required this.status,
    required this.isActive,
    required this.updatedAt,
  });

  bool get isLow => status.toUpperCase() == 'LOW';
  bool get isCritical => inStock <= 0;

  factory LowStockItem.fromJson(Map<String, dynamic> json) {
    return LowStockItem(
      id:           json['id'] as int,
      sku:          json['sku'] ?? '',
      itemName:     json['item_name'] ?? '',
      category:     json['category'] ?? '',
      subcategory:  json['subcategory'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      unit:         json['unit'] ?? '',
      unitShort:    json['unit_short'] ?? '',
      location:     json['location'] ?? '',
      minLevelQty:  (json['min_level_qty'] as num).toDouble(),
      inStock:      (json['in_stock'] as num).toDouble(),
      shortage:     (json['shortage'] as num).toDouble(),
      status:       json['status'] ?? '',
      isActive:     (json['is_active'] ?? 0) == 1,
      updatedAt:    DateTime.parse(json['updated_at']),
    );
  }
}