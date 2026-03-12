// class CustomerInvoiceModel {
//   final List<CustomerInvoice> invoices;
//
//   CustomerInvoiceModel({required this.invoices});
//
//   factory CustomerInvoiceModel.fromJson(Map<String, dynamic> json) {
//     return CustomerInvoiceModel(
//       invoices: (json['data']['data'] as List)
//           .map((e) => CustomerInvoice.fromJson(e))
//           .toList(),
//     );
//   }
// }
//
// class CustomerInvoice {
//   final int id;
//   final String invNo;
//   final double netTotal;
//   final String status;
//
//   CustomerInvoice({
//     required this.id,
//     required this.invNo,
//     required this.netTotal,
//     required this.status,
//   });
//
//   factory CustomerInvoice.fromJson(Map<String, dynamic> json) {
//     return CustomerInvoice(
//       id: json['id'],
//       invNo: json['inv_no'],
//       netTotal: double.parse(json['net_total']),
//       status: json['status'],
//     );
//   }
// }

// model/customer_payment_model/InvoicePaymentModel.dart

// model/customer_payment_model/InvoicePaymentModel.dart

class CustomerInvoice {
  final int id;
  final String invNo;
  final DateTime invoiceDate;
  final String invType;       // "CASH" / "TAX"
  final String sourceTable;  // "NOTAX" / "TAX" — sent as invoice_type to API
  final double netTotal;
  final String status;

  CustomerInvoice({
    required this.id,
    required this.invNo,
    required this.invoiceDate,
    required this.invType,
    required this.sourceTable,
    required this.netTotal,
    required this.status,
  });

  /// For this API outstanding_balance is not returned,
  /// so effectiveAmount always equals netTotal
  double get effectiveAmount => netTotal;

  factory CustomerInvoice.fromJson(Map<String, dynamic> json) {
    return CustomerInvoice(
      id: json['id'],
      invNo: json['inv_no'],
      invoiceDate: DateTime.parse(json['invoice_date']),
      invType: json['inv_type'] ?? '',
      sourceTable: json['source_table'] ?? 'NOTAX',
      netTotal: double.parse(json['net_total'].toString()),
      status: json['status'] ?? '',
    );
  }
}

class CustomerInvoiceModel {
  final List<CustomerInvoice> invoices;
  CustomerInvoiceModel({required this.invoices});

  factory CustomerInvoiceModel.fromJson(Map<String, dynamic> json) {
    final list = json['data']['data'] as List;
    return CustomerInvoiceModel(
      invoices: list.map((e) => CustomerInvoice.fromJson(e)).toList(),
    );
  }
}