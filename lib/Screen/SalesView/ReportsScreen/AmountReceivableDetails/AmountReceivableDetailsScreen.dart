


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../Provider/AmountReceivableDetailsProvider/AmountReceivableDetailsProvider.dart';
import '../../../../compoents/AppColors.dart';

class ReceivableScreen extends StatefulWidget {
  const ReceivableScreen({super.key});

  @override
  State<ReceivableScreen> createState() => _ReceivableScreenState();
}

class _ReceivableScreenState extends State<ReceivableScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: 0, max: 1, period: const Duration(milliseconds: 1500));

    Future.microtask(() {
      context.read<ReceivableProvider>().fetchReceivables();
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Shimmer effect builder
  Widget _buildShimmerEffect({required Widget child}) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: const [
            Color(0xFFE0E0E0),
            Color(0xFFF5F5F5),
            Color(0xFFE0E0E0),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment(-1.0, -0.5),
          end: Alignment(1.0, 0.5),
          transform: GradientRotation(_shimmerController.value * 2 * 3.14159),
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: child,
    );
  }

  // Shimmer loading for list items
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          "Receivable Details",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
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
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                context.read<ReceivableProvider>().fetchReceivables();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          // Consumer<ReceivableProvider>(
          //   builder: (context, provider, child) {
          //     if (provider.isLoading || provider.filteredList.isEmpty) {
          //       return const SizedBox.shrink();
          //     }
          //
          //     final totalReceivable = provider.filteredList.fold<double>(
          //       0,
          //           (sum, item) => sum + (double.tryParse(item.balance.toString()) ?? 0),
          //     );
          //
          //     // return Container(
          //     //   margin: const EdgeInsets.all(16),
          //     //   padding: const EdgeInsets.all(20),
          //     //   decoration: BoxDecoration(
          //     //     gradient: const LinearGradient(
          //     //       colors: [AppColors.primary, AppColors.secondary],
          //     //       begin: Alignment.topLeft,
          //     //       end: Alignment.bottomRight,
          //     //     ),
          //     //     borderRadius: BorderRadius.circular(24),
          //     //     boxShadow: [
          //     //       BoxShadow(
          //     //         color: AppColors.primary.withOpacity(0.3),
          //     //         blurRadius: 20,
          //     //         offset: const Offset(0, 8),
          //     //       ),
          //     //     ],
          //     //   ),
          //     //   child: Column(
          //     //     crossAxisAlignment: CrossAxisAlignment.start,
          //     //     children: [
          //     //       // const Text(
          //     //       //   "Total Receivable",
          //     //       //   style: TextStyle(
          //     //       //     color: Colors.white70,
          //     //       //     fontSize: 14,
          //     //       //     fontWeight: FontWeight.w500,
          //     //       //   ),
          //     //       // ),
          //     //       // const SizedBox(height: 8),
          //     //       // Text(
          //     //       //   "Rs:${NumberFormat('#,##,###').format(totalReceivable)}",
          //     //       //   style: const TextStyle(
          //     //       //     color: Colors.white,
          //     //       //     fontSize: 32,
          //     //       //     fontWeight: FontWeight.bold,
          //     //       //   ),
          //     //       // ),
          //     //       // const SizedBox(height: 16),
          //     //       // Row(
          //     //       //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     //       //   children: [
          //     //       //     _buildSummaryItem(
          //     //       //       icon: Icons.people_outline,
          //     //       //       label: "Customers",
          //     //       //       value: "${provider.filteredList.length}",
          //     //       //     ),
          //     //       //     _buildSummaryItem(
          //     //       //       icon: Icons.pending_actions,
          //     //       //       label: "With Balance",
          //     //       //       value: "${provider.filteredList.where((item) => (double.tryParse(item.balance.toString()) ?? 0) > 0).length}",
          //     //       //     ),
          //     //       //   ],
          //     //       // ),
          //     //     ],
          //     //   ),
          //     // );
          //   },
          // ),

          // Search and Filter Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by customer name...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey[500],
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ReceivableProvider>().updateSearch('');
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      context.read<ReceivableProvider>().updateSearch(value);
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Filter Options
                Row(
                  children: [
                    const Text(
                      "Show:",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Consumer<ReceivableProvider>(
                        builder: (context, provider, child) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Expanded(
                                //   child: _buildFilterChip(
                                //     label: "All",
                                //     isSelected: provider.withZero == null,
                                //     onTap: () => provider.updateWithZero(null),
                                //   ),
                                // ),
                                Expanded(
                                  child: _buildFilterChip(
                                    label: "With Balance",
                                    isSelected: provider.withZero == false,
                                    onTap: () => provider.updateWithZero(false),
                                  ),
                                ),
                                Expanded(
                                  child: _buildFilterChip(
                                    label: "Zero Balance",
                                    isSelected: provider.withZero == true,
                                    onTap: () => provider.updateWithZero(true),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Results Count
          Consumer<ReceivableProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading || provider.filteredList.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      "${provider.filteredList.length} records found",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 4),

          // List View
          Expanded(
            child: Consumer<ReceivableProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return _buildShimmerEffect(child: _buildShimmerLoading());
                }

                if (provider.filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.receipt_outlined,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "No Receivables Found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Text(
                        //   provider.searchQuery.isNotEmpty
                        //       ? "No results match your search"
                        //       : "There are no receivable records available",
                        //   textAlign: TextAlign.center,
                        //   style: TextStyle(
                        //     fontSize: 14,
                        //     color: Colors.grey.shade500,
                        //   ),
                        // ),
                        // if (provider.searchQuery.isNotEmpty) ...[
                        //   const SizedBox(height: 16),
                        //   ElevatedButton(
                        //     onPressed: () {
                        //       _searchController.clear();
                        //       provider.updateSearch('');
                        //     },
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: AppColors.primary,
                        //       foregroundColor: Colors.white,
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //       padding: const EdgeInsets.symmetric(
                        //         horizontal: 24,
                        //         vertical: 12,
                        //       ),
                        //     ),
                        //     child: const Text("Clear Search"),
                        //   ),
                        // ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.filteredList.length,
                  itemBuilder: (context, index) {
                    final item = provider.filteredList[index];
                    final balance = double.tryParse(item.balance.toString()) ?? 0;
                    final status = item.status.toString();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () {
                            // Optional: Add tap functionality for details
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Customer Avatar with Status Indicator
                                Stack(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: balance > 0
                                              ? [AppColors.primary, AppColors.secondary]
                                              : [Colors.grey.shade400, Colors.grey.shade500],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Center(
                                        child: Text(
                                          item.customerName.isNotEmpty
                                              ? item.customerName[0].toUpperCase()
                                              : "?",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (balance > 0)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 16),

                                // Customer Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.customerName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: balance > 0
                                                  ? Colors.orange.withOpacity(0.1)
                                                  : Colors.green.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: balance > 0
                                                        ? Colors.orange
                                                        : Colors.green,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  balance > 0 ? "Pending" : "Cleared",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: balance > 0
                                                        ? Colors.orange
                                                        : Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // const SizedBox(width: 10),
                                          // Container(
                                          //   padding: const EdgeInsets.symmetric(
                                          //     horizontal: 8,
                                          //     vertical: 2,
                                          //   ),
                                          //   decoration: BoxDecoration(
                                          //     color: Colors.grey.shade100,
                                          //     borderRadius: BorderRadius.circular(12),
                                          //   ),
                                          //   child: Text(
                                          //     "ID: ${item.id ?? 'N/A'}",
                                          //     style: TextStyle(
                                          //       fontSize: 10,
                                          //       color: Colors.grey[600],
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Balance Amount
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: balance > 0
                                        ? Colors.orange.withOpacity(0.1)
                                        : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: balance > 0
                                          ? Colors.orange.withOpacity(0.3)
                                          : Colors.green.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Balance",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: balance > 0
                                              ? Colors.orange.shade700
                                              : Colors.green.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Rs:${item.grossTotal}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: balance > 0
                                              ? Colors.orange.shade700
                                              : Colors.green.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}