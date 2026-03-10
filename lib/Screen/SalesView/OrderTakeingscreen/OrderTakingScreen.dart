//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../Provider/OrderTakingProvider/OrderTakingProvider.dart';
// import '../../../compoents/AppColors.dart';
// import 'AddOrder.dart';
// import 'UpdateOrderScreen.dart';
//
// class OrderTakingScreen extends StatefulWidget {
//   const OrderTakingScreen({super.key});
//
//   @override
//   State<OrderTakingScreen> createState() => _OrderTakingScreenState();
// }
//
// class _OrderTakingScreenState extends State<OrderTakingScreen> {
//   int currentPage = 1;
//   int itemsPerPage = 10;
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<OrderTakingProvider>(context, listen: false).FetchOrderTaking();
//     });
//   }
//
//
//   List getPaginatedData(List data) {
//     int start = (currentPage - 1) * itemsPerPage;
//     int end = start + itemsPerPage;
//
//     if (start >= data.length) return [];
//     if (end > data.length) end = data.length;
//
//     return data.sublist(start, end);
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<OrderTakingProvider>(context);
//
//     return Scaffold(
//       backgroundColor: Color(0xFFEEEEEE),
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: Center(child: const Text("Order Taking",
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//               letterSpacing: 1.2,
//             )),
//         ),
//         centerTitle: true,
//         elevation: 6,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [AppColors.secondary, AppColors.primary],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 final provider = Provider.of<OrderTakingProvider>(context, listen: false);
//
//                 String nextOrderId = "SO-0001"; // Default if no orders found
//
//                 // ✅ Check if data exists and not empty
//                 if (provider.orderData != null && provider.orderData!.data.isNotEmpty) {
//                   // ✅ Extract numeric parts from all order IDs
//                   final allNumbers = provider.orderData!.data.map((order) {
//                     final id = order.soNo?.toString() ?? "";
//                     final regex = RegExp(r'SO-(\d+)$');
//                     final match = regex.firstMatch(id);
//                     return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
//                   }).toList();
//
//                   // ✅ Find the maximum existing number
//                   final maxNumber = allNumbers.isNotEmpty ? allNumbers.reduce((a, b) => a > b ? a : b) : 0;
//
//                   // ✅ Generate the next order ID
//                   final incremented = maxNumber + 1;
//                   nextOrderId = "SO-${incremented.toString().padLeft(4, '0')}";
//                 }
//
//                 print("✅ Last Max Order ID: $nextOrderId");
//
//                // ✅ Navigate to AddOrderScreen with incremented ID
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => AddOrderScreen(nextOrderId: nextOrderId),
//                   ),
//                 );
//               },
//               icon: const Icon(Icons.add_circle_outline, color: Colors.white),
//               label: const Text(
//                 "Add Order",
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 shadowColor: Colors.transparent,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//             ),
//           ),
//         ],
//
//
//
//
//
//       ),
//       body: provider.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : provider.error != null
//           ? Center(child: Text(provider.error!))
//           : provider.orderData == null
//           ? const Center(child: Text("No data found"))
//           : Column(
//             children: [
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Builder(
//                     builder: (context) {
//                       final paginatedList = getPaginatedData(provider.orderData!.data);
//                       return ListView.builder(
//                         itemCount: paginatedList.length + 1,   // +1 for pagination row
//                         itemBuilder: (context, index) {
//                           // 👉 If last index → Show Pagination Buttons
//                           if (index == paginatedList.length) {
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   ElevatedButton(
//                                     onPressed: currentPage > 1
//                                         ? () {
//                                       setState(() {
//                                         currentPage--;
//                                       });
//                                     }
//                                         : null,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: AppColors.secondary,
//                                     ),
//                                     child: const Text("Previous",style: TextStyle(color: AppColors.text),),
//                                   ),
//
//                                   const SizedBox(width: 20),
//
//                                   Text(
//                                     "Page $currentPage",
//                                     style: const TextStyle(
//                                         fontSize: 16, fontWeight: FontWeight.bold),
//                                   ),
//
//                                   const SizedBox(width: 20),
//
//                                   ElevatedButton(
//                                     onPressed: (currentPage * itemsPerPage) <
//                                         provider.orderData!.data.length
//                                         ? () {
//                                       setState(() {
//                                         currentPage++;
//                                       });
//                                     }
//                                         : null,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: AppColors.secondary,
//                                     ),
//                                     child: const Text("Next",style: TextStyle(color: AppColors.text),),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }
//
//                           // 👉 Normal Order Card
//                           final order = paginatedList[index];
//
//                           final salesman = order.salesmanName;
//                           final customerName = order.customerName;
//
//                           final orderId = order.soNo;
//                           final date = order.orderDate.toLocal().toString().split(' ')[0];
//
//
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(16),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.15),
//                                   spreadRadius: 2,
//                                   blurRadius: 6,
//                                   offset: const Offset(0, 3),
//                                 ),
//                               ],
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(14.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text("Order ID: $orderId",
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 16,
//                                           )),
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 10, vertical: 4),
//                                         decoration: BoxDecoration(
//                                           color: Colors.blueAccent.withOpacity(0.1),
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                         child: Text(
//                                           date,
//                                           style: const TextStyle(
//                                             color: Colors.blueAccent,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//
//                                   const SizedBox(height: 8),
//                                   const Divider(),
//
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text("Salesman: $salesman",
//                                                 style: const TextStyle(
//                                                     fontWeight: FontWeight.w500)),
//                                             const SizedBox(height: 4),
//                                             Text("Customer: $customerName"),
//
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//
//                                   const SizedBox(height: 10),
//
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       ElevatedButton(
//                                         onPressed: () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   UpdateOrderScreen(order: order),
//                                             ),
//                                           );
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: AppColors.betprologo,
//                                           padding: const EdgeInsets.all(8),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(10),
//                                           ),
//                                         ),
//                                         child:
//                                         const Icon(Icons.edit, color: AppColors.text),
//                                       ),
//                                       SizedBox(width: 8),
//                                       ElevatedButton(
//                                         onPressed: () {
//                                           _confirmDelete(context, order.id);
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: AppColors.Instructions,
//                                           padding: const EdgeInsets.all(8),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(10),
//                                           ),
//                                         ),
//                                         child:
//                                         const Icon(Icons.delete, color: AppColors.text),
//                                       ),
//                                       SizedBox(width: 8),
//                                       ElevatedButton(
//                                         onPressed: () {
//                                           showModalBottomSheet(
//                                             context: context,
//                                             shape: const RoundedRectangleBorder(
//                                               borderRadius:
//                                               BorderRadius.vertical(top: Radius.circular(20)),
//                                             ),
//                                             builder: (_) =>
//                                                 _OrderDetailsSheet(orderId: orderId),
//                                           );
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: AppColors.secondary,
//                                           padding: const EdgeInsets.all(8),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(10),
//                                           ),
//                                         ),
//                                         child: const Icon(Icons.visibility,
//                                             color: AppColors.text),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//
//                     },
//                   ),
//                 ),
//               ),
//
//             ],
//           ),
//     );
//   }
//   Future<void> _confirmDelete(BuildContext context, String orderId) async {
//     final provider = Provider.of<OrderTakingProvider>(context, listen: false);
//
//     return showDialog(
//       context: context,
//       barrierDismissible: false, // user cannot close by tapping outside
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: const Text(
//             "Delete Order",
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           content: const Text(
//             "Are you sure you want to delete this order?",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context); // close dialog
//               },
//               child: const Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.pop(context); // close dialog first
//
//                 await provider.deleteOrder(orderId);
//
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Order deleted successfully")),
//                 );
//               },
//               child: const Text("Delete"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
// }
//
// class _OrderDetailsSheet extends StatelessWidget {
//   final String orderId;
//   const _OrderDetailsSheet({required this.orderId});
//
//   @override
//   Widget build(BuildContext context) {
//     final provider =
//     Provider.of<OrderTakingProvider>(context, listen: false);
//     final order =
//     provider.orderData!.data.firstWhere((o) => o.soNo == orderId);
//     final customer = order.customerId;
//
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//         BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.only(bottom: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             Text("Order ID: ${order.soNo}",
//                 style: const TextStyle(
//                     fontWeight: FontWeight.bold, fontSize: 18)),
//             const SizedBox(height: 8),
//             Text("Date: ${order.orderDate.toLocal().toString().split(' ')[0]}"),
//             Text("Customer: ${order.customerName}"),
//             const Divider(),
//             const Text("Products:",
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold, fontSize: 16)),
//             Text("item Quenty: ${order.totalQty}"),
//
//             const Divider(),
//             Text("Status: ${order.status}",
//                 style: const TextStyle(color: Colors.blueAccent)),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/OrderTakingProvider/OrderTakingProvider.dart';
import '../../../compoents/AppColors.dart';
import '../../../utils/access_control.dart';
import 'AddOrder.dart';
import 'UpdateOrderScreen.dart';
import 'package:shimmer/shimmer.dart';

class OrderTakingScreen extends StatefulWidget {
  const OrderTakingScreen({super.key});

  @override
  State<OrderTakingScreen> createState() => _OrderTakingScreenState();
}

class _OrderTakingScreenState extends State<OrderTakingScreen> {
  int currentPage = 1;
  int itemsPerPage = 10;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  // ✅ Permission Variables
  bool canAddOrder    = false;
  bool canEditOrder   = false;
  bool canDeleteOrder = false;
  bool canViewOrder   = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderTakingProvider>(context, listen: false).FetchOrderTaking();
    });
    _scrollController.addListener(_onScroll);
    _loadPermissions(); // ✅ Load permissions
  }

  // ✅ Permission Load Function
  Future<void> _loadPermissions() async {
    final add    = await AccessControl.canDo("can_add_order_booking");
    final edit   = await AccessControl.canDo("can_edit_order_booking");
    final delete = await AccessControl.canDo("can_delete_order_booking");
    final view   = await AccessControl.canDo("can_view_order_booking");

    setState(() {
      canAddOrder    = add;
      canEditOrder   = edit;
      canDeleteOrder = delete;
      canViewOrder   = view;
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     Provider.of<OrderTakingProvider>(context, listen: false).FetchOrderTaking();
  //   });
  //   _scrollController.addListener(_onScroll);
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Load more if needed for infinite scroll
    }
  }

  List getPaginatedData(List data) {
    // Apply search filter first
    final filteredData = data.where((order) {
      final query = searchQuery.toLowerCase();
      return order.soNo?.toLowerCase().contains(query) == true ||
          order.customerName?.toLowerCase().contains(query) == true ||
          order.salesmanName?.toLowerCase().contains(query) == true;
    }).toList();

    int start = (currentPage - 1) * itemsPerPage;
    int end = start + itemsPerPage;

    if (start >= filteredData.length) return [];
    if (end > filteredData.length) end = filteredData.length;

    return filteredData.sublist(start, end);
  }

  int get filteredItemCount {
    if (provider.orderData == null) return 0;
    return provider.orderData!.data.where((order) {
      final query = searchQuery.toLowerCase();
      return order.soNo?.toLowerCase().contains(query) == true ||
          order.customerName?.toLowerCase().contains(query) == true ||
          order.salesmanName?.toLowerCase().contains(query) == true;
    }).length;
  }

  late OrderTakingProvider provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<OrderTakingProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: provider.isLoading
          ? _buildShimmerLoading()
          : provider.error != null
          ? _buildErrorWidget()
          : provider.orderData == null || provider.orderData!.data.isEmpty
          ? _buildEmptyState()
          : _buildMainContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      title: const Text(
        "Order Management",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  currentPage = 1; // Reset to first page on search
                });
              },
              decoration: InputDecoration(
                hintText: 'Search orders...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade300,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.error!,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              provider.FetchOrderTaking();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_rounded,
              size: 80,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Orders Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first order',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _navigateToAddOrder();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    final paginatedList = getPaginatedData(provider.orderData!.data);
    final totalFilteredItems = filteredItemCount;
    final totalPages = (totalFilteredItems / itemsPerPage).ceil();

    return Column(
      children: [
        // Stats Cards

        // Add Order FAB for mobile-friendly experience
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                searchQuery.isEmpty ? 'Recent Orders' : 'Search Results',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (canAddOrder)
              ElevatedButton.icon(
                onPressed: _navigateToAddOrder,
                icon: const Icon(Icons.add),
                label: const Text('Add Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Orders List
        Expanded(
          child: paginatedList.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'No matching orders found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: paginatedList.length + (totalPages > 1 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == paginatedList.length) {
                return _buildPaginationControls(totalPages);
              }
              final order = paginatedList[index];
              return _buildOrderCard(order);
            },
          ),
        ),
      ],
    );
  }



  Widget _buildOrderCard(order) {
    final statusColor = order.status == 'Delivered'
        ? Colors.green
        : order.status == 'Pending'
        ? Colors.orange
        : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Show quick preview or navigate to details
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.soNo ?? 'N/A',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                order.orderDate.toLocal().toString().split(' ')[0],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.status ?? 'Unknown',
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Customer Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Customer',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  Text(
                                    order.customerName ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey.shade300,
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Items ${order.totalItems}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  Text(
                                    '${order.totalQty} Qty',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
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
                ),

                const SizedBox(height: 16),


                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Total Amount   Rs:${order.totalAmount}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 20),
                    if (canViewOrder)
                    _buildActionButton(
                      icon: Icons.visibility,
                      color: Colors.blue,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => _OrderDetailsSheet(orderId: order.soNo),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    if (canEditOrder)
                    _buildActionButton(
                      icon: Icons.edit,
                      color: AppColors.betprologo,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateOrderScreen(order: order),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    if (canDeleteOrder)
                    _buildActionButton(
                      icon: Icons.delete,
                      color: Colors.red,
                      onPressed: () {
                        _confirmDelete(context, order.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: color,),
      onPressed: onPressed,
      constraints: const BoxConstraints(
        minWidth: 36,
        minHeight: 36,
      ),
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1
                ? () {
              setState(() {
                currentPage--;
              });
            }
                : null,
            color: currentPage > 1 ? AppColors.primary : Colors.grey,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Page $currentPage of $totalPages',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages
                ? () {
              setState(() {
                currentPage++;
              });
            }
                : null,
            color: currentPage < totalPages ? AppColors.primary : Colors.grey,
          ),
        ],
      ),
    );
  }

  void _navigateToAddOrder() {
    String nextOrderId = "SO-0001";

    if (provider.orderData != null && provider.orderData!.data.isNotEmpty) {
      final allNumbers = provider.orderData!.data.map((order) {
        final id = order.soNo?.toString() ?? "";
        final regex = RegExp(r'SO-(\d+)$');
        final match = regex.firstMatch(id);
        return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
      }).toList();

      final maxNumber = allNumbers.isNotEmpty ? allNumbers.reduce((a, b) => a > b ? a : b) : 0;
      final incremented = maxNumber + 1;
      nextOrderId = "SO-${incremented.toString().padLeft(4, '0')}";
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOrderScreen(nextOrderId: nextOrderId),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String orderId) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Delete Order",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to delete this order? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                await provider.deleteOrder(orderId);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Order deleted successfully"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final String orderId;
  const _OrderDetailsSheet({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderTakingProvider>(context, listen: false);
    final order = provider.orderData!.data.firstWhere((o) => o.soNo == orderId);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.receipt,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            order.soNo ?? 'N/A',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: order.status == 'Delivered'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status ?? 'Unknown',
                        style: TextStyle(
                          color: order.status == 'Delivered'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildInfoRow(Icons.calendar_today, 'Order Date',
                        order.orderDate.toLocal().toString().split(' ')[0]),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.person, 'Customer', order.customerName ?? 'N/A'),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.person_outline, 'Salesman', order.salesmanName ?? 'N/A'),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.shopping_bag, 'Total Items', order.totalQty.toString()),
                    const SizedBox(height: 24),
                    const Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // You can add product list here if available
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('Product details will appear here'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}