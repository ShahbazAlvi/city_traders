// class LocationModel {
//   final int id;
//   final String name;
//   final String code;
//   final String? address;
//   final int isActive;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//
//   LocationModel({
//     required this.id,
//     required this.name,
//     required this.code,
//     this.address,
//     required this.isActive,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory LocationModel.fromJson(Map<String, dynamic> json) {
//     return LocationModel(
//       id: json['id'],
//       name: json['name'],
//       code: json['code'],
//       address: json['address'],
//       isActive: json['is_active'],
//       createdAt: DateTime.parse(json['created_at']),
//       updatedAt: DateTime.parse(json['updated_at']),
//     );
//   }
// }


class LocationModel {
  final int id;
  final String name;
  final String? code; // ✅ nullable
  final String? address;
  final int isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  LocationModel({
    required this.id,
    required this.name,
    this.code,
    this.address,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      address: json['address'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}