//
//
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
//
// import '../../../Provider/OrderTakingProvider/OrderTakingProvider.dart';
// import '../../../compoents/AppColors.dart';
// import '../../../model/OrderTakingModel/OrderTakingModel.dart';
//
// class UpdateOrderScreen extends StatefulWidget {
//   final OrderData order;
//
//   const UpdateOrderScreen({super.key, required this.order});
//
//   @override
//   State<UpdateOrderScreen> createState() => _UpdateOrderScreenState();
// }
//
// class _UpdateOrderScreenState extends State<UpdateOrderScreen> {
//   late TextEditingController soController;
//   late TextEditingController dateController;
//   late TextEditingController statusController;
//
//   int? selectedCustomerId;
//   int? selectedSalesmanId;
//
//   List<Map<String, dynamic>> orderItems = [];
//
//   bool isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     soController = TextEditingController(text: widget.order.soNo);
//     dateController = TextEditingController(
//       text: DateFormat('yyyy-MM-dd').format(widget.order.orderDate),
//     );
//     statusController = TextEditingController(text: widget.order.status);
//
//     selectedCustomerId = widget.order.customerId;
//     selectedSalesmanId = widget.order.salesmanId;
//
//     // Load existing order items (replace with API if needed)
//     orderItems = [
//       {"item_id": 7, "qty": 1, "rate": 100},
//     ];
//   }
//
//   @override
//   void dispose() {
//     soController.dispose();
//     dateController.dispose();
//     statusController.dispose();
//     super.dispose();
//   }
//
//   Future<void> updateOrder() async {
//     setState(() => isLoading = true);
//
//     final url = Uri.parse(
//         "https://api.distribution.afaqmis.com/api/sales-orders/${widget.order.id}");
//
//     final body = {
//       "so_no": soController.text,
//       "customer_id": selectedCustomerId,
//       "salesman_id": selectedSalesmanId,
//       "order_date": dateController.text,
//       "status": statusController.text,
//       "details": orderItems,
//     };
//
//     try {
//       final response = await http.put(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer YOUR_TOKEN_HERE",
//           "x-company-id": "2"
//         },
//         body: jsonEncode(body),
//       );
//
//       print("UPDATE RESPONSE: ${response.body}");
//
//       if (response.statusCode == 200) {
//         if (!mounted) return;
//
//         await Provider.of<OrderTakingProvider>(context, listen: false)
//             .FetchOrderTaking();
//
//         if (!mounted) return;
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: const [
//                 Icon(Icons.check_circle, color: Colors.white, size: 20),
//                 SizedBox(width: 12),
//                 Expanded(child: Text("Order Updated Successfully")),
//               ],
//             ),
//             backgroundColor: Colors.green,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         );
//
//         Navigator.pop(context);
//       } else {
//         throw Exception("Update failed");
//       }
//     } catch (e) {
//       print("ERROR: $e");
//       if (!mounted) return;
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: const [
//               Icon(Icons.error, color: Colors.white, size: 20),
//               SizedBox(width: 12),
//               Expanded(child: Text("Update Failed")),
//             ],
//           ),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       );
//     }
//
//     setState(() => isLoading = false);
//   }
//
//   Future<void> pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: widget.order.orderDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.primary,
//               onPrimary: Colors.white,
//               surface: Colors.white,
//               onSurface: Colors.black,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       setState(() {
//         dateController.text = DateFormat('yyyy-MM-dd').format(picked);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<OrderTakingProvider>(context);
//
//     // Get unique customer and salesman lists
//     final customers = <Map<String, dynamic>>[];
//     final customerIds = <int>{};
//     for (var order in provider.orderData?.data ?? []) {
//       if (!customerIds.contains(order.customerId)) {
//         customerIds.add(order.customerId);
//         customers.add({"id": order.customerId, "name": order.customerName});
//       }
//     }
//
//     final salesmen = <Map<String, dynamic>>[];
//     final salesmanIds = <int>{};
//     for (var order in provider.orderData?.data ?? []) {
//       if (!salesmanIds.contains(order.salesmanId)) {
//         salesmanIds.add(order.salesmanId);
//         salesmen.add({"id": order.salesmanId, "name": order.salesmanName});
//       }
//     }
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: _buildAppBar(),
//       body: isLoading
//           ? _buildLoadingIndicator()
//           : _buildMainContent(customers, salesmen),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       flexibleSpace: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [AppColors.secondary, AppColors.primary],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(30),
//             bottomRight: Radius.circular(30),
//           ),
//         ),
//       ),
//       title: const Text(
//         "Update Order",
//         style: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 22,
//         ),
//       ),
//       centerTitle: true,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//         onPressed: () => Navigator.pop(context),
//       ),
//       actions: [
//         Container(
//           margin: const EdgeInsets.only(right: 16),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: const Icon(
//             Icons.edit_note,
//             color: Colors.white,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLoadingIndicator() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Updating order...',
//             style: TextStyle(
//               color: Colors.grey.shade600,
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMainContent(
//       List<Map<String, dynamic>> customers,
//       List<Map<String, dynamic>> salesmen,
//       ) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Order Info Card
//           _buildOrderInfoCard(),
//           const SizedBox(height: 24),
//
//           // Order Information Section
//           _buildSectionTitle('Order Information'),
//           const SizedBox(height: 16),
//           _buildOrderNumberField(),
//           const SizedBox(height: 16),
//
//           // Customer Section
//           _buildSectionTitle('Customer Details'),
//           const SizedBox(height: 16),
//           _buildCustomerDropdown(customers),
//           const SizedBox(height: 16),
//
//           // Salesman Section
//           _buildSectionTitle('Salesman Details'),
//           const SizedBox(height: 16),
//           _buildSalesmanDropdown(salesmen),
//           const SizedBox(height: 16),
//
//           // Date & Status Section
//           _buildSectionTitle('Order Details'),
//           const SizedBox(height: 16),
//           _buildDateField(),
//           const SizedBox(height: 16),
//           _buildStatusField(),
//           const SizedBox(height: 24),
//
//           // Order Items Section (if any)
//           if (orderItems.isNotEmpty) ...[
//             _buildSectionTitle('Order Items'),
//             const SizedBox(height: 16),
//             _buildOrderItemsList(),
//             const SizedBox(height: 24),
//           ],
//
//           // Update Button
//           _buildUpdateButton(),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOrderInfoCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppColors.primary.withOpacity(0.1),
//             AppColors.secondary.withOpacity(0.1),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: AppColors.primary.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: const Icon(
//               Icons.receipt_long,
//               color: AppColors.primary,
//               size: 28,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Order ID',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   widget.order.soNo ?? 'N/A',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.primary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: _getStatusColor(widget.order.status ?? 'DRAFT').withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(widget.order.status ?? 'DRAFT'),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   widget.order.status ?? 'DRAFT',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     color: _getStatusColor(widget.order.status ?? 'DRAFT'),
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
//   Color _getStatusColor(String status) {
//     switch (status.toUpperCase()) {
//       case 'APPROVED':
//         return Colors.green;
//       case 'CLOSED':
//         return Colors.blue;
//       case 'CANCELLED':
//         return Colors.red;
//       case 'DRAFT':
//       default:
//         return Colors.orange;
//     }
//   }
//
//   Widget _buildSectionTitle(String title) {
//     return Row(
//       children: [
//         Container(
//           width: 4,
//           height: 24,
//           decoration: BoxDecoration(
//             color: AppColors.primary,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildOrderNumberField() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.08),
//             spreadRadius: 1,
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: soController,
//         decoration: InputDecoration(
//           labelText: "Order Number",
//           labelStyle: TextStyle(
//             fontSize: 14,
//             color: Colors.grey.shade600,
//           ),
//           prefixIcon: const Icon(
//             Icons.receipt,
//             color: AppColors.primary,
//             size: 20,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 16,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCustomerDropdown(List<Map<String, dynamic>> customers) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.08),
//             spreadRadius: 1,
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: DropdownButtonFormField<int>(
//         value: selectedCustomerId,
//         items: customers.map((customer) {
//           return DropdownMenuItem(
//             value: customer["id"] as int,
//             child: Text(
//               customer["name"] as String,
//               style: const TextStyle(fontSize: 15),
//             ),
//           );
//         }).toList(),
//         onChanged: (value) {
//           setState(() => selectedCustomerId = value);
//         },
//         decoration: InputDecoration(
//           labelText: "Select Customer",
//           labelStyle: TextStyle(
//             fontSize: 14,
//             color: Colors.grey.shade600,
//           ),
//           prefixIcon: const Icon(
//             Icons.business,
//             color: AppColors.primary,
//             size: 20,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 16,
//           ),
//         ),
//         icon: Icon(
//           Icons.keyboard_arrow_down,
//           color: AppColors.primary,
//         ),
//         dropdownColor: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//     );
//   }
//
//   Widget _buildSalesmanDropdown(List<Map<String, dynamic>> salesmen) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.08),
//             spreadRadius: 1,
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: DropdownButtonFormField<int>(
//         value: selectedSalesmanId,
//         items: salesmen.map((salesman) {
//           return DropdownMenuItem(
//             value: salesman["id"] as int,
//             child: Text(
//               salesman["name"] as String,
//               style: const TextStyle(fontSize: 15),
//             ),
//           );
//         }).toList(),
//         onChanged: (value) {
//           setState(() => selectedSalesmanId = value);
//         },
//         decoration: InputDecoration(
//           labelText: "Select Salesman",
//           labelStyle: TextStyle(
//             fontSize: 14,
//             color: Colors.grey.shade600,
//           ),
//           prefixIcon: const Icon(
//             Icons.person_outline,
//             color: AppColors.primary,
//             size: 20,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 16,
//           ),
//         ),
//         icon: Icon(
//           Icons.keyboard_arrow_down,
//           color: AppColors.primary,
//         ),
//         dropdownColor: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//     );
//   }
//
//   Widget _buildDateField() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.08),
//             spreadRadius: 1,
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: dateController,
//         readOnly: true,
//         onTap: pickDate,
//         decoration: InputDecoration(
//           labelText: "Order Date",
//           labelStyle: TextStyle(
//             fontSize: 14,
//             color: Colors.grey.shade600,
//           ),
//           prefixIcon: const Icon(
//             Icons.calendar_today,
//             color: AppColors.primary,
//             size: 20,
//           ),
//           suffixIcon: Container(
//             margin: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(
//               Icons.edit,
//               color: AppColors.primary,
//               size: 18,
//             ),
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 16,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatusField() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.08),
//             spreadRadius: 1,
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: statusController,
//         decoration: InputDecoration(
//           labelText: "Status",
//           labelStyle: TextStyle(
//             fontSize: 14,
//             color: Colors.grey.shade600,
//           ),
//           prefixIcon: const Icon(
//             Icons.business_center,
//             color: AppColors.primary,
//             size: 20,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(16),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 16,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOrderItemsList() {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: orderItems.length,
//       itemBuilder: (context, index) {
//         final item = orderItems[index];
//         return Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.05),
//                 spreadRadius: 1,
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${index + 1}',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primary,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Item ID: ${item['item_id']}',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 15,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Text(
//                           'Qty: ${item['qty']}',
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Text(
//                           'Rate: Rs:${item['rate']}',
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade50,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   'Rs:${item['qty'] * item['rate']}',
//                   style: TextStyle(
//                     color: Colors.green.shade700,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildUpdateButton() {
//     return Container(
//       width: double.infinity,
//       height: 56,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: const LinearGradient(
//           colors: [AppColors.secondary, AppColors.primary],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.3),
//             spreadRadius: 1,
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ElevatedButton(
//         onPressed: isLoading ? null : updateOrder,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//         child: isLoading
//             ? Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: 22,
//               height: 22,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               ),
//             ),
//             const SizedBox(width: 12),
//             const Text(
//               'Updating Order...',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         )
//             : const Text(
//           'Update Order',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../ApiLink/ApiEndpoint.dart';
import '../../../Provider/CustomerProvider/CustomerProvider.dart';
import '../../../Provider/OrderTakingProvider/OrderTakingProvider.dart';
import '../../../Provider/SaleManProvider/SaleManProvider.dart';
import '../../../compoents/AppColors.dart';
import '../../../compoents/ProductDropdown.dart';
import '../../../compoents/SalesAreaDropdown.dart';
import '../../../Provider/setup/SalesAreasProvider.dart';
import '../../../model/OrderTakingModel/OrderTakingModel.dart';
import '../../../model/ProductModel/itemsdetailsModel.dart';

class UpdateOrderScreen extends StatefulWidget {
  final OrderData order;
  const UpdateOrderScreen({super.key, required this.order});

  @override
  State<UpdateOrderScreen> createState() => _UpdateOrderScreenState();
}

class _UpdateOrderScreenState extends State<UpdateOrderScreen> {
  final formatter = NumberFormat('#,##,###');
  final dateFormat = DateFormat('yyyy-MM-dd');

  late TextEditingController dateController;
  String selectedStatus = 'APPROVED';

  int? selectedCustomerId;
  String? selectedCustomerName;
  int? selectedSalesmanId;
  String? selectedSalesmanName;
  int? selectedSalesAreaId;

  // Live editable items loaded from fetchSingleOrder
  List<_EditableItem> editableItems = [];

  // Add product panel
  bool _showAddProduct = false;
  ItemDetails? _newProduct;
  final TextEditingController _newQtyController = TextEditingController();
  final TextEditingController _newRateController = TextEditingController();

  bool isLoading = false;
  bool isFetchingOrder = true;

  final List<String> statusOptions = [
    'DRAFT',
    'APPROVED',
    'CLOSED',
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();

    dateController = TextEditingController(
      text: dateFormat.format(widget.order.orderDate),
    );
    selectedStatus = widget.order.status ?? 'APPROVED';
    selectedCustomerId = widget.order.customerId;
    selectedCustomerName = widget.order.customerName;
    selectedSalesmanId = widget.order.salesmanId;
    selectedSalesmanName = widget.order.salesmanName;

    Future.microtask(() async {
      // Fetch providers
      Provider.of<CustomerProvider>(context, listen: false).fetchCustomers();
      Provider.of<SaleManProvider>(context, listen: false).fetchEmployees();
      Provider.of<SalesAreasProvider>(context, listen: false).fetchSalesAreas();

      selectedSalesAreaId = widget.order.salesAreaId;

      // Fetch live order details
      await Provider.of<OrderTakingProvider>(context, listen: false)
          .fetchSingleOrder(int.parse(widget.order.id));

      final detail = Provider.of<OrderTakingProvider>(context, listen: false)
          .selectedOrder;

      if (detail != null && mounted) {
        setState(() {
          editableItems = detail.details
              .map((d) => _EditableItem(
            itemId: d.itemId,
            itemName: d.itemName,
            qty: d.qty,
            rate: d.rate,
          ))
              .toList();
          isFetchingOrder = false;
        });
      } else {
        setState(() => isFetchingOrder = false);
      }
    });
  }

  @override
  void dispose() {
    dateController.dispose();
    _newQtyController.dispose();
    _newRateController.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────

  double get grandTotal =>
      editableItems.fold(0.0, (s, i) => s + i.qty * i.rate);

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'CLOSED':
        return Colors.blue;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // ── Add product ─────────────────────────────

  void _addProduct() {
    if (_newProduct == null) {
      _showSnack("Please select a product", Colors.orange);
      return;
    }
    final qty = double.tryParse(_newQtyController.text.trim()) ?? 0;
    final rate = double.tryParse(_newRateController.text.trim()) ?? 0;
    if (qty <= 0) {
      _showSnack("Enter a valid quantity", Colors.orange);
      return;
    }
    if (rate <= 0) {
      _showSnack("Enter a valid rate", Colors.orange);
      return;
    }
    setState(() {
      editableItems.add(_EditableItem(
        itemId: int.tryParse(_newProduct!.id.toString()) ?? 0,
        itemName: _newProduct!.name ?? 'Product',
        qty: qty,
        rate: rate,
      ));
      _newProduct = null;
      _newQtyController.clear();
      _newRateController.clear();
      _showAddProduct = false;
    });
  }

  void _removeItem(int index) {
    setState(() => editableItems.removeAt(index));
  }

  // ── Submit ───────────────────────────────────

  Future<void> _submitUpdate() async {
    if (editableItems.isEmpty) {
      _showSnack("Add at least one product", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final body = {
        "so_no": widget.order.soNo,
        "customer_id": selectedCustomerId,
        "salesman_id": selectedSalesmanId,
        "sales_area_id": selectedSalesAreaId,
        "order_date": DateFormat('dd MMMM yyyy').format(DateTime.parse(dateController.text)),
        "status": selectedStatus,
        "details": editableItems
            .map((i) => {
          "item_id": i.itemId,
          "qty": i.qty,
          "rate": i.rate,
        })
            .toList(),
      };

      debugPrint("📦 Update Body: ${jsonEncode(body)}");

      final response = await http.put(
        Uri.parse(
            "${ApiEndpoints.baseUrl}/sales-orders/${widget.order.id}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "x-company-id": "2",
        },
        body: jsonEncode(body),
      );

      debugPrint("📡 Status: ${response.statusCode}");
      debugPrint("📡 Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Force re-fetch list
        Provider.of<OrderTakingProvider>(context, listen: false).resetFetch();
        await Provider.of<OrderTakingProvider>(context, listen: false)
            .FetchOrderTaking();

        if (!mounted) return;
        _showSnack("Order updated successfully", Colors.green);
        Navigator.pop(context, true);
      } else {
        final res = jsonDecode(response.body);
        _showSnack(
          res["message"] ?? "Failed (${response.statusCode})",
          Colors.red,
        );
      }
    } catch (e) {
      _showSnack("Error: $e", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ── Date picker ──────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.order.orderDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => dateController.text = dateFormat.format(picked));
    }
  }

  // ────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: isFetchingOrder
          ? const Center(child: CircularProgressIndicator())
          : isLoading
          ? _buildLoadingOverlay()
          : _buildBody(),
    );
  }

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
      title: const Text("Update Order",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20)),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Updating order...",
              style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Order info banner ──
          _buildOrderBanner(),
          const SizedBox(height: 16),

          // ── Customer ──
          _buildSectionLabel("Customer"),
          const SizedBox(height: 8),
          _buildCustomerDropdown(),
          const SizedBox(height: 14),

          // ── Salesman ──
          _buildSectionLabel("Salesman"),
          const SizedBox(height: 8),
          _buildSalesmanDropdown(),
          const SizedBox(height: 14),

          // ── Sales Area ──
          _buildSectionLabel("Sales Area"),
          const SizedBox(height: 8),
          _buildSalesAreaDropdown(),
          const SizedBox(height: 14),

          // ── Date + Status ──
          Row(
            children: [
              Expanded(child: _buildDateField()),
              const SizedBox(width: 10),
              Expanded(child: _buildStatusDropdown()),
            ],
          ),
          const SizedBox(height: 18),

          // ── Items header ──
          _buildItemsHeader(),
          const SizedBox(height: 10),

          // ── Editable items ──
          ...editableItems.asMap().entries.map(
                (e) => _buildItemCard(e.value, e.key),
          ),

          // ── Add product panel ──
          if (_showAddProduct) ...[
            const SizedBox(height: 8),
            _buildAddProductPanel(),
          ],

          const SizedBox(height: 16),

          // ── Grand total ──
          _buildGrandTotal(),
          const SizedBox(height: 16),

          // ── Submit ──
          _buildSubmitButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Order Banner ────────────────────────────

  Widget _buildOrderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.secondary.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
            const Icon(Icons.receipt_long, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.order.soNo ?? 'N/A',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: AppColors.primary)),
                Text(
                  dateFormat.format(widget.order.orderDate),
                  style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          _statusChip(selectedStatus),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  // ── Section Label ────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── Customer Dropdown ────────────────────────

  Widget _buildCustomerDropdown() {
    return Consumer<CustomerProvider>(
      builder: (context, cp, _) {
        if (cp.isLoading) return _skeleton(50);
        return _dropdownCard(
          icon: Icons.person_outline,
          child: DropdownButtonFormField<int>(
            value: selectedCustomerId,
            isExpanded: true,
            decoration: _innerDecoration("Select Customer"),
            icon: Icon(Icons.arrow_drop_down,
                color: Colors.grey.shade500),
            items: cp.customers
                .map((c) => DropdownMenuItem<int>(
              value: c.id,
              child: Text(c.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13)),
            ))
                .toList(),
            onChanged: (id) {
              setState(() {
                selectedCustomerId = id;
                selectedCustomerName = cp.customers
                    .firstWhere((c) => c.id == id)
                    .name;
              });
            },
          ),
        );
      },
    );
  }

  // ── Salesman Dropdown ────────────────────────

  Widget _buildSalesmanDropdown() {
    return Consumer<SaleManProvider>(
      builder: (context, sp, _) {
        if (sp.isLoading) return _skeleton(50);
        return _dropdownCard(
          icon: Icons.badge_outlined,
          child: DropdownButtonFormField<int>(
            value: selectedSalesmanId,
            isExpanded: true,
            decoration: _innerDecoration("Select Salesman"),
            icon: Icon(Icons.arrow_drop_down,
                color: Colors.grey.shade500),
            items: sp.employees
                .map((e) => DropdownMenuItem<int>(
              value: e.id,
              child: Text(e.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13)),
            ))
                .toList(),
            onChanged: (id) {
              setState(() {
                selectedSalesmanId = id;
                selectedSalesmanName = sp.employees
                    .firstWhere((e) => e.id == id)
                    .name;
              });
            },
          ),
        );
      },
    );
  }

  // ── Sales Area Dropdown ──────────────────────

  Widget _buildSalesAreaDropdown() {
    return Consumer<SalesAreasProvider>(
      builder: (context, ap, _) {
        if (ap.isLoading) return _skeleton(50);
        return _dropdownCard(
          icon: Icons.map_outlined,
          child: SalesAreaDropdown(
            selectedId: selectedSalesAreaId?.toString(),
            onChanged: (id) {
              setState(() {
                selectedSalesAreaId = id != null ? int.tryParse(id) : null;
              });
            },
          ),
        );
      },
    );
  }

  // ── Date Field ───────────────────────────────

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(dateController.text,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Status Dropdown ──────────────────────────

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatus,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down,
              color: Colors.grey.shade500),
          items: statusOptions
              .map((s) => DropdownMenuItem<String>(
            value: s,
            child: Row(
              children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: _statusColor(s),
                        shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(s,
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
          ))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => selectedStatus = val);
          },
        ),
      ),
    );
  }

  // ── Items Header ─────────────────────────────

  Widget _buildItemsHeader() {
    return Row(
      children: [
        const Text("Order Items",
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text("${editableItems.length}",
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700)),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() {
            _showAddProduct = !_showAddProduct;
            if (!_showAddProduct) {
              _newProduct = null;
              _newQtyController.clear();
              _newRateController.clear();
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _showAddProduct
                  ? Colors.red.shade50
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _showAddProduct
                    ? Colors.red.shade200
                    : AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _showAddProduct ? Icons.close : Icons.add,
                  size: 14,
                  color: _showAddProduct
                      ? Colors.red.shade600
                      : AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  _showAddProduct ? "Cancel" : "Add Product",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _showAddProduct
                          ? Colors.red.shade600
                          : AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Item Card ────────────────────────────────

  Widget _buildItemCard(_EditableItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Index badge
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Text("${index + 1}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(item.itemName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ),
              // Delete button
              GestureDetector(
                onTap: () => _removeItem(index),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.delete_outline,
                      color: Colors.red.shade400, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Qty field
              Expanded(
                child: _buildInlineField(
                  label: "Qty",
                  value: item.qty.toStringAsFixed(
                      item.qty % 1 == 0 ? 0 : 2),
                  icon: Icons.format_list_numbered,
                  onChanged: (val) {
                    setState(() => item.qty =
                        double.tryParse(val) ?? item.qty);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Rate field
              Expanded(
                child: _buildInlineField(
                  label: "Rate (Rs)",
                  value: item.rate.toStringAsFixed(
                      item.rate % 1 == 0 ? 0 : 2),
                  icon: Icons.money,
                  onChanged: (val) {
                    setState(() => item.rate =
                        double.tryParse(val) ?? item.rate);
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Total badge
              Expanded(child: _buildTotalBadge(item.qty * item.rate)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Add Product Panel ────────────────────────

  Widget _buildAddProductPanel() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.add_shopping_cart,
                    color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              const Text("Add New Product",
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),

          // Product search dropdown
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ItemDetailsDropdown(
              onItemSelected: (item) {
                setState(() => _newProduct = item);
                if (item != null) {
                  _newRateController.text =
                      item.salePrice?.toString() ?? '';
                }
              },
            ),
          ),

          if (_newProduct != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _newProduct!.name ?? 'Product',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      'Rs ${_newProduct!.salePrice?.toStringAsFixed(2) ?? '0.00'}',
                      style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildInlineFieldController(
                  controller: _newQtyController,
                  label: "Quantity",
                  icon: Icons.format_list_numbered,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInlineFieldController(
                  controller: _newRateController,
                  label: "Rate (Rs)",
                  icon: Icons.money,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _addProduct,
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add to Order",
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Grand Total ──────────────────────────────

  Widget _buildGrandTotal() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.secondary, AppColors.primary]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Grand Total",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          Text(
            "Rs ${formatter.format(grandTotal)}",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ── Submit Button ────────────────────────────

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : _submitUpdate,
        icon: const Icon(Icons.check_circle_outline,
            color: Colors.white, size: 20),
        label: const Text("Update Order",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  // ── Reusable Widgets ─────────────────────────

  Widget _buildInlineField({
    required String label,
    required String value,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        initialValue: value,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
          TextStyle(color: Colors.grey.shade600, fontSize: 11),
          prefixIcon:
          Icon(icon, size: 14, color: Colors.grey.shade500),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          isDense: true,
        ),
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildInlineFieldController({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
          TextStyle(fontSize: 12, color: Colors.grey.shade600),
          prefixIcon:
          Icon(icon, size: 16, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildTotalBadge(double amount) {
    return Container(
      height: 52,
      padding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.green.shade100]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total",
              style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
          Text(
            "Rs ${formatter.format(amount)}",
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: Color(0xFF166534)),
          ),
        ],
      ),
    );
  }

  Widget _dropdownCard(
      {required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8)),
            child:
            Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }

  InputDecoration _innerDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
      TextStyle(color: Colors.grey.shade500, fontSize: 13),
      border: InputBorder.none,
      isDense: true,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
    );
  }

  Widget _skeleton(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14)),
    );
  }
}

// ─────────────────────────────────────────────
// Local editable item model
// ─────────────────────────────────────────────
class _EditableItem {
  final int itemId;
  final String itemName;
  double qty;
  double rate;

  _EditableItem({
    required this.itemId,
    required this.itemName,
    required this.qty,
    required this.rate,
  });
}