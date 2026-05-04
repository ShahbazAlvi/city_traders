//
//
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
//
// import '../../../../Provider/CustomerLedgerProvider/LedgerProvider.dart';
// import '../../../../compoents/AppColors.dart';
// import '../../../../compoents/Customerdropdown.dart';
// import '../../../../model/CustomerModel/CustomersDefineModel.dart';
//
// class CustomerLedgerScreen extends StatefulWidget {
//   const CustomerLedgerScreen({super.key});
//
//   @override
//   State<CustomerLedgerScreen> createState() => _CustomerLedgerScreenState();
// }
//
// class _CustomerLedgerScreenState extends State<CustomerLedgerScreen>
//     with SingleTickerProviderStateMixin {
//   CustomerData? selectedCustomer;
//   DateTime? fromDate;
//   DateTime? toDate;
//   late AnimationController _shimmerController;
//
//   final dateFormat = DateFormat("yyyy-MM-dd");
//   final displayDateFormat = DateFormat("dd MMM yyyy");
//
//   /// 🔁 Call API safely
//   void loadLedger() {
//     if (selectedCustomer == null || fromDate == null || toDate == null) return;
//
//     context.read<CustomerLedgerProvider>().getLedger(
//       customerId: selectedCustomer!.id.toString(),
//       fromDate: dateFormat.format(fromDate!),
//       toDate: dateFormat.format(toDate!),
//     );
//   }
//
//   Future<void> pickFromDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: fromDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.primary,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: Color(0xFF1E293B),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (date != null) {
//       setState(() => fromDate = date);
//       loadLedger();
//     }
//   }
//
//   Future<void> pickToDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: toDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.primary,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: Color(0xFF1E293B),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (date != null) {
//       setState(() => toDate = date);
//       loadLedger();
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _shimmerController = AnimationController.unbounded(vsync: this)
//       ..repeat(min: 0, max: 1, period: const Duration(milliseconds: 1500));
//   }
//
//   @override
//   void dispose() {
//     _shimmerController.dispose();
//     super.dispose();
//   }
//
//   // Shimmer effect builder
//   Widget _buildShimmerEffect({required Widget child}) {
//     return ShaderMask(
//       shaderCallback: (bounds) {
//         return LinearGradient(
//           colors: const [
//             Color(0xFFE0E0E0),
//             Color(0xFFF5F5F5),
//             Color(0xFFE0E0E0),
//           ],
//           stops: const [0.0, 0.5, 1.0],
//           begin: Alignment(-1.0, -0.5),
//           end: Alignment(1.0, 0.5),
//           transform: GradientRotation(_shimmerController.value * 2 * 3.14159),
//         ).createShader(bounds);
//       },
//       blendMode: BlendMode.srcATop,
//       child: child,
//     );
//   }
//
//   // Shimmer loading for ledger items
//   Widget _buildShimmerLoading() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: 5,
//       itemBuilder: (context, index) {
//         return Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       width: 150,
//                       height: 16,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       width: double.infinity,
//                       height: 12,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Container(
//                           width: 60,
//                           height: 12,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[300],
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Container(
//                           width: 60,
//                           height: 12,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[300],
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<CustomerLedgerProvider>();
//
//     double totalCredit = 0;
//     double totalDebit = 0;
//
//     if (provider.ledgerData != null) {
//       for (var item in provider.ledgerData!.data.entries) {
//         totalCredit += item.credit;
//         totalDebit += item.debit;
//       }
//     }
//
//     final netBalance = totalDebit - totalCredit;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         foregroundColor: Colors.white,
//         title: const Text(
//           "Customer Ledger",
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.5,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [AppColors.secondary, AppColors.primary],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         actions: [
//           if (selectedCustomer != null && fromDate != null && toDate != null)
//             IconButton(
//               icon: const Icon(Icons.refresh, color: Colors.white),
//               onPressed: loadLedger,
//             ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Filter Section
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 // Customer Dropdown with enhanced styling
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: Colors.grey.shade200,
//                       width: 1.5,
//                     ),
//                   ),
//                   child: CustomerDropdown(
//                     selectedCustomerId: selectedCustomer?.id,
//                     onChanged: (customer) {
//                       setState(() => selectedCustomer = customer);
//                       loadLedger();
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // Date Range Selection
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildDatePickerCard(
//                         label: "From Date",
//                         date: fromDate,
//                         icon: Icons.calendar_today_outlined,
//                         onTap: pickFromDate,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: _buildDatePickerCard(
//                         label: "To Date",
//                         date: toDate,
//                         icon: Icons.calendar_month_outlined,
//                         onTap: pickToDate,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           // Summary Card (if data exists)
//           if (provider.ledgerData != null && !provider.isLoading) ...[
//             Container(
//               margin: const EdgeInsets.all(16),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [AppColors.primary, AppColors.secondary],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.primary.withOpacity(0.3),
//                     blurRadius: 20,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _buildSummaryItem(
//                         icon: Icons.arrow_upward,
//                         label: "Total Debit",
//                         value: "Rs:${NumberFormat('#,##,###').format(totalDebit)}",
//                         color: Colors.orange,
//                       ),
//                       _buildSummaryItem(
//                         icon: Icons.arrow_downward,
//                         label: "Total Credit",
//                         value: "Rs:${NumberFormat('#,##,###').format(totalCredit)}",
//                         color: Colors.green,
//                       ),
//                       _buildSummaryItem(
//                         icon: Icons.account_balance_wallet,
//                         label: "Balance",
//                         value: "Rs:${NumberFormat('#,##,###').format(netBalance.abs())}",
//                         color: netBalance >= 0 ? Colors.blue : Colors.red,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           netBalance >= 0 ? Icons.trending_up : Icons.trending_down,
//                           color: Colors.white,
//                           size: 16,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           selectedCustomer != null
//                               ? "${selectedCustomer!.name}"
//                               : "Customer Ledger",
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w500,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//
//           // Ledger Entries
//           Expanded(
//             child: provider.isLoading
//                 ? _buildShimmerEffect(child: _buildShimmerLoading())
//                 : provider.error != null
//                 ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.error_outline,
//                     size: 60,
//                     color: Colors.red.shade300,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     "Error Loading Data",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     provider.error!,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade500,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//                 : provider.ledgerData == null
//                 ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(30),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.receipt_outlined,
//                       size: 60,
//                       color: Colors.grey.shade400,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     "No Ledger Data",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     "Select a customer and date range\nto view ledger entries",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade500,
//                       height: 1.5,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//                 : Column(
//               children: [
//                 // Results count
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16, vertical: 8),
//                   child: Row(
//                     children: [
//                       Text(
//                         "${provider.ledgerData!.data.entries.length} transactions found",
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey[600],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // List of transactions
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount:
//                     provider.ledgerData!.data.entries.length,
//                     itemBuilder: (context, index) {
//                       final item = provider
//                           .ledgerData!.data.entries[index];
//
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.08),
//                               blurRadius: 10,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Material(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                               children: [
//                                 // Document Number and Date
//                                 Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment
//                                       .spaceBetween,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Container(
//                                           padding:
//                                           const EdgeInsets.all(
//                                               8),
//                                           decoration:
//                                           BoxDecoration(
//                                             color: AppColors
//                                                 .primary
//                                                 .withOpacity(0.1),
//                                             borderRadius:
//                                             BorderRadius
//                                                 .circular(10),
//                                           ),
//                                           child: const Icon(
//                                             Icons.receipt_outlined,
//                                             color:
//                                             AppColors.primary,
//                                             size: 16,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 10),
//                                         Text(
//                                           item.docNo,
//                                           style: const TextStyle(
//                                             fontWeight:
//                                             FontWeight.w600,
//                                             fontSize: 15,
//                                             color:
//                                             Color(0xFF1E293B),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Container(
//                                       padding: const EdgeInsets
//                                           .symmetric(
//                                         horizontal: 10,
//                                         vertical: 5,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: Colors.grey
//                                             .withOpacity(0.1),
//                                         borderRadius:
//                                         BorderRadius.circular(
//                                             20),
//                                       ),
//                                       child: Text(
//                                         displayDateFormat
//                                             .format(item.date),
//                                         style: TextStyle(
//                                           fontSize: 11,
//                                           color: Colors.grey[600],
//                                           fontWeight:
//                                           FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//
//                                 const SizedBox(height: 12),
//
//                                 // Narration
//                                 if (item.narration.isNotEmpty)
//                                   Container(
//                                     padding:
//                                     const EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey.shade50,
//                                       borderRadius:
//                                       BorderRadius.circular(
//                                           12),
//                                     ),
//                                     child: Text(
//                                       item.narration,
//                                       style: TextStyle(
//                                         fontSize: 13,
//                                         color: Colors.grey[700],
//                                         height: 1.4,
//                                       ),
//                                     ),
//                                   ),
//
//                                 const SizedBox(height: 12),
//
//                                 // Debit/Credit/Balance Row
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: _buildAmountChip(
//                                         label: "Debit",
//                                         amount: item.debit,
//                                         color: Colors.red,
//                                         icon: Icons.trending_up,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: _buildAmountChip(
//                                         label: "Credit",
//                                         amount: item.credit,
//                                         color: Colors.green,
//                                         icon: Icons.trending_down,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: _buildAmountChip(
//                                         label: "Balance",
//                                         amount: item.balance,
//                                         color: Colors.orange,
//                                         icon: Icons.account_balance_wallet_outlined,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDatePickerCard({
//     required String label,
//     required DateTime? date,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: Colors.grey.shade200,
//               width: 1.5,
//             ),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: AppColors.primary,
//                   size: 18,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       label,
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       date != null ? displayDateFormat.format(date) : "Select",
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight:
//                         date != null ? FontWeight.w600 : FontWeight.w400,
//                         color: date != null
//                             ? const Color(0xFF1E293B)
//                             : Colors.grey[500],
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSummaryItem({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//   }) {
//     return Expanded(
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(
//               icon,
//               color: Colors.white,
//               size: 16,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 15,
//               fontWeight: FontWeight.bold,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.8),
//               fontSize: 10,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAmountChip({
//     required String label,
//     required double amount,
//     required Color color,
//     required IconData icon,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: color.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 12,
//                 color: color,
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: color.withOpacity(0.7),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             "${NumberFormat('#,##,###').format(amount)}",
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../Provider/CustomerLedgerProvider/LedgerProvider.dart';
import '../../../../compoents/AppColors.dart';
import '../../../../compoents/Customerdropdown.dart';
import '../../../../model/CustomerModel/CustomersDefineModel.dart';
import '../../../../utils/access_control.dart';
import '../../../../utils/access_control.dart';

class CustomerLedgerScreen extends StatefulWidget {
  const CustomerLedgerScreen({super.key});

  @override
  State<CustomerLedgerScreen> createState() => _CustomerLedgerScreenState();
}

class _CustomerLedgerScreenState extends State<CustomerLedgerScreen>
    with SingleTickerProviderStateMixin {
  CustomerData? selectedCustomer;
  DateTime? fromDate;
  DateTime? toDate;
  late AnimationController _shimmerController;
  bool isAdmin = true;
  int? salesmanId;

  final dateFormat = DateFormat("yyyy-MM-dd");
  final displayDateFormat = DateFormat("dd MMM yyyy");

  /// 🔁 Call API safely
  void loadLedger() {
    if (selectedCustomer == null || fromDate == null || toDate == null) return;

    context.read<CustomerLedgerProvider>().getLedger(
      customerId: selectedCustomer!.id.toString(),
      fromDate: dateFormat.format(fromDate!),
      toDate: dateFormat.format(toDate!),
    );
  }

  Future<void> pickFromDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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

    if (date != null) {
      setState(() => fromDate = date);
      loadLedger();
    }
  }

  Future<void> pickToDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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

    if (date != null) {
      setState(() => toDate = date);
      loadLedger();
    }
  }

  @override
  void initState() {
    super.initState();
    fromDate = DateTime.now();
    toDate = DateTime.now();
    _checkRole();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: 0, max: 1, period: const Duration(milliseconds: 1500));
  }

  Future<void> _checkRole() async {
    final sId = await AccessControl.getSalesmanId();
    final admin = await AccessControl.isAdmin();
    setState(() {
      isAdmin = admin;
      salesmanId = sId;
    });
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

  // Shimmer loading for ledger items
  Widget _buildShimmerLoading() {
    return Column(
      children: List.generate(5, (index) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
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
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 60,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerLedgerProvider>();

    double totalCredit = 0;
    double totalDebit = 0;

    if (provider.ledgerData != null) {
      for (var item in provider.ledgerData!.data.entries) {
        totalCredit += item.credit;
        totalDebit += item.debit;
      }
    }

    final netBalance = totalDebit - totalCredit;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          "Customer Ledger",
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
          if (selectedCustomer != null && fromDate != null && toDate != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: loadLedger,
            ),
        ],
      ),
      // ✅ Entire body is now scrollable via CustomScrollView
      body: CustomScrollView(
        slivers: [
          // ── Filter Section ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
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
                  // Customer Dropdown
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: CustomerDropdown(
                      selectedCustomerId: selectedCustomer?.id,
                      salesmanId: salesmanId,
                      onChanged: (customer) {
                        setState(() => selectedCustomer = customer);
                        loadLedger();
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Date Range Selection
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePickerCard(
                          label: "From Date",
                          date: fromDate,
                          icon: Icons.calendar_today_outlined,
                          onTap: pickFromDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDatePickerCard(
                          label: "To Date",
                          date: toDate,
                          icon: Icons.calendar_month_outlined,
                          onTap: pickToDate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Summary Card ─────────────────────────────────────────────
          if (provider.ledgerData != null && !provider.isLoading)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem(
                          icon: Icons.arrow_upward,
                          label: "Total Debit",
                          value:
                          "Rs:${NumberFormat('#,##,###').format(totalDebit)}",
                          color: Colors.orange,
                        ),
                        _buildSummaryItem(
                          icon: Icons.arrow_downward,
                          label: "Total Credit",
                          value:
                          "Rs:${NumberFormat('#,##,###').format(totalCredit)}",
                          color: Colors.green,
                        ),
                        _buildSummaryItem(
                          icon: Icons.account_balance_wallet,
                          label: "Balance",
                          value:
                          "Rs:${NumberFormat('#,##,###').format(netBalance.abs())}",
                          color: netBalance >= 0 ? Colors.blue : Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            netBalance >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selectedCustomer != null
                                ? "${selectedCustomer!.name}"
                                : "Customer Ledger",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Loading shimmer ───────────────────────────────────────────
          if (provider.isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildShimmerEffect(child: _buildShimmerLoading()),
              ),
            ),

          // ── Error state ───────────────────────────────────────────────
          if (!provider.isLoading && provider.error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 60, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      "Error Loading Data",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),

          // ── Empty state ───────────────────────────────────────────────
          if (!provider.isLoading &&
              provider.error == null &&
              provider.ledgerData == null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.receipt_outlined,
                          size: 60, color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "No Ledger Data",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Select a customer and date range\nto view ledger entries",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Results count ─────────────────────────────────────────────
          if (!provider.isLoading &&
              provider.error == null &&
              provider.ledgerData != null)
            SliverToBoxAdapter(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "${provider.ledgerData!.data.entries.length} transactions found",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // ── Transaction list ──────────────────────────────────────────
          if (!provider.isLoading &&
              provider.error == null &&
              provider.ledgerData != null)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final item =
                    provider.ledgerData!.data.entries[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Document Number and Date
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
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
                                        child: const Icon(
                                          Icons.receipt_outlined,
                                          color: AppColors.primary,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        item.docNo,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color:
                                      Colors.grey.withOpacity(0.1),
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      displayDateFormat
                                          .format(item.date),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Narration
                              if (item.narration.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item.narration,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                      height: 1.4,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 12),

                              // Debit / Credit / Balance Row
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildAmountChip(
                                      label: "Debit",
                                      amount: item.debit,
                                      color: Colors.red,
                                      icon: Icons.trending_up,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildAmountChip(
                                      label: "Credit",
                                      amount: item.credit,
                                      color: Colors.green,
                                      icon: Icons.trending_down,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildAmountChip(
                                      label: "Balance",
                                      amount: item.balance,
                                      color: Colors.orange,
                                      icon: Icons
                                          .account_balance_wallet_outlined,
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
                  childCount:
                  provider.ledgerData!.data.entries.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDatePickerCard({
    required String label,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date != null
                          ? displayDateFormat.format(date)
                          : "Select",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: date != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: date != null
                            ? const Color(0xFF1E293B)
                            : Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountChip({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Rs:${NumberFormat('#,##,###').format(amount)}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}