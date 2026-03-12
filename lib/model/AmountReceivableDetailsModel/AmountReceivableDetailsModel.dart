class AmountReceivableModel {
  final bool success;
  final String message;
  final AmountReceivableData data;

  AmountReceivableModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AmountReceivableModel.fromJson(Map<String, dynamic> json) {
    return AmountReceivableModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: AmountReceivableData.fromJson(json["data"] ?? {}),
    );
  }
}
class AmountReceivableData {
  final List<CustomerReceivable> customers;
  final ReceivableSummary summary;

  AmountReceivableData({
    required this.customers,
    required this.summary,
  });

  factory AmountReceivableData.fromJson(Map<String, dynamic> json) {
    return AmountReceivableData(
      customers: (json["data"] as List? ?? [])
          .map((e) => CustomerReceivable.fromJson(e))
          .toList(),
      summary: ReceivableSummary.fromJson(json["summary"] ?? {}),
    );
  }
}
class CustomerReceivable {
  final int customerId;
  final String customerName;
  final double openingBalance;
  final List<ReceivableInvoice> invoices;
  final double totalNet;
  final double totalReceived;
  final double totalBalance;
  final double grandBalance;

  CustomerReceivable({
    required this.customerId,
    required this.customerName,
    required this.openingBalance,
    required this.invoices,
    required this.totalNet,
    required this.totalReceived,
    required this.totalBalance,
    required this.grandBalance,
  });

  factory CustomerReceivable.fromJson(Map<String, dynamic> json) {
    return CustomerReceivable(
      customerId: json["customer_id"] ?? 0,
      customerName: json["customer_name"] ?? "",
      openingBalance: (json["opening_balance"] ?? 0).toDouble(),
      invoices: (json["invoices"] as List? ?? [])
          .map((e) => ReceivableInvoice.fromJson(e))
          .toList(),
      totalNet: (json["total_net"] ?? 0).toDouble(),
      totalReceived: (json["total_received"] ?? 0).toDouble(),
      totalBalance: (json["total_balance"] ?? 0).toDouble(),
      grandBalance: (json["grand_balance"] ?? 0).toDouble(),
    );
  }
}
class ReceivableInvoice {
  final int id;
  final String invNo;
  final DateTime invoiceDate;
  final String invoiceType;
  final double grossTotal;
  final double taxTotal;
  final double netTotal;
  final double receivedViaPayments;
  final double receivedViaRecovery;
  final double received;
  final double balance;
  final String status;
  final int salesmanId;
  final String salesmanName;
  final int locationId;
  final String locationName;
  final String? remarks;
  final DateTime updatedAt;

  ReceivableInvoice({
    required this.id,
    required this.invNo,
    required this.invoiceDate,
    required this.invoiceType,
    required this.grossTotal,
    required this.taxTotal,
    required this.netTotal,
    required this.receivedViaPayments,
    required this.receivedViaRecovery,
    required this.received,
    required this.balance,
    required this.status,
    required this.salesmanId,
    required this.salesmanName,
    required this.locationId,
    required this.locationName,
    this.remarks,
    required this.updatedAt,
  });

  factory ReceivableInvoice.fromJson(Map<String, dynamic> json) {
    return ReceivableInvoice(
      id: json["id"] ?? 0,
      invNo: json["inv_no"] ?? "",
      invoiceDate: DateTime.parse(json["invoice_date"]),
      invoiceType: json["invoice_type"] ?? "",
      grossTotal: (json["gross_total"] ?? 0).toDouble(),
      taxTotal: (json["tax_total"] ?? 0).toDouble(),
      netTotal: (json["net_total"] ?? 0).toDouble(),
      receivedViaPayments: (json["received_via_payments"] ?? 0).toDouble(),
      receivedViaRecovery: (json["received_via_recovery"] ?? 0).toDouble(),
      received: (json["received"] ?? 0).toDouble(),
      balance: (json["balance"] ?? 0).toDouble(),
      status: json["status"] ?? "",
      salesmanId: json["salesman_id"] ?? 0,
      salesmanName: json["salesman_name"] ?? "",
      locationId: json["location_id"] ?? 0,
      locationName: json["location_name"] ?? "",
      remarks: json["remarks"],
      updatedAt: DateTime.parse(json["updated_at"]),
    );
  }
}
class ReceivableSummary {
  final int totalCustomers;
  final int totalRecords;
  final double totalOpeningBalance;
  final double totalNet;
  final double totalReceived;
  final double totalBalance;
  final double totalGrandBalance;
  final int countPaid;
  final int countPartial;
  final int countOpen;

  ReceivableSummary({
    required this.totalCustomers,
    required this.totalRecords,
    required this.totalOpeningBalance,
    required this.totalNet,
    required this.totalReceived,
    required this.totalBalance,
    required this.totalGrandBalance,
    required this.countPaid,
    required this.countPartial,
    required this.countOpen,
  });

  factory ReceivableSummary.fromJson(Map<String, dynamic> json) {
    return ReceivableSummary(
      totalCustomers: json["total_customers"] ?? 0,
      totalRecords: json["total_records"] ?? 0,
      totalOpeningBalance: (json["total_opening_balance"] ?? 0).toDouble(),
      totalNet: (json["total_net"] ?? 0).toDouble(),
      totalReceived: (json["total_received"] ?? 0).toDouble(),
      totalBalance: (json["total_balance"] ?? 0).toDouble(),
      totalGrandBalance: (json["total_grand_balance"] ?? 0).toDouble(),
      countPaid: json["count_paid"] ?? 0,
      countPartial: json["count_partial"] ?? 0,
      countOpen: json["count_open"] ?? 0,
    );
  }
}