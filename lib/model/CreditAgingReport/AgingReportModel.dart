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
  final String deliveryDate; // stored as formatted string
  final int allowDays;
  final int billDays;
  final int debit;
  final int credit;
  final int outstanding;
  final int underCredit;
  final int due;
  final String dueDate;     // stored as formatted string
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
    // ✅ Fix: parse ISO timestamp and format to readable date
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
      sr:           json['sr']            ?? 0,
      customerId:   json['customer_id']   ?? 0,
      customerName: json['customer_name'] ?? '',
      invoiceNo:    json['invoice_no']    ?? '',
      invoiceKind:  json['invoice_kind']  ?? '',
      deliveryDate: formatDate(json['delivery_date']),  // ✅ parse ISO
      allowDays:    json['allow_days']    ?? 0,
      billDays:     json['bill_days']     ?? 0,
      debit:        json['debit']         ?? 0,
      credit:       json['credit']        ?? 0,
      outstanding:  json['outstanding']   ?? 0,
      underCredit:  json['under_credit']  ?? 0,
      due:          json['due']           ?? 0,
      dueDate:      formatDate(json['due_date']),        // ✅ parse ISO
      salesmanId:   json['salesman_id']   ?? 0,
      salesmanName: json['salesman_name'] ?? '',
    );
  }
}

class Totals {
  final int debit;
  final int credit;
  final int outstanding;
  final int underCredit;
  final int due;

  Totals({
    required this.debit,
    required this.credit,
    required this.outstanding,
    required this.underCredit,
    required this.due,
  });

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(
      debit:        json['debit']         ?? 0,
      credit:       json['credit']        ?? 0,
      outstanding:  json['outstanding']   ?? 0,
      underCredit:  json['under_credit']  ?? 0,
      due:          json['due']           ?? 0,
    );
  }
}