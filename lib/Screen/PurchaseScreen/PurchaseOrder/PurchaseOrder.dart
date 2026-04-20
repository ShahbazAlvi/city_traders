
import 'package:demo_distribution/Screen/PurchaseScreen/PurchaseOrder/AddPurchaseOrder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../Provider/Purchase_Order_Provider/Purchase_order_provider.dart';
import '../../../Provider/SupplierProvider/supplierProvider.dart';
import '../../../compoents/AppColors.dart';
import '../../../model/Purchase_Order_Model/purchaseOrderDetails.dart';
import '../../../utils/access_control.dart';
import 'EditPurchaseOrder.dart';

class PurchaseOrderScreen extends StatefulWidget {
  const PurchaseOrderScreen({super.key});

  @override
  State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends State<PurchaseOrderScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;

  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _fmt = NumberFormat('#,##,###');
  String _searchQuery = '';
  bool canViewAdd = false;
  bool canViewDelete = false;
  bool canViewEdit     = false;


  @override
  void initState() {
    super.initState();
    _loadPermissions();

    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: 0, max: 1, period: const Duration(milliseconds: 1500));

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fabScaleAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );

    Future.microtask(() {
      context.read<PurchaseOrderProvider>().fetchPurchaseOrder().then((_) {
        _fabController.forward();
      });
    });

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }


  Future<void> _loadPermissions() async {
    final add     = await AccessControl.canDo("can_add_purchase_order");
    final delete     = await AccessControl.canDo("can_delete_purchase_order");
    final edit         = await AccessControl.canDo("can_edit_purchase_order");


    setState(() {
      canViewAdd    = add;
      canViewDelete    = delete;
      canViewEdit        = edit;

    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _fabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "APPROVED":
        return const Color(0xFF00C896);
      case "PENDING":
        return const Color(0xFFFFAB00);
      case "REJECTED":
        return const Color(0xFFFF4D4F);
      default:
        return const Color(0xFF8C8C8C);
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case "APPROVED":
        return Icons.check_circle_rounded;
      case "PENDING":
        return Icons.schedule_rounded;
      case "REJECTED":
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // ── Shimmer Loading ───────────────────────────────────────────────────────

  Widget _buildShimmerCard() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (_, __) {
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: const [
              Color(0xFFEEEEEE),
              Color(0xFFFAFAFA),
              Color(0xFFEEEEEE)
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            transform: GradientRotation(
                _shimmerController.value * 2 * 3.14159),
          ).createShader(bounds),
          blendMode: BlendMode.srcATop,
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => _buildShimmerCard(),
    );
  }

  // ── Next Order ID ─────────────────────────────────────────────────────────

  String _getNextOrderId(PurchaseOrderProvider provider) {
    if (provider.orders.isEmpty) return "PO-0001";
    final allNumbers = provider.orders.map((order) {
      final match = RegExp(r'PO-(\d+)$').firstMatch(order.poNo ?? '');
      return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
    }).toList();
    final max = allNumbers.reduce((a, b) => a > b ? a : b);
    return "PO-${(max + 1).toString().padLeft(4, '0')}";
  }


  Widget _summaryItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9E9E9E),
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() {
    return Container(
      height: 36,
      width: 1,
      color: const Color(0xFFE0E0E0),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8F0), width: 1),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A1A2E),
        ),
        decoration: InputDecoration(
          hintText: "Search by PO number or supplier...",
          hintStyle: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFFB0B0C0),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF9E9EC0),
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
            onTap: () => _searchController.clear(),
            child: const Icon(
              Icons.close_rounded,
              color: Color(0xFFB0B0C0),
              size: 18,
            ),
          )
              : null,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        ),
      ),
    );
  }

  // ── Order Card ────────────────────────────────────────────────────────────

  Widget _buildOrderCard(dynamic order, int index) {
    final statusColor = getStatusColor(order.status ?? '');
    final statusIcon = getStatusIcon(order.status ?? '');
    final amount = double.tryParse(order.totalAmount ?? '0') ?? 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 250 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) => Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.055),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: AppColors.primary.withOpacity(0.06),
            highlightColor: AppColors.primary.withOpacity(0.03),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _PurchaseOrderDetailSheet(orderId: order.id),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row: PO badge + status + actions ──
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          order.poNo,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_month,
                                size: 12, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd MMM yyyy').format(order.poDate),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Actions
                      _actionButton(
                        icon: Icons.edit_outlined,
                        color: const Color(0xFF4A90D9),
                        // In _buildOrderCard, replace the edit _actionButton onTap:
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MultiProvider(   // ← wrap with MultiProvider
                                providers: [
                                  ChangeNotifierProvider.value(
                                    value: Provider.of<PurchaseOrderProvider>(context, listen: false),
                                  ),
                                  ChangeNotifierProvider.value(
                                    value: Provider.of<SupplierProvider>(context, listen: false),
                                  ),
                                ],
                                child: EditPurchaseOrder(orderId: order.id),
                              ),
                            ),
                          ).then((updated) {
                            if (updated == true) {
                              context.read<PurchaseOrderProvider>().fetchPurchaseOrder();
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        icon: Icons.delete_outline_rounded,
                        color: const Color(0xFFFF4D4F),
                        onTap: () => _showDeleteDialog(
                            context, order.id, order.poNo),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFF0F0F6)),
                  const SizedBox(height: 14),

                  // ── Supplier ──
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Supplier",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFAAAAAA),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              (order.supplierName ?? '').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                             AppColors.secondary,
                              AppColors.primary,

                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                              AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          "Rs. ${NumberFormat('#,##0').format(amount)}",
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }

  // ── Delete Dialog ─────────────────────────────────────────────────────────

  Future<void> _showDeleteDialog(
      BuildContext context, int orderId, String poNo) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental close
      builder: (BuildContext dialogContext) {
        return Consumer<PurchaseOrderProvider>(
          builder: (context, provider, _) {
            final isDeleting = provider.isDeleting;

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4D4F).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: isDeleting
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                  strokeWidth: 3, color: Color(0xFFFF4D4F)),
                            )
                          : const Icon(
                              Icons.delete_outline_rounded,
                              size: 30,
                              color: Color(0xFFFF4D4F),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isDeleting ? "Deleting..." : "Delete Order",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isDeleting
                          ? "Please wait while we delete $poNo."
                          : "Are you sure you want to delete $poNo? This action cannot be undone.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF888899),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!isDeleting)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                side: const BorderSide(
                                    color: Color(0xFFE0E0E0), width: 1.5),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF555566),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                bool success =
                                    await provider.deletePurchaseOrder(orderId);
                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? '$poNo deleted successfully'
                                            : (provider.error ??
                                                'Delete failed'),
                                      ),
                                      backgroundColor: success
                                          ? const Color(0xFF00C896)
                                          : const Color(0xFFFF4D4F),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF4D4F),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text(
                                "Delete",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 44,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Purchase Orders",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap \"Add Order\" to create your first\npurchase order",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xFF9E9EB0),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PurchaseOrderProvider>();

    final filteredOrders = _searchQuery.isEmpty
        ? provider.orders
        : provider.orders.where((o) {
      return (o.poNo ?? '').toLowerCase().contains(_searchQuery) ||
          (o.supplierName ?? '').toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "Purchase Orders",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 19,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  // Add Order button
                  // GestureDetector(
                  //   onTap: () {
                  //     final p = Provider.of<PurchaseOrderProvider>(
                  //         context,
                  //         listen: false);
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => AddPurchaseOrder(
                  //           nextOrderId: _getNextOrderId(p),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  //   child: Container(
                  //     margin: const EdgeInsets.only(right: 8),
                  //     padding: const EdgeInsets.symmetric(
                  //         horizontal: 14, vertical: 8),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white.withOpacity(0.18),
                  //       borderRadius: BorderRadius.circular(14),
                  //       border: Border.all(
                  //         color: Colors.white.withOpacity(0.35),
                  //         width: 1,
                  //       ),
                  //     ),
                  //     child: const Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         Icon(Icons.add_rounded,
                  //             color: Colors.white, size: 18),
                  //         SizedBox(width: 5),
                  //         Text(
                  //           "Add",
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //             fontWeight: FontWeight.w600,
                  //             fontSize: 13,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: canViewAdd
          ? ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton.extended(
          elevation: 3,
          backgroundColor: AppColors.primary,
          onPressed: () {
            final p = Provider.of<PurchaseOrderProvider>(
                context, listen: false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPurchaseOrder(
                  nextOrderId: _getNextOrderId(p),
                ),
              ),
            );
          },
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            "Add Order",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      )
          : null,
      body: Builder(builder: (_) {
        if (provider.isLoading) {
          return Column(
            children: [

              const SizedBox(height: 12),
              _buildSearchBar(),
              const SizedBox(height: 12),
              Expanded(child: _buildShimmerLoading()),
            ],
          );
        }

        if ((provider.error ?? '').isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off_rounded,
                    size: 56, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  provider.error ?? 'Something went wrong',
                  style: const TextStyle(
                      fontSize: 15, color: Color(0xFF888899)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.read<PurchaseOrderProvider>().fetchPurchaseOrder(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text("Retry",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              context.read<PurchaseOrderProvider>().fetchPurchaseOrder(),
          color: AppColors.primary,
          backgroundColor: Colors.white,
          displacement: 30,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    if (provider.orders.isNotEmpty)
                    //  _buildSummaryStrip(provider),
                    const SizedBox(height: 16),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            filteredOrders.isEmpty
                                ? "No results"
                                : "${filteredOrders.length} Order${filteredOrders.length != 1 ? 's' : ''}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF888899),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              if (provider.orders.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else if (filteredOrders.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        const Text(
                          "No matching orders",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF888899),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child:
                        _buildOrderCard(filteredOrders[index], index),
                      ),
                      childCount: filteredOrders.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// Purchase Order Detail Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PurchaseOrderDetailSheet extends StatefulWidget {
  final int orderId;
  const _PurchaseOrderDetailSheet({required this.orderId});

  @override
  State<_PurchaseOrderDetailSheet> createState() =>
      _PurchaseOrderDetailSheetState();
}

class _PurchaseOrderDetailSheetState
    extends State<_PurchaseOrderDetailSheet> {
  final _fmt = NumberFormat('#,##,###');
  final _dateFmt = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<PurchaseOrderProvider>(context, listen: false)
            .fetchSinglePurchaseOrder(widget.orderId));
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return const Color(0xFF00C896);
      case 'PENDING':
        return const Color(0xFFFFAB00);
      case 'REJECTED':
        return const Color(0xFFFF4D4F);
      default:
        return const Color(0xFF8C8C8C);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PurchaseOrderProvider>(
      builder: (context, provider, _) {
        final order = provider.selectedOrder;

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
                          child: Icon(Icons.receipt_long_rounded,
                              color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Purchase Order',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                              if (order != null)
                                Text(order.poNo,
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13),
                                    overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        if (order != null) _statusBadge(order.status),
                      ],
                    ),
                  ),

                  const Divider(height: 24),

                  // ── Body ──
                  Expanded(
                    child: provider.isDetailLoading
                        ? const Center(child: CircularProgressIndicator())
                        : order == null
                        ? Center(
                        child: Text('No data found',
                            style: TextStyle(
                                color: Colors.grey.shade500)))
                        : _buildContent(order, controller),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContent(
      PurchaseOrderDetailData order, ScrollController controller) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        // ── Info block ──
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0F0F6)),
          ),
          child: Column(
            children: [
              _infoRow(Icons.calendar_today_outlined, 'PO Date',
                  _dateFmt.format(order.poDate)),
              const Divider(height: 20),
              _infoRow(Icons.storefront_rounded, 'Supplier',
                  order.supplierName),
              const Divider(height: 20),
              _infoRow(Icons.info_outline_rounded, 'Status',
                  order.status),
              if (order.taxPercent > 0) ...[
                const Divider(height: 20),
                _infoRow(Icons.percent_rounded, 'Tax %',
                    '${order.taxPercent.toStringAsFixed(2)}%'),
              ],
              if (order.remarks != null &&
                  order.remarks!.isNotEmpty) ...[
                const Divider(height: 20),
                _infoRow(Icons.notes_rounded, 'Remarks',
                    order.remarks!),
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
                color: AppColors.primary.withOpacity(0.09),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${order.details.length} item${order.details.length != 1 ? 's' : ''}',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Item cards ──
        ...order.details.asMap().entries.map(
              (e) => _itemCard(e.value, e.key + 1),
        ),

        const SizedBox(height: 16),

        // ── Sub total (if tax present) ──
        if (order.taxAmount > 0) ...[
          _totalRow('Sub Total', order.subTotal, isGray: true),
          const SizedBox(height: 8),
          _totalRow(
              'Tax (${order.taxPercent.toStringAsFixed(2)}%)',
              order.taxAmount,
              isGray: true),
          const SizedBox(height: 8),
        ],

        // ── Grand Total banner ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.secondary, AppColors.primary]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
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
                'Rs ${_fmt.format(order.grandTotal)}',
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

  Widget _itemCard(PurchaseOrderDetailItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F6)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Index badge
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.09),
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
                const SizedBox(height: 2),
                Text(item.itemSku,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFAAAAAA))),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Chips + line total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  _chip(
                    '${item.qty.toStringAsFixed(item.qty % 1 == 0 ? 0 : 2)} ${item.unitName}',
                    const Color(0xFFEEF4FF),
                    const Color(0xFF4A90D9),
                  ),
                  const SizedBox(width: 4),
                  _chip(
                    'Rs ${_fmt.format(item.rate)}',
                    const Color(0xFFFFF3E0),
                    const Color(0xFFFF8C00),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'Rs ${_fmt.format(item.lineTotal)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF00C896)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) {
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
              color: const Color(0xFFF0F0F6),
              borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: 16, color: const Color(0xFF888899)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFFAAAAAA))),
              const SizedBox(height: 2),
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

  Widget _totalRow(String label, double amount,
      {bool isGray = false}) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isGray ? const Color(0xFFF8F9FC) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF888899))),
          Text('Rs ${_fmt.format(amount)}',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(status,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ],
      ),
    );
  }
}



