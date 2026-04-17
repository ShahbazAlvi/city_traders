import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../Provider/Purchase_Provider/GRNProvider/GRN_Provider.dart';
import '../../../Provider/setup/location_provider.dart';
import '../../../compoents/AppColors.dart';
import '../../../compoents/ProductDropdown.dart';
import '../../../compoents/SupplierDropdown.dart';
import '../../../compoents/location_dropdown.dart';
import '../../../model/ProductModel/itemsdetailsModel.dart';

class AddGRNScreen extends StatefulWidget {
  final String nextOrderId;
  const AddGRNScreen({super.key, required this.nextOrderId});

  @override
  State<AddGRNScreen> createState() => _AddGRNScreenState();
}

class _AddGRNScreenState extends State<AddGRNScreen>
    with SingleTickerProviderStateMixin {
  String? selectedSupplierId;
  ItemDetails? selectedProduct;

  final taxController = TextEditingController();
  final discountController = TextEditingController();
  final qtyController = TextEditingController();
  final rateController = TextEditingController();

  int? selectedLocationId;

  double productTotal = 0;
  double taxAmount = 0;
  double grandTotal = 0;
  double grandTotalWithTax = 0;

  List<Map<String, dynamic>> selectedProducts = [];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // ── Calc / Add / Remove ───────────────────────────────────────────────────

  void calculateProductTotal() {
    final qty = double.tryParse(qtyController.text) ?? 0;
    final rate = double.tryParse(rateController.text) ?? 0;
    setState(() => productTotal = qty * rate);
  }

  void calculateGrandTotal() {
    grandTotal =
        selectedProducts.fold(0, (sum, item) => sum + (item["total"] as double));
    final tax = double.tryParse(taxController.text) ?? 0;
    taxAmount = grandTotal * tax / 100;
    grandTotalWithTax = grandTotal + taxAmount;
    setState(() {});
  }

  void addProductToList() {
    if (selectedProduct == null ||
        qtyController.text.isEmpty ||
        rateController.text.isEmpty) {
      _showSnack("Please fill all fields", isError: true);
      return;
    }

    selectedProducts.add({
      "item_id": selectedProduct!.id,
      "name": selectedProduct!.name,
      "qty_received": double.parse(qtyController.text),
      "unit_cost": double.parse(rateController.text),
      "total": productTotal,
    });

    qtyController.clear();
    rateController.clear();
    productTotal = 0;
    calculateGrandTotal(); // ✅ recalculates grandTotal + tax
  }

  void removeProduct(int index) {
    selectedProducts.removeAt(index);
    calculateGrandTotal(); // ✅ recalculates grandTotal + tax
  }

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

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

    Future.microtask(() {
      Provider.of<LocationProvider>(context, listen: false).getLocations();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    qtyController.dispose();
    rateController.dispose();
    taxController.dispose();
    discountController.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final grnProvider = Provider.of<GRNProvider>(context);

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
                  offset: Offset(0, 4)),
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
                      "Add GRN",
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
              _buildGrnIdCard(),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: "Order Details",
                icon: Icons.assignment_outlined,
                child: _buildOrderDetailsSection(),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: "Add Product",
                icon: Icons.add_shopping_cart_rounded,
                child: _buildProductSection(),
              ),
              const SizedBox(height: 16),
              if (selectedProducts.isNotEmpty) ...[
                _buildProductsTable(),
                const SizedBox(height: 16),
              ],
              _buildSaveButton(grnProvider),
            ],
          ),
        ),
      ),
    );
  }

  // ── GRN ID Card ───────────────────────────────────────────────────────────

  Widget _buildGrnIdCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.07),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border:
        Border.all(color: AppColors.primary.withOpacity(0.18), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.receipt_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "GRN Number",
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFAAAAAA),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.nextOrderId,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF00C896).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: Color(0xFF00C896)),
                const SizedBox(width: 5),
                Text(
                  DateFormat('dd MMM yyyy').format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00C896),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section card wrapper ──────────────────────────────────────────────────

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

  // ── Order Details (Supplier + Location + Tax) ─────────────────────────────

  Widget _buildOrderDetailsSection() {
    return Column(
      children: [
        // Supplier
        _styledDropdownWrapper(
          icon: Icons.storefront_rounded,
          child: SupplierDropdown(
            onSelected: (id) => setState(() => selectedSupplierId = id),
          ),
        ),
        const SizedBox(height: 14),
        // Location
        _styledDropdownWrapper(
          icon: Icons.location_on_outlined,
          child: Consumer<LocationProvider>(
            builder: (context, provider, _) => LocationDropdown(
              locations: provider.locationList,
              selectedId: selectedLocationId,
              onChanged: (value) =>
                  setState(() => selectedLocationId = value),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // ✅ Tax % Field
        _buildInputField(
          controller: taxController,
          label: "Tax %",
          icon: Icons.percent_rounded,
          onChanged: (_) => calculateGrandTotal(),
        ),

        // ✅ Live Tax Breakdown — only show when tax > 0 and products exist
        if ((double.tryParse(taxController.text) ?? 0) > 0 &&
            selectedProducts.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border:
              Border.all(color: const Color(0xFFFFD54F), width: 1),
            ),
            child: Column(
              children: [
                // Subtotal row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 15, color: Color(0xFFFF8F00)),
                        SizedBox(width: 6),
                        Text(
                          "Subtotal",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Rs ${NumberFormat('#,##0.##').format(grandTotal)}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF555566),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Tax row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.percent_rounded,
                            size: 15, color: Color(0xFFFF8F00)),
                        const SizedBox(width: 6),
                        Text(
                          "Tax (${taxController.text}%)",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "+ Rs ${NumberFormat('#,##0.##').format(taxAmount)}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF8F00),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 14, color: Color(0xFFFFD54F)),
                // Total with tax row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total with Tax",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      "Rs ${NumberFormat('#,##0.##').format(grandTotalWithTax)}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF8F00),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _styledDropdownWrapper(
      {required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8F0), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  // ── Product Section ───────────────────────────────────────────────────────

  Widget _buildProductSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ItemDetailsDropdown(
          onItemSelected: (item) {
            setState(() => selectedProduct = item);
          },
        ),

        if (selectedProduct != null) ...[
          const SizedBox(height: 14),

          // Selected product pill
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.18), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      (selectedProduct!.name ?? 'P')[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedProduct!.name ?? 'Product',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Qty + Rate row
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: qtyController,
                  label: "Quantity",
                  icon: Icons.format_list_numbered_rounded,
                  onChanged: (_) => calculateProductTotal(), // ✅ fixed name
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  controller: rateController,
                  label: "Rate",
                  icon: Icons.payments_outlined,
                  onChanged: (_) => calculateProductTotal(), // ✅ fixed name
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Live product total
          if (productTotal > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C63FF).withOpacity(0.08),
                    const Color(0xFF4A90D9).withOpacity(0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withOpacity(0.18),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calculate_outlined,
                          size: 16, color: Color(0xFF6C63FF)),
                      SizedBox(width: 8),
                      Text(
                        "Product Total",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF888899),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Rs ${NumberFormat('#,##0.##').format(productTotal)}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 14),

          // Add button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: addProductToList,
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
                "Add Product",
                style:
                TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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
    ValueChanged<String>? onChanged,
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
        onChanged: onChanged,
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
          prefixIcon: Icon(icon, color: const Color(0xFF9E9EC0), size: 18),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  // ── Products Table ────────────────────────────────────────────────────────

  Widget _buildProductsTable() {
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
          // Header
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
                  "Product List",
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
                    "${selectedProducts.length} item${selectedProducts.length != 1 ? 's' : ''}",
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

          // Column headers
          Container(
            color: const Color(0xFFF8F8FC),
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text("Item",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9E9EC0),
                          letterSpacing: 0.5,
                        ))),
                Expanded(
                    flex: 1,
                    child: Text("Qty",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9E9EC0),
                          letterSpacing: 0.5,
                        ))),
                Expanded(
                    flex: 2,
                    child: Text("Rate",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9E9EC0),
                          letterSpacing: 0.5,
                        ))),
                Expanded(
                    flex: 2,
                    child: Text("Total",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9E9EC0),
                          letterSpacing: 0.5,
                        ))),
                SizedBox(width: 34),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F6)),

          // Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: selectedProducts.length,
            separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFFF5F5FA)),
            itemBuilder: (_, index) {
              final p = selectedProducts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Center(
                              child: Text(
                                (p["name"] ?? 'P')[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              p["name"] ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        p["qty_received"].toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF555566),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        NumberFormat('#,##0.##').format(p["unit_cost"]),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF555566),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        NumberFormat('#,##0.##').format(p["total"]),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => removeProduct(index),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4D4F).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            size: 15, color: Color(0xFFFF4D4F)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Grand total
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 14),
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
                // ✅ Shows tax-included total if tax > 0
                Text(
                  "Rs ${NumberFormat('#,##0.##').format(grandTotalWithTax > 0 ? grandTotalWithTax : grandTotal)}",
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

  Widget _buildSaveButton(GRNProvider grnProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: grnProvider.isLoading
            ? null
            : const LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        color: grnProvider.isLoading ? const Color(0xFFCCCCCC) : null,
        borderRadius: BorderRadius.circular(18),
        boxShadow: grnProvider.isLoading
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
        onPressed: grnProvider.isLoading
            ? null
            : () async {
          if (selectedSupplierId == null ||
              selectedLocationId == null ||
              selectedProducts.isEmpty) {
            _showSnack(
                "Select supplier, location & add product",
                isError: true);
            return;
          }

          final grnDate =
          DateFormat("yyyy-MM-dd").format(DateTime.now());

          final List<Map<String, dynamic>> details =
          selectedProducts.map((e) => {
            "item_id": e["item_id"] is String
                ? int.parse(e["item_id"])
                : e["item_id"],
            "qty_received": e["qty_received"],
            "unit_cost": e["unit_cost"],
          }).toList();

          final double finalTotal =
          grandTotalWithTax > 0 ? grandTotalWithTax : grandTotal;
          final double taxPercent =
              double.tryParse(taxController.text) ?? 0;

          bool success = await grnProvider.addNewGRN(
            supplierId: int.parse(selectedSupplierId!),
            grnDate: grnDate,
            products: details,
            totalAmount: finalTotal,
            grnNo: widget.nextOrderId,
            locationId: selectedLocationId!,
            details: details,
            taxPercent: taxPercent,  // ✅ from tax field
            discount: 0,
          );

          if (success) {
            _showSnack("GRN Added Successfully");
            Navigator.pop(context);
          } else {
            _showSnack("Failed to Add GRN", isError: true);
          }
        },
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
            if (grnProvider.isLoading)
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
              grnProvider.isLoading ? "Saving..." : "Save GRN",
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
  }
}