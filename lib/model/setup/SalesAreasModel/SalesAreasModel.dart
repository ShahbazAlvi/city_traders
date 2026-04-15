class SalesAreaModel {
  final int id;
  final String name;
  final int isActive;
  final String createdAt;
  final String updatedAt;

  SalesAreaModel({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalesAreaModel.fromJson(Map<String, dynamic> json) {
    return SalesAreaModel(
      id: json['id'],
      name: json['name'],
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}