class DepartmentModel {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final int isActive;
  final String createdAt;
  final String updatedAt;

  DepartmentModel({
    required this.id,
    required this.name,
    this.code,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}