



import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Provider/OrderTakingProvider/OrderTakingProvider.dart';
import '../../../Provider/SaleInvoiceProvider/SaleInvoicesProvider.dart';
import '../../../Provider/SaleManProvider/SaleManProvider.dart';
import '../../../compoents/AppColors.dart';
import '../../../compoents/SaleManDropdown.dart';
import '../../../model/SaleInvoiceModel/SaleInvoiceDetailsModel.dart';
import '../../../utils/access_control.dart';
import 'AddSalesInvoiceScreen.dart';
import 'UpdateSalesInvoiceScreen.dart';

class SaleInvoiseScreen extends StatefulWidget {
  const SaleInvoiseScreen({super.key});

  @override
  State<SaleInvoiseScreen> createState() => _SaleInvoiseScreenState();
}

class _SaleInvoiseScreenState extends State<SaleInvoiseScreen> {
  String? selectedDate;
  String? selectedSalesmanId;
  int currentPage = 1;
  int itemsPerPage = 5;
  final formatted=NumberFormat("#,##,###");

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  bool canAddOrder = false;
  String? _loggedInSalesmanId;
  bool _isSalesmanLocked = false;

  Future<void> _loadSalesmanId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('salesman_id');
    setState(() {
      _loggedInSalesmanId = id?.toString();
      _isSalesmanLocked = id != null;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSalesmanId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SaleInvoicesProvider>(context, listen: false).fetchOrders();
    });
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final add = await AccessControl.canDo("can_add_sales_invoice_cash");
    setState(() => canAddOrder = add);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List getPaginatedData(List data) {
    final provider = Provider.of<SaleInvoicesProvider>(context, listen: false);
    final sourceData = provider.getFilteredInvoices(_loggedInSalesmanId);

    final filteredData = sourceData.where((invoice) {
      final query = searchQuery.toLowerCase();
      return invoice.invNo?.toLowerCase().contains(query) == true ||
          invoice.customerName?.toLowerCase().contains(query) == true ||
          invoice.salesmanName?.toLowerCase().contains(query) == true;
    }).toList();

    int start = (currentPage - 1) * itemsPerPage;
    int end = (start + itemsPerPage).clamp(0, filteredData.length);
    if (start >= filteredData.length) return [];
    return filteredData.sublist(start, end);
  }

  int get filteredItemCount {
    final provider = Provider.of<SaleInvoicesProvider>(context, listen: false);
    final sourceData = provider.getFilteredInvoices(_loggedInSalesmanId);
    return sourceData.where((invoice) {
      final query = searchQuery.toLowerCase();
      return invoice.invNo?.toLowerCase().contains(query) == true ||
          invoice.customerName?.toLowerCase().contains(query) == true ||
          invoice.salesmanName?.toLowerCase().contains(query) == true;
    }).length;
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat('#,##,###');
    return 'Rs: ${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SaleInvoicesProvider>(context);
    final orders = provider.orderData?.invoices ?? [];
    final totalFilteredItems = filteredItemCount;
    final totalPages = totalFilteredItems == 0
        ? 1
        : (totalFilteredItems / itemsPerPage).ceil();

    return ChangeNotifierProvider(
      create: (_) => SaleManProvider()..fetchEmployees(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildFilterSection(provider),
            _buildSearchBar(),
            Expanded(
              child: provider.isLoading
                  ? _buildLoadingShimmer()
                  : provider.error != null
                  ? _buildErrorWidget(provider.error!)
                  : orders.isEmpty
                  ? _buildEmptyState()
                  : _buildInvoicesList(provider, orders),
            ),
            if (!provider.isLoading && orders.isNotEmpty)
              _buildPaginationControls(totalPages),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
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
      // ✅ title uses FittedBox so it never overflows on narrow screens
      title: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "Sales Invoice",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        if (canAddOrder)
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: _navigateToAddInvoice,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text(
                "Add",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
      ],
    );
  }

  void _navigateToAddInvoice() {
    final invoiceProvider =
    Provider.of<SaleInvoicesProvider>(context, listen: false);
    String nextInvNo = "INV-0001";

    if (invoiceProvider.orderData != null &&
        invoiceProvider.orderData!.invoices.isNotEmpty) {
      final allNumbers = invoiceProvider.orderData!.invoices.map((invoice) {
        final id = invoice.invNo ?? "";
        final match = RegExp(r'INV-(\d+)$').firstMatch(id);
        return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
      }).toList();
      final max =
      allNumbers.isNotEmpty ? allNumbers.reduce((a, b) => a > b ? a : b) : 0;
      nextInvNo = "INV-${(max + 1).toString().padLeft(4, '0')}";
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddSalesInvoiceScreen(nextOrderId: nextInvNo),
      ),
    );
  }

  // ── Filter Row ──────────────────────────────────────────────────────────────
  Widget _buildFilterSection(SaleInvoicesProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Row(
        children: [
          // Date picker
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = DateFormat('yyyy-MM-dd').format(picked);
                    currentPage = 1;
                  });
                  provider.fetchOrders(
                      date: selectedDate, salesmanId: selectedSalesmanId);
                }
              },
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                  children: [
                    Icon(Icons.calendar_today,
                        size: 15, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        selectedDate ?? "Select Date",
                        style: TextStyle(
                          color: selectedDate == null
                              ? Colors.grey.shade500
                              : Colors.black,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade400, size: 20),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Salesman dropdown
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SalesmanDropdown(
                  selectedId: _isSalesmanLocked
                      ? _loggedInSalesmanId
                      : selectedSalesmanId,
                  isLocked: _isSalesmanLocked,
                  onChanged: (value) {
                    if (_isSalesmanLocked) return; // ← lock ho to kuch mat karo
                    setState(() {
                      selectedSalesmanId = value;
                      currentPage = 1;
                    });
                    provider.fetchOrders(
                        date: selectedDate, salesmanId: selectedSalesmanId);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ──────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(fontSize: 13),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
              currentPage = 1;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search invoices...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon:
            Icon(Icons.search, color: AppColors.primary, size: 18),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear,
                  color: Colors.grey.shade400, size: 16),
              onPressed: () {
                _searchController.clear();
                setState(() => searchQuery = '');
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            isDense: true,
          ),
        ),
      ),
    );
  }

  // ── Loading ─────────────────────────────────────────────────────────────────
  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // ── Error ───────────────────────────────────────────────────────────────────
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration:
              BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
              child:
              Icon(Icons.error_outline, size: 46, color: Colors.red.shade300),
            ),
            const SizedBox(height: 14),
            Text(
              'Error Loading Invoices',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(error,
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => Provider.of<SaleInvoicesProvider>(context,
                  listen: false)
                  .fetchOrders(date: selectedDate, salesmanId: selectedSalesmanId),
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

  // ── Empty State ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                  color: Colors.grey.shade200, shape: BoxShape.circle),
              child: Icon(Icons.receipt_outlined,
                  size: 56, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 18),
            Text(
              searchQuery.isEmpty ? 'No Invoices Found' : 'No matching invoices',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800),
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isEmpty
                  ? 'Start by creating your first invoice'
                  : 'Try adjusting your search',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            if (searchQuery.isEmpty) ...[
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const AddSalesInvoiceScreen(nextOrderId: "INV-0001"),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Create Invoice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Invoice List ────────────────────────────────────────────────────────────
  Widget _buildInvoicesList(SaleInvoicesProvider provider, List orders) {
    final paginatedList = getPaginatedData(orders);

    if (paginatedList.isEmpty && searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No results for "$searchQuery"',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: paginatedList.length,
      itemBuilder: (_, index) => _buildInvoiceCard(paginatedList[index]),
    );
  }

  // ── Invoice Card ────────────────────────────────────────────────────────────
  Widget _buildInvoiceCard(dynamic invoice) {
    final statusColor = invoice.status == 'Paid'
        ? Colors.green
        : invoice.status == 'Pending'
        ? Colors.orange
        : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showInvoiceDetails(invoice),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.receipt_long,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    // ✅ Expanded protects against text overflow
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice.invNo ?? 'N/A',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 11, color: Colors.grey.shade500),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  DateFormat('dd MMM yyyy')
                                      .format(invoice.invoiceDate),
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // ✅ Status badge with min size constraint
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                                color: statusColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            invoice.status ?? 'DRAFT',
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Customer / Salesman ──
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // Customer
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.business,
                                size: 13, color: Colors.grey.shade600),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Customer',
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey.shade500)),
                                  Text(
                                    invoice.customerName ?? 'N/A',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                          width: 1, height: 24, color: Colors.grey.shade300),
                      // Salesman
                      Expanded(
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Icon(Icons.person_outline,
                                size: 13, color: Colors.grey.shade600),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Salesman',
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.grey.shade500)),
                                  Text(
                                    invoice.salesmanName ?? 'N/A',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
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

                const SizedBox(height: 10),

                // ── Items + Gross row ──
                Row(
                  children: [
                    // ✅ Wrap chips in Flexible to prevent overflow on tiny screens
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildChip(
                            'Items: ${invoice.totalItems ?? 0}',
                            Colors.blue.shade50,
                            Colors.blue.shade700,
                          ),
                          const SizedBox(width: 5),
                          _buildChip(
                            'Qty: ${invoice.totalQty ?? 0}',
                            Colors.orange.shade50,
                            Colors.orange.shade700,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Gross',
                            style: TextStyle(
                                fontSize: 9, color: Colors.grey.shade500)),
                        Text(
                          formatCurrency(invoice.grossTotal ?? 0),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),

                const Divider(height: 14),

                // ── Net Total ──
                Row(
                  children: [
                    const Text(
                      'Net Total',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    // ✅ FittedBox prevents gradient badge overflow
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.secondary, AppColors.primary],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          formatCurrency(invoice.netTotal ?? 0),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
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

  Widget _buildChip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w500)),
    );
  }

  // Update _showInvoiceDetails to pass the invoice id (int)
  void _showInvoiceDetails(dynamic invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InvoiceDetailsSheet(invoiceId: invoice.id),
    );
  }

  // ── Pagination ──────────────────────────────────────────────────────────────
  Widget _buildPaginationControls(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed:
            currentPage > 1 ? () => setState(() => currentPage--) : null,
            color: currentPage > 1 ? AppColors.primary : Colors.grey,
            iconSize: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$currentPage of $totalPages',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                  fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages
                ? () => setState(() => currentPage++)
                : null,
            color: currentPage < totalPages ? AppColors.primary : Colors.grey,
            iconSize: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

}


class _InvoiceDetailsSheet extends StatefulWidget {
  final int invoiceId;
  const _InvoiceDetailsSheet({required this.invoiceId});

  @override
  State<_InvoiceDetailsSheet> createState() => _InvoiceDetailsSheetState();
}

class _InvoiceDetailsSheetState extends State<_InvoiceDetailsSheet> {
  final formatter = NumberFormat('#,##,###');
  final dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<SaleInvoicesProvider>(context, listen: false)
            .fetchSingleInvoice(widget.invoiceId));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SaleInvoicesProvider>(
      builder: (context, provider, _) {
        final invoice = provider.selectedInvoice;

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
                  const SizedBox(height: 14),

                  // ── Header ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.receipt,
                              color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Invoice Details',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                              if (invoice != null)
                                Text(invoice.invNo,
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13),
                                    overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        if (invoice != null) _statusBadge(invoice.status),
                      ],
                    ),
                  ),
                  // After the header Padding(...) and before const Divider(height: 24)
                  if (invoice != null) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // ── Edit button ──
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UpdateSalesInvoiceScreen(
                                      invoiceId: invoice.id,
                                      invNo: invoice.invNo,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text("Edit",
                                  style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(
                                    color: AppColors.primary.withOpacity(0.4)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // ── Delete button ──
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _confirmDelete(context, provider, invoice.id),
                              icon: const Icon(Icons.delete_outline,
                                  size: 16, color: Colors.white),
                              label: const Text("Delete",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade400,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Divider(height: 24),

                  // ── Body ──
                  Expanded(
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : invoice == null
                        ? Center(
                        child: Text('No data found',
                            style: TextStyle(
                                color: Colors.grey.shade500)))
                        : _buildContent(invoice, controller),
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
      SaleInvoiceDetailData invoice, ScrollController controller) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        // ── Info block ──
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            children: [
              _infoRow(Icons.calendar_today, 'Invoice Date',
                  dateFormat.format(invoice.invoiceDate)),
              const Divider(height: 20),
              _infoRow(Icons.person_outline, 'Customer',
                  invoice.customerName),
              const Divider(height: 20),
              _infoRow(Icons.badge_outlined, 'Salesman',
                  invoice.salesmanName),
              const Divider(height: 20),
              _infoRow(Icons.location_on_outlined, 'Location',
                  invoice.locationName ?? 'N/A'),
              const Divider(height: 20),
              _infoRow(Icons.receipt_outlined, 'Invoice Type',
                  invoice.invoiceType),
              if (invoice.salesOrderNo != null) ...[
                const Divider(height: 20),
                _infoRow(Icons.link, 'Sales Order',
                    invoice.salesOrderNo!),
              ],
              if (invoice.remarks != null &&
                  invoice.remarks!.isNotEmpty) ...[
                const Divider(height: 20),
                _infoRow(Icons.notes, 'Remarks', invoice.remarks!),
              ],
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ── Items header ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Invoice Items',
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
                '${invoice.details.length} items',
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
        ...invoice.details.asMap().entries.map(
              (e) => _itemCard(e.value, e.key + 1),
        ),

        const SizedBox(height: 16),

        // ── Gross total ──
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gross Total',
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey.shade700)),
              Text(
                'Rs ${formatter.format(invoice.grossTotal)}',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ── Net total banner ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.secondary, AppColors.primary]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Net Total',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
              Text(
                'Rs ${formatter.format(invoice.netTotal)}',
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

  Widget _itemCard(InvoiceDetailItem item, int index) {
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
          // Chips + line total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  _miniChip(
                      '${item.qty.toStringAsFixed(item.qty % 1 == 0 ? 0 : 2)} ${item.unitName}',
                      Colors.blue.shade50,
                      Colors.blue.shade700),
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
              borderRadius: BorderRadius.circular(9)),
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
    final isPosted = status == 'POSTED';
    final color = isPosted ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12)),
    );
  }
  void _confirmDelete(
      BuildContext context,
      SaleInvoicesProvider provider,
      int invoiceId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Invoice",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            "Are you sure you want to delete this invoice? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);   // close dialog
              Navigator.pop(context); // close sheet
              await provider.deleteInvoice(invoiceId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}