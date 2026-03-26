//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../../Provider/Purchase_Order_Provider/Purchase_order_provider.dart';
// import '../../../Provider/SupplierProvider/supplierProvider.dart';
// import '../../../compoents/AppColors.dart';
// import '../../../compoents/ProductDropdown.dart';
// import '../../../model/ProductModel/itemsdetailsModel.dart';
//
// class AddPurchaseOrder extends StatefulWidget {
//   final String nextOrderId;
//   const AddPurchaseOrder({super.key, required this.nextOrderId});
//
//   @override
//   State<AddPurchaseOrder> createState() => _AddPurchaseOrderState();
// }
//
// class _AddPurchaseOrderState extends State<AddPurchaseOrder> {
//   String? selectedSupplierId;
//   String supplierBalance = "0";
//
//   ItemDetails? selectedProduct;
//   String selectedStatus = "APPROVED";
//   DateTime selectedDate = DateTime.now();
//
//   final List<String> orderStatusList = [
//     "DRAFT",
//     "APPROVED",
//     "CLOSED",
//     "CANCELLED",
//   ];
//
//   final TextEditingController rateController = TextEditingController();
//   final TextEditingController qtyController = TextEditingController();
//
//   List<Map<String, dynamic>> orderItems = [];
//
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       Provider.of<SupplierProvider>(context, listen: false).loadSuppliers();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           "Add Purchase Order",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [AppColors.secondary, AppColors.primary],
//             ),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Order No: ${widget.nextOrderId}",
//                     style: const TextStyle(fontWeight: FontWeight.bold)),
//
//                 InkWell(
//                   onTap: _pickDate,
//                   child: Row(
//                     children: [
//                       const Icon(Icons.calendar_today, size: 18),
//                       const SizedBox(width: 5),
//                       Text(
//                         DateFormat('dd MMM yyyy').format(selectedDate),
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                 ),
//
//
//               ],
//             ),
//
//             const SizedBox(height: 14),
//
//             /// SUPPLIER DROPDOWN
//             Consumer<SupplierProvider>(
//               builder: (context, supplierP, _) {
//                 if (supplierP.isLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 return DropdownButtonFormField<int>(
//                   decoration: const InputDecoration(
//                     labelText: "Select Supplier",
//                     border: OutlineInputBorder(),
//                   ),
//                   items: supplierP.suppliers.map((s) {
//                     return DropdownMenuItem(
//                       value: s.id,
//                       child: Text(s.name),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedSupplierId = value.toString();
//                       final supplier =
//                       supplierP.suppliers.firstWhere((s) => s.id == value);
//                       supplierBalance =
//                           supplier.openingBalance?.toString() ?? "0";
//                     });
//                   },
//                 );
//               },
//             ),
//
//             const SizedBox(height: 12),
//
//             if (selectedSupplierId != null)
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text(
//                   "Supplier Balance: $supplierBalance",
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, color: Colors.blue),
//                 ),
//               ),
//
//             const SizedBox(height: 20),
//
//             _buildSectionTitle("Add Products"),
//             const SizedBox(height: 10),
//
//             _buildProductSelection(),
//
//             const SizedBox(height: 20),
//
//             if (orderItems.isNotEmpty) _buildOrderItemsList(),
//
//             const SizedBox(height: 20),
//
//             /// SAVE BUTTON
//             SizedBox(
//               width: double.infinity,
//               child: Consumer<PurchaseOrderProvider>(
//                 builder: (context, poProvider, _) {
//                   return ElevatedButton.icon(
//                     onPressed: poProvider.isLoading ? null : _savePurchaseOrder,
//                     icon: poProvider.isLoading
//                         ? const SizedBox(
//                       width: 18,
//                       height: 18,
//                       child: CircularProgressIndicator(
//                           strokeWidth: 2, color: Colors.white),
//                     )
//                         : const Icon(Icons.save),
//                     label: Text(
//                         poProvider.isLoading ? "Saving..." : "Save Order"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// SAVE PURCHASE ORDER
//   Future<void> _savePurchaseOrder() async {
//     if (selectedSupplierId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select a supplier")),
//       );
//       return;
//     }
//
//     if (orderItems.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please add at least one product")),
//       );
//       return;
//     }
//
//     /// MAP orderItems to API format: [{item_id, qty, rate}]
//     final List<Map<String, dynamic>> details = orderItems.map((item) {
//       final product = item["product"] as ItemDetails;
//       return {
//         "item_id": product.id is String ? int.parse(product.id!) : product.id,
//         "qty": item["qty"].toInt(),
//         "rate": item["price"],
//       };
//     }).toList();
//
//     final poProvider =
//     Provider.of<PurchaseOrderProvider>(context, listen: false);
//
//     final bool success = await poProvider.addPurchaseOrder(
//       poNo: widget.nextOrderId,
//       supplierId: int.parse(selectedSupplierId!),
//       selectedDate: selectedDate,
//       status: selectedStatus,
//       products: details,
//     );
//
//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Purchase Order Saved Successfully")),
//       );
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(poProvider.error.isNotEmpty
//             ? poProvider.error
//             : "Failed to Save Order")),
//       );
//     }
//   }
//
//   /// PRODUCT SELECTION UI
//   Widget _buildProductSelection() {
//     return Column(
//       children: [
//         ItemDetailsDropdown(
//           onItemSelected: (item) {
//             setState(() => selectedProduct = item);
//             if (item != null) {
//               rateController.text = item.purchasePrice?.toString() ?? '';
//             }
//           },
//         ),
//         if (selectedProduct != null) ...[
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildInputField(
//                   controller: qtyController,
//                   label: "Quantity",
//                   icon: Icons.format_list_numbered,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _buildInputField(
//                   controller: rateController,
//                   label: "Rate",
//                   icon: Icons.money,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: addProductToOrder,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//               ),
//               child: const Text("Add to Order"),
//             ),
//           ),
//         ],
//       ],
//     );
//   }
//
//   /// ORDER ITEMS LIST
//   Widget _buildOrderItemsList() {
//     double grandTotal = 0;
//     for (var item in orderItems) {
//       grandTotal += item["total"];
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionTitle("Order Items"),
//         const SizedBox(height: 10),
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: orderItems.length,
//           itemBuilder: (context, index) {
//             final item = orderItems[index];
//             final product = item["product"] as ItemDetails;
//             return Card(
//               child: ListTile(
//                 title: Text(product.name ?? "Product"),
//                 subtitle:
//                 Text("Qty: ${item["qty"]} | Rate: Rs ${item["price"]}",style: TextStyle(fontWeight: FontWeight.bold),),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text("Rs ${NumberFormat('#,##0').format(item['total'])}",),
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () => removeProduct(index),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//         const SizedBox(height: 10),
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.green.shade50,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text("Grand Total",
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//               Text("Rs ${grandTotal.toStringAsFixed(2)}",
//                   style: const TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSectionTitle(String title) {
//     return Text(title,
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
//   }
//
//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//   }) {
//     return TextField(
//       controller: controller,
//       keyboardType: TextInputType.number,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon),
//         border: const OutlineInputBorder(),
//       ),
//     );
//   }
//
//   /// ADD PRODUCT TO LIST
//   void addProductToOrder() {
//     if (selectedProduct == null || qtyController.text.isEmpty) return;
//
//     bool alreadyExists =
//     orderItems.any((item) => item["product"].id == selectedProduct!.id);
//
//     if (alreadyExists) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Product already added")),
//       );
//       return;
//     }
//
//     final qty = double.tryParse(qtyController.text) ?? 0;
//     final price = double.tryParse(rateController.text) ??
//         selectedProduct!.purchasePrice?.toDouble() ??
//         0;
//     final total = qty * price;
//
//     setState(() {
//       orderItems.add({
//         "product": selectedProduct!,
//         "qty": qty,
//         "price": price,
//         "total": total,
//       });
//       selectedProduct = null;
//       qtyController.clear();
//       rateController.clear();
//     });
//   }
//
//   void removeProduct(int index) {
//     setState(() {
//       orderItems.removeAt(index);
//     });
//   }
//   Future<void> _pickDate() async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//
//     if (pickedDate != null) {
//       setState(() {
//         selectedDate = pickedDate;
//       });
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Provider/Purchase_Order_Provider/Purchase_order_provider.dart';
import '../../../Provider/SupplierProvider/supplierProvider.dart';
import '../../../compoents/AppColors.dart';
import '../../../compoents/ProductDropdown.dart';
import '../../../model/ProductModel/itemsdetailsModel.dart';

class AddPurchaseOrder extends StatefulWidget {
  final String nextOrderId;
  const AddPurchaseOrder({super.key, required this.nextOrderId});

  @override
  State<AddPurchaseOrder> createState() => _AddPurchaseOrderState();
}

class _AddPurchaseOrderState extends State<AddPurchaseOrder>
    with SingleTickerProviderStateMixin {
  String? selectedSupplierId;
  String supplierBalance = "0";

  ItemDetails? selectedProduct;
  String selectedStatus = "APPROVED";
  DateTime selectedDate = DateTime.now();

  // final List<String> orderStatusList = [
  //   "DRAFT",
  //   "APPROVED",
  //   "CLOSED",
  //   "CANCELLED",
  // ];

  final TextEditingController rateController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();

  List<Map<String, dynamic>> orderItems = [];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    Future.microtask(() {
      Provider.of<SupplierProvider>(context, listen: false).loadSuppliers();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    rateController.dispose();
    qtyController.dispose();
    super.dispose();
  }

  // ── Status color ──────────────────────────────────────────────────────────

  Color _statusColor(String s) {
    switch (s) {
      case "APPROVED":
        return const Color(0xFF00C896);
      case "DRAFT":
        return const Color(0xFF6C63FF);
      case "CLOSED":
        return const Color(0xFF4A90D9);
      case "CANCELLED":
        return const Color(0xFFFF4D4F);
      default:
        return const Color(0xFFFFAB00);
    }
  }

  // ── Date Picker ───────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: const Color(0xFF1A1A2E),
          ),
        ),
        child: child!,
      ),
    );
    if (pickedDate != null) setState(() => selectedDate = pickedDate);
  }

  // ── Add product ───────────────────────────────────────────────────────────

  void addProductToOrder() {
    if (selectedProduct == null || qtyController.text.isEmpty) return;

    bool alreadyExists =
    orderItems.any((item) => item["product"].id == selectedProduct!.id);
    if (alreadyExists) {
      _showSnack("Product already added", isError: true);
      return;
    }

    final qty = double.tryParse(qtyController.text) ?? 0;
    final price = double.tryParse(rateController.text) ??
        selectedProduct!.purchasePrice?.toDouble() ??
        0;
    final total = qty * price;

    setState(() {
      orderItems.add({
        "product": selectedProduct!,
        "qty": qty,
        "price": price,
        "total": total,
      });
      selectedProduct = null;
      qtyController.clear();
      rateController.clear();
    });
  }

  void removeProduct(int index) => setState(() => orderItems.removeAt(index));

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor:
      isError ? const Color(0xFFFF4D4F) : const Color(0xFF00C896),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _savePurchaseOrder() async {
    if (selectedSupplierId == null) {
      _showSnack("Please select a supplier", isError: true);
      return;
    }
    if (orderItems.isEmpty) {
      _showSnack("Please add at least one product", isError: true);
      return;
    }

    final List<Map<String, dynamic>> details = orderItems.map((item) {
      final product = item["product"] as ItemDetails;
      return {
        "item_id":
        product.id is String ? int.parse(product.id!) : product.id,
        "qty": item["qty"].toInt(),
        "rate": item["price"],
      };
    }).toList();

    final poProvider =
    Provider.of<PurchaseOrderProvider>(context, listen: false);

    final bool success = await poProvider.addPurchaseOrder(
      poNo: widget.nextOrderId,
      supplierId: int.parse(selectedSupplierId!),
      selectedDate: selectedDate,
      status: selectedStatus,
      products: details,
    );

    if (success) {
      _showSnack("Purchase Order Saved Successfully");
      Navigator.pop(context);
    } else {
      _showSnack(
        (poProvider.error ?? '').isNotEmpty
            ? poProvider.error!
            : "Failed to Save Order",
        isError: true,
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "Add Purchase Order",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header card: Order No + Date + Status ──
              _buildHeaderCard(),
              const SizedBox(height: 16),

              // ── Supplier ──
              _buildSectionCard(
                title: "Supplier",
                icon: Icons.storefront_rounded,
                child: _buildSupplierSection(),
              ),
              const SizedBox(height: 16),

              // ── Add Product ──
              _buildSectionCard(
                title: "Add Products",
                icon: Icons.add_shopping_cart_rounded,
                child: _buildProductSelection(),
              ),
              const SizedBox(height: 16),

              // ── Order Items ──
              if (orderItems.isNotEmpty) ...[
                _buildOrderItemsList(),
                const SizedBox(height: 16),
              ],

              // ── Save Button ──
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header Card ───────────────────────────────────────────────────────────

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Order ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Order Number",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFAAAAAA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.nextOrderId,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Date picker
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Order Date",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFAAAAAA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFE8E8F0), width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined,
                                size: 16, color: Color(0xFF9E9EC0)),
                            const SizedBox(width: 7),
                            Text(
                              DateFormat('dd MMM yyyy').format(selectedDate),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F6)),
          const SizedBox(height: 16),

        ],
      ),
    );
  }

  // ── Section Card wrapper ──────────────────────────────────────────────────

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F6)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ── Supplier Section ──────────────────────────────────────────────────────

  Widget _buildSupplierSection() {
    return Consumer<SupplierProvider>(
      builder: (context, supplierP, _) {
        if (supplierP.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(14),
                border:
                Border.all(color: const Color(0xFFE8E8F0), width: 1),
              ),
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Select Supplier",
                  labelStyle: TextStyle(
                    color: Color(0xFF9E9EC0),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  prefixIcon: Icon(Icons.person_outline_rounded,
                      color: Color(0xFF9E9EC0), size: 20),
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(16),
                items: supplierP.suppliers.map((s) {
                  return DropdownMenuItem(
                    value: s.id,
                    child: Text(
                      s.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSupplierId = value.toString();
                    final supplier =
                    supplierP.suppliers.firstWhere((s) => s.id == value);
                    supplierBalance =
                        supplier.openingBalance?.toString() ?? "0";
                  });
                },
              ),
            ),
            if (selectedSupplierId != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4A90D9).withOpacity(0.08),
                      const Color(0xFF6C63FF).withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4A90D9).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined,
                        size: 18, color: Color(0xFF4A90D9)),
                    const SizedBox(width: 10),
                    const Text(
                      "Supplier Balance: ",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF888899),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      supplierBalance,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4A90D9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // ── Product Selection ─────────────────────────────────────────────────────

  Widget _buildProductSelection() {
    return Column(
      children: [
        ItemDetailsDropdown(
          onItemSelected: (item) {
            setState(() => selectedProduct = item);
            if (item != null) {
              rateController.text =
                  item.purchasePrice?.toString() ?? '';
            }
          },
        ),
        if (selectedProduct != null) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: qtyController,
                  label: "Quantity",
                  icon: Icons.format_list_numbered_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  controller: rateController,
                  label: "Rate",
                  icon: Icons.payments_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: addProductToOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text(
                "Add to Order",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8F0), width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF9E9EC0),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon:
          Icon(icon, color: const Color(0xFF9E9EC0), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  // ── Order Items List ──────────────────────────────────────────────────────

  Widget _buildOrderItemsList() {
    double grandTotal =
    orderItems.fold(0, (sum, item) => sum + (item["total"] as double));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C896).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.inventory_2_outlined,
                      size: 17, color: Color(0xFF00C896)),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Order Items",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C896).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${orderItems.length} item${orderItems.length != 1 ? 's' : ''}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00C896),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F0F6)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            itemCount: orderItems.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              color: Color(0xFFF5F5FA),
            ),
            itemBuilder: (context, index) {
              final item = orderItems[index];
              final product = item["product"] as ItemDetails;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    // Product avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          (product.name ?? 'P')[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name + qty/rate
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name ?? "Product",
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Qty: ${item['qty'].toStringAsFixed(item['qty'] % 1 == 0 ? 0 : 1)}  ·  Rs ${item['price']}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9E9EB0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Total
                    Text(
                      "Rs ${NumberFormat('#,##0').format(item['total'])}",
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete
                    GestureDetector(
                      onTap: () => removeProduct(index),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color:
                          const Color(0xFFFF4D4F).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: Color(0xFFFF4D4F),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Grand Total
          Container(
            margin: const EdgeInsets.all(16),
            padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C896), Color(0xFF00A37A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C896).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.receipt_outlined,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Grand Total",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Rs ${NumberFormat('#,##0.##').format(grandTotal)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Save Button ───────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return Consumer<PurchaseOrderProvider>(
      builder: (context, poProvider, _) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: poProvider.isLoading
                ? null
                : const LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            color: poProvider.isLoading
                ? const Color(0xFFCCCCCC)
                : null,
            borderRadius: BorderRadius.circular(18),
            boxShadow: poProvider.isLoading
                ? []
                : [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: poProvider.isLoading ? null : _savePurchaseOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (poProvider.isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                else
                  const Icon(Icons.save_rounded,
                      color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  poProvider.isLoading ? "Saving..." : "Save Purchase Order",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}