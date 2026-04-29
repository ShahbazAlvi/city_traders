// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../compoents/AppColors.dart';
// import '../utils/access_control.dart';
// import 'Auth/LoginScreen.dart';
// import 'Bank/BankDefine/BanksDefineScreen.dart';
// import 'DashBoardScreen.dart';
// import 'PurchaseScreen/PurchaseScreen.dart';
// import 'SalesView/SalesScreen.dart';
// import 'SalesView/stock/stockcard/stock_main.dart';
// import 'appTheme.dart' hide AppColors;
// import 'reports/reports_dashboard/reports_dashboard_screen.dart';
// import 'setup/setup_dashboard.dart';
//
// class _ModuleCard {
//   final IconData icon;
//   final String label;
//   final String subtitle;
//   final List<Color> colors;
//   final Widget Function() screenBuilder;
//
//   const _ModuleCard({
//     required this.icon,
//     required this.label,
//     required this.subtitle,
//     required this.colors,
//     required this.screenBuilder,
//   });
// }
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen>
//     with SingleTickerProviderStateMixin {
//   String _userName = 'User';
//   String _userInitial = 'U';
//   String _userEmail = '';
//   String _userType = '';
//   bool _isAdmin = false;
//   bool _loaded = false;
//   String _currentTime = '';
//   String _currentDate = '';
//   String _greeting = '';
//   Timer? _timer;
//
//   // Permission flags
//   bool canViewDashboard = false;
//   bool canViewSales = false;
//   bool canViewPurchase = false;
//   bool canViewStock = false;
//   bool canViewReports = false;
//   bool canViewBank = false;
//   bool canViewSetUp = false;
//
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeOut,
//     );
//     _updateTime();
//     _timer = Timer.periodic(const Duration(seconds: 30), (_) => _updateTime());
//     _loadUserData();
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _fadeController.dispose();
//     super.dispose();
//   }
//
//   void _updateTime() {
//     final now = DateTime.now();
//     final hour = now.hour;
//     setState(() {
//       _currentTime = DateFormat('hh:mm a').format(now);
//       _currentDate = DateFormat('EEEE, dd MMM yyyy').format(now);
//       if (hour < 12) {
//         _greeting = 'Good Morning';
//       } else if (hour < 17) {
//         _greeting = 'Good Afternoon';
//       } else {
//         _greeting = 'Good Evening';
//       }
//     });
//   }
//
//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final admin = await AccessControl.isAdmin();
//     final userType = prefs.getString('user_type') ?? '';
//
//     // Extract username & email from stored user JSON
//     String userName = 'User';
//     String userEmail = '';
//     final userJson = prefs.getString('user');
//     if (userJson != null) {
//       try {
//         final userMap = Map<String, dynamic>.from(
//             const JsonDecoder().convert(userJson));
//         userName = userMap['name'] ?? userMap['user_name'] ?? 'User';
//         userEmail = userMap['email'] ?? userMap['username'] ?? '';
//       } catch (_) {}
//     }
//     // Fallback to direct keys
//     if (userName == 'User') {
//       userName = prefs.getString('user_name') ?? prefs.getString('name') ?? 'User';
//     }
//
//     final dashboard = await AccessControl.canDo('can_view_dashboard');
//     final sales = await AccessControl.canDo('can_view_sales');
//     final purchase = await AccessControl.canDo('can_view_purchase');
//     final stock = await AccessControl.canDo('can_view_stock');
//     final reports = await AccessControl.canDo('can_view_reports');
//     final bank = await AccessControl.canDo('can_view_accounts');
//     final setup = await AccessControl.canDo('can_view_setup');
//
//     if (!mounted) return;
//     setState(() {
//       _userName = userName;
//       _userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
//       _userEmail = userEmail;
//       _userType = userType;
//       _isAdmin = admin;
//       canViewDashboard = dashboard;
//       canViewSales = sales;
//       canViewPurchase = purchase;
//       canViewStock = stock;
//       canViewReports = reports;
//       canViewBank = bank;
//       canViewSetUp = setup;
//       _loaded = true;
//     });
//     _fadeController.forward();
//   }
//
//   String get _displayRole {
//     if (_isAdmin) return 'Administrator';
//     if (_userType.isNotEmpty) {
//       // Capitalize first letter
//       return '${_userType[0].toUpperCase()}${_userType.substring(1)}';
//     }
//     return 'Staff';
//   }
//
//   List<_ModuleCard> get _visibleModules {
//     final all = <_ModuleCard>[
//       if (_isAdmin || canViewDashboard)
//         _ModuleCard(
//           icon: Icons.grid_view_rounded,
//           label: 'Dashboard',
//           subtitle: 'Analytics & KPIs',
//           colors: [const Color(0xFF5B86E5), const Color(0xFF36D1DC)],
//           screenBuilder: () => const DashboardScreen(),
//         ),
//       if (_isAdmin || canViewSales)
//         _ModuleCard(
//           icon: Icons.receipt_long_rounded,
//           label: 'Sales',
//           subtitle: 'Invoices & Orders',
//           colors: [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
//           screenBuilder: () => const SalesDashboard(),
//         ),
//       if (_isAdmin || canViewPurchase)
//         _ModuleCard(
//           icon: Icons.inventory_2_rounded,
//           label: 'Purchases',
//           subtitle: 'Purchase Orders',
//           colors: [const Color(0xFF059669), const Color(0xFF10B981)],
//           screenBuilder: () => const PurchaseDashboard(),
//         ),
//       if (_isAdmin || canViewStock)
//         _ModuleCard(
//           icon: Icons.warehouse_rounded,
//           label: 'Stock',
//           subtitle: 'Inventory & Items',
//           colors: [const Color(0xFFD97706), const Color(0xFFF59E0B)],
//           screenBuilder: () => const StockMain(),
//         ),
//       if (_isAdmin || canViewBank)
//         _ModuleCard(
//           icon: Icons.account_balance_rounded,
//           label: 'Accounts',
//           subtitle: 'Banks & Ledgers',
//           colors: [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)],
//           screenBuilder: () => const BanksDefineScreen(),
//         ),
//       if (_isAdmin || canViewReports)
//         _ModuleCard(
//           icon: Icons.bar_chart_rounded,
//           label: 'Reports',
//           subtitle: 'Analytics Reports',
//           colors: [const Color(0xFF0891B2), const Color(0xFF06B6D4)],
//           screenBuilder: () => const ReportsDashboardScreen(),
//         ),
//       if (_isAdmin || canViewSetUp)
//         _ModuleCard(
//           icon: Icons.settings_rounded,
//           label: 'Setup',
//           subtitle: 'Configuration',
//           colors: [const Color(0xFF64748B), const Color(0xFF94A3B8)],
//           screenBuilder: () => const SetUpDashboard(),
//         ),
//     ];
//     return all;
//   }
//
//   void _navigateToModule(_ModuleCard module) {
//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (_, animation, __) => module.screenBuilder(),
//         transitionsBuilder: (_, animation, __, child) => SlideTransition(
//           position: Tween<Offset>(
//             begin: const Offset(1.0, 0),
//             end: Offset.zero,
//           ).animate(
//               CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
//           child: child,
//         ),
//         transitionDuration: const Duration(milliseconds: 280),
//       ),
//     );
//   }
//
//   void _handleLogout() async {
//     final shouldLogout = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         backgroundColor: Colors.white,
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.red.shade50,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(Icons.logout_rounded,
//                   color: Colors.red.shade400, size: 20),
//             ),
//             const SizedBox(width: 12),
//             const Text('Logout',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
//           ],
//         ),
//         content: const Text(
//           'Are you sure you want to logout?',
//           style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text('Cancel',
//                 style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red.shade400,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             ),
//             onPressed: () => Navigator.pop(context, true),
//             child:
//                 const Text('Logout', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//
//     if (shouldLogout ?? false) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.clear();
//       if (mounted) {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => LoginScreen()),
//           (route) => false,
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       body: !_loaded
//           ? const Center(
//               child: CircularProgressIndicator(
//                 color: AppColors.primary,
//                 strokeWidth: 2.5,
//               ),
//             )
//           : FadeTransition(
//               opacity: _fadeAnimation,
//               child: SafeArea(
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // ── Header Card ──
//                       _buildHeaderCard(),
//
//                       const SizedBox(height: 24),
//
//                       // ── Quick Stats Row ──
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Row(
//                           children: [
//                             _buildStatChip(
//                               Icons.calendar_today_rounded,
//                               _currentDate,
//                               AppColors.secondary,
//                             ),
//                             const SizedBox(width: 10),
//                             _buildStatChip(
//                               Icons.access_time_rounded,
//                               _currentTime,
//                               AppColors.primary,
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(height: 28),
//
//                       // ── Quick Access Header ──
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 4,
//                               height: 22,
//                               decoration: BoxDecoration(
//                                 gradient: const LinearGradient(
//                                   colors: [
//                                     AppColors.secondary,
//                                     AppColors.primary
//                                   ],
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                 ),
//                                 borderRadius: BorderRadius.circular(2),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             const Text(
//                               'Quick Access',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w800,
//                                 color: Color(0xFF1A1A2E),
//                                 letterSpacing: -0.3,
//                               ),
//                             ),
//                             const Spacer(),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 12, vertical: 5),
//                               decoration: BoxDecoration(
//                                 color: AppColors.primary.withOpacity(0.08),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 '${_visibleModules.length} modules',
//                                 style: TextStyle(
//                                   color: AppColors.primary,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       // ── Module Cards ──
//                       if (_visibleModules.isEmpty)
//                         _buildNoModulesWidget()
//                       else
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: GridView.builder(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             gridDelegate:
//                                 const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               childAspectRatio: 1.05,
//                               crossAxisSpacing: 14,
//                               mainAxisSpacing: 14,
//                             ),
//                             itemCount: _visibleModules.length,
//                             itemBuilder: (context, index) {
//                               final module = _visibleModules[index];
//                               return _buildModuleCard(module, index);
//                             },
//                           ),
//                         ),
//
//                       const SizedBox(height: 30),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
//
//   // ── Header Card ──
//   Widget _buildHeaderCard() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [AppColors.secondary, AppColors.primary],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.secondary.withOpacity(0.3),
//             blurRadius: 24,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Top Row: Brand + Logout ──
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     width: 38,
//                     height: 38,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(11),
//                     ),
//                     child: const Icon(Icons.store_rounded,
//                         color: Colors.white, size: 20),
//                   ),
//                   const SizedBox(width: 10),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Siddiqui Traders',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                       Text(
//                         'Distribution Management',
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.7),
//                           fontSize: 10,
//                           letterSpacing: 0.8,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               GestureDetector(
//                 onTap: _handleLogout,
//                 child: Container(
//                   width: 38,
//                   height: 38,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(11),
//                   ),
//                   child: const Icon(Icons.logout_rounded,
//                       color: Colors.white70, size: 18),
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 24),
//
//           // ── Divider ──
//           Container(
//             height: 1,
//             color: Colors.white.withOpacity(0.15),
//           ),
//
//           const SizedBox(height: 20),
//
//           // ── User Info ──
//           Row(
//             children: [
//               // Avatar
//               Container(
//                 width: 54,
//                 height: 54,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.3),
//                     width: 2,
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     _userInitial,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '$_greeting,',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.75),
//                         fontSize: 13,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       _userName,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 22,
//                         fontWeight: FontWeight.w800,
//                         letterSpacing: -0.3,
//                       ),
//                     ),
//                     if (_userEmail.isNotEmpty) ...[
//                       const SizedBox(height: 3),
//                       Text(
//                         _userEmail,
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.6),
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 16),
//
//           // ── Role Badge ──
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.18),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.2),
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   _isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
//                   color: Colors.white,
//                   size: 15,
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   _displayRole,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.3,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Stat Chip ──
//   Widget _buildStatChip(IconData icon, String text, Color color) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: const Color(0xFFE4E9F2)),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.06),
//               blurRadius: 10,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(9),
//               ),
//               child: Icon(icon, color: color, size: 16),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 text,
//                 style: const TextStyle(
//                   color: Color(0xFF1A1A2E),
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Module Card ──
//   Widget _buildModuleCard(_ModuleCard module, int index) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0.0, end: 1.0),
//       duration: Duration(milliseconds: 300 + (index * 80)),
//       curve: Curves.easeOutCubic,
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(0, 20 * (1 - value)),
//           child: Opacity(
//             opacity: value.clamp(0.0, 1.0),
//             child: child,
//           ),
//         );
//       },
//       child: GestureDetector(
//         onTap: () => _navigateToModule(module),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: const Color(0xFFE4E9F2)),
//             boxShadow: [
//               BoxShadow(
//                 color: module.colors[0].withOpacity(0.07),
//                 blurRadius: 16,
//                 offset: const Offset(0, 6),
//               ),
//             ],
//           ),
//           child: Stack(
//             children: [
//               // ── Background circle decoration ──
//               Positioned(
//                 top: -15,
//                 right: -15,
//                 child: Container(
//                   width: 70,
//                   height: 70,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: module.colors[0].withOpacity(0.04),
//                   ),
//                 ),
//               ),
//               // ── Content ──
//               Padding(
//                 padding: const EdgeInsets.all(18),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Icon container
//                     Container(
//                       width: 48,
//                       height: 48,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             module.colors[0].withOpacity(0.12),
//                             module.colors[1].withOpacity(0.06),
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       child: Icon(module.icon,
//                           color: module.colors[0], size: 24),
//                     ),
//                     const SizedBox(height: 12),
//                     // Label
//                     Text(
//                       module.label,
//                       style: const TextStyle(
//                         color: Color(0xFF1A1A2E),
//                         fontSize: 15,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     // Subtitle
//                     Text(
//                       module.subtitle,
//                       style: const TextStyle(
//                         color: Color(0xFF94A3B8),
//                         fontSize: 11,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // ── Arrow ──
//               Positioned(
//                 bottom: 14,
//                 right: 14,
//                 child: Container(
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                     color: module.colors[0].withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     Icons.arrow_forward_ios_rounded,
//                     color: module.colors[0],
//                     size: 12,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── No Modules Widget ──
//   Widget _buildNoModulesWidget() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.all(40),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xFFE4E9F2)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 64,
//             height: 64,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(18),
//             ),
//             child: Icon(Icons.lock_outline_rounded,
//                 size: 32, color: Colors.grey.shade400),
//           ),
//           const SizedBox(height: 18),
//           const Text(
//             'No Modules Available',
//             style: TextStyle(
//               color: Color(0xFF1A1A2E),
//               fontSize: 17,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Contact your administrator\nto get access to modules',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Color(0xFF94A3B8),
//               fontSize: 13,
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../compoents/AppColors.dart';
import '../utils/access_control.dart';
import 'Auth/LoginScreen.dart';
import 'Bank/BankDefine/BanksDefineScreen.dart';
import 'DashBoardScreen.dart';
import 'PurchaseScreen/PurchaseScreen.dart';
import 'SalesView/SalesScreen.dart';
import 'SalesView/stock/stockcard/stock_main.dart';
import 'reports/reports_dashboard/reports_dashboard_screen.dart';
import 'setup/setup_dashboard.dart';

class _ModuleCard {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color accentColor;
  final Widget Function() screenBuilder;

  const _ModuleCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accentColor,
    required this.screenBuilder,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String _userName = 'User';
  String _userInitial = 'U';
  String _userEmail = '';
  String _userType = '';
  bool _isAdmin = false;
  bool _loaded = false;
  String _currentTime = '';
  String _currentDate = '';
  String _greeting = '';
  Timer? _timer;

  bool canViewDashboard = false;
  bool canViewSales = false;
  bool canViewPurchase = false;
  bool canViewStock = false;
  bool canViewReports = false;
  bool canViewBank = false;
  bool canViewSetUp = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // ── Design tokens ──
  static const Color _headerStart = Color(0xFF5B86E5);
  static const Color _headerEnd   = Color(0xFF36D1DC);
  static const Color _surface     = Color(0xFFF8FAFC);
  static const Color _cardBg      = Colors.white;
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textMuted   = Color(0xFF64748B);
  static const Color _border      = Color(0xFFE4E9F2);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _updateTime());
    _loadUserData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  void _updateTime() {
    final now  = DateTime.now();
    final hour = now.hour;
    setState(() {
      _currentTime = DateFormat('hh:mm a').format(now);
      _currentDate = DateFormat('EEE, dd MMM yyyy').format(now);
      if (hour < 12) {
        _greeting = 'Good Morning';
      } else if (hour < 17) {
        _greeting = 'Good Afternoon';
      } else {
        _greeting = 'Good Evening';
      }
    });
  }

  Future<void> _loadUserData() async {
    final prefs    = await SharedPreferences.getInstance();
    final admin    = await AccessControl.isAdmin();
    final userType = prefs.getString('user_type') ?? '';

    String userName  = 'User';
    String userEmail = '';
    final userJson   = prefs.getString('user');
    if (userJson != null) {
      try {
        final map = Map<String, dynamic>.from(
            const JsonDecoder().convert(userJson));
        userName  = map['name'] ?? map['user_name'] ?? 'User';
        userEmail = map['email'] ?? map['username'] ?? '';
      } catch (_) {}
    }
    if (userName == 'User') {
      userName = prefs.getString('user_name') ?? prefs.getString('name') ?? 'User';
    }

    final dashboard = await AccessControl.canDo('can_view_dashboard');
    final sales     = await AccessControl.canDo('can_view_sales');
    final purchase  = await AccessControl.canDo('can_view_purchase');
    final stock     = await AccessControl.canDo('can_view_stock');
    final reports   = await AccessControl.canDo('can_view_reports');
    final bank      = await AccessControl.canDo('can_view_accounts');
    final setup     = await AccessControl.canDo('can_view_setup');

    if (!mounted) return;
    setState(() {
      _userName          = userName;
      _userInitial       = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
      _userEmail         = userEmail;
      _userType          = userType;
      _isAdmin           = admin;
      canViewDashboard   = dashboard;
      canViewSales       = sales;
      canViewPurchase    = purchase;
      canViewStock       = stock;
      canViewReports     = reports;
      canViewBank        = bank;
      canViewSetUp       = setup;
      _loaded            = true;
    });
    _fadeController.forward();
  }

  String get _displayRole {
    if (_isAdmin) return 'Administrator';
    if (_userType.isNotEmpty) {
      return '${_userType[0].toUpperCase()}${_userType.substring(1)}';
    }
    return 'Staff';
  }

  List<_ModuleCard> get _visibleModules => [
    if (_isAdmin || canViewDashboard)
      _ModuleCard(
        icon: Icons.grid_view_rounded,
        label: 'Dashboard',
        subtitle: 'Analytics & KPIs',
        accentColor: const Color(0xFF2563EB),
        screenBuilder: () => const DashboardScreen(),
      ),
    if (_isAdmin || canViewSales)
      _ModuleCard(
        icon: Icons.receipt_long_rounded,
        label: 'Sales',
        subtitle: 'Invoices & Orders',
        accentColor: const Color(0xFF059669),
        screenBuilder: () => const SalesDashboard(),
      ),
    if (_isAdmin || canViewPurchase)
      _ModuleCard(
        icon: Icons.inventory_2_rounded,
        label: 'Purchases',
        subtitle: 'Purchase Orders',
        accentColor: const Color(0xFFD97706),
        screenBuilder: () => const PurchaseDashboard(),
      ),
    if (_isAdmin || canViewStock)
      _ModuleCard(
        icon: Icons.warehouse_rounded,
        label: 'Stock',
        subtitle: 'Inventory & Items',
        accentColor: const Color(0xFF7C3AED),
        screenBuilder: () => const StockMain(),
      ),
    if (_isAdmin || canViewBank)
      _ModuleCard(
        icon: Icons.account_balance_rounded,
        label: 'Accounts',
        subtitle: 'Banks & Ledgers',
        accentColor: const Color(0xFF0891B2),
        screenBuilder: () => const BanksDefineScreen(),
      ),
    if (_isAdmin || canViewReports)
      _ModuleCard(
        icon: Icons.bar_chart_rounded,
        label: 'Reports',
        subtitle: 'Analytics Reports',
        accentColor: const Color(0xFF2563EB),
        screenBuilder: () => const ReportsDashboardScreen(),
      ),
    if (_isAdmin || canViewSetUp)
      _ModuleCard(
        icon: Icons.settings_rounded,
        label: 'Setup',
        subtitle: 'Configuration',
        accentColor: const Color(0xFF64748B),
        screenBuilder: () => const SetUpDashboard(),
      ),
  ];

  void _navigateToModule(_ModuleCard module) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => module.screenBuilder(),
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
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.logout_rounded,
                  color: Colors.red.shade400, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Logout',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style:
                TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: !_loaded
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      )
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildDateTimeRow(),
                const SizedBox(height: 24),
                _buildSectionHeader(),
                const SizedBox(height: 14),
                _visibleModules.isEmpty
                    ? _buildEmpty()
                    : _buildGrid(),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_headerStart, _headerEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _headerStart.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.store_rounded,
                              color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Siddiqui Traders',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Distribution Management',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Logout
                    GestureDetector(
                      onTap: _handleLogout,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.15)),
                        ),
                        child: const Icon(Icons.logout_rounded,
                            color: Colors.white70, size: 17),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Divider(
                    color: Colors.white.withOpacity(0.12), thickness: 0.5),
                const SizedBox(height: 18),

                // User info
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.28),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _userInitial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_greeting,',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (_userEmail.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              _userEmail,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isAdmin
                            ? Icons.admin_panel_settings_rounded
                            : Icons.person_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _displayRole,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  DATE / TIME CHIPS
  // ─────────────────────────────────────────
  Widget _buildDateTimeRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip(Icons.calendar_today_rounded, _currentDate,
              const Color(0xFF2563EB)),
          const SizedBox(width: 10),
          _buildChip(Icons.access_time_rounded, _currentTime,
              const Color(0xFF059669)),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 15),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  SECTION HEADER
  // ─────────────────────────────────────────
  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_headerEnd, _headerStart],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_visibleModules.length} modules',
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  MODULE GRID
  // ─────────────────────────────────────────
  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.05,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _visibleModules.length,
        itemBuilder: (context, index) =>
            _buildModuleCard(_visibleModules[index], index),
      ),
    );
  }

  Widget _buildModuleCard(_ModuleCard module, int index) {
    final color = module.accentColor;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 280 + index * 70),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Transform.translate(
        offset: Offset(0, 18 * (1 - v)),
        child: Opacity(opacity: v.clamp(0.0, 1.0), child: child),
      ),
      child: GestureDetector(
        onTap: () => _navigateToModule(module),
        child: Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Faint accent circle
              Positioned(
                top: -16,
                right: -16,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(module.icon, color: color, size: 22),
                    ),
                    const SizedBox(height: 10),
                    // Labels
                    Text(
                      module.label,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      module.subtitle,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: color,
                    size: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  EMPTY STATE
  // ─────────────────────────────────────────
  Widget _buildEmpty() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.lock_outline_rounded,
                size: 28, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Modules Available',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Contact your administrator\nto get access to modules',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}