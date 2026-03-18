//
// import 'dart:ui';
// import 'package:demo_distribution/Screen/SalesView/stock/stock_positions.dart';
// import 'package:demo_distribution/model/BankModel/PaymentVoucher.dart';
// import 'package:flutter/material.dart';
// import '../../../../compoents/AppColors.dart';
// import '../../../../utils/access_control.dart';
// import '../../PurchaseScreen/SupplierLedgerScreen/SupplierLedgerScreen.dart';
// import '../../SalesView/DailysaleScreen/DailySaleScreen.dart';
// import '../../SalesView/ReportsScreen/AgingScreen/AgingScreen.dart';
// import '../../SalesView/ReportsScreen/CustomerLedgerScreen/LedgerScreen.dart';
// import '../PendingReportScreen.dart';
// import '../SalesmanRecoveryReportScreen.dart';
//
//
//
//
// class ReportsDashboardScreen extends StatefulWidget {
//   const ReportsDashboardScreen({super.key});
//
//   @override
//   State<ReportsDashboardScreen> createState() => _SalesDashboardState();
// }
//
// class _SalesDashboardState extends State<ReportsDashboardScreen> {
//   // Permissions
//   bool canViewItem = false;
//   bool canViewSalesInvoice = false;
//   bool canViewRecovery     = false;
//   bool canViewCustomerPayment = false;
//   bool canViewStockPosition   = false;
//   bool canViewReceivable      = false;
//   bool canViewLedger          = false;
//   bool canViewAging           = false;
//   bool canViewDailySales      = false;
//   bool canViewLedgerSupplier          = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadPermissions();
//   }
//   Future<void> _loadPermissions() async {
//
//
//     final ledger           = await AccessControl.canDo("can_view_customer_ledger_report");
//     final aging            = await AccessControl.canDo("can_view_credit_aging");
//     final dailySales       = await AccessControl.canDo("can_view_daily_sales_report");
//     final Supplier_ledger           = await AccessControl.canDo("can_view_supplier_ledger_report");
//
//     setState(() {
//       canViewLedger          = ledger;
//       canViewAging           = aging;
//       canViewDailySales      = dailySales;
//       canViewLedgerSupplier          = Supplier_ledger;
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFEEEEEE),
//       // backgroundColor: const Color(0xFFF6F7FB),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 🔹 Header
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [AppColors.secondary, AppColors.primary],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(25),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     )
//                   ],
//                 ),
//                 child: const Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Reports Dashboard",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 0.8,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       "Manage reports, item define, and customer data efficiently",
//                       style: TextStyle(color: Colors.white70, fontSize: 14),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 28),
//
//               // 🔸 Functionalities Section
//               _buildSectionTitle("📊 Reports"),
//               const SizedBox(height: 14),
//               _buildCardGrid([
//                 if (canViewLedger)
//                   DashboardCard(
//                     icon: Icons.newspaper,
//                     title: "Customer Ledger",
//                     color: Colors.purpleAccent,
//                     onTap: () {
//                       Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerLedgerScreen()));
//                     },
//                   ),
//                // SaleManRecoveryScreen
//                 DashboardCard(
//                   icon: Icons.newspaper,
//                   title: "SalesMan Recovery Report",
//                   color: Colors.purpleAccent,
//                   onTap: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (_) => const SaleManRecoveryScreen()));
//                   },
//                 ),
//                   if(canViewAging)
//                   DashboardCard(
//                     icon: Icons.add_chart_rounded,
//                     title: "Credit Aging",
//                     color: Colors.cyanAccent,
//                     onTap: () {
//                       Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditAgingScreen()));
//                     },
//                   ),
//                 if (canViewDailySales)
//                   DashboardCard(
//                     icon: Icons.sim_card_alert_rounded,
//                     title: "Daily Sales",
//                     color: Colors.lightBlueAccent,
//                     onTap: () {
//                       Navigator.push(context, MaterialPageRoute(builder: (_) => const DailySaleReportScreen()));
//                     },
//                   ),
//                 if(canViewLedgerSupplier)
//                   DashboardCard(
//                     icon: Icons.people_alt_rounded,
//                     title: "Supplier Ledger",
//                     color: Colors.greenAccent,
//                     onTap: () {
//                       Navigator.push(context,MaterialPageRoute(builder: (context)=>SupplierLedgerScreen()));
//                     },
//                   ),
//                 DashboardCard(
//                   icon: Icons.newspaper,
//                   title: "Pending Recovery",
//                   color: Colors.purpleAccent,
//                   onTap: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (_) => const PendingReportScreen()));
//                   },
//                 ),
//
//
//               ]),
//
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//         color: Color(0xFF333333),
//       ),
//     );
//   }
//
//   Widget _buildCardGrid(List<DashboardCard> cards) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
//         return GridView.count(
//           crossAxisCount: crossAxisCount,
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//           childAspectRatio: 1.2,
//           children: cards,
//         );
//       },
//     );
//   }
// }
//
// // 🔹 Reusable Glass Card Component
// class DashboardCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final Color color;
//   final VoidCallback onTap;
//
//   const DashboardCard({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.color,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(25),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               //  color: Colors.white.withOpacity(0.4),
//               border: Border.all(color: Colors.white.withOpacity(0.2)),
//               borderRadius: BorderRadius.circular(25),
//               // boxShadow: [
//               //   BoxShadow(
//               //     color: color.withOpacity(0.4),
//               //     blurRadius: 12,
//               //     spreadRadius: 2,
//               //     offset: const Offset(0, 3),
//               //   ),
//               // ],
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(icon, size: 40, color: color),
//                 const SizedBox(height: 10),
//                 Text(
//                   title,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                     fontSize: 15,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


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

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final ledger         = await AccessControl.canDo("can_view_customer_ledger_report");
    final aging          = await AccessControl.canDo("can_view_credit_aging");
    final dailySales     = await AccessControl.canDo("can_view_daily_sales_report");
    final supplierLedger = await AccessControl.canDo("can_view_supplier_ledger_report");

    setState(() {
      canViewLedger         = ledger;
      canViewAging          = aging;
      canViewDailySales     = dailySales;
      canViewLedgerSupplier = supplierLedger;
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

              _buildSectionTitle("📊 Reports"),
              const SizedBox(height: 14),

              _buildCardGrid([

                // ── Customer Ledger ──
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

                // ── SalesMan Recovery ──
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