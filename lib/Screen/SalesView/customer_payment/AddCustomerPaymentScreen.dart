//
//
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shimmer/shimmer.dart'; // Add this to pubspec.yaml
//
// import '../../../Provider/BankProvider/BankListProvider.dart';
// import '../../../Provider/customer_Payment/customer_payment_provider.dart';
// import '../../../compoents/AppColors.dart';
// import '../../../compoents/BankDropDown.dart';
// import '../../../compoents/Customerdropdown.dart';
// import '../../../model/BankModel/BankListModel.dart';
// import '../../../model/CustomerModel/CustomersDefineModel.dart';
// import '../../../model/customer_payment_model/InvoicePaymentModel.dart';
//
// class AddCustomerPaymentScreen extends StatefulWidget {
//   final String paymentNo;
//   const AddCustomerPaymentScreen({super.key, required this.paymentNo});
//
//   @override
//   State<AddCustomerPaymentScreen> createState() => _AddCustomerPaymentScreenState();
// }
//
// class _AddCustomerPaymentScreenState extends State<AddCustomerPaymentScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   BankData? selectedBank;
//   String paymentMode = "CASH";
//   String searchQuery = '';
//   CustomerData? selectedCustomer;
//   String selectedStatus = "DRAFT";
//   CustomerInvoice? selectedInvoice;
//
//   final TextEditingController invoiceAmountController = TextEditingController();
//   final TextEditingController paymentController = TextEditingController();
//   final TextEditingController balanceController = TextEditingController();
//
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//
//   final List<String> orderStatusList = [
//     "DRAFT",
//     "POSTED",
//     "CANCELLED",
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _animationController.forward();
//
//     Future.microtask(() {
//       context.read<BankProvider>().fetchBanks();
//     });
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _searchController.dispose();
//     invoiceAmountController.dispose();
//     paymentController.dispose();
//     balanceController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: _buildAppBar(),
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildPaymentHeader(),
//               const SizedBox(height: 24),
//
//               // Customer Information Card
//               _buildGlassCard(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildSectionTitle('Customer Information', Icons.person_outline),
//                     const SizedBox(height: 16),
//                     _buildCustomerField(),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // Order Status Card
//               _buildGlassCard(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildSectionTitle('Order Status', Icons.info_outline),
//                     const SizedBox(height: 16),
//                     _buildStatusField(),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // Invoice Selection Card
//               _buildGlassCard(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildSectionTitle('Invoice Details', Icons.receipt_outlined),
//                     const SizedBox(height: 16),
//                     _buildInvoiceField(),
//                     const SizedBox(height: 16),
//                     _buildInvoiceAmountField(),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // Payment Details Card
//               _buildGlassCard(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildSectionTitle('Payment Details', Icons.payment_outlined),
//                     const SizedBox(height: 16),
//                     _buildPaymentModeField(),
//                     if (paymentMode == "BANK") ...[
//                       const SizedBox(height: 16),
//                       _buildBankField(),
//                     ],
//                     const SizedBox(height: 16),
//                     _buildPaymentField(),
//                     const SizedBox(height: 16),
//                     _buildBalanceField(),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 30),
//
//               // Submit Button
//               _buildSubmitButton(),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Modern App Bar with Gradient
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       flexibleSpace: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [AppColors.primary, AppColors.secondary],
//           ),
//           borderRadius: const BorderRadius.only(
//             bottomLeft: Radius.circular(30),
//             bottomRight: Radius.circular(30),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.primary.withOpacity(0.3),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//       ),
//       title: const Text(
//         "Customer Payments",
//         style: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 20,
//           letterSpacing: 0.5,
//         ),
//       ),
//       centerTitle: true,
//       leading: IconButton(
//         icon: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
//         ),
//         onPressed: () => Navigator.pop(context),
//       ),
//       actions: [
//         Container(
//           margin: const EdgeInsets.only(right: 16),
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
//         ),
//       ],
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(80),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Container(
//             height: 50,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: TextField(
//               controller: _searchController,
//               onChanged: (value) => setState(() => searchQuery = value),
//               decoration: InputDecoration(
//                 hintText: "Search payments...",
//                 hintStyle: TextStyle(color: Colors.grey.shade400),
//                 prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(vertical: 15),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Payment Header with Payment Number
//   Widget _buildPaymentHeader() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.5)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 28),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Payment #${widget.paymentNo}",
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "Create new customer payment",
//                   style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//           _buildStatusChip(selectedStatus),
//         ],
//       ),
//     );
//   }
//
//   // Modern Glass Card Effect
//   Widget _buildGlassCard({required Widget child}) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 2,
//             blurRadius: 20,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
//
//   // Enhanced Section Title
//   Widget _buildSectionTitle(String title, IconData icon) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: AppColors.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: AppColors.primary, size: 20),
//         ),
//         const SizedBox(width: 12),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 0.3,
//           ),
//         ),
//       ],
//     );
//   }
//
//   // Modern Customer Field
//   Widget _buildCustomerField() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: CustomerDropdown(
//         selectedCustomerId: selectedCustomer?.id,
//         onChanged: (customer) {
//           setState(() {
//             selectedCustomer = customer;
//             selectedInvoice = null;
//             invoiceAmountController.clear();
//             paymentController.clear();
//             balanceController.clear();
//           });
//           if (customer != null) {
//             context.read<CustomerPaymentProvider>()
//                 .fetchCustomerInvoices(customer.id);
//           }
//         },
//       ),
//     );
//   }
//
//   // Enhanced Status Field with Modern Design
//   Widget _buildStatusField() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: selectedStatus,
//           isExpanded: true,
//           icon: Container(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
//           ),
//           items: orderStatusList.map((status) {
//             return DropdownMenuItem(
//               value: status,
//               child: Row(
//                 children: [
//                   Container(
//                     width: 10,
//                     height: 10,
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(status),
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: _getStatusColor(status).withOpacity(0.3),
//                           blurRadius: 4,
//                           spreadRadius: 1,
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Text(
//                     status,
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w500,
//                       color: _getStatusColor(status),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//           onChanged: (value) {
//             setState(() => selectedStatus = value!);
//           },
//         ),
//       ),
//     );
//   }
//
//   // Enhanced Invoice Field with Shimmer
//   Widget _buildInvoiceField() {
//     final provider = context.watch<CustomerPaymentProvider>();
//
//     return provider.invoiceLoading
//         ? _buildShimmerInvoice()
//         : Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<CustomerInvoice>(
//           hint: Row(
//             children: [
//               Icon(Icons.receipt_rounded, color: Colors.grey.shade400, size: 20),
//               const SizedBox(width: 12),
//               Text(
//                 "Select Invoice",
//                 style: TextStyle(color: Colors.grey.shade600),
//               ),
//             ],
//           ),
//           value: selectedInvoice,
//           isExpanded: true,
//           icon: Container(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
//           ),
//           items: provider.customerInvoices.map((inv) {
//             return DropdownMenuItem(
//               value: inv,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             inv.invNo,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColors.primary.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         "Rs ${inv.netTotal.toStringAsFixed(0)}",
//                         style: TextStyle(
//                           color: AppColors.primary,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//           onChanged: (invoice) {
//             setState(() {
//               selectedInvoice = invoice;
//               invoiceAmountController.text =
//                   invoice!.netTotal.toStringAsFixed(0);
//               paymentController.clear();
//               balanceController.text =
//                   invoice.netTotal.toStringAsFixed(0);
//             });
//           },
//         ),
//       ),
//     );
//   }
//
//   // Shimmer Effect for Invoice Loading
//   Widget _buildShimmerInvoice() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey.shade300,
//       highlightColor: Colors.grey.shade100,
//       child: Container(
//         height: 60,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),
//     );
//   }
//
//   // Modern Payment Field
//   Widget _buildPaymentField() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: Colors.grey.shade50,
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: TextField(
//         controller: paymentController,
//         keyboardType: TextInputType.number,
//         onChanged: (_) => _calculateBalance(),
//         style: const TextStyle(fontSize: 16),
//         decoration: InputDecoration(
//           labelText: "Payment Amount",
//           labelStyle: TextStyle(color: Colors.grey.shade600),
//           prefixIcon: Icon(Icons.payments_rounded, color: AppColors.primary),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.transparent,
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         ),
//       ),
//     );
//   }
//
//   // Modern Invoice Amount Field
//   Widget _buildInvoiceAmountField() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: Colors.grey.shade100,
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: TextField(
//         controller: invoiceAmountController,
//         readOnly: true,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: Colors.black87,
//         ),
//         decoration: InputDecoration(
//           labelText: "Invoice Amount",
//           labelStyle: TextStyle(color: Colors.grey.shade600),
//           prefixIcon: Icon(Icons.receipt_rounded, color: Colors.grey.shade500),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.transparent,
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         ),
//       ),
//     );
//   }
//
//   // Modern Balance Field
//   Widget _buildBalanceField() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: LinearGradient(
//           colors: [AppColors.primary.withOpacity(0.05), AppColors.secondary.withOpacity(0.05)],
//         ),
//         border: Border.all(color: AppColors.primary.withOpacity(0.2)),
//       ),
//       child: TextField(
//         controller: balanceController,
//         readOnly: true,
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: AppColors.primary,
//         ),
//         decoration: InputDecoration(
//           labelText: "Balance",
//           labelStyle: TextStyle(color: AppColors.primary),
//           prefixIcon: Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.transparent,
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         ),
//       ),
//     );
//   }
//
//   // Modern Payment Mode Field
//   Widget _buildPaymentModeField() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: paymentMode,
//           isExpanded: true,
//           icon: Container(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
//           ),
//           items: const [
//             DropdownMenuItem(
//               value: "CASH",
//               child: Row(
//                 children: [
//                   Icon(Icons.money_rounded, color: Colors.green, size: 20),
//                   SizedBox(width: 12),
//                   Text("Cash", style: TextStyle(fontSize: 15)),
//                 ],
//               ),
//             ),
//             DropdownMenuItem(
//               value: "BANK",
//               child: Row(
//                 children: [
//                   Icon(Icons.account_balance_rounded, color: Colors.blue, size: 20),
//                   SizedBox(width: 12),
//                   Text("Bank", style: TextStyle(fontSize: 15)),
//                 ],
//               ),
//             ),
//           ],
//           onChanged: (value) {
//             setState(() {
//               paymentMode = value!;
//               selectedBank = null;
//             });
//           },
//         ),
//       ),
//     );
//   }
//
//   // Modern Bank Field
//   Widget _buildBankField() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: BankDropdown(
//         selectedBank: selectedBank,
//         onChanged: (bank) {
//           setState(() => selectedBank = bank);
//         },
//       ),
//     );
//   }
//
//   // Enhanced Submit Button
//   Widget _buildSubmitButton() {
//     final provider = context.watch<CustomerPaymentProvider>();
//
//     return SizedBox(
//       width: double.infinity,
//       height: 56,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primary,
//           foregroundColor: Colors.white,
//           elevation: 5,
//           shadowColor: AppColors.primary.withOpacity(0.5),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//         ),
//         onPressed: provider.isLoading ? null : _submitPayment,
//         child: provider.isLoading
//             ? const CircularProgressIndicator(color: Colors.white)
//             : Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             Icon(Icons.save_rounded),
//             SizedBox(width: 12),
//             Text(
//               "Save Payment",
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Status Chip Widget
//   Widget _buildStatusChip(String status) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: _getStatusColor(status).withOpacity(0.1),
//         borderRadius: BorderRadius.circular(30),
//         border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(
//               color: _getStatusColor(status),
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             status,
//             style: TextStyle(
//               color: _getStatusColor(status),
//               fontWeight: FontWeight.w600,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper Methods (unchanged functionality)
//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'POSTED':
//         return Colors.green;
//       case 'CANCELLED':
//         return Colors.red;
//       case 'DRAFT':
//       default:
//         return Colors.orange;
//     }
//   }
//
//   void _calculateBalance() {
//     final invoiceAmount = double.tryParse(invoiceAmountController.text) ?? 0;
//     final payment = double.tryParse(paymentController.text) ?? 0;
//     final balance = invoiceAmount - payment;
//     balanceController.text = balance.toStringAsFixed(0);
//   }
//
//   Future<void> _submitPayment() async {
//     if (selectedCustomer == null) {
//       _showMsg("Please select customer");
//       return;
//     }
//
//     if (selectedInvoice == null) {
//       _showMsg("Please select invoice");
//       return;
//     }
//
//     if (paymentMode == "BANK" && selectedBank == null) {
//       _showMsg("Please select bank");
//       return;
//     }
//
//     final paymentAmount = double.tryParse(paymentController.text.trim()) ?? 0;
//
//     if (paymentAmount <= 0) {
//       _showMsg("Enter valid payment amount");
//       return;
//     }
//
//     final provider = context.read<CustomerPaymentProvider>();
//
//     final success = await provider.submitCustomerPayment(
//       paymentNo: widget.paymentNo,
//       paymentDate: DateTime.now().toString().split(" ").first,
//       customerId: selectedCustomer!.id,
//       invoice: selectedInvoice!,
//       paymentAmount: paymentAmount,
//       status: selectedStatus,
//       paymentMode: paymentMode,
//       bankId: selectedBank?.id,
//     );
//
//     if (!mounted) return;
//
//     if (success) {
//       _showMsg("Payment saved successfully ✅");
//       Navigator.pop(context, true);
//     } else {
//       _showMsg(provider.error.isEmpty ? "Payment failed ❌" : provider.error);
//     }
//   }
//
//   void _showMsg(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
// }

// screens/CustomerPayment/AddCustomerPaymentScreen.dart


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../Provider/BankProvider/BankListProvider.dart';
import '../../../Provider/customer_Payment/customer_payment_provider.dart';
import '../../../compoents/AppColors.dart';
import '../../../compoents/BankDropDown.dart';
import '../../../compoents/Customerdropdown.dart';
import '../../../model/BankModel/BankListModel.dart';
import '../../../model/CustomerModel/CustomersDefineModel.dart';
import '../../../model/customer_payment_model/InvoicePaymentModel.dart';

class AddCustomerPaymentScreen extends StatefulWidget {
  final String paymentNo;
  const AddCustomerPaymentScreen({super.key, required this.paymentNo});

  @override
  State<AddCustomerPaymentScreen> createState() =>
      _AddCustomerPaymentScreenState();
}

class _AddCustomerPaymentScreenState extends State<AddCustomerPaymentScreen>
    with SingleTickerProviderStateMixin {
  BankData? selectedBank;
  String paymentMode = "CASH";
  CustomerData? selectedCustomer;
  String selectedStatus = "POSTED";
  CustomerInvoice? selectedInvoice;

  final TextEditingController invoiceAmountController =
  TextEditingController();
  final TextEditingController paymentController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> orderStatusList = ["DRAFT", "POSTED", "CANCELLED"];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
    Future.microtask(() => context.read<BankProvider>().fetchBanks());
  }

  @override
  void dispose() {
    _animationController.dispose();
    invoiceAmountController.dispose();
    paymentController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _calculateBalance() {
    final invoiceAmount =
        double.tryParse(invoiceAmountController.text) ?? 0;
    final payment = double.tryParse(paymentController.text) ?? 0;
    balanceController.text = (invoiceAmount - payment).toStringAsFixed(0);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'POSTED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPaymentHeader(),
              const SizedBox(height: 24),

              // ── Customer ────────────────────────────────────────
              _buildGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                        'Customer Information', Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildCustomerField(),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Status ──────────────────────────────────────────
              _buildGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                        'Order Status', Icons.info_outline),
                    const SizedBox(height: 16),
                    _buildStatusField(),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Invoice + Aging ─────────────────────────────────
              _buildGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                        'Invoice Details', Icons.receipt_outlined),
                    const SizedBox(height: 16),
                    _buildInvoiceField(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildInvoiceAmountField()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildBalanceField()),
                      ],
                    ),
                    // ✅ Aging shown when customer is selected
                    if (selectedCustomer != null) ...[
                      const SizedBox(height: 16),
                      _buildAgingCard(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Payment Details ─────────────────────────────────
              _buildGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                        'Payment Details', Icons.payment_outlined),
                    const SizedBox(height: 16),
                    _buildPaymentModeToggle(),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          SizeTransition(
                            sizeFactor: animation,
                            child: FadeTransition(
                                opacity: animation, child: child),
                          ),
                      child: paymentMode == "BANK"
                          ? Column(
                        key: const ValueKey("bank"),
                        children: [
                          _buildBankField(),
                          const SizedBox(height: 16),
                        ],
                      )
                          : const SizedBox.shrink(
                          key: ValueKey("no_bank")),
                    ),
                    _buildPaymentField(),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Aging Card (uses CustomerData) ────────────────────────────────────────

  Widget _buildAgingCard() {
    final agingDays = selectedCustomer!.agingDays ?? 30;
    final creditLimit =
        double.tryParse(selectedCustomer!.creditLimit) ?? 0;
    final openingBalance =
        double.tryParse(selectedCustomer!.openingBalance) ?? 0;

    final Color agingColor = agingDays <= 15
        ? Colors.green
        : agingDays <= 30
        ? Colors.orange
        : agingDays <= 60
        ? Colors.deepOrange
        : Colors.red;

    final String agingLabel = agingDays <= 15
        ? "Low Risk"
        : agingDays <= 30
        ? "Moderate"
        : agingDays <= 60
        ? "High Risk"
        : "Critical";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: agingColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: agingColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: agingColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.access_time_rounded,
                    color: agingColor, size: 18),
              ),
              const SizedBox(width: 10),
              const Text("Customer Aging",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1E293B))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: agingColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(agingLabel,
                    style: TextStyle(
                        color: agingColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 1
          Row(
            children: [
              Expanded(
                child: _buildAgingStat(
                  label: "Aging Days",
                  value: "$agingDays days",
                  icon: Icons.hourglass_bottom_rounded,
                  color: agingColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAgingStat(
                  label: "Credit Limit",
                  value: "Rs ${creditLimit.toStringAsFixed(0)}",
                  icon: Icons.credit_card_outlined,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2
          Row(
            children: [
              Expanded(
                child: _buildAgingStat(
                  label: "Opening Balance",
                  value: "Rs ${openingBalance.toStringAsFixed(0)}",
                  icon: Icons.account_balance_wallet_outlined,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAgingStat(
                  label: "Invoice Amount",
                  value: selectedInvoice != null
                      ? "Rs ${selectedInvoice!.netTotal.toStringAsFixed(0)}"
                      : "—",
                  icon: Icons.receipt_rounded,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgingStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Payment Mode Toggle ───────────────────────────────────────────────────

  Widget _buildPaymentModeToggle() {
    return Row(
      children: ["CASH", "BANK"].map((mode) {
        final isSelected = paymentMode == mode;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              paymentMode = mode;
              if (mode == "CASH") selectedBank = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(
                  right: mode == "CASH" ? 8 : 0,
                  left: mode == "BANK" ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary])
                    : null,
                color: isSelected ? null : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
                    : [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    mode == "CASH"
                        ? Icons.money_rounded
                        : Icons.account_balance_outlined,
                    color: isSelected
                        ? Colors.white
                        : Colors.grey.shade500,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(mode,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade600)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Reusable Widgets ──────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      title: const Text("Customer Payments",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20)),
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildPaymentHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.primary.withOpacity(0.1),
          AppColors.secondary.withOpacity(0.1)
        ]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.receipt_long_rounded,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Payment #${widget.paymentNo}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Create new customer payment",
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 14)),
              ],
            ),
          ),
          _buildStatusChip(selectedStatus),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3)),
      ],
    );
  }

  Widget _buildCustomerField() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200)),
      child: CustomerDropdown(
        selectedCustomerId: selectedCustomer?.id,
        onChanged: (customer) {
          setState(() {
            selectedCustomer = customer;
            selectedInvoice = null;
            invoiceAmountController.clear();
            paymentController.clear();
            balanceController.clear();
          });
          if (customer != null) {
            context
                .read<CustomerPaymentProvider>()
                .fetchCustomerInvoices(customer.id);
          }
        },
      ),
    );
  }

  Widget _buildStatusField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatus,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary),
          items: orderStatusList.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Row(
                children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Text(status,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(status))),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => selectedStatus = v!),
        ),
      ),
    );
  }

  Widget _buildInvoiceField() {
    final provider = context.watch<CustomerPaymentProvider>();
    return provider.invoiceLoading
        ? _buildShimmer()
        : Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CustomerInvoice>(
          hint: Row(
            children: [
              Icon(Icons.receipt_rounded,
                  color: Colors.grey.shade400, size: 20),
              const SizedBox(width: 12),
              Text("Select Invoice",
                  style:
                  TextStyle(color: Colors.grey.shade600)),
            ],
          ),
          value: selectedInvoice,
          isExpanded: true,
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary),
          ),
          items: provider.customerInvoices.map((inv) {
            return DropdownMenuItem(
              value: inv,
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(inv.invNo,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      Text(inv.sourceTable,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color:
                        AppColors.primary.withOpacity(0.1),
                        borderRadius:
                        BorderRadius.circular(20)),
                    child: Text(
                      "Rs ${inv.netTotal.toStringAsFixed(0)}",
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (invoice) {
            setState(() {
              selectedInvoice = invoice;
              invoiceAmountController.text =
                  invoice!.netTotal.toStringAsFixed(0);
              paymentController.clear();
              balanceController.text =
                  invoice.netTotal.toStringAsFixed(0);
            });
          },
        ),
      ),
    );
  }

  Widget _buildInvoiceAmountField() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300)),
      child: TextField(
        controller: invoiceAmountController,
        readOnly: true,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87),
        decoration: InputDecoration(
          labelText: "Invoice Amount",
          labelStyle:
          TextStyle(color: Colors.grey.shade600, fontSize: 12),
          prefixIcon: Icon(Icons.receipt_rounded,
              color: Colors.grey.shade500, size: 18),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBalanceField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [
          AppColors.primary.withOpacity(0.05),
          AppColors.secondary.withOpacity(0.05)
        ]),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: TextField(
        controller: balanceController,
        readOnly: true,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.primary),
        decoration: InputDecoration(
          labelText: "Balance",
          labelStyle:
          TextStyle(color: AppColors.primary, fontSize: 12),
          prefixIcon: Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.primary,
              size: 18),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPaymentField() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade200)),
      child: TextField(
        controller: paymentController,
        keyboardType: TextInputType.number,
        onChanged: (_) => _calculateBalance(),
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: "Payment Amount",
          labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon:
          Icon(Icons.payments_rounded, color: AppColors.primary),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildBankField() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200)),
      child: BankDropdown(
        selectedBank: selectedBank,
        onChanged: (bank) => setState(() => selectedBank = bank),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: _getStatusColor(status).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(status,
              style: TextStyle(
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
          height: 60,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16))),
    );
  }

  Widget _buildSubmitButton() {
    final provider = context.watch<CustomerPaymentProvider>();
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 5,
          shadowColor: AppColors.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: provider.isLoading ? null : _submitPayment,
        child: provider.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_rounded),
            SizedBox(width: 12),
            Text("Save Payment",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submitPayment() async {
    if (selectedCustomer == null)
      return _showMsg("Please select customer");
    if (selectedInvoice == null)
      return _showMsg("Please select invoice");
    if (paymentMode == "BANK" && selectedBank == null)
      return _showMsg("Please select bank");

    final paymentAmount =
        double.tryParse(paymentController.text.trim()) ?? 0;
    if (paymentAmount <= 0)
      return _showMsg("Enter valid payment amount");

    final provider = context.read<CustomerPaymentProvider>();
    final success = await provider.submitCustomerPayment(
      paymentNo: widget.paymentNo,
      paymentDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      customerId: selectedCustomer!.id,
      invoice: selectedInvoice!,
      paymentAmount: paymentAmount,
      status: selectedStatus,
      paymentMode: paymentMode,
      bankId: paymentMode == "BANK" ? selectedBank?.id : null,
    );

    if (!mounted) return;
    if (success) {
      _showMsg("Payment saved successfully ✅");
      Navigator.pop(context, true);
    } else {
      _showMsg(
          provider.error.isEmpty ? "Payment failed ❌" : provider.error);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
    ));
  }
}