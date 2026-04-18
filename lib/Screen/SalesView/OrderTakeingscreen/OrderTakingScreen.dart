

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Provider/OrderTakingProvider/OrderTakingProvider.dart';
import '../../../compoents/AppColors.dart';
import '../../../model/OrderTakingModel/DetailsOrderModel.dart';
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
  final formatter = NumberFormat('#,##,###');
  final formatedDate=DateFormat("dd,MMM,yyyy");
  String searchQuery = '';

  bool canAddOrder    = false;
  bool canEditOrder   = false;
  bool canDeleteOrder = false;
  bool canViewOrder   = false;
  String? _loggedInSalesmanId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderTakingProvider>(context, listen: false).FetchOrderTaking();
    });
    _scrollController.addListener(_onScroll);
    _loadPermissions();
    _loadSalesmanId();
  }
  Future<void> _loadSalesmanId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('salesman_id');
    setState(() {
      _loggedInSalesmanId = id?.toString();
    });
  }

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

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more if needed
    }
  }

  List getPaginatedData(List data) {
    // Salesman filter
    final sourceData = provider.getFilteredOrders(_loggedInSalesmanId);

    final filteredData = sourceData.where((order) {
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
    final sourceData = provider.getFilteredOrders(_loggedInSalesmanId);
    return sourceData.where((order) {
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
      iconTheme: IconThemeData(color:AppColors.text),
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
        "Order Booking",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20, // ✅ Slightly reduced for small screens
          letterSpacing: 1.0,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Container(
            height: 48,
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
                  currentPage = 1;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search orders...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => searchQuery = '');
                  },
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
            height: 170,
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.FetchOrderTaking(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inbox_rounded, size: 72, color: Colors.grey.shade400),
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
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToAddOrder,
              icon: const Icon(Icons.add),
              label: const Text('Add Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    final paginatedList = getPaginatedData(provider.orderData!.data);
    final totalFilteredItems = filteredItemCount;
    final totalPages = (totalFilteredItems / itemsPerPage).ceil();

    return Column(
      children: [
        const SizedBox(height: 12),
        // ✅ Header row — wrap to avoid overflow on small screens
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  searchQuery.isEmpty ? 'Recent Orders' : 'Search Results',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (canAddOrder)
                ElevatedButton.icon(
                  onPressed: _navigateToAddOrder,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Order', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: paginatedList.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'No matching orders found',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
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
              return _buildOrderCard(paginatedList[index]);
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
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Row ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt_long, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 10),
                    // ✅ Expanded to prevent overflow
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.soNo ?? 'N/A',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 11, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  formatedDate.format(order.orderDate),
                                  // order.orderDate.toLocal().toString().split(' ')[0],
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ✅ Status badge — constrained width
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.status ?? 'Unknown',
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Customer Info Row ──
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Customer
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Customer',
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                  ),
                                  Text(
                                    order.customerName ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 28, color: Colors.grey.shade300),
                      // Items
                      Expanded(
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Icon(Icons.shopping_cart_outlined, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Items ${order.totalItems}',
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${order.totalQty} Qty',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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

                const SizedBox(height: 12),

                // ── Amount + Actions Row ──
                // ✅ Wrap prevents overflow when buttons don't fit
                Row(
                  children: [
                    // Amount — takes remaining space
                    Expanded(
                      child: Text(
                        'Rs: ${formatter.format(order.totalAmount)}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Action buttons — fixed, won't overflow
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (canViewOrder) ...[
                          _buildActionButton(
                            icon: Icons.visibility,
                            color: Colors.blue,
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => _OrderDetailsSheet(orderId: int.parse(order.id)),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                        ],
                        if (canEditOrder) ...[
                          _buildActionButton(
                            icon: Icons.edit,
                            color: AppColors.betprologo,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UpdateOrderScreen(order: order),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                        ],
                        if (canDeleteOrder)
                          _buildActionButton(
                            icon: Icons.delete,
                            color: Colors.red,
                            onPressed: () => _confirmDelete(context, order.id),
                          ),
                      ],
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
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                ? () => setState(() => currentPage--)
                : null,
            color: currentPage > 1 ? AppColors.primary : Colors.grey,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Page $currentPage of $totalPages',
              style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.primary, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages
                ? () => setState(() => currentPage++)
                : null,
            color: currentPage < totalPages ? AppColors.primary : Colors.grey,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  void _navigateToAddOrder() {
    String prefix = "OS";
    String nextOrderId = "$prefix-0001";

    if (provider.orderData != null && provider.orderData!.data.isNotEmpty) {
      final allNumbers = provider.orderData!.data.map((order) {
        final id = order.soNo?.toString() ?? "";
        // Support both old SO- and new OS- formats
        final regex = RegExp(r'(?:OS|os)-(\d+)$');
        final match = regex.firstMatch(id);
        return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
      }).toList();

      final maxNumber =
      allNumbers.isNotEmpty ? allNumbers.reduce((a, b) => a > b ? a : b) : 0;
      nextOrderId = "$prefix-${(maxNumber + 1).toString().padLeft(4, '0')}";
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddOrderScreen(nextOrderId: nextOrderId),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String orderId) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Delete Order", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            "Are you sure you want to delete this order? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final error = await provider.deleteOrder(orderId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error == null
                          ? "Order deleted successfully"
                          : "Delete failed: $error"),
                      backgroundColor: error == null ? Colors.green : Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order Details Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _OrderDetailsSheet extends StatefulWidget {
  final int orderId;    // pass int id, not soNo string
  const _OrderDetailsSheet({required this.orderId});

  @override
  State<_OrderDetailsSheet> createState() => _OrderDetailsSheetState();
}

class _OrderDetailsSheetState extends State<_OrderDetailsSheet> {
  final formatter = NumberFormat('#,##,###');
  final dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<OrderTakingProvider>(context, listen: false)
            .fetchSingleOrder(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderTakingProvider>(
      builder: (context, provider, _) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // ── Handle ──
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

                  // ── Header ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.receipt,
                              color: AppColors.primary, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Order Details',
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold)),
                              if (provider.selectedOrder != null)
                                Text(
                                  provider.selectedOrder!.soNo,
                                  style: TextStyle(
                                      color: Colors.grey.shade600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        if (provider.selectedOrder != null)
                          _statusBadge(provider.selectedOrder!.status),
                      ],
                    ),
                  ),

                  const Divider(height: 24),

                  // ── Body ──
                  Expanded(
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : provider.selectedOrder == null
                        ? Center(
                        child: Text('No data found',
                            style: TextStyle(
                                color: Colors.grey.shade500)))
                        : _buildDetail(
                        provider.selectedOrder!, controller),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetail(DetailsOrderData order, ScrollController controller) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        // ── Info Cards ──
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            children: [
              _infoRow(Icons.calendar_today, 'Order Date',
                  dateFormat.format(order.orderDate)),
              const Divider(height: 20),
              _infoRow(
                  Icons.person_outline, 'Customer', order.customerName),
              const Divider(height: 20),
              _infoRow(Icons.badge_outlined, 'Salesman',
                  order.salesmanName),
              const Divider(height: 20),
              _infoRow(Icons.info_outline, 'Status', order.status),
              if (order.remarks != null && order.remarks!.isNotEmpty) ...[
                const Divider(height: 20),
                _infoRow(
                    Icons.notes, 'Remarks', order.remarks!),
              ],
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ── Items header ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Order Items',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${order.details.length} items',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Item Cards ──
        ...order.details.asMap().entries.map((e) =>
            _itemCard(e.value, e.key + 1)),

        const SizedBox(height: 16),

        // ── Grand Total ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondary.withOpacity(0.9),
                AppColors.primary
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
              Text(
                'Rs ${formatter.format(order.grandTotal)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemCard(DetailsOrderItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Index badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text('$index',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          const SizedBox(width: 10),
          // Name + SKU
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.itemName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                    overflow: TextOverflow.ellipsis),
                Text(item.itemSku,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Qty / Rate / Total chips
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  _miniChip('${item.qty.toStringAsFixed(0)} ${item.unitName}',
                      Colors.blue.shade50, Colors.blue.shade700),
                  const SizedBox(width: 4),
                  _miniChip(
                      'Rs ${formatter.format(item.rate)}',
                      Colors.orange.shade50,
                      Colors.orange.shade700),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Rs ${formatter.format(item.lineTotal)}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.green.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    final isApproved = status == 'APPROVED';
    final color = isApproved ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12)),
    );
  }
}