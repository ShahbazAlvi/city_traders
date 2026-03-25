


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Provider/OrderTakingProvider/OrderTakingProvider.dart';
import '../../../Provider/setup/location_provider.dart';
import '../../../Provider/CustomerProvider/CustomerProvider.dart';
import '../../../Provider/SaleManProvider/SaleManProvider.dart';
import '../../../compoents/AppColors.dart';
import '../../../compoents/ProductDropdown.dart';
import '../../../compoents/location_dropdown.dart';
import '../../../compoents/tax_types_dropdown.dart';

import '../../../model/ProductModel/itemsdetailsModel.dart';
import '../../../model/SaleInvoiceModel/InvoiceOrderUpdate.dart';

import '../../../ApiLink/ApiEndpoint.dart';
import 'package:http/http.dart' as http;
import '../../../model/setup/tax_Types_model.dart';

class AddTaxSalesInvoiceScreen extends StatefulWidget {
  final String nextOrderId;
  const AddTaxSalesInvoiceScreen({super.key, required this.nextOrderId});

  @override
  State<AddTaxSalesInvoiceScreen> createState() => _AddTaxSalesInvoiceScreenState();
}

class _AddTaxSalesInvoiceScreenState extends State<AddTaxSalesInvoiceScreen>
    with SingleTickerProviderStateMixin {
  int? selectedOrderId;
  int? selectedLocationId;
  TaxModel? selectedTax;
  late AnimationController _shimmerController;
  List<DropdownMenuItem<int>> _dropdownItems = [];

  // Customer & Salesman override
  int? selectedCustomerId;
  String? selectedSalesmanId;

  // Add New Product state
  bool _showAddProduct = false;
  ItemDetails? selectedProduct;
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  List<_ExtraItem> extraItems = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<LocationProvider>(context, listen: false).getLocations();
      Provider.of<CustomerProvider>(context, listen: false).fetchCustomers();
      Provider.of<SaleManProvider>(context, listen: false).fetchEmployees();
    });

    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: 0, max: 1, period: const Duration(milliseconds: 1500));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    qtyController.dispose();
    rateController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    final provider = Provider.of<OrderTakingProvider>(context, listen: false);
    await provider.FetchOrderTaking();

    if (provider.orderData?.data != null &&
        provider.orderData!.data.isNotEmpty) {
      setState(() {
        _dropdownItems = provider.orderData!.data.map((order) {
          return DropdownMenuItem<int>(
            value: int.parse(order.id),
            child: Container(
              width: MediaQuery.of(context).size.width - 80,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          order.soNo,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            order.customerName,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList();
      });
    }
  }

  void onOrderSelected(int orderId) async {
    setState(() {
      selectedOrderId = orderId;
      extraItems.clear();
      _showAddProduct = false;
      selectedProduct = null;
      qtyController.clear();
      rateController.clear();
    });

    await Provider.of<OrderTakingProvider>(context, listen: false)
        .fetchSingleOrder(orderId);

    final provider = Provider.of<OrderTakingProvider>(context, listen: false);
    if (provider.selectedOrder != null) {
      setState(() {
        selectedCustomerId = provider.selectedOrder!.customerId;
        selectedSalesmanId = provider.selectedOrder!.salesmanId.toString();
      });
    }
  }

  void updateLineTotal(OrderDetail item) {
    item.lineTotal = item.qty * item.rate;
  }

  void addProductToOrder() {
    final qty = double.tryParse(qtyController.text.trim()) ?? 0;
    final rate = double.tryParse(rateController.text.trim()) ?? 0;

    if (selectedProduct == null) {
      _showSnack("Please select a product", Colors.orange);
      return;
    }

    if (selectedProduct!.id == null) {
      _showSnack("Selected product has no valid ID. Please choose another.", Colors.red);
      return;
    }

    if (qty <= 0) {
      _showSnack("Please enter a valid quantity", Colors.orange);
      return;
    }

    if (rate <= 0) {
      _showSnack("Please enter a valid rate", Colors.orange);
      return;
    }

    setState(() {
      extraItems.add(_ExtraItem(
        product: selectedProduct!,
        qty: qty,
        rate: rate,
      ));
      selectedProduct = null;
      qtyController.clear();
      rateController.clear();
      _showAddProduct = false;
    });
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void removeExtraProduct(int index) {
    setState(() => extraItems.removeAt(index));
  }

  // ✅ Helper: safely convert any id value to int
  int? _toInt(dynamic id) {
    if (id == null) return null;
    if (id is int) return id;
    if (id is double) return id.toInt();
    if (id is String) return int.tryParse(id);
    return null;
  }

  Future<void> createInvoice() async {
    final provider = Provider.of<OrderTakingProvider>(context, listen: false);
    if (provider.selectedOrder == null) return;

    // Pre-flight: validate extra item IDs
    for (final item in extraItems) {
      final id = _toInt(item.product.id);
      if (id == null) {
        _showSnack(
          "Product '${item.product.name ?? 'Unknown'}' has no valid ID. Please remove it.",
          Colors.red,
        );
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final allDetails = [
      // Original order items — item_id already comes as int from server
      ...provider.selectedOrder!.details.map((item) => {
        "item_id": item.itemId,
        "qty": item.qty,
        "rate": item.rate,
        "tax_type_id": selectedTax?.id,
      }),

      // ✅ KEY FIX: _toInt() ensures item_id is always int, never String
      // The API rejected "33" (string) — it must be 33 (int)
      ...extraItems.map((item) => {
        "item_id": _toInt(item.product.id),
        "qty": item.qty,
        "rate": item.rate,
        "tax_type_id": selectedTax?.id,
      }),
    ];

    final body = {
      "inv_no": widget.nextOrderId,
      "sales_order_id": provider.selectedOrder!.id,
      "customer_id": selectedCustomerId ?? provider.selectedOrder!.customerId,
      "salesman_id": selectedSalesmanId != null
          ? int.tryParse(selectedSalesmanId!) ?? provider.selectedOrder!.salesmanId
          : provider.selectedOrder!.salesmanId,
      "location_id": selectedLocationId,
      "invoice_date": DateTime.now().toIso8601String().split("T").first,
      "invoice_type": "CASH",
      "status": "POSTED",
      "details": allDetails,
    };

    debugPrint("📦 Invoice Body: ${jsonEncode(body)}");

    try {
      final response = await http.post(
        Uri.parse("${ApiEndpoints.baseUrl}/sales-invoices-notax"),//sales-invoices-notax
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "x-company-id": "2",
        },
        body: jsonEncode(body),
      );

      debugPrint("📡 Status: ${response.statusCode}");
      debugPrint("📡 Response: ${response.body}");

      final res = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack(res["message"] ?? "Invoice created successfully", Colors.green);
        Navigator.pop(context, true);
      } else {
        final errorMsg = res["message"] ??
            res["error"] ??
            res["errors"]?.toString() ??
            "Failed to create invoice (${response.statusCode})";
        _showSnack(errorMsg, Colors.red);
      }
    } catch (e) {
      _showSnack("Something went wrong: ${e.toString()}", Colors.red);
    }
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderTakingProvider>(context);
    final orderTotal = provider.selectedOrder?.details
        .fold(0.0, (sum, item) => sum + item.lineTotal) ??
        0.0;
    final extraTotal = extraItems.fold(0.0, (sum, item) => sum + item.total);
    final total = orderTotal + extraTotal;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: provider.isLoading
          ? _buildShimmerEffect(child: _buildShimmerLoading())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSalesOrderDropdown(provider),
            const SizedBox(height: 12),

            TaxTypeDropdown(
              onSelected: (tax) => setState(() => selectedTax = tax),
            ),
            const SizedBox(height: 12),

            Consumer<LocationProvider>(
              builder: (context, locProvider, _) {
                return LocationDropdown(
                  locations: locProvider.locationList,
                  selectedId: selectedLocationId,
                  onChanged: (value) =>
                      setState(() => selectedLocationId = value),
                );
              },
            ),
            const SizedBox(height: 12),

            if (provider.selectedOrder != null) ...[
              Row(
                children: [
                  Expanded(child: _buildCustomerDropdown()),
                  const SizedBox(width: 10),
                  Expanded(child: _buildSalesmanDropdown()),
                ],
              ),
              const SizedBox(height: 12),
            ],

            if (provider.orderData?.data == null ||
                provider.orderData!.data.isEmpty)
              _buildNoOrdersWidget(),

            if (provider.selectedOrder != null) ...[
              _buildItemsHeader(total),
              const SizedBox(height: 8),

              Expanded(
                child: ListView(
                  children: [
                    ...provider.selectedOrder!.details
                        .asMap()
                        .entries
                        .map((e) => _buildOrderItemCard(e.value, e.key)),

                    if (extraItems.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _buildExtraItemsSection(),
                    ],

                    if (_showAddProduct) ...[
                      const SizedBox(height: 8),
                      _buildAddProductPanel(),
                    ],

                    const SizedBox(height: 12),
                    _buildBottomBar(total),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],

            if (provider.selectedOrder == null &&
                !provider.isLoading &&
                provider.orderData?.data != null &&
                provider.orderData!.data.isNotEmpty)
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // UI WIDGETS
  // ─────────────────────────────────────────────

  Widget _buildSalesOrderDropdown(OrderTakingProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<int>(
        value: selectedOrderId,
        hint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text("Select Sales Order",
              style: TextStyle(color: Colors.grey[600], fontSize: 15)),
        ),
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        icon: const Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF2563EB), size: 28),
        ),
        isExpanded: true,
        items: _dropdownItems.isEmpty && provider.orderData?.data != null
            ? provider.orderData!.data
            .map((order) => DropdownMenuItem<int>(
          value: int.parse(order.id),
          child: Text(order.soNo),
        ))
            .toList()
            : _dropdownItems,
        onChanged: (id) {
          if (id != null) onOrderSelected(id);
        },
      ),
    );
  }

  Widget _buildItemsHeader(double total) {
    return Row(
      children: [
        const Text(
          "Order Items",
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B)),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Rs${total.toStringAsFixed(2)}",
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2563EB)),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            setState(() {
              _showAddProduct = !_showAddProduct;
              if (!_showAddProduct) {
                selectedProduct = null;
                qtyController.clear();
                rateController.clear();
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  color:
                  _showAddProduct ? Colors.red.shade600 : AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  _showAddProduct ? "Cancel" : "Add Product",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _showAddProduct
                        ? Colors.red.shade600
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemCard(OrderDetail item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
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
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                        fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.itemName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF1E293B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: "Qty",
                  value: item.qty.toString(),
                  icon: Icons.production_quantity_limits,
                  onChanged: (val) {
                    item.qty = double.tryParse(val) ?? 0;
                    setState(() => updateLineTotal(item));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInputField(
                  label: "Rate (Rs)",
                  value: item.rate.toString(),
                  icon: Icons.money,
                  onChanged: (val) {
                    item.rate = double.tryParse(val) ?? 0;
                    setState(() => updateLineTotal(item));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildTotalBadge(item.lineTotal)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExtraItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Row(
            children: [
              Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 6),
              Text(
                "Added Products (${extraItems.length})",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700),
              ),
            ],
          ),
        ),
        ...extraItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.add_box_outlined,
                          color: Colors.green.shade700, size: 15),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.product.name ?? 'Product',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF1E293B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => removeExtraProduct(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6)),
                        child: Icon(Icons.close,
                            color: Colors.red.shade400, size: 15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMiniChip("Qty: ${item.qty}",
                        Colors.blue.shade50, Colors.blue.shade700),
                    const SizedBox(width: 6),
                    _buildMiniChip("Rs${item.rate}",
                        Colors.orange.shade50, Colors.orange.shade700),
                    const Spacer(),
                    Text(
                      "Rs${item.total.toStringAsFixed(2)}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green.shade700),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMiniChip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _buildAddProductPanel() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
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
              const Text(
                "Add New Product",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ItemDetailsDropdown(
              onItemSelected: (item) {
                setState(() => selectedProduct = item);
                if (item != null) {
                  rateController.text = item.salePrice?.toString() ?? '';
                }
              },
            ),
          ),

          if (selectedProduct != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border:
                Border.all(color: AppColors.primary.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedProduct!.name ?? 'Selected Product',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          // ✅ Show parsed int ID so you can confirm it's a number
                          'Stock: ${selectedProduct!.minLevelQty ?? 'N/A'}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      'Rs${selectedProduct!.salePrice?.toStringAsFixed(2) ?? '0.00'}',
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
                child: _buildInputFieldController(
                  controller: qtyController,
                  label: 'Quantity',
                  icon: Icons.format_list_numbered,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInputFieldController(
                  controller: rateController,
                  label: 'Rate (Rs)',
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
              onPressed: addProductToOrder,
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text('Add to Order',
                  style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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

  Widget _buildTotalBadge(double amount) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
            "Rs${amount.toStringAsFixed(2)}",
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Color(0xFF166534)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Grand Total",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B))),
              Text(
                "Rs:${total.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: createInvoice,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                padding: EdgeInsets.zero,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.secondary, AppColors.primary]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline,
                          color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text("Create Invoice",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoOrdersWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text("No Orders Available",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text("There are no sales orders to create invoices",
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100, shape: BoxShape.circle),
              child: Icon(Icons.receipt_outlined,
                  size: 70, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 20),
            Text("No Order Selected",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Text("Please select a sales order from\nthe dropdown above",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.5)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DROPDOWNS
  // ─────────────────────────────────────────────

  Widget _buildCustomerDropdown() {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, _) {
        if (customerProvider.isLoading) return _buildDropdownSkeleton();
        return _buildDropdownCard(
          icon: Icons.person_outline,
          child: DropdownButtonFormField<int>(
            value: selectedCustomerId,
            isExpanded: true,
            hint: Text("Select Customer",
                style:
                TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            decoration: _dropdownDecoration(),
            icon: const SizedBox.shrink(),
            items: customerProvider.customers.map((c) {
              return DropdownMenuItem<int>(
                value: c.id,
                child: Row(
                  children: [
                    Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(c.name,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (id) => setState(() => selectedCustomerId = id),
          ),
        );
      },
    );
  }

  Widget _buildSalesmanDropdown() {
    return Consumer<SaleManProvider>(
      builder: (context, salesmanProvider, _) {
        if (salesmanProvider.isLoading) return _buildDropdownSkeleton();
        return _buildDropdownCard(
          icon: Icons.badge_outlined,
          child: DropdownButtonFormField<String>(
            value: selectedSalesmanId,
            isExpanded: true,
            hint: Text("Select Salesman",
                style:
                TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            decoration: _dropdownDecoration(),
            icon: const SizedBox.shrink(),
            items: salesmanProvider.employees.map((emp) {
              return DropdownMenuItem<String>(
                value: emp.id.toString(),
                child: Row(
                  children: [
                    Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: Colors.blue, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(emp.name,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) => setState(() => selectedSalesmanId = val),
          ),
        );
      },
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
      suffixIcon:
      Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
    );
  }

  Widget _buildDropdownCard(
      {required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildDropdownSkeleton() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14)),
    );
  }

  // ─────────────────────────────────────────────
  // INPUT FIELDS
  // ─────────────────────────────────────────────

  Widget _buildInputField({
    required String label,
    required String value,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: TextFormField(
        initialValue: value,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
          TextStyle(color: Colors.grey.shade600, fontSize: 11),
          floatingLabelStyle: const TextStyle(
              color: Colors.blue, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, size: 14, color: Colors.grey.shade500),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          isDense: true,
        ),
        style:
        const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildInputFieldController({
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
          prefixIcon: Icon(icon, size: 16, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SHIMMER
  // ─────────────────────────────────────────────

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
          begin: const Alignment(-1.0, -0.5),
          end: const Alignment(1.0, 0.5),
          transform:
          GradientRotation(_shimmerController.value * 2 * 3.14159),
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: child,
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
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
                  offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 8),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 12,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────

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
        "Sales Invoice",
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Strongly-typed model — no Map key errors, no cast failures
// ─────────────────────────────────────────────
class _ExtraItem {
  final ItemDetails product;
  final double qty;
  final double rate;

  const _ExtraItem({
    required this.product,
    required this.qty,
    required this.rate,
  });

  double get total => qty * rate;
}