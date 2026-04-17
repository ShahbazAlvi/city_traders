// Screen/Recovery_Screen/RecoveryScreen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


import '../../Provider/SaleManProvider/SaleManProvider.dart';
import '../../Provider/SalemanRecoveryReport/salemanReport.dart';
import '../../compoents/AppColors.dart';
import '../../compoents/SaleManDropdown.dart';
import 'SalemanRecoveryReportShimmer.dart';


class SaleManRecoveryScreen extends StatefulWidget {
  const SaleManRecoveryScreen({super.key});

  @override
  State<SaleManRecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<SaleManRecoveryScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedSalesmanId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
      Future.microtask(() => context.read<SaleManProvider>().fetchEmployees());

      // if (widget.isUpdate && widget.existingOrder != null) {
      //   final order = widget.existingOrder!;
      //   selectedSalesmanId = order.salesmanId?.toString();
      // }
    });
  }

  // Update _fetchData to pass salesmanId
  void _fetchData() {
    final date = selectedDate.toIso8601String().split('T').first;
    Provider.of<SaleManRecoveryProvider>(context, listen: false)
        .fetchRecoveries(
      date: date,
      salesmanId: selectedSalesmanId != null
          ? int.tryParse(selectedSalesmanId!)
          : null,
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
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
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
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20),
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
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.blue, size: 18),
                  const SizedBox(width: 5),
                  Text(
                    DateFormat('dd MMM yyyy').format(selectedDate),
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

           // Salesman Section
            _buildSectionTitle('Salesman Information'),
            const SizedBox(height: 12),
            _buildSalesmanField(),
            const SizedBox(height: 24),
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
                          margin: const EdgeInsets.all(14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.secondary, AppColors.primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _summaryTile("Salesmen",
                                  "${provider.summary!.totalSalesmen}"),
                              _divider(),
                              _summaryTile("Recoveries",
                                  "${provider.summary!.totalRecoveries}"),
                              _divider(),
                              _summaryTile("Total",
                                  "₨ ${NumberFormat('#,##0').format(provider.summary!.totalRecovered)}"),
                            ],
                          ),
                        ),

                      /// -------- LIST --------
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          itemCount: provider.recoveries.length,
                          itemBuilder: (context, index) {
                            final item = provider.recoveries[index];
                            return GestureDetector(
                              onTap: () => _showDetailSheet(context, item.salesmanId, item.salesmanName),
                              child: Card(
                                elevation: 3,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      /// Salesman Name
                                      Row(
                                        children: [
                                          const Icon(Icons.person,
                                              color: AppColors.primary, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            item.salesmanName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        ],
                                      ),

                                      const Divider(height: 16),

                                      /// Stats Row
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          _statChip(Icons.receipt_long,
                                              "Recoveries", "${item.recoveryCount}",
                                              Colors.blue),
                                          _statChip(Icons.people,
                                              "Customers", "${item.customerCount}",
                                              Colors.orange),
                                          _statChip(Icons.attach_money,
                                              "Total",
                                              "₨ ${NumberFormat('#,##0').format(item.totalRecovered)}",
                                              Colors.green),
                                        ],
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

  Widget _summaryTile(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _divider() {
    return Container(height: 30, width: 1, color: Colors.white38);
  }

  Widget _statChip(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        Text(label,
            style:
            const TextStyle(fontSize: 11, color: Colors.grey)),
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
    final date = selectedDate.toIso8601String().split('T').first;

    // Fetch detail BEFORE opening sheet
    Provider.of<SaleManRecoveryProvider>(context, listen: false)
        .fetchSalesmanDetail(salesmanId: salesmanId, date: date);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChangeNotifierProvider.value(   // ← ADD THIS
        value: Provider.of<SaleManRecoveryProvider>(context, listen: false),
        child: _SalesmanDetailSheet(
          salesmanName: salesmanName,
          date: date,
        ),
      ),
    );
  }
}
class _SalesmanDetailSheet extends StatelessWidget {
  final String salesmanName;
  final String date;

  const _SalesmanDetailSheet({
    required this.salesmanName,
    required this.date,
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
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryItem("Recoveries",
                          provider.detailSummary!.recoveryCount.toString()),
                      _summaryItem("Customers",
                          provider.detailSummary!.customerCount.toString()),
                      _summaryItem(
                        "Total",
                        "₨ ${NumberFormat('#,##0').format(provider.detailSummary!.totalRecovered)}",
                      ),
                    ],
                  ),
                ),

              const Divider(),

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

  Widget _summaryItem(String title, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

}

