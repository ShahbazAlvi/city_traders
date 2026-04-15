class EmployeeSalesmanModel {
  final int id;
  final String name;
  final String phone;
  final String address;
  final int departmentId;
  final int designationId;
  final String departmentName;
  final String designationName;
  final int isActive;
  final String createdAt;
  final String updatedAt;

  EmployeeSalesmanModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.departmentId,
    required this.designationId,
    required this.departmentName,
    required this.designationName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeSalesmanModel.fromJson(Map<String, dynamic> json) {
    return EmployeeSalesmanModel(
      id: json['id'],
      name: json['name'] ?? "",
      phone: json['phone'] ?? "",
      address: json['address'] ?? "",
      departmentId: json['department_id'],
      designationId: json['designation_id'],
      departmentName: json['department_name'] ?? "",
      designationName: json['designation_name'] ?? "",
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}