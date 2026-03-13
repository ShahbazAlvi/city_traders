import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Provider/CustomerProvider/CustomerProvider.dart';
import '../../Provider/DashBoardProvider.dart';
import '../../compoents/AppColors.dart';
import '../../model/CustomerModel/CustomersDefineModel.dart';
import 'AddCustomerScreen.dart';
import 'Update customer.dart';

class CustomersDefineScreen extends StatefulWidget {
  const CustomersDefineScreen({super.key});

  @override
  State<CustomersDefineScreen> createState() => _CustomersDefineScreenState();
}

class _CustomersDefineScreenState extends State<CustomersDefineScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _fmt = NumberFormat('#,##,###');

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(
          min: 0,
          max: 1,
          period: const Duration(milliseconds: 1500));

    Future.microtask(
            () => context.read<CustomerProvider>().fetchCustomers());
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
        colors: const [
          Color(0xFFE0E0E0),
          Color(0xFFF5F5F5),
          Color(0xFFE0E0E0)
        ],
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
            borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Customers",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 1.2),
        ),
        centerTitle: true,
        elevation: 0,
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
                context.read<CustomerProvider>().fetchCustomers(),
          ),
        ],
      ),
      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AddCustomerScreen()),
          );
          if (result == true && mounted) {
            context.read<CustomerProvider>().fetchCustomers();
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text("Add Customer",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // ── Summary ───────────────────────────────────────────────────
          Consumer<CustomerProvider>(
            builder: (_, provider, __) {
              if (provider.isLoading ||
                  provider.customers.isEmpty) {
                return const SizedBox.shrink();
              }
              return _buildSummaryCard(provider);
            },
          ),

          // ── Search Bar ────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (v) {
                context.read<CustomerProvider>().updateSearch(v);
                setState(() {}); // refresh suffix icon
              },
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                hintStyle:
                TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded,
                    color: AppColors.primary, size: 22),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear,
                      color: Colors.grey[500], size: 20),
                  onPressed: () {
                    _searchController.clear();
                    context
                        .read<CustomerProvider>()
                        .updateSearch('');
                    setState(() {});
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                    BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                    BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5)),
              ),
            ),
          ),

          // ── Count ─────────────────────────────────────────────────────
          Consumer<CustomerProvider>(
            builder: (_, provider, __) {
              if (provider.isLoading) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      "${provider.filteredCustomers.length} customers",
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

          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (_, provider, __) {
                if (provider.isLoading) {
                  return _buildShimmerEffect(
                      child: _buildShimmerLoading());
                }

                if (provider.filteredCustomers.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding:
                  const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  itemCount: provider.filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer =
                    provider.filteredCustomers[index];
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

  // ── Summary Card ──────────────────────────────────────────────────────────

  Widget _buildSummaryCard(CustomerProvider provider) {
    final total = provider.customers.length;
    final active = provider.customers
        .where((c) => c.isActive == 1)
        .length;

    return Container(




    );
  }



  // ── Customer Card ─────────────────────────────────────────────────────────

  Widget _buildCustomerCard(CustomerData customer) {
    final isActive = customer.isActive == 1;
    final openingBal =
        double.tryParse(customer.openingBalance) ?? 0;
    final creditLimit =
        double.tryParse(customer.creditLimit) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showCustomerDetail(customer),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Row ────────────────────────────────────────
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isActive
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
                          customer.name.isNotEmpty
                              ? customer.name[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Name + phone
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                "Aging Days",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                customer.agingDays.toString(),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Status + actions
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildStatusPill(isActive),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionBtn(
                              icon: Icons.edit_outlined,
                              color: Colors.blue,
                              onTap: () =>
                                  _navigateToUpdate(customer),
                            ),
                            const SizedBox(width: 6),
                            _buildActionBtn(
                              icon: Icons.delete_outline,
                              color: Colors.red,
                              onTap: () => _confirmDelete(
                                  context,
                                  customer.id.toString()),
                            ),
                          ],
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

  Widget _buildStatusPill(bool isActive) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
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
                color: isActive ? Colors.green : Colors.red),
          ),
          const SizedBox(width: 5),
          Text(
            isActive ? "Active" : "Inactive",
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.green : Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: Colors.grey[500]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
        width: 1, height: 32, color: Colors.grey.shade200);
  }

  // ── Customer Detail Bottom Sheet ──────────────────────────────────────────

  void _showCustomerDetail(CustomerData customer) {
    final openingBal =
        double.tryParse(customer.openingBalance) ?? 0;
    final creditLimit =
        double.tryParse(customer.creditLimit) ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),

            // Name + status
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.secondary
                        ]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      customer.name[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B))),
                      Text(customer.openingDate?? "",
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600])),
                    ],
                  ),
                ),
                _buildStatusPill(customer.isActive == 1),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Detail rows
            _buildDetailRow(
                Icons.calendar_month, "Date", customer.openingDate ?? ""),
            _buildDetailRow(Icons.location_on_outlined, "Address",
                customer.address),
            _buildDetailRow(
                Icons.account_balance_wallet_outlined,
                "Opening Balance",
                "Rs ${_fmt.format(openingBal.toInt())}"),
            _buildDetailRow(Icons.credit_card_outlined,
                "Credit Limit",
                "Rs ${_fmt.format(creditLimit.toInt())}"),
            _buildDetailRow(
                Icons.hourglass_bottom_rounded,
                "Aging Days",
                "${customer.agingDays ?? 0} days"),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToUpdate(customer);
                    },
                    icon: const Icon(Icons.edit_outlined,
                        color: AppColors.primary),
                    label: const Text("Edit",
                        style: TextStyle(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(
                          context, customer.id.toString());
                    },
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.white),
                    label: const Text("Delete",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[500])),
                Text(value.isEmpty ? "N/A" : value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _navigateToUpdate(CustomerData customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdateCustomerScreen(
          customer: {
            "_id": customer.id,
            "salesArea": customer.salesAreaId,
            "customerName": customer.name,
            "address": customer.address,
            "phoneNumber": customer.phone,
            "creditLimit": customer.creditLimit,
            "creditTime": customer.agingDays?.toString() ?? "0",
            "openingBalanceDate": customer.openingBalance,
          },
        ),
      ),
    ).then((result) {
      if (result == true && mounted) {
        context.read<CustomerProvider>().fetchCustomers();
      }
    });
  }

  void _confirmDelete(BuildContext context, String customerId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Customer"),
        content: const Text(
            "Are you sure you want to delete this customer?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text("Delete",
                style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Navigator.pop(context);
              final dashProvider = Provider.of<DashboardProvider>(
                  context,
                  listen: false);
              final success = await context
                  .read<CustomerProvider>()
                  .DeleteCustomer(customerId, dashProvider);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success
                      ? "Deleted successfully"
                      : "Failed to delete"),
                  backgroundColor:
                  success ? Colors.green : Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ));
              }
            },
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
                color: Colors.grey.shade100,
                shape: BoxShape.circle),
            child: Icon(Icons.people_outline,
                size: 60, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          Text("No Customers Found",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          Text("Tap + to add a new customer",
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
  String formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('d MMM yyyy').format(parsedDate);
  }
}