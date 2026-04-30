// class DeliveryBoyResponse {
//   final bool success;
//   final String message;
//   final DeliveryBoyData data;
//
//   DeliveryBoyResponse({
//     required this.success,
//     required this.message,
//     required this.data,
//   });
//
//   factory DeliveryBoyResponse.fromJson(Map<String, dynamic> json) {
//     return DeliveryBoyResponse(
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       data: DeliveryBoyData.fromJson(json['data']),
//     );
//   }
// }
//
// class DeliveryBoyData {
//   final List<DeliveryBoy> data;
//
//   DeliveryBoyData({required this.data});
//
//   factory DeliveryBoyData.fromJson(Map<String, dynamic> json) {
//     return DeliveryBoyData(
//       data: (json['data'] as List<dynamic>)
//           .map((e) => DeliveryBoy.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
// }
//
// class DeliveryBoy {
//   final int id;
//   final int? companyId;
//   final int? createdBy;
//   final int? updatedBy;
//   final int? employeeId;
//   final int? salesmanId;
//   final String name;
//   final String? phone;
//   final int isActive;
//   final String createdAt;
//   final String updatedAt;
//   final String salesmanName;
//   final List<int> areaIds;
//   final String areaNames;
//   final int userId;
//   final String username;
//
//   DeliveryBoy({
//     required this.id,
//     this.companyId,
//     this.createdBy,
//     this.updatedBy,
//     this.employeeId,
//     this.salesmanId,
//     required this.name,
//     this.phone,
//     required this.isActive,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.salesmanName,
//     required this.areaIds,
//     required this.areaNames,
//     required this.userId,
//     required this.username,
//   });
//
//   bool get active => isActive == 1;
//
//   factory DeliveryBoy.fromJson(Map<String, dynamic> json) {
//     return DeliveryBoy(
//       id: json['id'] as int,
//       companyId: json['company_id'] as int?,
//       createdBy: json['created_by'] as int?,
//       updatedBy: json['updated_by'] as int?,
//       employeeId: json['employee_id'] as int?,
//       salesmanId: json['salesman_id'] as int?,
//       name: json['name'] ?? '',
//       phone: json['phone'] as String?,
//       isActive: json['is_active'] ?? 0,
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       salesmanName: json['salesman_name'] ?? '',
//       areaIds: (json['area_ids'] as List<dynamic>).map((e) => e as int).toList(),
//       areaNames: json['area_names'] ?? '',
//       userId: json['user_id'] as int,
//       username: json['username'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'company_id': companyId,
//       'created_by': createdBy,
//       'updated_by': updatedBy,
//       'employee_id': employeeId,
//       'salesman_id': salesmanId,
//       'name': name,
//       'phone': phone,
//       'is_active': isActive,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//       'salesman_name': salesmanName,
//       'area_ids': areaIds,
//       'area_names': areaNames,
//       'user_id': userId,
//       'username': username,
//     };
//   }
// }


class DeliveryBoyResponse {
  final bool success;
  final String message;
  final DeliveryBoyData data;

  DeliveryBoyResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DeliveryBoyResponse.fromJson(Map<String, dynamic> json) {
    return DeliveryBoyResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? DeliveryBoyData.fromJson(json['data'])
          : DeliveryBoyData(data: []),
    );
  }
}

class DeliveryBoyData {
  final List<DeliveryBoy> data;

  DeliveryBoyData({required this.data});

  factory DeliveryBoyData.fromJson(Map<String, dynamic> json) {
    return DeliveryBoyData(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => DeliveryBoy.fromJson(e))
          .toList(),
    );
  }
}

class DeliveryBoy {
  final int id;
  final int? companyId;
  final int? createdBy;
  final int? updatedBy;
  final int? employeeId;
  final int? salesmanId;
  final String name;
  final String? phone;
  final int isActive;
  final String createdAt;
  final String updatedAt;
  final String salesmanName;
  final List<int> areaIds;
  final String areaNames;
  final int userId;
  final String username;

  DeliveryBoy({
    required this.id,
    this.companyId,
    this.createdBy,
    this.updatedBy,
    this.employeeId,
    this.salesmanId,
    required this.name,
    this.phone,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.salesmanName,
    required this.areaIds,
    required this.areaNames,
    required this.userId,
    required this.username,
  });

  bool get active => isActive == 1;

  factory DeliveryBoy.fromJson(Map<String, dynamic> json) {
    return DeliveryBoy(
      id: json['id'] ?? 0,
      companyId: json['company_id'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      employeeId: json['employee_id'],
      salesmanId: json['salesman_id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      isActive: json['is_active'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      salesmanName: json['salesman_name'] ?? '',
      areaIds: (json['area_ids'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
      areaNames: json['area_names'] ?? '',
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'employee_id': employeeId,
      'salesman_id': salesmanId,
      'name': name,
      'phone': phone,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'salesman_name': salesmanName,
      'area_ids': areaIds,
      'area_names': areaNames,
      'user_id': userId,
      'username': username,
    };
  }
}