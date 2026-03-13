
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

class _AddPurchaseOrderState extends State<AddPurchaseOrder> {
  String? selectedSupplierId;
  String supplierBalance = "0";

  ItemDetails? selectedProduct;
  String selectedStatus = "APPROVED";
  DateTime selectedDate = DateTime.now();

  final List<String> orderStatusList = [
    "DRAFT",
    "APPROVED",
    "CLOSED",
    "CANCELLED",
  ];

  final TextEditingController rateController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();

  List<Map<String, dynamic>> orderItems = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<SupplierProvider>(context, listen: false).loadSuppliers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Purchase Order",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order No: ${widget.nextOrderId}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),

                InkWell(
                  onTap: _pickDate,
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        DateFormat('dd MMM yyyy').format(selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),


              ],
            ),

            const SizedBox(height: 14),

            /// SUPPLIER DROPDOWN
            Consumer<SupplierProvider>(
              builder: (context, supplierP, _) {
                if (supplierP.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: "Select Supplier",
                    border: OutlineInputBorder(),
                  ),
                  items: supplierP.suppliers.map((s) {
                    return DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name),
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
                );
              },
            ),

            const SizedBox(height: 12),

            if (selectedSupplierId != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Supplier Balance: $supplierBalance",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),

            const SizedBox(height: 20),

            _buildSectionTitle("Add Products"),
            const SizedBox(height: 10),

            _buildProductSelection(),

            const SizedBox(height: 20),

            if (orderItems.isNotEmpty) _buildOrderItemsList(),

            const SizedBox(height: 20),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: Consumer<PurchaseOrderProvider>(
                builder: (context, poProvider, _) {
                  return ElevatedButton.icon(
                    onPressed: poProvider.isLoading ? null : _savePurchaseOrder,
                    icon: poProvider.isLoading
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                        : const Icon(Icons.save),
                    label: Text(
                        poProvider.isLoading ? "Saving..." : "Save Order"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// SAVE PURCHASE ORDER
  Future<void> _savePurchaseOrder() async {
    if (selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a supplier")),
      );
      return;
    }

    if (orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one product")),
      );
      return;
    }

    /// MAP orderItems to API format: [{item_id, qty, rate}]
    final List<Map<String, dynamic>> details = orderItems.map((item) {
      final product = item["product"] as ItemDetails;
      return {
        "item_id": product.id is String ? int.parse(product.id!) : product.id,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Purchase Order Saved Successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(poProvider.error.isNotEmpty
            ? poProvider.error
            : "Failed to Save Order")),
      );
    }
  }

  /// PRODUCT SELECTION UI
  Widget _buildProductSelection() {
    return Column(
      children: [
        ItemDetailsDropdown(
          onItemSelected: (item) {
            setState(() => selectedProduct = item);
            if (item != null) {
              rateController.text = item.purchasePrice?.toString() ?? '';
            }
          },
        ),
        if (selectedProduct != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: qtyController,
                  label: "Quantity",
                  icon: Icons.format_list_numbered,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInputField(
                  controller: rateController,
                  label: "Rate",
                  icon: Icons.money,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: addProductToOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text("Add to Order"),
            ),
          ),
        ],
      ],
    );
  }

  /// ORDER ITEMS LIST
  Widget _buildOrderItemsList() {
    double grandTotal = 0;
    for (var item in orderItems) {
      grandTotal += item["total"];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Order Items"),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orderItems.length,
          itemBuilder: (context, index) {
            final item = orderItems[index];
            final product = item["product"] as ItemDetails;
            return Card(
              child: ListTile(
                title: Text(product.name ?? "Product"),
                subtitle:
                Text("Qty: ${item["qty"]} | Rate: Rs ${item["price"]}",style: TextStyle(fontWeight: FontWeight.bold),),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Rs ${NumberFormat('#,##0').format(item['total'])}",),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeProduct(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Grand Total",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Rs ${grandTotal.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  /// ADD PRODUCT TO LIST
  void addProductToOrder() {
    if (selectedProduct == null || qtyController.text.isEmpty) return;

    bool alreadyExists =
    orderItems.any((item) => item["product"].id == selectedProduct!.id);

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product already added")),
      );
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

  void removeProduct(int index) {
    setState(() {
      orderItems.removeAt(index);
    });
  }
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }
}