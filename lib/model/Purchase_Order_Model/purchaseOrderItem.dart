class PurchaseOrderItem {
  final int id;
  final int itemId;
  final String itemName;
  final String itemSku;
  final double qty;
  final double rate;
  final double lineTotal;
  final int unitId;
  final String unitName;

  PurchaseOrderItem({
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

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      id: json['id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      itemName: json['item_name'] ?? '',
      itemSku: json['item_sku'] ?? '',
      qty: double.tryParse(json['qty'].toString()) ?? 0.0,
      rate: double.tryParse(json['rate'].toString()) ?? 0.0,
      lineTotal: double.tryParse(json['line_total'].toString()) ?? 0.0,
      unitId: json['unit_id'] ?? 0,
      unitName: json['unit_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
}