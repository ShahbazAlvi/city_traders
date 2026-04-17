


import 'dart:ui';
import 'package:demo_distribution/Screen/SalesView/stock/stock_positions.dart';
import 'package:demo_distribution/model/BankModel/PaymentVoucher.dart';
import 'package:flutter/material.dart';
import '../../../../compoents/AppColors.dart';
import '../../../../utils/access_control.dart';
import '../../PurchaseScreen/SupplierLedgerScreen/SupplierLedgerScreen.dart';
import '../../SalesView/DailysaleScreen/DailySaleScreen.dart';
import '../../SalesView/ReportsScreen/AgingScreen/AgingScreen.dart';
import '../../SalesView/ReportsScreen/CustomerLedgerScreen/LedgerScreen.dart';
import '../PendingReportScreen.dart';
import '../SalesmanRecoveryReportScreen.dart';

class ReportsDashboardScreen extends StatefulWidget {
  const ReportsDashboardScreen({super.key});

  @override
  State<ReportsDashboardScreen> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<ReportsDashboardScreen> {
  bool canViewLedger         = false;
  bool canViewAging          = false;
  bool canViewDailySales     = false;
  bool canViewLedgerSupplier = false;
  bool canSalesRecovery = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final ledger         = await AccessControl.canDo("can_view_customer_ledger_report");
    final aging          = await AccessControl.canDo("can_view_credit_aging");
    final dailySales     = await AccessControl.canDo("can_view_daily_sales_report");
    final supplierLedger = await AccessControl.canDo("can_view_supplier_ledger_report");  //can_view_sales_recovery_reports
    final sales_recovery = await AccessControl.canDo("can_view_sales_recovery_reports");

    setState(() {
      canViewLedger         = ledger;
      canViewAging          = aging;
      canViewDailySales     = dailySales;
      canViewLedgerSupplier = supplierLedger;
      canSalesRecovery= sales_recovery;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reports Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Manage reports, invoices, and customer data efficiently",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              _buildSectionTitle("📊 Sales Reports"),
              const SizedBox(height: 14),

              _buildCardGrid([



                // ── SalesMan Recovery ──
                if(canSalesRecovery)
                DashboardCard(
                  icon:  Icons.price_check_sharp,
                  title: "Recovery Report",
                  color: const Color(0xFF0284C7), // sky blue
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SaleManRecoveryScreen()),
                  ),
                ),



                // ── Daily Sales ──
                if (canViewDailySales)
                  DashboardCard(
                    icon:  Icons.bar_chart_sharp,
                    title: "Daily Sales",
                    color: const Color(0xFF0369A1), // blue
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DailySaleReportScreen()),
                    ),
                  ),



                // ── Pending Recovery ──

                DashboardCard(
                  icon:  Icons.pending_actions_sharp,
                  title: "Pending Recovery",
                  color: const Color(0xFFDC2626), // red
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PendingReportScreen()),
                  ),
                ),

              ]),
              const SizedBox(height: 10),
              _buildSectionTitle("📊 Accounts Reports"),
              const SizedBox(height: 14),
              _buildCardGrid([

                // customers ledger
                if (canViewLedger)
                  DashboardCard(
                    icon:  Icons.account_balance_wallet_sharp,
                    title: "Customer Ledger",
                    color: const Color(0xFF7C3AED), // deep purple
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CustomerLedgerScreen()),
                    ),
                  ),
                // suppliers Ledger
                // ── Supplier Ledger ──
                if (canViewLedgerSupplier)
                  DashboardCard(
                    icon:  Icons.local_shipping_sharp,
                    title: "Supplier Ledger",
                    color: const Color(0xFF059669), // emerald green
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SupplierLedgerScreen()),
                    ),
                  ),
                // ── Credit Aging ──
                if (canViewAging)
                  DashboardCard(
                    icon:  Icons.hourglass_bottom_sharp,
                    title: "Credit Aging",
                    color: const Color(0xFF0891B2), // cyan
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CreditAgingScreen()),
                    ),
                  ),




              ]),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildCardGrid(List<DashboardCard> cards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: cards,
        );
      },
    );
  }
}

// ── Reusable Card ────────────────────────────────────────────────────────────
class DashboardCard extends StatelessWidget {
  final IconData   icon;
  final String     title;
  final Color      color;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Icon with colored background ──
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 12),

                // ── Title ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}