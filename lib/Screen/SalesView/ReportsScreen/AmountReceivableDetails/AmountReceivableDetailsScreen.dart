import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../Provider/AmountReceivableDetailsProvider/AmountReceivableDetailsProvider.dart';
import '../../../../Provider/SaleManProvider/SaleManProvider.dart';
import '../../../../compoents/AppColors.dart';
import '../../../../model/AmountReceivableDetailsModel/AmountReceivableDetailsModel.dart';
import '../../../../model/SaleManModel/EmployeesModel.dart';

class ReceivableScreen extends StatefulWidget {
  const ReceivableScreen({super.key});

  @override
  State<ReceivableScreen> createState() => _ReceivableScreenState();
}

class _ReceivableScreenState extends State<ReceivableScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _fmt = NumberFormat('#,##,###');

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: 0, max: 1, period: const Duration(milliseconds: 1500));

    Future.microtask(() async {
      final provider = context.read<ReceivableProvider>();
      await provider.fetchReceivables();
      if (provider.isAdmin) {
        context.read<SaleManProvider>().fetchEmployees();
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _searchController.dispose();
    super.dispose();
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

  // ── Build ─────────────────────────────────────────────────────────────────

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
              color: Colors.white),
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
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                context.read<ReceivableProvider>().fetchReceivables(),
          ),
        ],
      ),
      body: Column(
        children: [

          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.grey.shade200, width: 1.5),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by customer name...',
                      hintStyle: TextStyle(
                          color: Colors.grey[400], fontSize: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: AppColors.primary, size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear,
                            color: Colors.grey[500], size: 20),
                        onPressed: () {
                          _searchController.clear();
                          context
                              .read<ReceivableProvider>()
                              .updateSearch('');
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    onChanged: (v) =>
                        context.read<ReceivableProvider>().updateSearch(v),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Chips
                Consumer<ReceivableProvider>(
                  builder: (context, provider, _) => Row(
                    children: [
                      FilterChip(
                        label: const Text("Show Zero Balance"),
                        selected: provider.withZero ?? false,
                        onSelected: (val) => provider.updateWithZero(val),
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                // Error Message
                Consumer<ReceivableProvider>(
                  builder: (context, provider, _) {
                    if (provider.errorMessage == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    );
                  },
                ),
                // Salesman Dropdown (Admin only)
                Consumer2<ReceivableProvider, SaleManProvider>(
                  builder: (context, recvProv, saleProv, _) {
                    if (!recvProv.isAdmin) return const SizedBox.shrink();
                    
                    return Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200, width: 1.5),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int?>(
                              value: recvProv.salesmanId,
                              isExpanded: true,
                              hint: const Text("Select Salesman"),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text("All Salesmen"),
                                ),
                                ...saleProv.employees.map((e) => DropdownMenuItem<int?>(
                                  value: e.id,
                                  child: Text(e.name),
                                )),
                              ],
                              onChanged: (val) => recvProv.updateSalesmanId(val),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Record Count ───────────────────────────────────────────────
          Consumer<ReceivableProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading || provider.filteredList.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      "${provider.filteredList.length} customers found",
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            },
          ),

          // ── List ───────────────────────────────────────────────────────
          Expanded(
            child: Consumer<ReceivableProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return _buildShimmerEffect(
                      child: _buildShimmerLoading());
                }

                if (provider.filteredList.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: provider.filteredList.length,
                  itemBuilder: (context, index) {
                    final customer = provider.filteredList[index];
                    return _buildCustomerCard(customer);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildCustomerCard(CustomerReceivable customer) {
    final grandBalance = customer.grandBalance;
    final hasPending = grandBalance > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _showCustomerDetail(customer),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Row ──────────────────────────────────────────
                Row(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: hasPending
                                  ? [
                                AppColors.primary,
                                AppColors.secondary
                              ]
                                  : [
                                Colors.grey.shade400,
                                Colors.grey.shade500
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              customer.customerName.isNotEmpty
                                  ? customer.customerName[0]
                                  .toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(width: 14),

                    // Name + status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.customerName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 4),



                        ],
                      ),
                    ),

                    // Grand Balance
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Rs ${_fmt.format(grandBalance)}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: hasPending
                                  ? Colors.orange.shade700
                                  : Colors.green.shade700),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Bottom Stats ──────────────────────────────────────

              ],
            ),
          ),
        ),
      ),
    );
  }




  // ── Customer Detail Bottom Sheet ──────────────────────────────────────────

  void _showCustomerDetail(CustomerReceivable customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(customer.customerName,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B))),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Rs ${_fmt.format(customer.grandBalance)}",
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Invoice list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: customer.invoices.length,
                  itemBuilder: (_, i) =>
                      _buildInvoiceRow(customer.invoices[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(ReceivableInvoice inv) {
    final hasBal = inv.balance > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: hasBal
                ? Colors.orange.withOpacity(0.3)
                : Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(inv.invNo,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF1E293B))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: hasBal
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  hasBal ? "Pending" : "Paid",
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: hasBal ? Colors.orange : Colors.green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInvStat("Net",
                  "Rs ${_fmt.format(inv.netTotal)}", AppColors.primary),
              _buildInvStat("Received",
                  "Rs ${_fmt.format(inv.received)}", Colors.teal),
              _buildInvStat("Balance",
                  "Rs ${_fmt.format(inv.balance)}", Colors.orange),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "${inv.salesmanName}  •  ${DateFormat('dd MMM yyyy').format(inv.invoiceDate)}",
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildInvStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: Colors.grey[500])),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
                color: Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(Icons.receipt_outlined,
                size: 60, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          Text("No Receivables Found",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700)),
        ],
      ),
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
          child: Text(label,
              style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w500)),
        ),
      ),
    );
  }
}