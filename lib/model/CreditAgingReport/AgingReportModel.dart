// AgingReportModel.dart
class CreditAgingReportModel {
  final bool success;
  final String message;
  final String asOfDate;
  final List<CreditAgingData> data;
  final Totals totals;

  CreditAgingReportModel({
    required this.success,
    required this.message,
    required this.asOfDate,
    required this.data,
    required this.totals,
  });

  factory CreditAgingReportModel.fromJson(Map<String, dynamic> json) {
    final innerData = json['data'];
    return CreditAgingReportModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      asOfDate: innerData['as_of_date'] ?? '',
      data: (innerData['data'] as List)
          .map((e) => CreditAgingData.fromJson(e))
          .toList(),
      totals: Totals.fromJson(innerData['totals']),
    );
  }
}

class CreditAgingData {
  final int sr;
  final int customerId;
  final String customerName;
  final String invoiceNo;
  final String invoiceKind;
  final String deliveryDate;
  final int allowDays;
  final int billDays;

  final double debit;
  final double credit;
  final double outstanding;
  final double underCredit;
  final double due;

  final String dueDate;
  final int salesmanId;
  final String salesmanName;

  CreditAgingData({
    required this.sr,
    required this.customerId,
    required this.customerName,
    required this.invoiceNo,
    required this.invoiceKind,
    required this.deliveryDate,
    required this.allowDays,
    required this.billDays,
    required this.debit,
    required this.credit,
    required this.outstanding,
    required this.underCredit,
    required this.due,
    required this.dueDate,
    required this.salesmanId,
    required this.salesmanName,
  });

  factory CreditAgingData.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      return (value as num).toDouble();
    }

    String formatDate(String? raw) {
      if (raw == null || raw.isEmpty) return '-';
      try {
        final dt = DateTime.parse(raw).toLocal();
        return "${dt.day.toString().padLeft(2, '0')}-"
            "${dt.month.toString().padLeft(2, '0')}-"
            "${dt.year}";
      } catch (_) {
        return raw;
      }
    }

    return CreditAgingData(
      sr: json['sr'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      invoiceNo: json['invoice_no'] ?? '',
      invoiceKind: json['invoice_kind'] ?? '',
      deliveryDate: formatDate(json['delivery_date']),
      allowDays: json['allow_days'] ?? 0,
      billDays: json['bill_days'] ?? 0,

      debit: toDouble(json['debit']),
      credit: toDouble(json['credit']),
      outstanding: toDouble(json['outstanding']),
      underCredit: toDouble(json['under_credit']),
      due: toDouble(json['due']),

      dueDate: formatDate(json['due_date']),
      salesmanId: json['salesman_id'] ?? 0,
      salesmanName: json['salesman_name'] ?? '',
    );
  }
}

class Totals {
  final double debit;
  final double credit;
  final double outstanding;
  final double underCredit;
  final double due;

  Totals({
    required this.debit,
    required this.credit,
    required this.outstanding,
    required this.underCredit,
    required this.due,
  });

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(
      debit: (json['debit'] ?? 0).toDouble(),
      credit: (json['credit'] ?? 0).toDouble(),
      outstanding: (json['outstanding'] ?? 0).toDouble(),
      underCredit: (json['under_credit'] ?? 0).toDouble(),
      due: (json['due'] ?? 0).toDouble(),
    );
  }
}