// Screen/Recovery_Screen/RecoveryScreen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


import '../../Provider/SaleManProvider/SaleManProvider.dart';
import '../../Provider/SalemanRecoveryReport/salemanReport.dart';
import '../../compoents/AppColors.dart';
import '../../compoents/SaleManDropdown.dart';
import '../../utils/access_control.dart';
import 'SalemanRecoveryReportShimmer.dart';


class SaleManRecoveryScreen extends StatefulWidget {
  const SaleManRecoveryScreen({super.key});

  @override
  State<SaleManRecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<SaleManRecoveryScreen> {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  String? selectedSalesmanId;
  bool isAdmin = true; // Default to true
  String selectedFilter = 'Today';

  @override
  void initState() {
    super.initState();
    _checkRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
      Future.microtask(() => context.read<SaleManProvider>().fetchEmployees());
    });
  }

  Future<void> _checkRole() async {
    final sId = await AccessControl.getSalesmanId();
    final admin = await AccessControl.isAdmin();
    setState(() {
      isAdmin = admin;
      if (sId != null) {
        selectedSalesmanId = sId.toString();
      }
    });
    // Re-fetch data once we know the salesmanId
    _fetchData();
  }

  // Update _fetchData to pass salesmanId and date range
  void _fetchData() {
    final from = fromDate.toIso8601String().split('T').first;
    final to = toDate.toIso8601String().split('T').first;
    Provider.of<SaleManRecoveryProvider>(context, listen: false)
        .fetchRecoveries(
      dateFrom: from,
      dateTo: to,
      salesmanId: selectedSalesmanId != null
          ? int.tryParse(selectedSalesmanId!)
          : null,
    );
  }

  void _setFilter(String filter) {
    DateTime now = DateTime.now();
    DateTime start = now;
    DateTime end = now;

    switch (filter) {
      case 'Today':
        start = now;
        end = now;
        break;
      case 'Yesterday':
        start = now.subtract(const Duration(days: 1));
        end = now.subtract(const Duration(days: 1));
        break;
      case 'Last Week':
        start = now.subtract(const Duration(days: 7));
        end = now;
        break;
      case 'This Month':
        start = DateTime(now.year, now.month, 1);
        end = now;
        break;
      case 'Last Month':
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0);
        break;
      case 'This Year':
        start = DateTime(now.year, 1, 1);
        end = now;
        break;
      case 'Last Year':
        start = DateTime(now.year - 1, 1, 1);
        end = DateTime(now.year - 1, 12, 31);
        break;
    }

    setState(() {
      selectedFilter = filter;
      fromDate = start;
      toDate = end;
    });
    _fetchData();
  }

  Widget _buildQuickFilters() {
    final filters = [
      'Today',
      'Yesterday',
      'Last Week',
      'This Month',
      'Last Month',
      'This Year',
      'Last Year',
      'Custom'
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: filters.contains(selectedFilter) ? selectedFilter : 'Today',
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          items: filters.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue == 'Custom') {
              _pickDateRange();
            } else if (newValue != null) {
              _setFilter(newValue);
            }
          },
        ),
      ),
    );
  }

// Update _buildSalesmanField — call _fetchData on change
  Widget _buildSalesmanField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SalesmanDropdown(
        selectedId: selectedSalesmanId,
        onChanged: (value) {
          setState(() => selectedSalesmanId = value);
          _fetchData(); // ← trigger filtered fetch
        },
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: fromDate, end: toDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
        selectedFilter = 'Custom';
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Recovery Report",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            /// -------- DATE FILTER SECTION --------
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Date Filter'),
                  const SizedBox(height: 12),
                  _buildQuickFilters(),
                  if (selectedFilter == 'Custom') ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickDateRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.edit_calendar_outlined,
                                    color: AppColors.primary, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  "${DateFormat('dd MMM yyyy').format(fromDate)} - ${DateFormat('dd MMM yyyy').format(toDate)}",
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        "${DateFormat('dd MMM yyyy').format(fromDate)} - ${DateFormat('dd MMM yyyy').format(toDate)}",
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Salesman Section
            if (isAdmin) ...[
              _buildSectionTitle('Salesman Information'),
              const SizedBox(height: 10),
              _buildSalesmanField(),
              const SizedBox(height: 20),
            ],
            Expanded(
              child: Consumer<SaleManRecoveryProvider>(
                builder: (context, provider, _) {

                  /// Shimmer
                  if (provider.isLoading) return const RecoveryShimmer();

                  /// Error
                  if (provider.error.isNotEmpty) {
                    return Center(
                      child: Text(provider.error,
                          style: const TextStyle(color: Colors.red)),
                    );
                  }

                  /// Empty
                  if (provider.recoveries.isEmpty) {
                    return const Center(child: Text("No Recovery Data Found"));
                  }

                  return Column(
                    children: [



                      /// -------- SUMMARY CARD --------
                      if (provider.summary != null)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.secondary, AppColors.primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -20,
                                top: -20,
                                child: Icon(
                                  Icons.analytics_outlined,
                                  size: 100,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _summaryTile("Salesmen",
                                      "${provider.summary!.totalSalesmen}", Icons.people_outline),
                                  _divider(),
                                  _summaryTile("Recoveries",
                                      "${provider.summary!.totalRecoveries}", Icons.receipt_long_outlined),
                                  _divider(),
                                  _summaryTile("Total",
                                      "₨ ${NumberFormat('#,##0').format(provider.summary!.totalRecovered)}", Icons.payments_outlined),
                                ],
                              ),
                            ],
                          ),
                        ),

                      /// -------- LIST --------
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          itemCount: provider.recoveries.length,
                          itemBuilder: (context, index) {
                            final item = provider.recoveries[index];
                            return GestureDetector(
                              onTap: () => _showDetailSheet(context, item.salesmanId, item.salesmanName),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            bottomLeft: Radius.circular(16),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.primary.withOpacity(0.1),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: const Icon(Icons.person,
                                                            color: AppColors.primary, size: 20),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        item.salesmanName,
                                                        style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                            color: Colors.black87),
                                                      ),
                                                    ],
                                                  ),
                                                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                                                ],
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(vertical: 12),
                                                child: Divider(height: 1),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  _statChip(Icons.receipt_long,
                                                      "Recoveries", "${item.recoveryCount}",
                                                      Colors.blue.shade700),
                                                  _statChip(Icons.group_outlined,
                                                      "Customers", "${item.customerCount}",
                                                      Colors.orange.shade700),
                                                  _statChip(Icons.currency_exchange,
                                                      "Amount",
                                                      "₨ ${NumberFormat('#,##0').format(item.totalRecovered)}",
                                                      Colors.green.shade700),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  // Widget _buildSalesmanField() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.08),
  //           spreadRadius: 1,
  //           blurRadius: 6,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: SalesmanDropdown(
  //       selectedId: selectedSalesmanId,
  //       onChanged: (value) {
  //         setState(() => selectedSalesmanId = value);
  //       },
  //     ),
  //   );
  // }

  Widget _summaryTile(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _divider() {
    return Container(height: 40, width: 1, color: Colors.white24);
  }

  Widget _statChip(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        Text(label,
            style:
            TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
      ],
    );
  }
  // void _showDetailSheet(BuildContext context, int salesmanId, String salesmanName) {
  //   final date = selectedDate.toIso8601String().split('T').first;
  //
  //   // Fetch detail
  //   Provider.of<SaleManRecoveryProvider>(context, listen: false)
  //       .fetchSalesmanDetail(salesmanId: salesmanId, date: date);
  //
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) => _SalesmanDetailSheet(
  //       salesmanName: salesmanName,
  //       date: date,
  //     ),
  //   );
  // }
  void _showDetailSheet(BuildContext context, int salesmanId, String salesmanName) {
    final from = fromDate.toIso8601String().split('T').first;
    final to = toDate.toIso8601String().split('T').first;

    // Fetch detail BEFORE opening sheet
    Provider.of<SaleManRecoveryProvider>(context, listen: false)
        .fetchSalesmanDetail(salesmanId: salesmanId, dateFrom: from, dateTo: to);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChangeNotifierProvider.value(   // ← ADD THIS
        value: Provider.of<SaleManRecoveryProvider>(context, listen: false),
        child: _SalesmanDetailSheet(
          salesmanName: salesmanName,
          dateFrom: from,
          dateTo: to,
        ),
      ),
    );
  }
}
class _SalesmanDetailSheet extends StatelessWidget {
  final String salesmanName;
  final String dateFrom;
  final String dateTo;

  const _SalesmanDetailSheet({
    required this.salesmanName,
    required this.dateFrom,
    required this.dateTo,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SaleManRecoveryProvider>(
      builder: (context, provider, _) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [

              /// HEADER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                  ),
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        salesmanName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),

              /// SUMMARY
              if (provider.detailSummary != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryItem("Recoveries",
                          provider.detailSummary!.recoveryCount.toString(), Icons.receipt_outlined),
                      _verticalDivider(),
                      _summaryItem("Customers",
                          provider.detailSummary!.customerCount.toString(), Icons.people_outline),
                      _verticalDivider(),
                      _summaryItem(
                        "Total",
                        "₨ ${NumberFormat('#,##0').format(provider.detailSummary!.totalRecovered)}",
                        Icons.payments_outlined,
                      ),
                    ],
                  ),
                ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(),
              ),

              /// TABLE
              Expanded(
                child: provider.isDetailLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 20,
                      // headingRowColor:
                      // MaterialStateProperty.all(Colors.grey[200]),
                      headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                      columns: const [

                        DataColumn(label: Text("Date")),
                        DataColumn(label: Text("Voucher")),
                        DataColumn(label: Text("Customer")),
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Mode")),
                        DataColumn(label: Text("Invoices")),
                      ],
                      rows: provider.detailList.map((item) {
                        return DataRow(cells: [
                          DataCell(
                            Text(
                              DateFormat('dd MMM yyyy')
                                  .format(DateTime.parse(item.recoveryDate)),
                            ),
                          ),
                          DataCell(Text(item.voucherNo)),
                          DataCell(Text(item.customerName)),

                          DataCell(Text(
                              NumberFormat('#,##0').format(item.amount))),
                          DataCell(Text(item.mode)),
                          DataCell(Text(item.invoiceNumbers)),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
        Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.shade300);
  }
}

