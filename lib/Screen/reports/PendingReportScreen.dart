import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Provider/Report/Pending Report.dart';
import '../../Provider/SaleManProvider/SaleManProvider.dart';
import '../../compoents/AppColors.dart';
import '../../compoents/SaleManDropdown.dart';
import '../../utils/access_control.dart';
import 'SalemanRecoveryReportShimmer.dart';

class PendingReportScreen extends StatefulWidget {
  const PendingReportScreen({super.key});

  @override
  State<PendingReportScreen> createState() => _PendingReportScreenState();
}

class _PendingReportScreenState extends State<PendingReportScreen> {
  DateTime? selectedDate;        // ✅ null means not selected yet
  String?   selectedSalesmanId;
  bool      _dateSelected = false; // ✅ track if user picked date
  bool      isAdmin = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SaleManProvider>(context, listen: false).fetchEmployees();
      _fetchData(); // ✅ first load — no date, no salesman
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
    _fetchData();
  }

  void _fetchData() {
    Provider.of<RecoveryPendingReportProvider>(context, listen: false)
        .fetchRecoveryReport(
      // ✅ only send date if user picked one
      date:       _dateSelected && selectedDate != null
          ? selectedDate!.toIso8601String().split('T').first
          : null,
      // ✅ only send salesmanId if user selected one
      salesmanId: selectedSalesmanId != null
          ? int.tryParse(selectedSalesmanId!)
          : null,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context:     context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate:   DateTime(2020),
      lastDate:    DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate  = picked;
        _dateSelected = true; // ✅ mark date as selected
      });
      _fetchData();
    }
  }

  // ✅ Clear date filter
  void _clearDate() {
    setState(() {
      selectedDate  = null;
      _dateSelected = false;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Pending Recovery Report",
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
        padding: const EdgeInsets.all(12),
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

                  // ✅ Fix: null-safe date display
                  Text(
                    _dateSelected && selectedDate != null
                        ? DateFormat('dd MMM yyyy').format(selectedDate!)
                        : "Select Date",
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),

                  // ✅ Show clear button only when date is selected
                  if (_dateSelected) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _clearDate,
                      child: const Icon(Icons.close,
                          color: Colors.blue, size: 16),
                    ),
                  ],
                ],
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(height: 12),
              _buildSectionTitle('Filter by Salesman'),
              const SizedBox(height: 10),
              _buildSalesmanField(),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<RecoveryPendingReportProvider>(
                builder: (context, provider, _) {

                  if (provider.isLoading) return const RecoveryShimmer();

                  // ✅ Fix 6: null check before isNotEmpty
                  if (provider.error != null && provider.error!.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 56, color: Colors.red[300]),
                          const SizedBox(height: 12),
                          Text(provider.error!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _fetchData,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Retry"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.recoveryReport == null ||
                      provider.recoveryReport!.data.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text("No Pending Recovery Data Found",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[500])),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _fetchData,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Refresh"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final reportData = provider.recoveryReport!.data;
                  final summary    = provider.recoveryReport!.summary;

                  return Column(
                    children: [
                      // ── Summary Card ──
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.secondary, AppColors.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _summaryTile(
                                "Salesmen", "${summary.totalSalesmen}"),
                            _divider(),
                            _summaryTile("Pending Invoices",
                                "${summary.totalPendingInvoiceCount}"),
                            _divider(),
                            _summaryTile(
                              "Total Pending",
                              "₨ ${NumberFormat('#,##0').format(summary.totalPendingAmount)}",
                            ),
                          ],
                        ),
                      ),

                      // ── List ──
                      Expanded(
                        child: ListView.builder(
                          itemCount: reportData.length,
                          itemBuilder: (context, index) {
                            final item = reportData[index];
                            return GestureDetector(
                              onTap: () => _showDetailSheet(
                                  context, item.salesmanId, item.salesmanName),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                              BorderRadius.circular(10),
                                            ),
                                            child: Icon(Icons.person,
                                                color: AppColors.primary,
                                                size: 18),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              item.salesmanName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                          ),
                                          Icon(Icons.arrow_forward_ios,
                                              size: 14, color: Colors.grey[400]),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Divider(color: Colors.grey[200], height: 1),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _statChip(
                                              Icons.receipt_long,
                                              "Pending Invoices",
                                              "${item.pendingInvoiceCount}",
                                              Colors.blue,
                                            ),
                                          ),
                                          Expanded(
                                            child: _statChip(
                                              Icons.attach_money,
                                              "Pending Amount",
                                              "₨ ${NumberFormat('#,##0').format(item.totalPendingAmount)}",
                                              Colors.green,
                                            ),
                                          ),
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
          width: 4, height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

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
      child: Column(
        children: [
          SalesmanDropdown(
            selectedId: selectedSalesmanId,
            onChanged: (value) {
              setState(() => selectedSalesmanId = value);
              _fetchData();
            },
          ),
          if (selectedSalesmanId != null)
            TextButton.icon(
              onPressed: () {
                setState(() => selectedSalesmanId = null);
                _fetchData();
              },
              icon: const Icon(Icons.clear, size: 14),
              label: const Text("Clear Filter — Show All Salesmen",
                  style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
        ],
      ),
    );
  }

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
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _divider() =>
      Container(height: 30, width: 1, color: Colors.white38);

  Widget _statChip(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center),
      ],
    );
  }

  // ✅ Fix 7: no token needed — provider reads internally
  void _showDetailSheet(
      BuildContext context, int salesmanId, String salesmanName) {
    final date = selectedDate?.toIso8601String().split('T').first;

    Provider.of<RecoveryPendingReportProvider>(context, listen: false)
        .fetchPendingReportDetail(
      salesmanId: salesmanId,
      date:       date,
    );

    showModalBottomSheet(
      context:           context,
      isScrollControlled: true,
      backgroundColor:   Colors.transparent,
      builder: (_) => _PendingDetailSheet(salesmanName: salesmanName),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _PendingDetailSheet extends StatelessWidget {
  final String salesmanName;
  const _PendingDetailSheet({required this.salesmanName});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecoveryPendingReportProvider>(
      builder: (context, provider, _) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ── Header ──
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
                      child: Text(salesmanName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // ✅ Fix 8: use isDetailLoading not isLoading
              if (provider.isDetailLoading)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))

              // ✅ Fix 9: use detailError not error
              else if (provider.detailError != null &&
                  provider.detailError!.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Text(provider.detailError!,
                        style: const TextStyle(color: Colors.red)),
                  ),
                )

              else if (provider.pendingReportDoc == null ||
                    provider.pendingReportDoc!.data.isEmpty)
                  const Expanded(
                      child: Center(child: Text("No pending invoices found")))

                else ...[
                    // ── Summary ──
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _summaryItem("Invoices",
                              "${provider.pendingReportDoc!.summary.pendingInvoiceCount}"),
                          _summaryItem(
                            "Net Total",
                            "₨ ${NumberFormat('#,##0').format(provider.pendingReportDoc!.summary.totalNetAmount)}",
                          ),
                          _summaryItem(
                            "Paid",
                            "₨ ${NumberFormat('#,##0').format(provider.pendingReportDoc!.summary.totalPaidAmount)}",
                          ),
                          _summaryItem(
                            "Pending",
                            "₨ ${NumberFormat('#,##0').format(provider.pendingReportDoc!.summary.totalPendingAmount)}",
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // ── Invoice List ──
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: provider.pendingReportDoc!.data.length,
                        itemBuilder: (context, index) {
                          final inv = provider.pendingReportDoc!.data[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Invoice No + Type + Date
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(inv.invNo,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary)),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(inv.invoiceType,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.purple[700])),
                                    ),
                                    const Spacer(),
                                    Text(
                                      inv.invoiceDate != null && inv.invoiceDate!.isNotEmpty
                                          ? DateFormat('dd MMM yyyy').format(
                                              DateTime.parse(inv.invoiceDate!))
                                          : "N/A",
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Customer
                                Row(
                                  children: [
                                    Icon(Icons.person_outline,
                                        size: 14, color: Colors.grey[500]),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(inv.customerName,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    if (inv.customerPhone != null)
                                      Text(inv.customerPhone!,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[500])),
                                  ],
                                ),

                                const SizedBox(height: 10),
                                Divider(color: Colors.grey[200], height: 1),
                                const SizedBox(height: 10),

                                // Amounts
                                Row(
                                  children: [
                                    Expanded(child: _amountItem(
                                        "Net Total", inv.netTotal, Colors.blue)),
                                    Expanded(child: _amountItem(
                                        "Paid", inv.paidAmount, Colors.green)),
                                    Expanded(child: _amountItem(
                                        "Pending", inv.pendingAmount, Colors.red)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(title,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _amountItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        const SizedBox(height: 2),
        Text(
          "₨ ${NumberFormat('#,##0').format(value)}",
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}