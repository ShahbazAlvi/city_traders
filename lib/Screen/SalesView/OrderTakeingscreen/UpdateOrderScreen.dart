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
//           "Authorization":
//           "Bearer YOUR_TOKEN_HERE", // 👉 Replace with actual token
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
//         Provider.of<OrderTakingProvider>(context, listen: false)
//             .FetchOrderTaking();
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Order Updated Successfully")),
//         );
//
//         Navigator.pop(context);
//       } else {
//         throw Exception("Update failed");
//       }
//     } catch (e) {
//       print("ERROR: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Update Failed")),
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
//     );
//
//     if (picked != null) {
//       dateController.text = DateFormat('yyyy-MM-dd').format(picked);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<OrderTakingProvider>(context);
//
// // Get unique customer and salesman lists
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
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Update Order"),
//         backgroundColor: AppColors.primary,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Order Number
//             TextField(
//               controller: soController,
//               decoration: const InputDecoration(
//                 labelText: "Order Number",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 15),
//
//             // Customer Dropdown
//             DropdownButtonFormField<int>(
//               value: selectedCustomerId,
//               items: customers.map((customer) {
//                 return DropdownMenuItem(
//                   value: customer["id"] as int,
//                   child: Text(customer["name"] as String),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() => selectedCustomerId = value);
//               },
//               decoration: const InputDecoration(
//                 labelText: "Customer",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 15),
//
//             // Salesman Dropdown
//             DropdownButtonFormField<int>(
//               value: selectedSalesmanId,
//               items: salesmen.map((salesman) {
//                 return DropdownMenuItem(
//                   value: salesman["id"] as int,
//                   child: Text(salesman["name"] as String),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() => selectedSalesmanId = value);
//               },
//               decoration: const InputDecoration(
//                 labelText: "Salesman",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 15),
//
//             // Order Date
//             TextField(
//               controller: dateController,
//               readOnly: true,
//               onTap: pickDate,
//               decoration: const InputDecoration(
//                 labelText: "Order Date",
//                 border: OutlineInputBorder(),
//                 suffixIcon: Icon(Icons.calendar_today),
//               ),
//             ),
//             const SizedBox(height: 15),
//
//             // Status
//             TextField(
//               controller: statusController,
//               decoration: const InputDecoration(
//                 labelText: "Status",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 25),
//
//             // Update Button
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: updateOrder,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.secondary,
//                 ),
//                 child: const Text(
//                   "Update Order",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.text,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../Provider/OrderTakingProvider/OrderTakingProvider.dart';
import '../../../compoents/AppColors.dart';
import '../../../model/OrderTakingModel/OrderTakingModel.dart';

class UpdateOrderScreen extends StatefulWidget {
  final OrderData order;

  const UpdateOrderScreen({super.key, required this.order});

  @override
  State<UpdateOrderScreen> createState() => _UpdateOrderScreenState();
}

class _UpdateOrderScreenState extends State<UpdateOrderScreen> {
  late TextEditingController soController;
  late TextEditingController dateController;
  late TextEditingController statusController;

  int? selectedCustomerId;
  int? selectedSalesmanId;

  List<Map<String, dynamic>> orderItems = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    soController = TextEditingController(text: widget.order.soNo);
    dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.order.orderDate),
    );
    statusController = TextEditingController(text: widget.order.status);

    selectedCustomerId = widget.order.customerId;
    selectedSalesmanId = widget.order.salesmanId;

    // Load existing order items (replace with API if needed)
    orderItems = [
      {"item_id": 7, "qty": 1, "rate": 100},
    ];
  }

  @override
  void dispose() {
    soController.dispose();
    dateController.dispose();
    statusController.dispose();
    super.dispose();
  }

  Future<void> updateOrder() async {
    setState(() => isLoading = true);

    final url = Uri.parse(
        "https://api.distribution.afaqmis.com/api/sales-orders/${widget.order.id}");

    final body = {
      "so_no": soController.text,
      "customer_id": selectedCustomerId,
      "salesman_id": selectedSalesmanId,
      "order_date": dateController.text,
      "status": statusController.text,
      "details": orderItems,
    };

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer YOUR_TOKEN_HERE",
          "x-company-id": "2"
        },
        body: jsonEncode(body),
      );

      print("UPDATE RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        if (!mounted) return;

        await Provider.of<OrderTakingProvider>(context, listen: false)
            .FetchOrderTaking();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(child: Text("Order Updated Successfully")),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        Navigator.pop(context);
      } else {
        throw Exception("Update failed");
      }
    } catch (e) {
      print("ERROR: $e");
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(child: Text("Update Failed")),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.order.orderDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderTakingProvider>(context);

    // Get unique customer and salesman lists
    final customers = <Map<String, dynamic>>[];
    final customerIds = <int>{};
    for (var order in provider.orderData?.data ?? []) {
      if (!customerIds.contains(order.customerId)) {
        customerIds.add(order.customerId);
        customers.add({"id": order.customerId, "name": order.customerName});
      }
    }

    final salesmen = <Map<String, dynamic>>[];
    final salesmanIds = <int>{};
    for (var order in provider.orderData?.data ?? []) {
      if (!salesmanIds.contains(order.salesmanId)) {
        salesmanIds.add(order.salesmanId);
        salesmen.add({"id": order.salesmanId, "name": order.salesmanName});
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: isLoading
          ? _buildLoadingIndicator()
          : _buildMainContent(customers, salesmen),
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
      title: const Text(
        "Update Order",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.edit_note,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Updating order...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
      List<Map<String, dynamic>> customers,
      List<Map<String, dynamic>> salesmen,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Info Card
          _buildOrderInfoCard(),
          const SizedBox(height: 24),

          // Order Information Section
          _buildSectionTitle('Order Information'),
          const SizedBox(height: 16),
          _buildOrderNumberField(),
          const SizedBox(height: 16),

          // Customer Section
          _buildSectionTitle('Customer Details'),
          const SizedBox(height: 16),
          _buildCustomerDropdown(customers),
          const SizedBox(height: 16),

          // Salesman Section
          _buildSectionTitle('Salesman Details'),
          const SizedBox(height: 16),
          _buildSalesmanDropdown(salesmen),
          const SizedBox(height: 16),

          // Date & Status Section
          _buildSectionTitle('Order Details'),
          const SizedBox(height: 16),
          _buildDateField(),
          const SizedBox(height: 16),
          _buildStatusField(),
          const SizedBox(height: 24),

          // Order Items Section (if any)
          if (orderItems.isNotEmpty) ...[
            _buildSectionTitle('Order Items'),
            const SizedBox(height: 16),
            _buildOrderItemsList(),
            const SizedBox(height: 24),
          ],

          // Update Button
          _buildUpdateButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order ID',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.order.soNo ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.order.status ?? 'DRAFT').withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.order.status ?? 'DRAFT'),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.order.status ?? 'DRAFT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(widget.order.status ?? 'DRAFT'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'CLOSED':
        return Colors.blue;
      case 'CANCELLED':
        return Colors.red;
      case 'DRAFT':
      default:
        return Colors.orange;
    }
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

  Widget _buildOrderNumberField() {
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
      child: TextField(
        controller: soController,
        decoration: InputDecoration(
          labelText: "Order Number",
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          prefixIcon: const Icon(
            Icons.receipt,
            color: AppColors.primary,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerDropdown(List<Map<String, dynamic>> customers) {
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
      child: DropdownButtonFormField<int>(
        value: selectedCustomerId,
        items: customers.map((customer) {
          return DropdownMenuItem(
            value: customer["id"] as int,
            child: Text(
              customer["name"] as String,
              style: const TextStyle(fontSize: 15),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => selectedCustomerId = value);
        },
        decoration: InputDecoration(
          labelText: "Select Customer",
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          prefixIcon: const Icon(
            Icons.business,
            color: AppColors.primary,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.primary,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildSalesmanDropdown(List<Map<String, dynamic>> salesmen) {
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
      child: DropdownButtonFormField<int>(
        value: selectedSalesmanId,
        items: salesmen.map((salesman) {
          return DropdownMenuItem(
            value: salesman["id"] as int,
            child: Text(
              salesman["name"] as String,
              style: const TextStyle(fontSize: 15),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => selectedSalesmanId = value);
        },
        decoration: InputDecoration(
          labelText: "Select Salesman",
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          prefixIcon: const Icon(
            Icons.person_outline,
            color: AppColors.primary,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.primary,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildDateField() {
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
      child: TextField(
        controller: dateController,
        readOnly: true,
        onTap: pickDate,
        decoration: InputDecoration(
          labelText: "Order Date",
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          prefixIcon: const Icon(
            Icons.calendar_today,
            color: AppColors.primary,
            size: 20,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.edit,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusField() {
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
      child: TextField(
        controller: statusController,
        decoration: InputDecoration(
          labelText: "Status",
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          prefixIcon: const Icon(
            Icons.business_center,
            color: AppColors.primary,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItemsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orderItems.length,
      itemBuilder: (context, index) {
        final item = orderItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item ID: ${item['item_id']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Qty: ${item['qty']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Rate: Rs:${item['rate']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Rs:${item['qty'] * item['rate']}',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : updateOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Updating Order...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        )
            : const Text(
          'Update Order',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}