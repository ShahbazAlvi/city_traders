
import 'dart:ui';
import 'package:demo_distribution/Screen/SalesView/stock/stock_positions.dart';
import 'package:demo_distribution/Screen/setup/tax_tapes/tax_types_screen.dart';
import 'package:flutter/material.dart';
import '../../../compoents/AppColors.dart';
import '../../utils/access_control.dart';
import '../CustomerScreen/CustomersDefineScreen.dart';
import '../PurchaseScreen/StockPositionScreen/StockPositionScreen.dart';
import '../SalesView/SetUp/EmployeeDefine/EmployeeDefine.dart';
import '../SalesView/SetUp/ItemsListScreen/ItemCategoriesScreen.dart';
import '../SalesView/SetUp/ItemsListScreen/ItemTypeScreen.dart';
import '../SalesView/SetUp/ItemsListScreen/ItemUnitScreen.dart';
import '../SalesView/SetUp/ItemsListScreen/ItemsListsScreen.dart';

import '../SalesView/SetUp/supplier/SupplierScreen.dart';
import 'locations/locatioins_screen.dart';



class SetUpDashboard extends StatefulWidget {
  const SetUpDashboard({super.key});

  @override
  State<SetUpDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SetUpDashboard> {
  // Permissions
  bool canViewOrderBooking = false;
  bool canViewSalesInvoice = false;
  bool canViewRecovery     = false;
  bool canViewCustomerPayment = false;
  bool canViewStockPosition   = false;
  bool canViewReceivable      = false;
  bool canViewLedger          = false;
  bool canViewAging           = false;
  bool canViewDailySales      = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }
  Future<void> _loadPermissions() async {
    final locations     = await AccessControl.canDo("can_view_location");
    final salesInvoice     = await AccessControl.canDo("can_view_sales_invoice_cash");
    final recovery         = await AccessControl.canDo("can_view_recovery_voucher");
    final customerPayment  = await AccessControl.canDo("can_view_customer_payments");
    final stockPosition    = await AccessControl.canDo("can_view_stock_position");
    final receivable       = await AccessControl.canDo("can_view_amount_receivables");
    final ledger           = await AccessControl.canDo("can_view_customer_ledger_report");
    final aging            = await AccessControl.canDo("can_view_credit_aging");
    final dailySales       = await AccessControl.canDo("can_view_daily_sales_report");

    setState(() {
      canViewOrderBooking    =  locations;
      canViewSalesInvoice    = salesInvoice;
      canViewRecovery        = recovery;
      canViewCustomerPayment = customerPayment;
      canViewStockPosition   = stockPosition;
      canViewReceivable      = receivable;
      canViewLedger          = ledger;
      canViewAging           = aging;
      canViewDailySales      = dailySales;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      // backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SetUp Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Manage setup ,sales, invoices, and customer data efficiently",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 🔸 Functionalities Section

              //🔸 Setup Section
              _buildSectionTitle("🧩 Setup"),
              const SizedBox(height: 14),
              _buildCardGrid([
                DashboardCard(
                  icon: Icons.location_on_rounded,
                  title: "location",
                  color: Colors.limeAccent,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationScreen()));
                  },
                ),
                DashboardCard(
                  icon: Icons.category,
                  title: "Category Item",
                  color: Colors.orangeAccent,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
                  },
                ),

                DashboardCard(
                  icon: Icons.layers,
                  title: "Items Type ",
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemTypeScreen()));
                  },
                ),
                DashboardCard(
                  icon: Icons.straighten,
                  title: "Item Unit ",
                  color: Colors.tealAccent  ,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemUnitScreen()));
                  },
                ),
                DashboardCard(
                  icon: Icons.inventory_2,
                  title: "List of Items",
                  color: Colors.lightBlueAccent,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemListScreen()));
                  },
                ),
                DashboardCard(
                  icon: Icons.people,
                  title: "Define Customers",
                  color: Colors.pinkAccent,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersDefineScreen()));
                  },
                ),
                DashboardCard(
                  icon: Icons.person,
                  title: "Employee Information",
                  color: Colors.orangeAccent,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeesScreen()));
                  },
                ),
                DashboardCard(
                  icon: Icons.local_shipping,
                  title: "Vehicle Information",
                  color: Colors.blueAccent,
                  onTap: () {},
                ),
                DashboardCard(
                  icon: Icons.store_rounded,
                  title: "Supplier",
                  color: Colors.tealAccent,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplierListScreen()));
                  },
                ),
                DashboardCard(
                  icon: Icons.store_rounded,
                  title: "Tax Types",
                  color: Colors.tealAccent,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TaxTypesScreen() ));
                  },
                ),
              ]),

              const SizedBox(height: 40),
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
        int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: cards,
        );
      },
    );
  }
}

// 🔹 Reusable Glass Card Component
class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
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
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              //  color: Colors.white.withOpacity(0.4),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 15,
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
