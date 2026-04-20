



import 'package:demo_distribution/compoents/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../ApiLink/ApiEndpoint.dart';
import '../../../Provider/stock_provider/stock_position_provider.dart';

class StockPositionScreen extends StatefulWidget {
  const StockPositionScreen({super.key});

  @override
  State<StockPositionScreen> createState() => _StockPositionScreenState();
}

class _StockPositionScreenState extends State<StockPositionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    Future.microtask(() =>
        Provider.of<StockPositionProvider>(context, listen: false)
            .fetchStockPosition());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      appBar: _buildAppBar(),
      body: Consumer<StockPositionProvider>(
        builder: (context, provider, child) {
          if (provider.loading) return _buildShimmerLoading();

          if (provider.stockList.isEmpty) {
            return _buildEmptyState(provider.message);
          }

          final filteredList = provider.stockList.where((item) {
            final query = searchQuery.toLowerCase();
            return item.itemName.toLowerCase().contains(query) ||
                item.sku.toLowerCase().contains(query) ||
                item.category.toLowerCase().contains(query);
          }).toList();

          if (filteredList.isEmpty) return _buildNoSearchResults();

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildStatsCard(provider),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final itemStock = item.inQty - item.outQty;
                      final isNegative = item.balanceQty < 0;
                      return _buildStockCard(item, itemStock, isNegative);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
      ),
      title: const Text(
        "Stock Position",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
        color: Colors.white,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () =>
              context.read<StockPositionProvider>().fetchStockPosition(),
          color: Colors.white,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: "Search by item name, SKU, or category...",
                hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon:
                Icon(Icons.search_rounded, color: Colors.blue.shade700),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Stats Card ────────────────────────────────────────────────────────────
  Widget _buildStatsCard(StockPositionProvider provider) {
    final totalItems = provider.stockList.length;
    final lowStockItems =
        provider.stockList.where((item) => item.balanceQty < 10).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.inventory_2_rounded,
            label: "Total Items",
            value: "$totalItems",
            color: Colors.blue,
          ),
          Container(width: 1, height: 44, color: Colors.grey.shade200),
          _buildStatItem(
            icon: Icons.warning_amber_rounded,
            label: "Low Stock",
            value: "$lowStockItems",
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Stock Card as ListTile ────────────────────────────────────────────────
  Widget _buildStockCard(item, num itemStock, bool isNegative) {
    final statusColor =
    isNegative ? Colors.orange : const Color(0xFF38A169);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

            // ── Leading: item image ──────────────────────────────────────
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.image != null && item.image!.isNotEmpty
                  ? Image.network(
                '${ApiEndpoints.baseUrl}/uploads/items/${item.image}',
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _imageFallback(isNegative),
                loadingBuilder: (_, child, progress) =>
                progress == null ? child : _imageFallback(isNegative),
              )
                  : _imageFallback(isNegative),
            ),

            // ── Title: name + status pill ────────────────────────────────
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item.itemName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A202C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border:
                    Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    isNegative ? "Low Stock" : "In Stock",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            // ── Subtitle: category + stock + rate pills ──────────────────
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.category,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                // Metric pills row
                Row(
                  children: [
                    _buildMetricPill(
                      icon: Icons.inventory_rounded,
                      label: "Stock",
                      value: itemStock.toStringAsFixed(0),
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildMetricPill(
                      icon: Icons.inbox_rounded,
                      label: "Rate",
                      value: item.salePrice.toStringAsFixed(0),
                      color: const Color(0xFF38A169),
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

  // ─── Image Fallback ────────────────────────────────────────────────────────
  Widget _imageFallback(bool isNegative) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isNegative ? Colors.red.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        isNegative ? Icons.warning_rounded : Icons.inventory_rounded,
        color: isNegative ? Colors.red.shade300 : Colors.blue.shade300,
        size: 26,
      ),
    );
  }

  // ─── Metric Pill ──────────────────────────────────────────────────────────
  Widget _buildMetricPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shimmer Loading ───────────────────────────────────────────────────────
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 7,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ─── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message.isEmpty ? "No Stock Items Found" : message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── No Search Results ─────────────────────────────────────────────────────
  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No items match your search",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try searching with different keywords",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}