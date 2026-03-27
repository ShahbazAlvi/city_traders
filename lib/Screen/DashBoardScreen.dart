
import 'package:demo_distribution/Screen/reports/reports_dashboard/reports_dashboard_screen.dart';
import 'package:demo_distribution/Screen/setup/setup_dashboard.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Provider/DashBoardProvider.dart';
import '../model/DashBoardModel.dart';
import '../utils/access_control.dart';

import 'Auth/LoginScreen.dart';
import 'Bank/BankDefine/BanksDefineScreen.dart';
import 'PurchaseScreen/PurchaseScreen.dart';
import 'SalesView/SalesScreen.dart';
import 'SalesView/stock/stockcard/stock_main.dart';
import 'appTheme.dart';


// ─── Helpers ──────────────────────────────────────────────────────────────────

String fmtAmount(double n) {
  final abs = n.abs();
  if (abs >= 1000000) return '${(abs / 1000000).toStringAsFixed(2)}M';
  if (abs >= 1000) return '${(abs / 1000).toStringAsFixed(1)}K';
  return abs.toStringAsFixed(0);
}

String pkr(double n) => '${n < 0 ? '-' : ''}PKR ${fmtAmount(n)}';


class _NavItem {
  final IconData icon;
  final String label;
  final String permissionKey;

  /// If true, shown to ALL users regardless of permissions (e.g. Logout)
  final bool alwaysVisible;

  /// If true, renders in red and triggers onLogout instead of navigation
  final bool isLogout;

  /// Null for logout items — they don't navigate to a screen
  final Widget Function()? screenBuilder;

  const _NavItem({
    required this.icon,
    required this.label,
    this.permissionKey = '',
    this.alwaysVisible = false,
    this.isLogout = false,
    this.screenBuilder,
  });
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final Gradient? gradient;

  const AppCard(
      {super.key,
        required this.child,
        this.padding,
        this.width,
        this.gradient});

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: gradient == null ? AppTheme.card : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.border),
      boxShadow: [
        BoxShadow(
          color: AppColors.secondary.withOpacity(0.07),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader(
      {super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ShaderMask(
          shaderCallback: (b) => AppTheme.brandGradient.createShader(b),
          child: Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
        ),
        if (subtitle != null)
          Text(subtitle!,
              style:
              const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
      ]),
    ),
    if (trailing != null) trailing!,
  ]);
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const LegendDot({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 4),
    Text(label,
        style:
        const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
  ]);
}

class KpiCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String icon;
  final bool positive;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.border),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: positive
                          ? [
                        AppColors.secondary.withOpacity(0.15),
                        AppColors.primary.withOpacity(0.08)
                      ]
                          : [
                        AppTheme.red.withOpacity(0.12),
                        AppTheme.red.withOpacity(0.05)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                      child: Text(icon,
                          style: const TextStyle(fontSize: 17))),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: positive
                        ? AppColors.primary.withOpacity(0.10)
                        : AppTheme.red.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    positive ? '▲' : '▼',
                    style: TextStyle(
                        fontSize: 10,
                        color: positive
                            ? AppColors.primary
                            : AppTheme.red,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
          const SizedBox(height: 12),
          ShaderMask(
            shaderCallback: (b) => LinearGradient(
              colors: positive
                  ? [AppColors.secondary, AppColors.primary]
                  : [AppTheme.red, AppTheme.red.withOpacity(0.8)],
            ).createShader(b),
            child: Text(
              pkr(value),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ]),
  );
}

class ActivityRow extends StatelessWidget {
  final String refNo;
  final String type;
  final String who;
  final String date;
  final double amount;

  const ActivityRow({
    super.key,
    required this.refNo,
    required this.type,
    required this.who,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.typeColor(type);
    final icon = AppTheme.typeIcon(type);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.18),
                color.withOpacity(0.06)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
              child:
              Text(icon, style: TextStyle(color: color, fontSize: 16))),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        color.withOpacity(0.15),
                        color.withOpacity(0.05)
                      ]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(type,
                        style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 6),
                  Text(refNo,
                      style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                          fontFamily: 'monospace')),
                ]),
                const SizedBox(height: 3),
                Text(
                  who.isNotEmpty
                      ? '${who[0].toUpperCase()}${who.substring(1)}'
                      : who,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          ShaderMask(
            shaderCallback: (b) =>
                AppTheme.brandGradient.createShader(b),
            child: Text('PKR ${fmtAmount(amount)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
          ),
          Text(date,
              style:
              const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        ]),
      ]),
    );
  }
}

class InvoiceStatusRow extends StatelessWidget {
  final String label;
  final int count;
  final double amount;
  final Color color;
  final String icon;

  const InvoiceStatusRow({
    super.key,
    required this.label,
    required this.count,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppTheme.bg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.18),
              color.withOpacity(0.06)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
            child: Text(icon,
                style: TextStyle(color: color, fontSize: 15))),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Text('$count invoice${count != 1 ? 's' : ''}',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 11)),
            ]),
      ),
      Text(pkr(amount),
          style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w800)),
    ]),
  );
}

class RecoveryBar extends StatelessWidget {
  final String label;
  final double value;
  final double total;
  final Color color;

  const RecoveryBar(
      {super.key,
        required this.label,
        required this.value,
        required this.total,
        required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12)),
        ]),
        Text('PKR ${fmtAmount(value)}',
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 6),
      Stack(children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        FractionallySizedBox(
          widthFactor: pct,
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.secondary, AppColors.primary]),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 5)
              ],
            ),
          ),
        ),
      ]),
    ]);
  }
}

// ─── Dashboard Screen ─────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  // ── Permission flags ──
  bool _loaded = false;
  bool isAdmin = false;
  bool canViewDashboard = false;
  bool canViewSales = false;
  bool canViewPurchase = false;
  bool canViewStock = false;
  bool canViewReports = false;
  bool canViewBank = false;
  bool canViewSetUp = false;

  // ── Full nav definition (permission key = '' means always show) ──
  static final _allNavItems = <_NavItem>[
    _NavItem(
      icon: Icons.grid_view_rounded,
      label: 'Dashboard',
      permissionKey: 'can_view_dashboard',
      screenBuilder: () => const DashboardScreen(),
    ),
    _NavItem(
      icon: Icons.receipt_long,
      label: 'Sales',
      permissionKey: 'can_view_sales',
      screenBuilder: () => const SalesDashboard(),
    ),
    _NavItem(
      icon: Icons.inventory_2_outlined,
      label: 'Purchases',
      permissionKey: 'can_view_purchase',
      screenBuilder: () => const PurchaseDashboard(),
    ),

    _NavItem(
      icon: Icons.sync_alt,
      label: 'setup',
      permissionKey: 'can_view_sales',
      screenBuilder: () => const SetUpDashboard(),
    ),
    _NavItem(
      icon: Icons.warehouse_outlined,
      label: 'Stock',
      permissionKey: 'can_view_stock',
      screenBuilder: () => const StockMain(),
    ),
    _NavItem(
      icon: Icons.account_balance_outlined,
      label: 'Accounts',
      permissionKey: 'can_view_accounts',
      screenBuilder: () => const BanksDefineScreen(),
    ),
    _NavItem(
      icon: Icons.bar_chart,
      label: 'Reports',
      permissionKey: 'can_view_reports',
      screenBuilder: () => const ReportsDashboardScreen(),
    ),
    _NavItem(
      icon: Icons.bar_chart,
      label: 'Logout',
      permissionKey: 'can_view_dashboard',
      screenBuilder: () => const LoginScreen(),
    ),
  ];

  // const Divider(),
  //           ListTile(
  //             leading: const Icon(Icons.logout, color: Colors.red),
  //             title: const Text('Logout'),
  //             onTap: () async {
  //               Navigator.pop(context); // close drawer first
  //               final shouldLogout = await showDialog<bool>(
  //                 context: context,
  //                 builder: (context) => AlertDialog(
  //                   title: const Text('Confirm Logout'),
  //                   content: const Text('Are you sure you want to logout?'),
  //                   actions: [
  //                     TextButton(
  //                       onPressed: () => Navigator.pop(context, false),
  //                       child: const Text('Cancel'),
  //                     ),
  //                     ElevatedButton(
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: Colors.red,
  //                       ),
  //                       onPressed: () => Navigator.pop(context, true),
  //                       child: const Text('Logout'),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //
  //               if (shouldLogout ?? false) {
  //                 // ✅ Navigate to LoginScreen after logout
  //                 Navigator.pushReplacement(
  //                   context,
  //                   MaterialPageRoute(builder: (context) => LoginScreen()), // replace with your login screen
  //                 );
  //               }

  // ── Derived: visible items based on permissions ──
  List<_NavItem> get _visibleItems => _allNavItems.where((item) {
    if (!_loaded) return false;
    if (isAdmin) return true; // admin sees everything
    return _hasPermission(item.permissionKey);
  }).toList();

  bool _hasPermission(String key) {
    switch (key) {
      case 'can_view_dashboard': return canViewDashboard;
      case 'can_view_sales':     return canViewSales;
      case 'can_view_purchase':  return canViewPurchase;
      case 'can_view_stock':     return canViewStock;
      case 'can_view_reports':   return canViewReports;
      case 'can_view_accounts':  return canViewBank;
      case 'can_view_setup':     return canViewSetUp;
      default:                   return false;
    }
  }

  int _navIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetch();
      _loadAccess();
    });
  }

  Future<void> _loadAccess() async {
    final admin    = await AccessControl.isAdmin();
    final stock    = await AccessControl.canDo('can_view_stock');
    final reports  = await AccessControl.canDo('can_view_reports');
    final sales    = await AccessControl.canDo('can_view_sales');
    final purchase = await AccessControl.canDo('can_view_purchase');
    final dashboard= await AccessControl.canDo('can_view_dashboard');
    final bank     = await AccessControl.canDo('can_view_accounts');
    final setup    = await AccessControl.canDo('can_view_setup');

    setState(() {
      isAdmin          = admin;
      canViewStock     = stock;
      canViewReports   = reports;
      canViewSales     = sales;
      canViewPurchase  = purchase;
      canViewDashboard = dashboard;
      canViewBank      = bank;
      canViewSetUp     = setup;
      _loaded          = true;
      _navIndex        = 0;
    });
  }

  void _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Confirm Logout', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldLogout ?? false) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all user data
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Date Range', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildFilterTile('This Week', () {
              final now = DateTime.now();
              final monday = now.subtract(Duration(days: now.weekday - 1));
              final sunday = monday.add(const Duration(days: 6));
              _updateDates(monday, sunday);
            }),
            _buildFilterTile('This Month', () {
              final now = DateTime.now();
              final first = DateTime(now.year, now.month, 1);
              final last = DateTime(now.year, now.month + 1, 0);
              _updateDates(first, last);
            }),
            _buildFilterTile('This Year', () {
              final now = DateTime.now();
              _updateDates(DateTime(now.year, 1, 1), DateTime(now.year, 12, 31));
            }),
            _buildFilterTile('Custom Range', () async {
              Navigator.pop(context);
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      surface: AppTheme.surface,
                      onSurface: AppTheme.textPrimary,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                _updateDates(picked.start, picked.end);
              }
            }),
          ],
        ),
      ),
    );
  }

  void _updateDates(DateTime start, DateTime end) {
    final sStr = start.toIso8601String().split('T')[0];
    final eStr = end.toIso8601String().split('T')[0];
    context.read<DashboardProvider>().fetch(from: sStr, to: eStr);
    Navigator.pop(context);
  }

  Widget _buildFilterTile(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: AppTheme.textPrimary)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
      onTap: onTap,
    );
  }

  // ── Navigate to a screen on nav item tap ──
  void _onNavTap(_NavItem item) {
    // Close drawer on mobile
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }

    // If it's the first item (Dashboard), just update index — we're already here
    final idx = _visibleItems.indexOf(item);
    if (idx == 0) {
      setState(() => _navIndex = 0);
      return;
    }

    setState(() => _navIndex = idx);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => item.screenBuilder!(),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
              parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    ).then((_) {
      // Reset to dashboard when coming back
      setState(() => _navIndex = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isTablet  = w >= 768;
    final isDesktop = w >= 1200;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.bg,
      drawer: isTablet ? null : _buildDrawer(),
      appBar: _buildAppBar(isTablet),

      body: Row(children: [
        if (isTablet) _buildSidebar(isDesktop),
        Expanded(
          child: Column(children: [
            SizedBox(height: 10,),
           // _buildTopBar(isTablet),
            Expanded(
              child: Consumer<DashboardProvider>(
                builder: (_, prov, __) {
                  if (!_loaded || prov.state == LoadState.loading)
                    return _buildLoading();
                  if (prov.state == LoadState.error)
                    return _buildError(prov.errorMsg, prov.refresh);
                  if (prov.data == null) return _buildEmpty();
                  return _buildBody(prov.data!, isTablet, isDesktop);
                },
              ),
            ),
          ]),
        ),
      ]),
      bottomNavigationBar: (isTablet || !_loaded)
          ? null
          : _buildBottomNav(),
    );
  }

  // ─── Sidebar ────────────────────────────────────────────────────────────

  Widget _buildSidebar(bool isDesktop) {
    final items = _visibleItems;
    return Container(
      width: isDesktop ? 220 : 72,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(right: BorderSide(color: AppTheme.border)),
        boxShadow: [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(2, 0))
        ],
      ),
      child: Column(children: [
        // ── Logo ──
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border))),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: const Center(
                  child: Text('🏪', style: TextStyle(fontSize: 20))),
            ),
            if (isDesktop) ...[
              const SizedBox(width: 10),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (b) =>
                          AppTheme.brandGradient.createShader(b),
                      child: const Text('City Traders',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16)),
                    ),
                    const Text('DASHBOARD',
                        style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 9,
                            letterSpacing: 1.5)),
                  ]),
            ],
          ]),
        ),

        // ── Nav Items ──
        Expanded(
          child: !_loaded
              ? const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary),
            ),
          )
              : items.isEmpty
              ? Center(
            child: Text(
              isDesktop ? 'No access' : '🔒',
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 12),
            ),
          )
              : ListView(
            padding: const EdgeInsets.symmetric(
                vertical: 12, horizontal: 8),
            children: List.generate(items.length, (i) {
              final item = items[i];
              final active = _navIndex == i;
              return _buildNavTile(
                  item, active, isDesktop, i);
            }),
          ),
        ),

        // ── User chip ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
              border:
              Border(top: BorderSide(color: AppTheme.border))),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: const Center(
                  child: Text('A',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15))),
            ),
            if (isDesktop) ...[
              const SizedBox(width: 10),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Admin',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Text(
                      isAdmin ? 'Super Admin' : 'Staff',
                      style: TextStyle(
                          color: isAdmin
                              ? AppColors.primary
                              : AppTheme.textMuted,
                          fontSize: 10,
                          fontWeight: isAdmin
                              ? FontWeight.w600
                              : FontWeight.w400),
                    ),
                  ]),
            ],
          ]),
        ),
      ]),
    );
  }

  // ── Single nav tile ──
  Widget _buildNavTile(
      _NavItem item, bool active, bool isDesktop, int idx) {
    return Tooltip(
      message: isDesktop ? '' : item.label,
      child: GestureDetector(
        onTap: () => _onNavTap(item),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 2),
          padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 12 : 0, vertical: 10),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(colors: [
              AppColors.secondary.withOpacity(0.12),
              AppColors.primary.withOpacity(0.06),
            ])
                : null,
            borderRadius: BorderRadius.circular(10),
            border: active
                ? Border.all(
                color: AppColors.primary.withOpacity(0.2))
                : null,
          ),
          child: Row(
            mainAxisAlignment: isDesktop
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (b) => (active
                    ? AppTheme.brandGradient
                    : const LinearGradient(colors: [
                  AppTheme.textMuted,
                  AppTheme.textMuted
                ]))
                    .createShader(b),
                child: Icon(item.icon, size: 20, color: Colors.white),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item.label,
                      style: TextStyle(
                          color: active
                              ? AppColors.secondary
                              : AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400)),
                ),
                if (active)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      gradient: AppTheme.brandGradient,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                // small arrow hint
                  const Icon(Icons.chevron_right,
                      size: 14, color: AppTheme.textMuted),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() => Drawer(
    backgroundColor: AppTheme.surface,
    child: _buildSidebar(true),
  );

  // ─── Top Bar ──────────────────────────────────────────────────────────────

  // Widget _buildTopBar(bool isTablet) => Container(
  //   height: 62,
  //   padding: const EdgeInsets.symmetric(horizontal: 16),
  //   decoration: const BoxDecoration(
  //     color: AppTheme.surface,
  //     border:
  //     Border(bottom: BorderSide(color: AppTheme.border)),
  //     boxShadow: [
  //       BoxShadow(
  //           color: Color(0x08000000),
  //           blurRadius: 8,
  //           offset: Offset(0, 2))
  //     ],
  //   ),
  //   child: Row(children: [
  //     if (!isTablet)
  //       IconButton(
  //         onPressed: () =>
  //             _scaffoldKey.currentState?.openDrawer(),
  //         icon: ShaderMask(
  //           shaderCallback: (b) =>
  //               AppTheme.brandGradient.createShader(b),
  //           child: const Icon(Icons.menu,
  //               color: Colors.white, size: 22),
  //         ),
  //       ),
  //     Expanded(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           ShaderMask(
  //             shaderCallback: (b) =>
  //                 AppTheme.brandGradient.createShader(b),
  //             child: const Text('Dashboard Overview',
  //                 style: TextStyle(
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.w700,
  //                     fontSize: 16)),
  //           ),
  //           const Text('Feb 28 – Mar 30, 2026',
  //               style: TextStyle(
  //                   color: AppTheme.textMuted, fontSize: 11)),
  //         ],
  //       ),
  //     ),
  //     // Admin badge
  //     if (isAdmin)
  //       Container(
  //         margin: const EdgeInsets.only(right: 8),
  //         padding: const EdgeInsets.symmetric(
  //             horizontal: 10, vertical: 4),
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(colors: [
  //             AppColors.secondary.withOpacity(0.15),
  //             AppColors.primary.withOpacity(0.15),
  //           ]),
  //           borderRadius: BorderRadius.circular(20),
  //           border: Border.all(
  //               color: AppColors.primary.withOpacity(0.3)),
  //         ),
  //         child: ShaderMask(
  //           shaderCallback: (b) =>
  //               AppTheme.brandGradient.createShader(b),
  //           child: const Text('Admin',
  //               style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 10,
  //                   fontWeight: FontWeight.w700)),
  //         ),
  //       ),
  //     // Live badge
  //     Container(
  //       padding: const EdgeInsets.symmetric(
  //           horizontal: 12, vertical: 5),
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(colors: [
  //           AppColors.secondary.withOpacity(0.12),
  //           AppColors.primary.withOpacity(0.12)
  //         ]),
  //         borderRadius: BorderRadius.circular(8),
  //         border: Border.all(
  //             color: AppColors.primary.withOpacity(0.25)),
  //       ),
  //       child: ShaderMask(
  //         shaderCallback: (b) =>
  //             AppTheme.brandGradient.createShader(b),
  //         child: const Text('● Live',
  //             style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w700)),
  //       ),
  //     ),
  //     const SizedBox(width: 4),
  //     Consumer<DashboardProvider>(
  //       builder: (_, prov, __) => IconButton(
  //         onPressed: prov.state == LoadState.loading
  //             ? null
  //             : prov.refresh,
  //         icon: ShaderMask(
  //           shaderCallback: (b) =>
  //               AppTheme.brandGradient.createShader(b),
  //           child: const Icon(Icons.refresh,
  //               color: Colors.white, size: 20),
  //         ),
  //       ),
  //     ),
  //   ]),
  // );

  PreferredSizeWidget _buildAppBar(bool isTablet) {
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: !isTablet
          ? IconButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: ShaderMask(
          shaderCallback: (b) => AppTheme.brandGradient.createShader(b),
          child: const Icon(Icons.menu, color: Colors.white),
        ),
      )
          : null,
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (b) => AppTheme.brandGradient.createShader(b),
            child: const Text(
              'Dashboard Overview',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          Consumer<DashboardProvider>(
            builder: (context, prov, child) {
              return Text(
                '${prov.fromDate} – ${prov.toDate}',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
              );
            },
          ),
        ],
      ),
      actions: [
        if (isAdmin)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.secondary.withOpacity(0.15),
                AppColors.primary.withOpacity(0.15),
              ]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'Admin',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ),

        IconButton(
          onPressed: _showFilterOptions,
          icon: const Icon(Icons.calendar_month_outlined),
        ),
        IconButton(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout_outlined, color: AppTheme.red),
        ),
        Consumer<DashboardProvider>(
          builder: (_, prov, __) => IconButton(
            onPressed: prov.state == LoadState.loading ? null : prov.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }

  // ─── Bottom Nav ───────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    // Show max 5 items in bottom nav
    final items = _visibleItems.take(5).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
        boxShadow: [
          BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, -2))
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppTheme.textMuted,
        currentIndex: _navIndex.clamp(0, items.length - 1),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        onTap: (i) {
          if (i < items.length) _onNavTap(items[i]);
        },
        items: items
            .map((e) => BottomNavigationBarItem(
          icon: Icon(e.icon, size: 20),
          label: e.label,
        ))
            .toList(),
      ),
    );
  }

  // ─── Loading / Empty ──────────────────────────────────────────────────────

  Widget _buildLoading() => Center(
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (b) =>
                AppTheme.brandGradient.createShader(b),
            child: const CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5),
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (b) =>
                AppTheme.brandGradient.createShader(b),
            child: const Text('Loading dashboard…',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ]),
  );

  Widget _buildEmpty() => const Center(
    child: Text('No data available',
        style: TextStyle(color: AppTheme.textMuted)),
  );

  Widget _buildError(String msg, VoidCallback retry) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.red),
          const SizedBox(height: 16),
          Text(
            'API Error',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: retry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try Again'),
          ),
        ],
      ),
    ),
  );

  // ─── Body ─────────────────────────────────────────────────────────────────

  Widget _buildBody(
      DashboardData d, bool isTablet, bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _KpiGrid(d: d, isTablet: isTablet, isDesktop: isDesktop),
        const SizedBox(height: 20),
        if (isTablet)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                flex: 3,
                child: _TrendChart(trend: d.monthlyTrend)),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(children: [
                _InvoiceCard(status: d.invoiceStatus),
                const SizedBox(height: 16),
                _RecoveryCard(summary: d.recoverySummary),
              ]),
            ),
          ])
        else
          Column(children: [
            _TrendChart(trend: d.monthlyTrend),
            const SizedBox(height: 16),
            _InvoiceCard(status: d.invoiceStatus),
            const SizedBox(height: 16),
            _RecoveryCard(summary: d.recoverySummary),
          ]),
        const SizedBox(height: 20),
        if (isDesktop)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
                width: 300,
                child: _ProductsCard(products: d.topProducts)),
            const SizedBox(width: 16),
            Expanded(
                child: _ActivityCard(activity: d.recentActivity)),
          ])
        else
          Column(children: [
            _ProductsCard(products: d.topProducts),
            const SizedBox(height: 16),
            _ActivityCard(activity: d.recentActivity),
          ]),
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ─── KPI Grid ─────────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final DashboardData d;
  final bool isTablet;
  final bool isDesktop;
  const _KpiGrid(
      {required this.d, required this.isTablet, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final kpi = d.kpiCards;
    final cards = [
      KpiCard(label: 'Total Sales', value: kpi.totalSales, color: AppColors.primary, icon: '📈', positive: true),
      KpiCard(label: 'Purchases', value: kpi.totalPurchases, color: AppTheme.orange, icon: '🛒', positive: false),
      KpiCard(label: 'Payments In', value: kpi.totalPaymentsIn, color: AppColors.secondary, icon: '💰', positive: true),
      KpiCard(label: 'Recoveries', value: kpi.totalRecoveries, color: AppTheme.green, icon: '🔄', positive: true),

    ];

    final cols = isDesktop ? 4 : (isTablet ? 3 : 2);
    final rows = <Widget>[];
    for (var i = 0; i < cards.length; i += cols) {
      final slice = cards.skip(i).take(cols).toList();
      rows.add(Row(children: [
        for (var j = 0; j < slice.length; j++) ...[
          if (j > 0) const SizedBox(width: 12),
          Expanded(child: slice[j]),
        ],
        for (var k = slice.length; k < cols; k++) ...[
          const SizedBox(width: 12),
          const Expanded(child: SizedBox()),
        ],
      ]));
      if (i + cols < cards.length) rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }
}

// ─── Trend Chart ──────────────────────────────────────────────────────────────

class _TrendChart extends StatelessWidget {
  final List<TrendPoint> trend;
  const _TrendChart({required this.trend});

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
              title: 'Trend Overview',
              subtitle: 'Sales · Purchases · Payments Out'),
          const SizedBox(height: 10),
          Wrap(spacing: 16, children: [
            LegendDot(color: AppColors.primary, label: 'Sales'),
            LegendDot(color: AppTheme.orange, label: 'Purchases'),
            LegendDot(color: AppTheme.red, label: 'Pay Out'),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(LineChartData(
              backgroundColor: Colors.transparent,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: AppTheme.border, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= trend.length)
                        return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(trend[i].month,
                            style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 10)),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppTheme.surface,
                  getTooltipItems: (spots) => spots.map((s) {
                    final colors = [
                      AppColors.primary,
                      AppTheme.orange,
                      AppTheme.red
                    ];
                    return LineTooltipItem(
                      'PKR ${fmtAmount(s.y)}',
                      TextStyle(
                          color:
                          colors[s.barIndex % colors.length],
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                _line(trend.map((t) => t.sales).toList(),
                    AppColors.primary, AppColors.secondary),
                _line(trend.map((t) => t.purchases).toList(),
                    AppTheme.orange, AppTheme.orange),
                _line(trend.map((t) => t.paymentsOut).toList(),
                    AppTheme.red, AppTheme.red),
              ],
            )),
          ),
        ]),
  );

  LineChartBarData _line(
      List<double> values, Color color, Color gradColor) =>
      LineChartBarData(
        spots: List.generate(
            values.length, (i) => FlSpot(i.toDouble(), values[i])),
        isCurved: true,
        gradient: LinearGradient(colors: [color, gradColor]),
        barWidth: 2.5,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.12),
              color.withOpacity(0.0)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
}

// ─── Invoice Card ─────────────────────────────────────────────────────────────

class _InvoiceCard extends StatelessWidget {
  final InvoiceStatus status;
  const _InvoiceCard({required this.status});

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
              title: 'Invoice Status', subtitle: 'Current period'),
          const SizedBox(height: 16),
          InvoiceStatusRow(label: 'Paid', count: status.paid.count, amount: status.paid.amount, color: AppColors.primary, icon: '✓'),
          InvoiceStatusRow(label: 'Receivable', count: status.receivable.count, amount: status.receivable.amount, color: AppTheme.orange, icon: '⏳'),
          InvoiceStatusRow(label: 'Overdue', count: status.overdue.count, amount: status.overdue.amount, color: AppTheme.red, icon: '⚠'),
        ]),
  );
}

// ─── Recovery Card ────────────────────────────────────────────────────────────

class _RecoveryCard extends StatelessWidget {
  final RecoverySummary summary;
  const _RecoveryCard({required this.summary});

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
              title: 'Recovery Breakdown',
              subtitle: 'Cash vs Bank'),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: PieChart(PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 30,
              sections: [
                PieChartSectionData(
                  value: summary.cashAmount,
                  gradient: AppTheme.brandGradient,
                  radius: 26,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: summary.bankAmount,
                  color: AppColors.secondary.withOpacity(0.3),
                  radius: 22,
                  showTitle: false,
                ),
              ],
            )),
          ),
          const SizedBox(height: 14),
          RecoveryBar(label: 'Cash', value: summary.cashAmount, total: summary.totalAmount, color: AppColors.primary),
          const SizedBox(height: 10),
          RecoveryBar(label: 'Bank', value: summary.bankAmount, total: summary.totalAmount, color: AppColors.secondary),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.secondary.withOpacity(0.08),
                AppColors.primary.withOpacity(0.05),
              ]),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.18)),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL RECOVERED',
                      style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                  ShaderMask(
                    shaderCallback: (b) =>
                        AppTheme.brandGradient.createShader(b),
                    child: Text(
                        'PKR ${fmtAmount(summary.totalAmount)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800)),
                  ),
                ]),
          ),
        ]),
  );
}

// ─── Top Products Card ────────────────────────────────────────────────────────

class _ProductsCard extends StatelessWidget {
  final List<TopProduct> products;
  const _ProductsCard({required this.products});

  @override
  Widget build(BuildContext context) {
    final maxSold = products.isEmpty
        ? 1
        : products
        .map((p) => p.sold)
        .reduce((a, b) => a > b ? a : b);

    return AppCard(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
                title: 'Top Products',
                subtitle: 'Units sold this period'),
            const SizedBox(height: 16),
            ...List.generate(products.length, (i) {
              final p = products[i];
              final pct = maxSold > 0 ? p.sold / maxSold : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${p.name[0].toUpperCase()}${p.name.substring(1)}',
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ShaderMask(
                              shaderCallback: (b) =>
                                  AppTheme.brandGradient.createShader(b),
                              child: Text('${p.sold} units',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ]),
                      const SizedBox(height: 6),
                      Stack(children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppTheme.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: pct,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                AppColors.secondary,
                                AppColors.primary
                              ]),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.primary
                                        .withOpacity(0.35),
                                    blurRadius: 5),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ]),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.surface,
                    getTooltipItem:
                        (group, groupIndex, rod, rodIndex) =>
                        BarTooltipItem(
                          '${products[groupIndex].sold} units',
                          const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i >= products.length)
                          return const SizedBox();
                        final name = products[i].name;
                        final short = name.length > 10
                            ? name.substring(0, 10)
                            : name;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(short,
                              style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 9),
                              overflow: TextOverflow.ellipsis),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  products.length,
                      (i) => BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: products[i].sold.toDouble(),
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.secondary,
                          AppColors.primary
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: 32,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6)),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxSold.toDouble() * 1.2,
                        color: AppTheme.border,
                      ),
                    ),
                  ]),
                ),
              )),
            ),
          ]),
    );
  }
}

// ─── Activity Card ────────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final List<ActivityItem> activity;
  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Recent Activity',
            subtitle: '${activity.length} transactions this period',
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.secondary.withOpacity(0.12),
                  AppColors.primary.withOpacity(0.12),
                ]),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.22)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ShaderMask(
                shaderCallback: (b) =>
                    AppTheme.brandGradient.createShader(b),
                child: const Text('View All',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...activity.map((item) => ActivityRow(
            refNo: item.refNo,
            type: item.type,
            who: item.who,
            date: item.date,
            amount: item.amount,
          )),
        ]),
  );
}