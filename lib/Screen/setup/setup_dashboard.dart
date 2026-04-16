
import 'dart:ui';
import 'package:demo_distribution/Screen/SalesView/stock/stock_positions.dart';
import 'package:demo_distribution/Screen/setup/Payroll/Department/Department_screen.dart';
import 'package:demo_distribution/Screen/setup/Payroll/Designation/Designation_Screen.dart';
import 'package:demo_distribution/Screen/setup/Sales_Areas/Sales_Areas_Screen.dart';
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
  bool canViewCategories   = false;
  bool canViewItemTypes     = false;
  bool canViewUnits         = false;
  bool canViewItems         = false;
  bool canViewLocations     = false;
  bool canViewCustomers     = false;
  bool canViewEmployees     = false;
  bool canViewVehicles      = false;
  bool canViewSuppliers     = false;
  bool canViewTaxTypes      = false;
  bool canViewSalesAreas    = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final categories   = await AccessControl.canDo("can_view_categories");
    final itemTypes    = await AccessControl.canDo("can_view_item_types");
    final units        = await AccessControl.canDo("can_view_units");
    final items        = await AccessControl.canDo("can_view_item_definition");
    final locations    = await AccessControl.canDo("can_view_locations");
    final customers    = await AccessControl.canDo("can_view_customers");
    final employees    = await AccessControl.canDo("can_view_employees");
    final vehicles     = await AccessControl.canDo("can_view_vehicles");
    final suppliers    = await AccessControl.canDo("can_view_suppliers");
    final taxTypes     = await AccessControl.canDo("can_view_tax_types");
    final salesAreas   = await AccessControl.canDo("can_view_sales_areas");

    if (mounted) {
      setState(() {
        canViewCategories   = categories;
        canViewItemTypes     = itemTypes;
        canViewUnits         = units;
        canViewItems         = items;
        canViewLocations     = locations;
        canViewCustomers     = customers;
        canViewEmployees     = employees;
        canViewVehicles      = vehicles;
        canViewSuppliers     = suppliers;
        canViewTaxTypes      = taxTypes;
        canViewSalesAreas    = salesAreas;
      });
    }
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
                if (canViewLocations)
                  DashboardCard(
                    icon: Icons.location_on_rounded,
                    title: "location",
                    color: Colors.limeAccent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationScreen()));
                    },
                  ),
                if (canViewCategories)
                  DashboardCard(
                    icon: Icons.category,
                    title: "Category Item",
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
                    },
                  ),
                if (canViewItemTypes)
                  DashboardCard(
                    icon: Icons.layers,
                    title: "Items Type ",
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemTypeScreen()));
                    },
                  ),
                if (canViewUnits)
                  DashboardCard(
                    icon: Icons.straighten,
                    title: "Item Unit ",
                    color: Colors.tealAccent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemUnitScreen()));
                    },
                  ),
                if (canViewItems)
                  DashboardCard(
                    icon: Icons.inventory_2,
                    title: "List of Items",
                    color: Colors.lightBlueAccent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ItemListScreen()));
                    },
                  ),
                if (canViewCustomers)
                  DashboardCard(
                    icon: Icons.people,
                    title: "Define Customers",
                    color: Colors.pinkAccent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersDefineScreen()));
                    },
                  ),
                if (canViewEmployees)
                  DashboardCard(
                    icon: Icons.person,
                    title: "Employee Information",
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeesScreen()));
                    },
                  ),
                if (canViewVehicles)
                  DashboardCard(
                    icon: Icons.local_shipping,
                    title: "Vehicle Information",
                    color: Colors.blueAccent,
                    onTap: () {},
                  ),
                if (canViewSuppliers)
                  DashboardCard(
                    icon: Icons.store_rounded,
                    title: "Supplier",
                    color: Colors.tealAccent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplierListScreen()));
                    },
                  ),
                if (canViewTaxTypes)
                  DashboardCard(
                    icon: Icons.store_rounded,
                    title: "Tax Types",
                    color: Colors.tealAccent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TaxTypesScreen()));
                    },
                  ),
                if (canViewSalesAreas)
                  DashboardCard(
                    icon: Icons.area_chart,
                    title: "Sales Areas ",
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SalesAreasScreen()));
                    },
                  ),
                if (canViewEmployees) ...[
                  DashboardCard(
                    icon: Icons.local_fire_department,
                    title: "Department",
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DepartmentScreen()));
                    },
                  ),
                  DashboardCard(
                    icon: Icons.settings_system_daydream,
                    title: "Designation",
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DesignationScreen()));
                    },
                  ),
                ],
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
