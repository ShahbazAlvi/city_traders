class KpiCards {
  final double totalSales;
  final double totalPurchases;
  final double totalPaymentsIn;
  final double totalPaymentsOut;
  final double totalRecoveries;
  final double totalCustomerPayments;
  final double grossProfit;
  final double netCash;

  KpiCards({
    required this.totalSales,
    required this.totalPurchases,
    required this.totalPaymentsIn,
    required this.totalPaymentsOut,
    required this.totalRecoveries,
    required this.totalCustomerPayments,
    required this.grossProfit,
    required this.netCash,
  });

  factory KpiCards.fromJson(Map<String, dynamic> j) => KpiCards(
    totalSales: (j['total_sales'] as num).toDouble(),
    totalPurchases: (j['total_purchases'] as num).toDouble(),
    totalPaymentsIn: (j['total_payments_in'] as num).toDouble(),
    totalPaymentsOut: (j['total_payments_out'] as num).toDouble(),
    totalRecoveries: (j['total_recoveries'] as num).toDouble(),
    totalCustomerPayments: (j['total_customer_payments'] as num).toDouble(),
    grossProfit: (j['gross_profit'] as num).toDouble(),
    netCash: (j['net_cash'] as num).toDouble(),
  );
}

class TrendPoint {
  final String month;
  final double sales;
  final double purchases;
  final double paymentsIn;
  final double paymentsOut;
  final double recoveries;

  TrendPoint({
    required this.month,
    required this.sales,
    required this.purchases,
    required this.paymentsIn,
    required this.paymentsOut,
    required this.recoveries,
  });

  factory TrendPoint.fromJson(Map<String, dynamic> j) {
    final raw = j['month'] as String;
    final dt = DateTime.tryParse(raw);
    final label = dt != null ? 'Mar ${dt.day}' : raw.substring(5);
    return TrendPoint(
      month: label,
      sales: (j['sales'] as num).toDouble(),
      purchases: (j['purchases'] as num).toDouble(),
      paymentsIn: (j['paymentsIn'] as num).toDouble(),
      paymentsOut: (j['paymentsOut'] as num).toDouble(),
      recoveries: (j['recoveries'] as num).toDouble(),
    );
  }
}

class InvoiceGroup {
  final int count;
  final double amount;
  InvoiceGroup({required this.count, required this.amount});
  factory InvoiceGroup.fromJson(Map<String, dynamic> j) =>
      InvoiceGroup(count: j['count'] as int, amount: (j['amount'] as num).toDouble());
}

class InvoiceStatus {
  final InvoiceGroup paid;
  final InvoiceGroup receivable;
  final InvoiceGroup overdue;
  InvoiceStatus({required this.paid, required this.receivable, required this.overdue});
  factory InvoiceStatus.fromJson(Map<String, dynamic> j) => InvoiceStatus(
    paid: InvoiceGroup.fromJson(j['paid']),
    receivable: InvoiceGroup.fromJson(j['receivable']),
    overdue: InvoiceGroup.fromJson(j['overdue']),
  );
}

class TopProduct {
  final String name;
  final int sold;
  TopProduct({required this.name, required this.sold});
  factory TopProduct.fromJson(Map<String, dynamic> j) =>
      TopProduct(name: j['name'] as String, sold: j['sold'] as int);
}

class ActivityItem {
  final int id;
  final String type;
  final String who;
  final double amount;
  final String date;
  final String refNo;

  ActivityItem({
    required this.id,
    required this.type,
    required this.who,
    required this.amount,
    required this.date,
    required this.refNo,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> j) {
    final raw = j['date'] as String;
    final dt = DateTime.tryParse(raw);
    final label = dt != null ? 'Mar ${dt.day}' : raw.substring(5, 10);
    return ActivityItem(
      id: j['id'] as int,
      type: j['type'] as String,
      who: j['who'] as String,
      amount: (j['amount'] as num).toDouble(),
      date: label,
      refNo: j['ref_no'] as String,
    );
  }
}

class RecoverySummary {
  final double totalAmount;
  final int totalCount;
  final double cashAmount;
  final double bankAmount;

  RecoverySummary({
    required this.totalAmount,
    required this.totalCount,
    required this.cashAmount,
    required this.bankAmount,
  });

  factory RecoverySummary.fromJson(Map<String, dynamic> j) => RecoverySummary(
    totalAmount: (j['total_amount'] as num).toDouble(),
    totalCount: j['total_count'] as int,
    cashAmount: (j['cash_amount'] as num).toDouble(),
    bankAmount: (j['bank_amount'] as num).toDouble(),
  );
}

class DashboardData {
  final KpiCards kpiCards;
  final List<TrendPoint> monthlyTrend;
  final InvoiceStatus invoiceStatus;
  final List<TopProduct> topProducts;
  final List<ActivityItem> recentActivity;
  final RecoverySummary recoverySummary;

  DashboardData({
    required this.kpiCards,
    required this.monthlyTrend,
    required this.invoiceStatus,
    required this.topProducts,
    required this.recentActivity,
    required this.recoverySummary,
  });

  factory DashboardData.fromJson(Map<String, dynamic> data) => DashboardData(
    kpiCards: KpiCards.fromJson(data['kpi_cards']),
    monthlyTrend: (data['monthly_trend'] as List)
        .map((e) => TrendPoint.fromJson(e))
        .toList(),
    invoiceStatus: InvoiceStatus.fromJson(data['invoice_status']),
    topProducts: (data['top_products'] as List)
        .map((e) => TopProduct.fromJson(e))
        .toList(),
    recentActivity: (data['recent_activity'] as List)
        .map((e) => ActivityItem.fromJson(e))
        .toList(),
    recoverySummary: RecoverySummary.fromJson(data['recoveries']['summary']),
  );
}