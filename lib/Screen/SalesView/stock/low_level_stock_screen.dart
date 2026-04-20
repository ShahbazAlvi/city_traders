import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';


import '../../../Provider/stock_provider/low_level_stock_provider.dart';
import '../../../compoents/AppColors.dart';
import '../../../model/stock/low_level_stock_model.dart';


class LowLevelStockScreen extends StatefulWidget {
  const LowLevelStockScreen({super.key});

  @override
  State<LowLevelStockScreen> createState() => _LowLevelStockScreenState();
}

class _LowLevelStockScreenState extends State<LowLevelStockScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _fmt = NumberFormat('#,##,###.##');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LowLevelStockProvider>().fetchLowLevelStock();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LowLevelStockProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(provider),
          _buildFilterChips(provider),
          _buildSummaryStrip(provider),
          Expanded(
            child: provider.isLoading
                ? _buildShimmer()
                : provider.error != null
                ? _buildError(provider)
                : provider.filteredItems.isEmpty
                ? _buildEmpty()
                : _buildList(provider.filteredItems),
          ),
        ],
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
      ),
      title: const Text(
        'Low Level Stock',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        Consumer<LowLevelStockProvider>(
          builder: (_, p, __) => IconButton(
            onPressed: p.isLoading ? null : p.refresh,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ── Search Bar ──────────────────────────────────────────────────────────

  Widget _buildSearchBar(LowLevelStockProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: provider.setSearch,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search by name, SKU or category...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear, color: Colors.grey.shade400, size: 16),
              onPressed: () {
                _searchController.clear();
                provider.setSearch('');
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // ── Filter Chips ────────────────────────────────────────────────────────

  Widget _buildFilterChips(LowLevelStockProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: ['ALL', 'LOW', 'OK'].map((f) {
          final selected = provider.filter == f;
          final color = f == 'LOW'
              ? Colors.red
              : f == 'OK'
              ? Colors.green
              : AppColors.primary;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => provider.setFilter(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? color : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? color : Colors.grey.shade300,
                  ),
                  boxShadow: selected
                      ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6)]
                      : [],
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Summary Strip ────────────────────────────────────────────────────────

  Widget _buildSummaryStrip(LowLevelStockProvider provider) {
    if (provider.totalCount == 0) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Total', provider.totalCount.toString(), Icons.inventory_2_outlined),
          _vDivider(),
          _statItem('Low Stock', provider.lowCount.toString(), Icons.warning_amber_rounded),
          _vDivider(),
          _statItem('OK', provider.okCount.toString(), Icons.check_circle_outline),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _vDivider() => Container(
    width: 1, height: 36,
    color: Colors.white.withOpacity(0.3),
  );

  // ── List ────────────────────────────────────────────────────────────────

  Widget _buildList(List<LowStockItem> items) {
    return RefreshIndicator(
      onRefresh: () => context.read<LowLevelStockProvider>().refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: items.length,
        itemBuilder: (_, i) => _buildCard(items[i]),
      ),
    );
  }

  // ── Card ────────────────────────────────────────────────────────────────

  Widget _buildCard(LowStockItem item) {
    final isLow = item.isLow;
    final isCritical = item.isCritical;

    final statusColor = isCritical
        ? Colors.red.shade700
        : isLow
        ? Colors.orange
        : Colors.green;

    final statusLabel = isCritical ? 'CRITICAL' : item.status;

    // Fill percentage: inStock / minLevelQty clamped 0–1
    final fillPct = item.minLevelQty > 0
        ? (item.inStock / item.minLevelQty).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isLow
            ? Border.all(color: statusColor.withOpacity(0.25), width: 1.2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCritical
                        ? Icons.error_outline
                        : isLow
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                    ],
                  ),
                ),
                // Status badge
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
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                            color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        statusLabel,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Stock bar ──
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: fillPct,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),

            const SizedBox(height: 10),

            // ── Chips row ──
            Row(
              children: [
                _chip(
                  Icons.layers_outlined,
                  'In Stock',
                  '${_fmt.format(item.inStock)} ',
                  isCritical ? Colors.red.shade50 : Colors.blue.shade50,
                  isCritical ? Colors.red.shade700 : Colors.blue.shade700,
                ),
                const SizedBox(width: 6),
                _chip(
                  Icons.flag_outlined,
                  'Min Level',
                  _fmt.format(item.minLevelQty),
                  Colors.grey.shade100,
                  Colors.grey.shade700,
                ),
                const SizedBox(width: 6),
                if (item.shortage > 0)
                  _chip(
                    Icons.trending_down,
                    'Shortage',
                    _fmt.format(item.shortage),
                    Colors.red.shade50,
                    Colors.red.shade700,
                  ),
              ],
            ),


          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, String value, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 9, color: fg.withOpacity(0.7))),
              Text(value,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Shimmer ─────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 130,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────────

  Widget _buildError(LowLevelStockProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(provider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: provider.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty ────────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
                color: Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(Icons.inventory_2_outlined,
                size: 56, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text('No items found',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text('All stock levels are healthy',
              style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}