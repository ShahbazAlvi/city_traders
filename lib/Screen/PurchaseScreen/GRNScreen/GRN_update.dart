import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Provider/Purchase_Provider/GRNProvider/GRN_Provider.dart';
import '../../../Provider/SupplierProvider/Supplier_services.dart';
import '../../../Provider/setup/location_provider.dart';
import '../../../compoents/AppColors.dart';
import '../../../compoents/ProductDropdown.dart';
import '../../../compoents/SupplierDropdown.dart';
import '../../../compoents/location_dropdown.dart';
import '../../../model/ProductModel/itemsdetailsModel.dart';
import '../../../model/Purchase_Model/GNRModel/GNR_Model.dart';

class GrnUpdate extends StatefulWidget {
  final GRNModel grn;

  const GrnUpdate({super.key, required this.grn});

  @override
  State<GrnUpdate> createState() => _GrnUpdateState();
}

class _GrnUpdateState extends State<GrnUpdate> with SingleTickerProviderStateMixin {
  final qtyController = TextEditingController();
  final rateController = TextEditingController();
  final discountController = TextEditingController(text: "0");
  final taxController = TextEditingController(text: "0");

  String? selectedSupplierId;
  int? selectedLocationId;
  ItemDetails? selectedProduct;

  List<Map<String, dynamic>> selectedProducts = [];
  double productTotal = 0;
  
  bool _isFirstLoad = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

    selectedSupplierId = widget.grn.supplierId.toString();
    selectedLocationId = widget.grn.locationId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final grnProvider = Provider.of<GRNProvider>(context, listen: false);
    await grnProvider.fetchGrnDetails(widget.grn.id);
    
    if (grnProvider.selectedGrnDetails != null) {
      final details = grnProvider.selectedGrnDetails!;
      setState(() {
        discountController.text = details.discount.toStringAsFixed(0);
        taxController.text = details.taxPercent.toStringAsFixed(0);
        
        selectedProducts = details.details.map<Map<String, dynamic>>((item) => <String, dynamic>{
          "item_id": item.itemId,
          "name": item.itemName,
          "qty_received": item.qtyReceived,
          "unit_cost": item.unitCost,
          "total": item.lineTotal,
        }).toList();
        
        _isFirstLoad = false;
      });
    }

    Provider.of<LocationProvider>(context, listen: false).getLocations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    qtyController.dispose();
    rateController.dispose();
    discountController.dispose();
    taxController.dispose();
    super.dispose();
  }

  // ── Calculation ───────────────────────────────────────────────────────────

  void calculateProductTotal() {
    final qty = double.tryParse(qtyController.text) ?? 0;
    final rate = double.tryParse(rateController.text) ?? 0;
    setState(() => productTotal = qty * rate);
  }

  double get subTotal => selectedProducts.fold(0.0, (sum, item) => sum + (item["total"] as double));
  double get discount => double.tryParse(discountController.text) ?? 0;
  double get taxPercent => double.tryParse(taxController.text) ?? 0;
  double get taxAmount => (subTotal - discount) * (taxPercent / 100);
  double get grandTotal => (subTotal - discount) + taxAmount;

  // ── Actions ───────────────────────────────────────────────────────────────

  void addProductToList() {
    if (selectedProduct == null || qtyController.text.isEmpty || rateController.text.isEmpty) {
      _showSnack("Please fill all product fields", isError: true);
      return;
    }

    final qty = double.parse(qtyController.text);
    final rate = double.parse(rateController.text);

    setState(() {
      final existingIndex = selectedProducts.indexWhere((p) => p["item_id"] == selectedProduct!.id);

      if (existingIndex != -1) {
        selectedProducts[existingIndex]["qty_received"] = qty;
        selectedProducts[existingIndex]["unit_cost"] = rate;
        selectedProducts[existingIndex]["total"] = qty * rate;
        _showSnack("Product updated in list");
      } else {
        selectedProducts.add(<String, dynamic>{
          "item_id": selectedProduct!.id,
          "name": selectedProduct!.name,
          "qty_received": qty,
          "unit_cost": rate,
          "total": qty * rate,
        });
        _showSnack("Product added to list");
      }

      _clearProductForm();
    });
  }

  void _clearProductForm() {
    qtyController.clear();
    rateController.clear();
    selectedProduct = null;
    productTotal = 0;
  }

  void removeProduct(int index) {
    setState(() => selectedProducts.removeAt(index));
  }

  Future<void> _saveGRN() async {
    if (selectedSupplierId == null || selectedLocationId == null || selectedProducts.isEmpty) {
      _showSnack("Select supplier, location & add at least one product", isError: true);
      return;
    }

    final grnProvider = Provider.of<GRNProvider>(context, listen: false);
    
    // Calculate aging due date if supplier changed or use existing
    String agingDueDate;
    if (selectedSupplierId == widget.grn.supplierId.toString() && grnProvider.selectedGrnDetails?.agingDueDate != null) {
       agingDueDate = DateFormat("yyyy-MM-dd").format(grnProvider.selectedGrnDetails!.agingDueDate!);
    } else {
       // Fetch aging days for new supplier
       int agingDays = await SupplierApi.fetchSupplierAging(int.parse(selectedSupplierId!));
       agingDueDate = DateFormat("yyyy-MM-dd").format(DateTime.now().add(Duration(days: agingDays)));
    }

    final List<Map<String, dynamic>> details = selectedProducts.map((e) => {
      "item_id": e["item_id"] is String ? int.parse(e["item_id"]) : e["item_id"],
      "qty_received": e["qty_received"],
      "unit_cost": e["unit_cost"],
    }).toList();

    bool success = await grnProvider.updateGRN(
      id: widget.grn.id,
      grnNo: widget.grn.grnNo,
      supplierId: int.parse(selectedSupplierId!),
      grnDate: DateFormat("yyyy-MM-dd").format(widget.grn.grnDate),
      locationId: selectedLocationId!,
      status: "POSTED",
      agingDueDate: agingDueDate,
      discount: discount,
      taxPercent: taxPercent,
      details: details,
    );

    if (success) {
      _showSnack("GRN Updated Successfully");
      Navigator.pop(context, true);
    } else {
      _showSnack("Failed to Update GRN", isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: isError ? const Color(0xFFFF4D4F) : const Color(0xFF00C896),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Build UI ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final grnProvider = Provider.of<GRNProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: _buildAppBar(),
      body: grnProvider.isLoading && _isFirstLoad
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                child: Column(
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: "Order Details",
                      icon: Icons.assignment_outlined,
                      child: _buildDetailsSection(),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: "Add Product",
                      icon: Icons.add_shopping_cart_rounded,
                      child: _buildProductEntrySection(),
                    ),
                    const SizedBox(height: 16),
                    if (selectedProducts.isNotEmpty) _buildProductsList(),
                    const SizedBox(height: 16),
                    _buildPricingCard(),
                  ],
                ),
              ),
            ),
      bottomSheet: _buildBottomAction(grnProvider),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        "Edit GRN",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.secondary, AppColors.primary]),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.grn.grnNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                "Date: ${DateFormat('dd MMM yyyy').format(widget.grn.grnDate)}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          _statusBadge(widget.grn.status),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF00C896).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Color(0xFF00C896), fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      children: [
        _dropdownWrapper(
          child: SupplierDropdown(
            selectedSupplierId: selectedSupplierId,
            onSelected: (id) => setState(() => selectedSupplierId = id),
          ),
        ),
        const SizedBox(height: 12),
        _dropdownWrapper(
          child: Consumer<LocationProvider>(
            builder: (context, locProv, _) => LocationDropdown(
              locations: locProv.locationList,
              selectedId: selectedLocationId,
              onChanged: (id) => setState(() => selectedLocationId = id),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownWrapper({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8F0)),
      ),
      child: child,
    );
  }

  Widget _buildProductEntrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ItemDetailsDropdown(onItemSelected: (item) => setState(() => selectedProduct = item)),
        if (selectedProduct != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _qtyField(
                  controller: qtyController,
                  label: "Qty",
                  onChanged: (_) => calculateProductTotal(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _qtyField(
                  controller: rateController,
                  label: "Rate",
                  onChanged: (_) => calculateProductTotal(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total: ₨ ${NumberFormat('#,##0').format(productTotal)}",
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              ElevatedButton.icon(
                onPressed: addProductToList,
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text("Add", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _qtyField({required TextEditingController controller, required String label, Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        filled: true,
        fillColor: const Color(0xFFF8F9FB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildProductsList() {
    return _buildSectionCard(
      title: "Added Products",
      icon: Icons.list_alt_rounded,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: selectedProducts.length,
        separatorBuilder: (_, __) => const Divider(height: 20),
        itemBuilder: (context, index) {
          final p = selectedProducts[index];
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p["name"], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      "${p["qty_received"]} x ₨ ${p["unit_cost"]}",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                "₨ ${NumberFormat('#,##0').format(p["total"])}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                onPressed: () => removeProduct(index),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPricingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _priceRow("Subtotal", subTotal, isSmall: true),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text("Discount", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ),
              SizedBox(
                width: 80,
                height: 35,
                child: TextField(
                  controller: discountController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text("Tax (%)", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ),
              SizedBox(
                width: 80,
                height: 35,
                child: TextField(
                  controller: taxController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          _priceRow("Grand Total", grandTotal),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double val, {bool isSmall = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isSmall ? Colors.white70 : Colors.white, fontSize: isSmall ? 14 : 16, fontWeight: isSmall ? null : FontWeight.bold)),
        Text(
          "₨ ${NumberFormat('#,##0.##').format(val)}",
          style: TextStyle(color: Colors.white, fontSize: isSmall ? 14 : 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBottomAction(GRNProvider grnProv) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: grnProv.isLoading ? null : _saveGRN,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: grnProv.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Update GRN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
