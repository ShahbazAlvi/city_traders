// model/SaleRecoveryModel/RecoveryCustomerInvoice.dart

class CustomerInvoice {
  final int id;
  final String invNo;
  final DateTime invoiceDate;
  final String invType;
  final double netTotal;
  final String status;
  final int customerId;
  final String customerName;
  final String sourceTable;
  final double? outstandingBalance;
  final DateTime? paymentDueDate;
  final bool hasPartialPayment;

  CustomerInvoice({
    required this.id,
    required this.invNo,
    required this.invoiceDate,
    required this.invType,
    required this.netTotal,
    required this.status,
    required this.customerId,
    required this.customerName,
    required this.sourceTable,
    this.outstandingBalance,
    this.paymentDueDate,
    required this.hasPartialPayment,
  });

  // ✅ ADD THIS — outstanding_balance if exists, else net_total
  double get effectiveAmount => outstandingBalance ?? netTotal;

  factory CustomerInvoice.fromJson(Map<String, dynamic> json) {
    return CustomerInvoice(
      id: json['id'],
      invNo: json['inv_no'],
      invoiceDate: DateTime.parse(json['invoice_date']),
      invType: json['inv_type'] ?? '',
      netTotal: double.parse(json['net_total'].toString()),
      status: json['status'] ?? '',
      customerId: json['customer_id'],
      customerName: json['customer_name'] ?? '',
      sourceTable: json['source_table'] ?? '',
      outstandingBalance: json['outstanding_balance'] != null
          ? double.parse(json['outstanding_balance'].toString())
          : null,
      paymentDueDate: json['payment_due_date'] != null
          ? DateTime.parse(json['payment_due_date'])
          : null,
      hasPartialPayment: json['has_partial_payment'] == 1,
    );
  }
}