//
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../../Provider/DailySaleReport/DailySaleReportProvider.dart';
// import '../../../Provider/SaleManProvider/SaleManProvider.dart';
// import '../../../compoents/AppColors.dart';
// import '../../../compoents/SaleManDropdown.dart';
//
// class DailySaleReportScreen extends StatefulWidget {
//   const DailySaleReportScreen({super.key});
//
//   @override
//   State<DailySaleReportScreen> createState() => _DailySaleReportScreenState();
// }
//
// class _DailySaleReportScreenState extends State<DailySaleReportScreen> {
//   String? selectedSalesmanId;
//   String selectedDate = "";
//
//   @override
//   void initState() {
//     super.initState();
//     // Default date is today
//     final now = DateTime.now();
//     selectedDate = "${now.year}-${now.month}-${now.day}";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<DailySaleReportProvider>(context);
//
//     return ChangeNotifierProvider(
//       create: (_) => SaleManProvider()..fetchEmployees(),
//       child: Scaffold(
//         appBar: AppBar(
//           iconTheme: const IconThemeData(color: Colors.white),
//           title: const Text(
//             "Daily Sales Report",
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 22,
//             ),
//           ),
//           centerTitle: true,
//           elevation: 6,
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [AppColors.secondary, AppColors.primary],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// 🔥 Salesman Dropdown
//               SalesmanDropdown(
//                 selectedId: selectedSalesmanId,
//                 onChanged: (value) {
//                   setState(() => selectedSalesmanId = value);
//
//                   // 🔥 Auto fetch report when salesman selected
//                   if (selectedSalesmanId != null) {
//                     provider.fetchDailyReport(
//                       salesmanId: selectedSalesmanId!,
//                       date: selectedDate,
//                     );
//                   }
//                 },
//                // label: "Select Salesman",
//               ),
//
//               const SizedBox(height: 20),
//
//               /// 🔥 Date Picker
//               Text(
//                 "Select Date",
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               InkWell(
//                 onTap: pickDate,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(width: 1.2),
//                     color: Colors.grey.shade100,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         selectedDate,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const Icon(Icons.calendar_month),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//
//               /// 🔥 Show Loading
//               if (provider.isLoading)
//                 const Center(child: CircularProgressIndicator()),
//
//               /// 🔥 Show Report
//               if (!provider.isLoading && provider.reportData != null)
//                 buildReport(provider),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// 🔥 Date Picker Function
//   Future<void> pickDate() async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       initialDate: DateTime.now(),
//     );
//
//     if (picked != null) {
//       setState(() {
//         selectedDate = "${picked.year}-${picked.month}-${picked.day}";
//
//         // 🔥 If salesman already selected, fetch report immediately
//         final provider =
//         Provider.of<DailySaleReportProvider>(context, listen: false);
//         if (selectedSalesmanId != null) {
//           provider.fetchDailyReport(
//             salesmanId: selectedSalesmanId!,
//             date: selectedDate,
//           );
//         }
//       });
//     }
//   }
//
//   /// 🔥 Report UI
//   Widget buildReport(DailySaleReportProvider provider) {
//     final reportData = provider.reportData!.data;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Salesman: $selectedSalesmanId",
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
//             Text(formatDate(selectedDate),
//                 style: const TextStyle(fontSize: 16)),
//           ],
//         ),
//
//         const SizedBox(height: 20),
//
//         // Product Section
//         const Text("Product Section",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: DataTable(
//             headingRowColor: MaterialStateProperty.all(Colors.green.shade50),
//             columns: const [
//               DataColumn(label: Text("Product")),
//               DataColumn(label: Text("Qty")),
//               DataColumn(label: Text("Purchase")),
//               DataColumn(label: Text("Sale")),
//             ],
//             rows: reportData.salesItems.map((item) {
//               return DataRow(cells: [
//                 DataCell(Text(item.itemName)),
//                 DataCell(Text(item.totalQty.toString())),
//                 DataCell(Text(item.totalAmount.toString())), // or purchaseTotal if available
//                 DataCell(Text(item.totalAmount.toString())),
//               ]);
//             }).toList(),
//           ),
//         ),
//
//         const SizedBox(height: 20),
//
//         // Customer Section
//         const Text("Customer Section",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: DataTable(
//             headingRowColor: MaterialStateProperty.all(Colors.green.shade50),
//             columns: const [
//               DataColumn(label: Text("Customer")),
//               DataColumn(label: Text("Sales")),
//               DataColumn(label: Text("Recovery")),
//               DataColumn(label: Text("Balance")),
//             ],
//             rows: reportData.paymentsReceived.map((item) {
//               return DataRow(cells: [
//                 DataCell(Text(item.customerName)),
//                 DataCell(Text(item.totalInvoiceAmount.toString())),
//                 DataCell(Text(item.totalReceived.toString())),
//                 DataCell(Text(item.balance.toString())),
//               ]);
//             }).toList(),
//           ),
//         ),
//
//         const SizedBox(height: 20),
//
//         // Totals
//         Text("Total Sales: ${reportData.summary.payments.totalInvoiceAmount}",
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         Text("Total Recovery: ${reportData.summary.recoveries.totalRecovered}",
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//       ],
//     );
//   }
//
//   String formatDate(String? date) {
//     if (date == null || date.isEmpty) return "N/A";
//
//     try {
//       DateTime parsed = DateTime.parse(date);
//       return DateFormat('dd-MM-yyyy').format(parsed); // simple date
//     } catch (e) {
//       return date; // fallback if parsing fails
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Provider/DailySaleReport/DailySaleReportProvider.dart';
import '../../../Provider/SaleManProvider/SaleManProvider.dart';
import '../../../compoents/AppColors.dart';
import '../../../compoents/SaleManDropdown.dart';

class DailySaleReportScreen extends StatefulWidget {
  const DailySaleReportScreen({super.key});

  @override
  State<DailySaleReportScreen> createState() => _DailySaleReportScreenState();
}

class _DailySaleReportScreenState extends State<DailySaleReportScreen>
    with SingleTickerProviderStateMixin {
  String? selectedSalesmanId;
  String selectedDate = "";
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    // Default date is today
    final now = DateTime.now();
    selectedDate = "${now.year}-${now.month}-${now.day}";

    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: 0, max: 1, period: const Duration(milliseconds: 1500));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
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

  // Shimmer loading for report
  Widget _buildShimmerLoading() {
    return Column(
      children: [
        // Header shimmer
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
                      width: 150,
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
        ),

        // Table shimmer
        Container(
          height: 200,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: List.generate(4, (index) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            )),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DailySaleReportProvider>(context);

    return ChangeNotifierProvider(
      create: (_) => SaleManProvider()..fetchEmployees(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: const Text(
            "Daily Sales Report",
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
            if (selectedSalesmanId != null)
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  provider.fetchDailyReport(
                    salesmanId: selectedSalesmanId!,
                    date: selectedDate,
                  );
                },
              ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Section Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Filter Report",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Salesman Dropdown
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: SalesmanDropdown(
                        selectedId: selectedSalesmanId,
                        onChanged: (value) {
                          setState(() => selectedSalesmanId = value);
                          if (selectedSalesmanId != null) {
                            provider.fetchDailyReport(
                              salesmanId: selectedSalesmanId!,
                              date: selectedDate,
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Date Picker
                    const Text(
                      "Select Date",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: pickDate,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.calendar_today_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatDate(selectedDate),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Loading State
              if (provider.isLoading)
                _buildShimmerEffect(child: _buildShimmerLoading()),

              // Report Data
              if (!provider.isLoading && provider.reportData != null)
                buildReport(provider),

              // Empty/No Selection State
              if (!provider.isLoading &&
                  provider.reportData == null &&
                  selectedSalesmanId != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.insert_chart_outlined,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "No Data Available",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No sales data found for the selected date",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
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
  }

  /// 🔥 Date Picker Function
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = "${picked.year}-${picked.month}-${picked.day}";
        final provider =
        Provider.of<DailySaleReportProvider>(context, listen: false);
        if (selectedSalesmanId != null) {
          provider.fetchDailyReport(
            salesmanId: selectedSalesmanId!,
            date: selectedDate,
          );
        }
      });
    }
  }

  /// 🔥 Report UI
  Widget buildReport(DailySaleReportProvider provider) {
    final reportData = provider.reportData!.data;
    final dateFormat = DateFormat('dd MMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Card
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      label: "Total Sales",
                      value: "Rs:${NumberFormat('#,##,###').format(reportData.summary.payments.totalInvoiceAmount)}",
                      icon: Icons.shopping_cart_outlined,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      label: "Total Recovery",
                      value: "Rs:${NumberFormat('#,##,###').format(reportData.summary.recoveries.totalRecovered)}",
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Report Date: ${formatDate(selectedDate)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Salesman ID: $selectedSalesmanId",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Product Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Product Sales",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),

        // Product Table
        if (reportData.salesItems.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  AppColors.primary.withOpacity(0.05),
                ),
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontSize: 13,
                ),
                dataTextStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                ),
                columns: const [
                  DataColumn(label: Text("Product")),
                  DataColumn(label: Text("Qty")),
                  DataColumn(label: Text("Purchase")),
                  DataColumn(label: Text("Sale")),
                ],
                rows: reportData.salesItems.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: Text(
                            item.itemName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(item.totalQty.toString())),
                      DataCell(
                        Text(
                          "Rs:${NumberFormat('#,##,###').format(item.totalAmount)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          "Rs:${NumberFormat('#,##,###').format(item.totalAmount)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

        // Customer Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.people_outline,
                  color: Colors.green,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Customer Payments",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),

        // Customer Table
        if (reportData.paymentsReceived.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  Colors.green.withOpacity(0.05),
                ),
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                  fontSize: 13,
                ),
                dataTextStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                ),
                columns: const [
                  DataColumn(label: Text("Customer")),
                  DataColumn(label: Text("Sales")),
                  DataColumn(label: Text("Recovery")),
                  DataColumn(label: Text("Balance")),
                ],
                rows: reportData.paymentsReceived.map((item) {
                  final balance = item.totalInvoiceAmount - item.totalReceived;
                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: Text(
                            item.customerName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          "Rs:${NumberFormat('#,##,###').format(item.totalInvoiceAmount)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          "RS:${NumberFormat('#,##,###').format(item.totalReceived)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          "Rs:${NumberFormat('#,##,###').format(balance)}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: balance > 0 ? Colors.orange : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

        // Summary Section
        if (reportData.salesItems.isNotEmpty || reportData.paymentsReceived.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Sales",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      "Rs:${NumberFormat('#,##,###').format(reportData.summary.payments.totalInvoiceAmount)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Recovery",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      "Rs:${NumberFormat('#,##,###').format(reportData.summary.recoveries.totalRecovered)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Outstanding Balance",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      "Rs:${NumberFormat('#,##,###').format(reportData.summary.payments.totalInvoiceAmount - reportData.summary.recoveries.totalRecovered)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
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
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String formatDate(String date) {
    if (date.isEmpty) return "N/A";
    try {
      DateTime parsed = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (e) {
      return date;
    }
  }
}