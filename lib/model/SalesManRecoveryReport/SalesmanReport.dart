// model/Recovery_Model/RecoveryModel.dart salesman

class RecoveryResponse {
  final bool success;
  final String message;
  final RecoveryData data;

  RecoveryResponse({required this.success, required this.message, required this.data});

  factory RecoveryResponse.fromJson(Map<String, dynamic> json) {
    return RecoveryResponse(
      success: json['success'],
      message: json['message'],
      data: RecoveryData.fromJson(json['data']),
    );
  }
}

class RecoveryData {
  final List<RecoveryEntry> data;
  final RecoverySummary summary;

  RecoveryData({required this.data, required this.summary});

  factory RecoveryData.fromJson(Map<String, dynamic> json) {
    return RecoveryData(
      data: (json['data'] as List).map((e) => RecoveryEntry.fromJson(e)).toList(),
      summary: RecoverySummary.fromJson(json['summary']),
    );
  }
}

class RecoveryEntry {
  final int salesmanId;
  final String salesmanName;
  final int recoveryCount;
  final int customerCount;
  final double totalRecovered;

  RecoveryEntry({
    required this.salesmanId,
    required this.salesmanName,
    required this.recoveryCount,
    required this.customerCount,
    required this.totalRecovered,
  });

  factory RecoveryEntry.fromJson(Map<String, dynamic> json) {
    return RecoveryEntry(
      salesmanId: json['salesman_id'],
      salesmanName: json['salesman_name'],
      recoveryCount: json['recovery_count'],
      customerCount: json['customer_count'],
      totalRecovered: double.parse(json['total_recovered'].toString()),
    );
  }
}

class RecoverySummary {
  final int totalSalesmen;
  final double totalRecovered;
  final int totalRecoveries;

  RecoverySummary({
    required this.totalSalesmen,
    required this.totalRecovered,
    required this.totalRecoveries,
  });

  factory RecoverySummary.fromJson(Map<String, dynamic> json) {
    return RecoverySummary(
      totalSalesmen: json['total_salesmen'],
      totalRecovered: json['total_recovered'].toDouble(),
      totalRecoveries: json['total_recoveries'],
    );
  }
}