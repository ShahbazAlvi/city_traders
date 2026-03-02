class StockPositionModel {
  final bool success;
  final String message;
  final List<StockItem> items;

  StockPositionModel({
    required this.success,
    required this.message,
    required this.items,
  });

  factory StockPositionModel.fromJson(Map<String, dynamic> json) {
    return StockPositionModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      items: (json['data']['data'] as List)
          .map((e) => StockItem.fromJson(e))
          .toList(),
    );
  }
}
class StockItem {
  final int id;
  final String sku;
  final String? image;
  final String itemName;

  final String itemType;
  final String category;
  final String manufacturer;
  final String unit;
  final String unitShort;

  final String location;
  final String locationCode;

  final num minLevelQty;
  final num purchasePrice;
  final num salePrice;

  final num openingQty;
  final num inQty;
  final num outQty;
  final num balanceQty;

  final num avgRate;
  final num stockValue;

  final bool isActive;
  final DateTime? updatedAt;

  final StockBreakdown breakdown;

  StockItem({
    required this.id,
    required this.sku,
    required this.image,
    required this.itemName,
    required this.itemType,
    required this.category,
    required this.manufacturer,
    required this.unit,
    required this.unitShort,
    required this.location,
    required this.locationCode,
    required this.minLevelQty,
    required this.purchasePrice,
    required this.salePrice,
    required this.openingQty,
    required this.inQty,
    required this.outQty,
    required this.balanceQty,
    required this.avgRate,
    required this.stockValue,
    required this.isActive,
    required this.updatedAt,
    required this.breakdown,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    num toNum(dynamic v) => v == null ? 0 : num.tryParse(v.toString()) ?? 0;

    return StockItem(
      id: json['id'] ?? 0,
      sku: json['sku'] ?? '',
      image: json['image'],
      itemName: json['item_name'] ?? '',

      itemType: json['item_type'] ?? '',
      category: json['category'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      unit: json['unit'] ?? '',
      unitShort: json['unit_short'] ?? '',

      location: json['location'] ?? '',
      locationCode: json['location_code'] ?? '',

      minLevelQty: toNum(json['min_level_qty']),
      purchasePrice: toNum(json['purchase_price']),
      salePrice: toNum(json['sale_price']),

      openingQty: toNum(json['opening_qty']),
      inQty: toNum(json['in_qty']),
      outQty: toNum(json['out_qty']),
      balanceQty: toNum(json['balance_qty']),

      avgRate: toNum(json['avg_rate']),
      stockValue: toNum(json['stock_value']),

      isActive: json['is_active'] == 1,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,

      breakdown: StockBreakdown.fromJson(json['breakdown'] ?? {}),
    );
  }
}
class StockBreakdown {
  final num purchases;
  final num purchaseReturns;
  final num salesTax;
  final num salesNoTax;
  final num salesTotal;
  final num salesReturns;
  final num salesOrders;

  StockBreakdown({
    required this.purchases,
    required this.purchaseReturns,
    required this.salesTax,
    required this.salesNoTax,
    required this.salesTotal,
    required this.salesReturns,
    required this.salesOrders,
  });

  factory StockBreakdown.fromJson(Map<String, dynamic> json) {
    num toNum(dynamic v) => v == null ? 0 : num.tryParse(v.toString()) ?? 0;

    return StockBreakdown(
      purchases: toNum(json['purchases']),
      purchaseReturns: toNum(json['purchase_returns']),
      salesTax: toNum(json['sales_tax']),
      salesNoTax: toNum(json['sales_notax']),
      salesTotal: toNum(json['sales_total']),
      salesReturns: toNum(json['sales_returns']),
      salesOrders: toNum(json['sales_orders']),
    );
  }
}