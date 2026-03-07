class TaxModel {
  final int id;
  final String name;
  final String ratePercent;
  final int isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaxModel({
    required this.id,
    required this.name,
    required this.ratePercent,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      ratePercent: json['rate_percent'] ?? '0',
      isActive: json['is_active'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}