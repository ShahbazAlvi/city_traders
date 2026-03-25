import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../Provider/CreditAgingReportProvider/AgingProvider.dart';
import '../../../../Provider/SaleManProvider/SaleManProvider.dart';
import '../../../../compoents/AppColors.dart';
import '../../../../compoents/SaleManDropdown.dart';

import '../../../../model/CreditAgingReport/AgingReportModel.dart'; // ✅ import your dropdown

class CreditAgingScreen extends StatefulWidget {
  final int? salesmanId;
  final String? salesmanName;

  const CreditAgingScreen({
    super.key,
    this.salesmanId,
    this.salesmanName,
  });

  @override
  State<CreditAgingScreen> createState() => _CreditAgingScreenState();
}

class _CreditAgingScreenState extends State<CreditAgingScreen> {
  final NumberFormat _fmt = NumberFormat('#,##,###');
  DateTime _selectedDate = DateTime.now();
  int? _selectedSalesmanId;
  String? _selectedSalesmanName;

  @override
  void initState() {
    super.initState();
    _selectedSalesmanId = widget.salesmanId;
    _selectedSalesmanName = widget.salesmanName;

    Future.microtask(() {
      // ✅ Fetch salesmen list for dropdown
      Provider.of<SaleManProvider>(context, listen: false)..fetchEmployees();
      // ✅ Fetch report
      _fetchData();
    });
  }

  void _fetchData() {
    Provider.of<CreditAgingProvider>(context, listen: false)
        .fetchCreditAging(
      salesmanId: _selectedSalesmanId,
      asOfDate: _selectedDate.toIso8601String().substring(0, 10),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CreditAgingProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF1A1F2E) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Credit Aging Report",
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
      ),
      body: Column(
        children: [
          _buildFilterBar(isDark),
          Expanded(child: _buildBody(provider, isDark)),
        ],
      ),
    );
  }

  // ── Filter Bar ──────────────────────────────────────────────────
  Widget _buildFilterBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3447) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Title + Refresh ──
          Row(
            children: [
              Icon(Icons.filter_alt_outlined,
                  size: 18,
                  color: isDark ? Colors.white54 : Colors.black45),
              const SizedBox(width: 6),
              Text(
                "Filters",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const Spacer(),
              // Refresh button
              GestureDetector(
                onTap: _fetchData,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.refresh,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        "Refresh",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Row 2: Date Picker ──
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1F2538)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white12
                      : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.calendar_today_outlined,
                        size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "As of Date",
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? Colors.white38
                              : Colors.black45,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy')
                            .format(_selectedDate),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_drop_down,
                      color: isDark
                          ? Colors.white38
                          : Colors.black38),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Row 3: Salesman Dropdown ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 2),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.person_outline,
                          size: 16, color: Colors.indigo[400]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Salesman",
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? Colors.white38
                            : Colors.black45,
                      ),
                    ),
                    const Spacer(),
                    // ✅ "All" chip — tap to clear filter
                    if (_selectedSalesmanId != null)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSalesmanId = null;
                            _selectedSalesmanName = null;
                          });
                          _fetchData();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.close,
                                  size: 12,
                                  color: Colors.red[400]),
                              const SizedBox(width: 3),
                              Text(
                                "Clear",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red[400],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ✅ Your SalesmanDropdown widget
              SalesmanDropdown(
                selectedId: _selectedSalesmanId?.toString(),
                onChanged: (value) {
                  setState(() {
                    if (value == null) {
                      _selectedSalesmanId = null;
                      _selectedSalesmanName = null;
                    } else {
                      _selectedSalesmanId = int.tryParse(value);
                      // Get name from provider
                      final salesmanProvider =
                      Provider.of<SaleManProvider>(
                          context,
                          listen: false);
                      final match =
                      salesmanProvider.employees.where(
                            (e) => e.id.toString() == value,
                      );
                      _selectedSalesmanName = match.isNotEmpty
                          ? match.first.name
                          : null;
                    }
                  });
                  _fetchData(); // ✅ auto fetch on salesman change
                },
              ),

              // ✅ Active filter chip shown below dropdown
              if (_selectedSalesmanId != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 13,
                              color: Colors.indigo[400]),
                          const SizedBox(width: 5),
                          Text(
                            _selectedSalesmanName ??
                                "ID: $_selectedSalesmanId",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.indigo[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              // ✅ "All salesmen" chip when none selected
              if (_selectedSalesmanId == null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline,
                          size: 13, color: Colors.green[600]),
                      const SizedBox(width: 5),
                      Text(
                        "All Salesmen",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────────
  Widget _buildBody(CreditAgingProvider provider, bool isDark) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 60, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(provider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    if (provider.report == null || provider.report!.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined,
                size: 60, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text("No data found",
                style: TextStyle(
                    fontSize: 16, color: Colors.grey[500])),
            const SizedBox(height: 6),
            Text(
              _selectedSalesmanId != null
                  ? "No records for this salesman"
                  : "No records found for selected date",
              style: TextStyle(
                  fontSize: 13, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    return _buildReport(provider, isDark);
  }

  // ── Report ──────────────────────────────────────────────────────
  Widget _buildReport(CreditAgingProvider provider, bool isDark) {
    final totals = provider.report!.totals;
    final rows = provider.report!.data;

    final Map<int, List<CreditAgingData>> grouped = {};
    for (final row in rows) {
      grouped.putIfAbsent(row.customerId, () => []).add(row);
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16),
        //   child: _buildTotalsCard(totals, isDark),
        // ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                "${grouped.length} Customer${grouped.length > 1 ? 's' : ''}",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "• ${rows.length} Invoice${rows.length > 1 ? 's' : ''}",
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _fetchData(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final customerId = grouped.keys.elementAt(index);
                final invoices = grouped[customerId]!;
                final customerName = invoices.first.customerName;
                final custOutstanding = invoices.fold<double>(
                    0, (sum, i) => sum + i.outstanding);
                final custDue = invoices.fold<double>(
                    0, (sum, i) => sum + i.due);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isDark
                        ? const Color(0xFF2D3447)
                        : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      childrenPadding:
                      const EdgeInsets.only(bottom: 8),
                      title: Text(
                        "${index + 1}. $customerName",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            // _miniChip(
                            //   "Outstanding: ${_fmt.format(custOutstanding)}",
                            //   Colors.orange,
                            // ),
                            // _miniChip(
                            //   "Due: ${_fmt.format(custDue)}",
                            //   custDue > 0
                            //       ? Colors.red
                            //       : Colors.green,
                            // ),
                            if (_selectedSalesmanId == null)
                              _miniChip(
                                invoices.first.salesmanName,
                                Colors.indigo,
                              ),
                          ],
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color:
                          AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.expand_more,
                            color: AppColors.primary),
                      ),
                      children: invoices.map<Widget>((inv) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1F2538)
                                : Colors.grey[50],
                            borderRadius:
                            BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white
                                  .withOpacity(0.05)
                                  : Colors.grey
                                  .withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets
                                        .symmetric(
                                        horizontal: 10,
                                        vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withOpacity(0.1),
                                      borderRadius:
                                      BorderRadius.circular(
                                          8),
                                    ),
                                    child: Text(
                                      inv.invoiceNo,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets
                                        .symmetric(
                                        horizontal: 8,
                                        vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.purple
                                          .withOpacity(0.1),
                                      borderRadius:
                                      BorderRadius.circular(
                                          8),
                                    ),
                                    child: Text(
                                      inv.invoiceKind,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.purple[700],
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 13,
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.black38,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        inv.salesmanName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _infoItem(
                                      Icons
                                          .local_shipping_outlined,
                                      "Delivery",
                                      inv.deliveryDate,
                                      isDark,
                                    ),
                                  ),
                                  Expanded(
                                    child: _infoItem(
                                      Icons
                                          .event_available_outlined,
                                      "Due Date",
                                      inv.dueDate,
                                      isDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _infoItem(
                                      Icons.timer_outlined,
                                      "Allow Days",
                                      "${inv.allowDays}d",
                                      isDark,
                                    ),
                                  ),
                                  Expanded(
                                    child: _infoItem(
                                      Icons
                                          .hourglass_bottom_outlined,
                                      "Bill Days",
                                      "${inv.billDays}d",
                                      isDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(
                                color: isDark
                                    ? Colors.white12
                                    : Colors.grey[200],
                                height: 1,
                              ),
                              const SizedBox(height: 12),
                              _amountsGrid(inv, isDark),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── Totals Card ──────────────────────────────────────────────────
  // Widget _buildTotalsCard(Totals totals, bool isDark) {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: isDark
  //             ? [const Color(0xFF2D3447), const Color(0xFF1F2538)]
  //             : [Colors.white, Colors.grey[50]!],
  //       ),
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.04),
  //           blurRadius: 12,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(8),
  //               decoration: BoxDecoration(
  //                 color: AppColors.primary.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               child: Icon(Icons.summarize_outlined,
  //                   color: AppColors.primary, size: 20),
  //             ),
  //             const SizedBox(width: 10),
  //             Expanded(
  //               child: Text(
  //                 "Totals Summary",
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.w700,
  //                   fontSize: 16,
  //                   color: isDark ? Colors.white : Colors.black87,
  //                 ),
  //               ),
  //             ),
  //             Container(
  //               padding: const EdgeInsets.symmetric(
  //                   horizontal: 8, vertical: 4),
  //               decoration: BoxDecoration(
  //                 color: AppColors.primary.withOpacity(0.08),
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Text(
  //                 _selectedSalesmanId != null
  //                     ? (_selectedSalesmanName ??
  //                     "ID: $_selectedSalesmanId")
  //                     : "All Salesmen",
  //                 style: TextStyle(
  //                   fontSize: 11,
  //                   color: AppColors.primary,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 4),
  //         Padding(
  //           padding: const EdgeInsets.only(left: 4),
  //           child: Text(
  //             DateFormat('dd MMM yyyy').format(_selectedDate),
  //             style: TextStyle(
  //               fontSize: 12,
  //               color: isDark ? Colors.white38 : Colors.black45,
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 14),
  //         Row(
  //           children: [
  //             Expanded(
  //                 child: _totalBox(
  //                     "Debit", totals.debit, Colors.blue, isDark)),
  //             const SizedBox(width: 8),
  //             Expanded(
  //                 child: _totalBox("Credit", totals.credit,
  //                     Colors.green, isDark)),
  //             const SizedBox(width: 8),
  //             Expanded(
  //                 child: _totalBox("Outstanding",
  //                     totals.outstanding, Colors.orange, isDark)),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Row(
  //           children: [
  //             Expanded(
  //                 child: _totalBox("Under Credit",
  //                     totals.underCredit, Colors.purple, isDark)),
  //             const SizedBox(width: 8),
  //             Expanded(
  //                 child: _totalBox(
  //                     "Due", totals.due, Colors.red, isDark)),
  //             const SizedBox(width: 8),
  //             const Expanded(child: SizedBox()),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _totalBox(
      String label, int value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color:
                  isDark ? Colors.white54 : Colors.black45)),
          const SizedBox(height: 4),
          Text(
            _fmt.format(value),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountsGrid(CreditAgingData inv, bool isDark) {
    return Row(
      children: [
        Expanded(
            child: _amountItem(
                "Debit", inv.debit, Colors.blue, isDark)),
        Expanded(
            child: _amountItem(
                "Credit", inv.credit, Colors.green, isDark)),
        Expanded(
            child: _amountItem("Outstanding", inv.outstanding,
                Colors.orange, isDark)),
        Expanded(
            child: _amountItem(
                "Due", inv.due, Colors.red, isDark)),
      ],
    );
  }

  Widget _amountItem(
      String label, double value, Color color, bool isDark) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color:
                isDark ? Colors.white38 : Colors.black45)),
        const SizedBox(height: 2),
        Text(
          _fmt.format(value),
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color),
        ),
      ],
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500)),
    );
  }

  Widget _infoItem(
      IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon,
            size: 14,
            color: isDark ? Colors.white38 : Colors.black45),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? Colors.white38
                        : Colors.black45)),
            Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white70
                        : Colors.black87)),
          ],
        ),
      ],
    );
  }
}