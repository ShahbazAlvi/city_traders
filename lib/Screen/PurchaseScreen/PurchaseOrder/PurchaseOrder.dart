import 'package:demo_distribution/Screen/PurchaseScreen/PurchaseOrder/AddPurchaseOrder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


import '../../../Provider/Purchase_Order_Provider/Purchase_order_provider.dart';
import '../../../compoents/AppColors.dart';

class PurchaseOrderScreen extends StatefulWidget {
  const PurchaseOrderScreen({super.key});

  @override
  State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends State<PurchaseOrderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _fmt = NumberFormat('#,##,###');

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: 0, max: 1, period: const Duration(milliseconds: 1500));

    Future.microtask(() {
      context.read<PurchaseOrderProvider>().fetchPurchaseOrder();
    });
  }
  @override
  void dispose() {
    _shimmerController.dispose();
    _searchController.dispose();
    super.dispose();
  }




  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "APPROVED":
        return Colors.green;
      case "PENDING":
        return Colors.orange;
      case "REJECTED":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  // ── Shimmer ───────────────────────────────────────────────────────────────

  Widget _buildShimmerEffect({required Widget child}) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: const [Color(0xFFE0E0E0), Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
        stops: const [0.0, 0.5, 1.0],
        transform:
        GradientRotation(_shimmerController.value * 2 * 3.14159),
      ).createShader(bounds),
      blendMode: BlendMode.srcATop,
      child: child,
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PurchaseOrderProvider>();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Center(child: const Text("Purchase Order",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.2,
            )),
        ),
        centerTitle: true,
        elevation: 6,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                final provider =
                Provider.of<PurchaseOrderProvider>(context, listen: false);

                String nextOrderId = "PO-0001";

                if (provider.orders.isNotEmpty) {
                  final allNumbers = provider.orders.map((order) {
                    final id = order.poNo;
                    final regex = RegExp(r'PO-(\d+)$');
                    final match = regex.firstMatch(id);
                    return match != null
                        ? int.tryParse(match.group(1)!) ?? 0
                        : 0;
                  }).toList();

                  final maxNumber = allNumbers.reduce((a, b) => a > b ? a : b);
                  final incremented = maxNumber + 1;

                  nextOrderId = "PO-${incremented.toString().padLeft(4, '0')}";
                }

                print("✅ Next Order ID: $nextOrderId");

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddPurchaseOrder(nextOrderId: nextOrderId),
                  ),
                );
              },

              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text(
                "Add Order",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],





      ),

      body: Builder(
        builder: (_) {

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(child: Text(provider.error));
          }

          if (provider.orders.isEmpty) {
            return const Center(child: Text("No Purchase Orders"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.orders.length,
            itemBuilder: (context, index) {
              final order = provider.orders[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// PO Number + Status
                      Row(
                    children: [
                          Text(order.poNo,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(width: 5,),

                      Text(
                        (order.supplierName ?? '').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )

                        ],
                      ),

                      const SizedBox(height: 6),

                      /// Supplier


                      /// Date
                      Row(
                        children: [
                          Text("${DateFormat('dd MMM yyyy').format(order.poDate)}"),
                          SizedBox(width: 10,),
                          Text(
                            "Rs. ${NumberFormat('#,##0').format(double.parse(order.totalAmount))}",
                          )
                        ],
                      ),




                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
// import 'package:demo_distribution/Screen/PurchaseScreen/PurchaseOrder/AddPurchaseOrder.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import 'package:shimmer/shimmer.dart';
//
// import '../../../Provider/Purchase_Order_Provider/Purchase_order_provider.dart';
// import '../../../compoents/AppColors.dart';
//
// class PurchaseOrderScreen extends StatefulWidget {
//   const PurchaseOrderScreen({super.key});
//
//   @override
//   State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
// }
//
// class _PurchaseOrderScreenState extends State<PurchaseOrderScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   final NumberFormat _fmt = NumberFormat('#,##,###');
//   final FocusNode _searchFocusNode = FocusNode();
//
//   // Animation for search bar
//   late AnimationController _animationController;
//   late Animation<double> _searchAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _searchAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//
//     Future.microtask(() {
//       context.read<PurchaseOrderProvider>().fetchPurchaseOrder();
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _searchFocusNode.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   Color getStatusColor(String status) {
//     switch (status.toUpperCase()) {
//       case "APPROVED":
//         return const Color(0xFF10B981);
//       case "PENDING":
//         return const Color(0xFFF59E0B);
//       case "REJECTED":
//         return const Color(0xFFEF4444);
//       default:
//         return Colors.grey;
//     }
//   }
//
//   String getStatusText(String status) {
//     switch (status.toUpperCase()) {
//       case "APPROVED":
//         return "Approved";
//       case "PENDING":
//         return "Pending";
//       case "REJECTED":
//         return "Rejected";
//       default:
//         return status;
//     }
//   }
//
//   // Delete confirmation dialog
//   Future<void> _showDeleteDialog(BuildContext context, int orderId, String poNo) async {
//     return showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text('Delete Order'),
//           content: Text('Are you sure you want to delete $poNo?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(dialogContext); // close confirm dialog
//
//                 final provider = Provider.of<PurchaseOrderProvider>(
//                     context, listen: false
//                 );
//
//                 // No manual loading dialog — provider handles state
//                 bool success = await provider.deletePurchaseOrder(orderId);
//
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         success
//                             ? 'Order $poNo deleted successfully'
//                             : provider.error,
//                       ),
//                       backgroundColor: success ? Colors.green : Colors.red,
//                       behavior: SnackBarBehavior.floating,
//                     ),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildShimmerLoading() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: 6,
//       itemBuilder: (_, __) => Shimmer.fromColors(
//         baseColor: Colors.grey[300]!,
//         highlightColor: Colors.grey[100]!,
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 16),
//           height: 180,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<PurchaseOrderProvider>();
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF1A1F2E) : const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [AppColors.secondary, AppColors.primary],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(30),
//               bottomRight: Radius.circular(30),
//             ),
//           ),
//         ),
//         title: const Text(
//           "Purchase Orders",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w700,
//             fontSize: 22,
//             letterSpacing: 0.5,
//           ),
//         ),
//         centerTitle: false,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           Container(
//             margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               color: Colors.white.withOpacity(0.2),
//             ),
//             child: IconButton(
//               onPressed: () {
//                 _animationController.isCompleted
//                     ? _animationController.reverse()
//                     : _animationController.forward();
//                 _searchFocusNode.requestFocus();
//               },
//               icon: const Icon(Icons.search, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Animated Search Bar
//           SizeTransition(
//             sizeFactor: _searchAnimation,
//             axisAlignment: -1.0,
//             child: Container(
//               margin: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 focusNode: _searchFocusNode,
//                 decoration: InputDecoration(
//                   hintText: "Search by PO number or supplier...",
//                   hintStyle: TextStyle(
//                     color: isDark ? Colors.white38 : Colors.black38,
//                     fontSize: 14,
//                   ),
//                   prefixIcon: Icon(
//                     Icons.search,
//                     color: isDark ? Colors.white54 : Colors.black54,
//                   ),
//                   suffixIcon: _searchController.text.isNotEmpty
//                       ? IconButton(
//                     icon: Icon(
//                       Icons.clear,
//                       color: isDark ? Colors.white54 : Colors.black54,
//                     ),
//                     onPressed: () {
//                       _searchController.clear();
//                       // Add search functionality here
//                     },
//                   )
//                       : null,
//                   filled: true,
//                   fillColor: isDark ? const Color(0xFF2D3447) : Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20),
//                     borderSide: BorderSide.none,
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20),
//                     borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(vertical: 12),
//                 ),
//                 style: TextStyle(
//                   color: isDark ? Colors.white : Colors.black87,
//                   fontSize: 15,
//                 ),
//                 onChanged: (value) {
//                   // Add search functionality here
//                 },
//               ),
//             ),
//           ),
//
//           // Stats Cards
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _buildStatCard(
//                     title: "Total Orders",
//                     value: provider.orders.length.toString(),
//                     icon: Icons.shopping_cart_outlined,
//                     color: AppColors.primary,
//                     isDark: isDark,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildStatCard(
//                     title: "Total Amount",
//                     value: "Rs ${_fmt.format(provider.orders.fold(0.0, (sum, order) => sum + (double.tryParse(order.totalAmount) ?? 0)))}",
//                     icon: Icons.currency_rupee,
//                     color: Colors.green,
//                     isDark: isDark,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Orders List
//           Expanded(
//             child: Builder(
//               builder: (_) {
//                 if (provider.isLoading) {
//                   return _buildShimmerLoading();
//                 }
//
//                 if (provider.error.isNotEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.error_outline,
//                           size: 60,
//                           color: Colors.red[300],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           provider.error,
//                           style: const TextStyle(fontSize: 16),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: () {
//                             context.read<PurchaseOrderProvider>().fetchPurchaseOrder();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primary,
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text("Retry"),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//
//                 if (provider.orders.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: Colors.grey.withOpacity(0.1),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             Icons.inventory_2_outlined,
//                             size: 60,
//                             color: Colors.grey[400],
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           "No Purchase Orders Found",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: isDark ? Colors.white70 : Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Click the + button to create your first order",
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: isDark ? Colors.white38 : Colors.black54,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//
//                 return RefreshIndicator(
//                   onRefresh: () => context.read<PurchaseOrderProvider>().fetchPurchaseOrder(),
//                   color: AppColors.primary,
//                   backgroundColor: isDark ? const Color(0xFF2D3447) : Colors.white,
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: provider.orders.length,
//                     itemBuilder: (context, index) {
//                       final order = provider.orders[index];
//
//                       return TweenAnimationBuilder(
//                         tween: Tween<double>(begin: 0, end: 1),
//                         duration: Duration(milliseconds: 300 + (index * 100)),
//                         curve: Curves.easeOut,
//                         builder: (context, double value, child) {
//                           return Transform.translate(
//                             offset: Offset(0, 50 * (1 - value)),
//                             child: Opacity(
//                               opacity: value,
//                               child: child,
//                             ),
//                           );
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.only(bottom: 16),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(24),
//                             gradient: LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                               colors: isDark
//                                   ? [const Color(0xFF2D3447), const Color(0xFF1F2538)]
//                                   : [Colors.white, Colors.grey[50]!],
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.03),
//                                 blurRadius: 20,
//                                 offset: const Offset(0, 8),
//                               ),
//                             ],
//                           ),
//                           child: Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(24),
//                               onTap: () {
//                                 // Navigate to order details
//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.all(20),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     // Header Row with PO Number and Action Buttons
//                                     Row(
//                                       children: [
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 12,
//                                             vertical: 6,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             color: AppColors.primary.withOpacity(0.1),
//                                             borderRadius: BorderRadius.circular(12),
//                                           ),
//                                           child: Text(
//                                             order.poNo,
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w600,
//                                               color: AppColors.primary,
//                                             ),
//                                           ),
//                                         ),
//                                         const Spacer(),
//
//                                         // Edit Button
//                                         Container(
//                                           margin: const EdgeInsets.only(right: 8),
//                                           decoration: BoxDecoration(
//                                             color: Colors.blue.withOpacity(0.1),
//                                             borderRadius: BorderRadius.circular(12),
//                                           ),
//                                           child: IconButton(
//                                             icon: Icon(
//                                               Icons.edit_outlined,
//                                               size: 20,
//                                               color: Colors.blue[700],
//                                             ),
//                                             onPressed: () {
//                                              // Navigate to edit screen with order data
//                                               Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                   builder: (context) => AddPurchaseOrder(
//                                                     nextOrderId: order.poNo,
//
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                             padding: const EdgeInsets.all(8),
//                                             constraints: const BoxConstraints(),
//                                           ),
//                                         ),
//
//                                         // Delete Button
//                                         Container(
//                                           decoration: BoxDecoration(
//                                             color: Colors.red.withOpacity(0.1),
//                                             borderRadius: BorderRadius.circular(12),
//                                           ),
//                                           child: IconButton(
//                                             icon: Icon(
//                                               Icons.delete_outline,
//                                               size: 20,
//                                               color: Colors.red[700],
//                                             ),
//                                             onPressed: () {
//                                               _showDeleteDialog(context, order.id, order.poNo);
//                                             },
//                                             padding: const EdgeInsets.all(8),
//                                             constraints: const BoxConstraints(),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 16),
//
//                                     // Status Badge
//                                     Row(
//                                       children: [
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 12,
//                                             vertical: 6,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             color: getStatusColor(order.status).withOpacity(0.1),
//                                             borderRadius: BorderRadius.circular(20),
//                                           ),
//                                           child: Row(
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: [
//                                               Container(
//                                                 width: 8,
//                                                 height: 8,
//                                                 decoration: BoxDecoration(
//                                                   color: getStatusColor(order.status),
//                                                   shape: BoxShape.circle,
//                                                 ),
//                                               ),
//                                               const SizedBox(width: 6),
//                                               Text(
//                                                 getStatusText(order.status),
//                                                 style: TextStyle(
//                                                   fontSize: 12,
//                                                   fontWeight: FontWeight.w500,
//                                                   color: getStatusColor(order.status),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 16),
//
//                                     // Supplier Info
//                                     Row(
//                                       children: [
//                                         Container(
//                                           padding: const EdgeInsets.all(10),
//                                           decoration: BoxDecoration(
//                                             color: Colors.grey.withOpacity(0.1),
//                                             borderRadius: BorderRadius.circular(14),
//                                           ),
//                                           child: const Icon(
//                                             Icons.business_outlined,
//                                             size: 20,
//                                             color: AppColors.primary,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 "Supplier",
//                                                 style: TextStyle(
//                                                   fontSize: 12,
//                                                   color: isDark ? Colors.white38 : Colors.black45,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 2),
//                                               Text(
//                                                 order.supplierName.toUpperCase(),
//                                                 style: TextStyle(
//                                                   fontSize: 15,
//                                                   fontWeight: FontWeight.w600,
//                                                   color: isDark ? Colors.white : Colors.black87,
//                                                 ),
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 16),
//
//                                     // Date, Items, and Amount Row
//                                     Row(
//                                       children: [
//                                         // Date
//                                         Expanded(
//                                           child: Row(
//                                             children: [
//                                               Icon(
//                                                 Icons.calendar_today_outlined,
//                                                 size: 16,
//                                                 color: isDark ? Colors.white38 : Colors.black45,
//                                               ),
//                                               const SizedBox(width: 8),
//                                               Text(
//                                                 DateFormat('dd MMM yyyy').format(order.poDate),
//                                                 style: TextStyle(
//                                                   fontSize: 14,
//                                                   color: isDark ? Colors.white70 : Colors.black54,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//
//                                         // Total Items
//                                         Container(
//                                           margin: const EdgeInsets.only(right: 12),
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 8,
//                                             vertical: 4,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             color: Colors.orange.withOpacity(0.1),
//                                             borderRadius: BorderRadius.circular(8),
//                                           ),
//                                           child: Row(
//                                             children: [
//                                               Icon(
//                                                 Icons.inventory_2_outlined,
//                                                 size: 14,
//                                                 color: Colors.orange[700],
//                                               ),
//                                               const SizedBox(width: 4),
//                                               Text(
//                                                 '${order.totalItems} items',
//                                                 style: TextStyle(
//                                                   fontSize: 12,
//                                                   color: Colors.orange[700],
//                                                   fontWeight: FontWeight.w500,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//
//                                         // Amount
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 12,
//                                             vertical: 6,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             color: Colors.green.withOpacity(0.1),
//                                             borderRadius: BorderRadius.circular(12),
//                                           ),
//                                           child: Text(
//                                             "₹ ${NumberFormat('#,##0').format(double.parse(order.totalAmount))}",
//                                             style: const TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w700,
//                                               color: Color(0xFF10B981),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: Container(
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [AppColors.secondary, AppColors.primary],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(30),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.primary.withOpacity(0.3),
//               blurRadius: 15,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: FloatingActionButton(
//           onPressed: () {
//             final provider = Provider.of<PurchaseOrderProvider>(context, listen: false);
//
//             String nextOrderId = "PO-0001";
//
//             if (provider.orders.isNotEmpty) {
//               final allNumbers = provider.orders.map((order) {
//                 final id = order.poNo;
//                 final regex = RegExp(r'PO-(\d+)$');
//                 final match = regex.firstMatch(id);
//                 return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
//               }).toList();
//
//               final maxNumber = allNumbers.reduce((a, b) => a > b ? a : b);
//               final incremented = maxNumber + 1;
//               nextOrderId = "PO-${incremented.toString().padLeft(4, '0')}";
//             }
//
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => AddPurchaseOrder(
//                   nextOrderId: nextOrderId,
//
//                 ),
//               ),
//             );
//           },
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           child: const Icon(
//             Icons.add,
//             color: Colors.white,
//             size: 28,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//     required bool isDark,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: isDark
//               ? [const Color(0xFF2D3447), const Color(0xFF1F2538)]
//               : [Colors.white, Colors.grey[50]!],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: isDark ? Colors.white38 : Colors.black45,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     color: isDark ? Colors.white : Colors.black87,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }