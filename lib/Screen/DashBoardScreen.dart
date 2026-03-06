
import 'dart:convert';

import 'package:demo_distribution/Screen/reports/reports_dashboard/reports_dashboard_screen.dart';
import 'package:demo_distribution/Screen/setup/setup_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Provider/DashBoardProvider.dart';
import '../model/DashBoardModel.dart';
import '../utils/access_control.dart';
import 'Auth/LoginScreen.dart';
import 'Bank/BankDefine/BanksDefineScreen.dart';
import 'CustomerScreen/CustomersDefineScreen.dart';
import 'PurchaseScreen/PurchaseScreen.dart';
import 'SalesView/DailysaleScreen/DailySaleScreen.dart';
import 'SalesView/SalesScreen.dart';
import 'SalesView/SetUp/EmployeeDefine/EmployeeDefine.dart';
import 'SalesView/SetUp/ItemsListScreen/ItemsListsScreen.dart';
import 'SalesView/stock/stockcard/stock_main.dart';
import 'dashBoardView/calender.dart';
import 'dashBoardView/chartdashboard.dart';
import 'dashBoardView/recoverienChart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboardscreen extends StatefulWidget {
  const Dashboardscreen({super.key});

  @override
  State<Dashboardscreen> createState() => _DashboardscreenState();
}

class _DashboardscreenState extends State<Dashboardscreen> {
  String? selectedOption;
  bool isButtonSelected = false;

  final List<String> dropdownItems = ['Today', 'Week', 'Month', 'Year'];

  List<double> salesData = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
  late final recovered = [10.0, 25.0, 40.0, 55.0, 70.0, 80.0, 85.0, 90.0, 95.0, 100.0];
  late final due = [20.0, 30.0, 35.0, 50.0, 60.0, 70.0, 78.0, 82.0, 90.0, 98.0];


  void _onDropdownChanged(String? value) {
    setState(() {
      selectedOption = value;
      isButtonSelected = false;
      _updateChartData(value);
    });
  }

  void _onButtonPressed() {
    setState(() {
      if (!isButtonSelected) {
        selectedOption = null;
        isButtonSelected = true;
        _updateChartData("All");
      } else {
        isButtonSelected = false;
      }
    });
  }

  void _updateChartData(String? filter) {
    switch (filter) {
      case 'Today':
        salesData = [10, 20, 30, 40, 30, 20, 10];
        break;
      case 'Week':
        salesData = [20, 30, 50, 60, 70, 80, 90];
        break;
      case 'Month':
        salesData = [30, 40, 60, 70, 90, 100];
        break;
      case 'Year':
        salesData = [40, 60, 80, 100];
        break;
      case 'All':
        salesData = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
        break;
      default:
        salesData = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
    }
  }

  bool isAdmin = false;
  bool canViewStock = false;
  bool canViewReports = false;
  bool canViewSales = false;
  bool canViewPurchase=false;
  bool canViewDashboard=false;
  bool canViewBank=false;
  bool canViewSetUp=false;


  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      Provider.of<DashBoardProvider>(context, listen: false)
          .fetchDashboardData();
    });

    loadAccess();
  }

  Future<void> loadAccess() async {
    // Use canDo() which checks admin OR permission
    final admin     = await AccessControl.isAdmin();
    final stock = await AccessControl.canDo("can_view_stock");
    final reports     = await AccessControl.canDo("can_view_reports");
    final sales     = await AccessControl.canDo("can_view_sales");
    final purchase  = await AccessControl.canDo("can_view_purchase");
    final dashboard  = await AccessControl.canDo("can_view_dashboard");
    final bank  = await AccessControl.canDo("can_view_accounts");//can_view_setup
    final setup  = await AccessControl.canDo("can_view_setup");//can_view_setup

    setState(() {
      isAdmin          = admin;
      canViewStock = stock;
      canViewReports     = reports;
      canViewSales     = sales;
      canViewPurchase  = purchase;
      canViewSetUp= setup;
      canViewBank=bank;
      canViewDashboard=dashboard;

    });
  }
  // Add these methods inside _DashboardscreenState class

  Future<String?> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return "Admin";
    final user = jsonDecode(userJson);
    return user['username'];
  }

  Future<String?> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roles = prefs.getStringList('roles');
    if (roles == null || roles.isEmpty) return "User";
    return roles.join(', '); // shows all roles e.g. "manager"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Center(child: const Text("City Traders",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 1.2,
            )),
        ),
        centerTitle: true,
        elevation: 6,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Color(0xFFEEEEEE),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5B86E5), Color(0xFF36D1DC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: FutureBuilder<List<String?>>(
                future: Future.wait([_getUsername(), _getUserRole()]),
                builder: (context, snapshot) {
                  final username = snapshot.data?[0] ?? "Admin";
                  final role = snapshot.data?[1] ?? "User";
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Color(0xFF5B86E5),
                          size: 35,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Welcome $username',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Now add username text outside const

            if(canViewDashboard)
            ListTile(
              leading: const Icon(Icons.dashboard, color: Color(0xFF5B86E5)),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            if (canViewStock)
              ListTile(
                leading: const Icon(Icons.block, color: Color(0xFF5B86E5)),
                title: const Text('Stock'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => StockMain()));
                },
              ),
            if (canViewSales)
              ListTile(
                leading: const Icon(Icons.sell, color: Color(0xFF5B86E5)),
                title: const Text('Sales'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SalesDashboard()));
                },
              ),
            if(canViewPurchase)
            ListTile(
              leading: const Icon(Icons.shop, color: Color(0xFF5B86E5)),
              title: const Text('Purchase'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>PurchaseDashboard()));

              },
            ),
            if(canViewBank)
            ListTile(
              leading: const Icon(Icons.account_balance, color: Color(0xFF5B86E5)),
              title: const Text('Bank'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>BanksDefineScreen()));

              },
            ),
            if (canViewSetUp)
              ListTile(
                leading: const Icon(Icons.wifi_protected_setup, color: Color(0xFF5B86E5)),
                title: const Text('SetUp'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SetUpDashboard()));
                },
              ),

            if (canViewReports)
              ListTile(
                leading: const Icon(Icons.report, color: Color(0xFF5B86E5)),
                title: const Text('reports'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ReportsDashboardScreen()));
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context); // close drawer first
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout ?? false) {
                  // ✅ Navigate to LoginScreen after logout
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()), // replace with your login screen
                  );
                }
              },
            ),

          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    /// Dropdown (Equal Width)
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedOption,
                        hint: const Text('Select Period'),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 10),
                          border: OutlineInputBorder(

                            borderRadius: BorderRadius.circular(12),

                          ),
                        ),
                        items: dropdownItems
                            .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ))
                            .toList(),
                        onChanged: _onDropdownChanged,
                      ),
                    ),
                    const SizedBox(width: 12),

                    /// Button (Equal Width)
                    Expanded(
                      child: SizedBox(
                        height: 58, // match dropdown height
                        child: ElevatedButton(
                          onPressed: _onButtonPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isButtonSelected
                                ? Color(0xFF5B86E5)
                                : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "All",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),



              const SizedBox(height: 16),

            const SizedBox(height: 16),

              // In your Consumer builder, handle null data gracefully
              Consumer<DashBoardProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final dashboardData = provider.dashboardData;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => DailySaleReportScreen()));
                              },
                              child: AnimatedDashboardCard(
                                icon: Icons.person,
                                title: 'Total Sales',
                                count: dashboardData?.stats.totalSales.toString() ?? '0',  // ← default '0'
                                bcolor: Colors.green,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => ItemListScreen()));
                              },
                              child: AnimatedDashboardCard(
                                icon: Icons.shop,
                                title: 'Total Products',
                                count: dashboardData?.stats.totalProducts.toString() ?? '0',  // ← default '0'
                                bcolor: Colors.red,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => CustomersDefineScreen()));
                              },
                              child: AnimatedDashboardCard(
                                icon: Icons.people_alt,
                                title: 'Total Customer',
                                count: dashboardData?.stats.totalCustomers.toString() ?? '0',  // ← default '0'
                                bcolor: Colors.blue,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => EmployeesScreen()));
                              },
                              child: AnimatedDashboardCard(
                                icon: Icons.account_balance_wallet,
                                title: 'Total Salesman',
                                count: dashboardData?.stats.totalStaff.toString() ?? '0',  // ← default '0'
                                bcolor: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              Text('Sales',style: TextStyle(fontWeight: FontWeight.bold),),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SalesChart(
                  salesData: salesData,
                  selectedFilter: selectedOption ?? (isButtonSelected ? "All" : "Today"),
                ),
              ),


              Text('Calender Recoveries',style: TextStyle(fontWeight: FontWeight.bold),),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: CalendarWidget(),
              ),
              Text('Recoveries Done & Due',style: TextStyle(fontWeight: FontWeight.bold),),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Recoverienchart(recoveredData: recovered, dueData: due),
              ),



            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedDashboardCard extends StatefulWidget {
  final IconData icon;
  final  String title;
  final String count;
  final Color bcolor;
  const AnimatedDashboardCard({super.key, required this.icon, required this.title, required this.count, required this.bcolor});

  @override
  State<AnimatedDashboardCard> createState() => _AnimatedDashboardCardState();
}

class _AnimatedDashboardCardState extends State<AnimatedDashboardCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 24,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: widget.bcolor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: widget.bcolor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(widget.icon,size: 32,color: Colors.white,),
          const SizedBox(height: 10),
          Text(widget.title,style: TextStyle(color: Colors.white),),
          const SizedBox(height: 10),
          Text(widget.count,style: TextStyle(color: Colors.white),),

        ],
      ),
    );
  }




// Fix the empty _getUsername() in Dashboardscreen:
  Future<String?> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return "Admin";
    final user = jsonDecode(userJson);
    return user['username'];
  }
}

