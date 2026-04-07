class LoadSheetDetail {
  int? soId;
  int itemId;
  String itemName;
  double qtyLoaded;

  LoadSheetDetail({
    this.soId,
    required this.itemId,
    required this.itemName,
    required this.qtyLoaded,
  });

  Map<String, dynamic> toJson() => {
    if (soId != null) 'so_id': soId,
    'item_id': itemId,
    'qty_loaded': qtyLoaded,
  };
}