import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Provider/Purchase_Order_Provider/Purchase_order_provider.dart';
import '../../../Provider/SupplierProvider/SupplierProvider.dart';
import '../../../Provider/SupplierProvider/Supplier_services.dart';
import '../../../compoents/AppColors.dart';
import '../../../compoents/ProductDropdown.dart';
import '../../../compoents/SupplierDropdown.dart';
import '../../../model/ProductModel/itemsdetailsModel.dart';
import '../../../model/Purchase_Order_Model/purchaseOrderDetails.dart';

class EditPurchaseOrder extends StatefulWidget {
  final int orderId;
  const EditPurchaseOrder({super.key, required this.orderId});

  @override
  State<EditPurchaseOrder> createState() => _EditPurchaseOrderState();
}

class _EditPurchaseOrderState extends State<EditPurchaseOrder> {
  final _fmt = NumberFormat('#,##,###');
  final _dateFmt = DateFormat('yyyy-MM-dd');

  // ── Form state ──────────────────────────────
  String _poNo = '';
  int? _supplierId;
  String _selectedStatus = 'APPROVED';
  DateTime _poDate = DateTime.now();
  List<_EditItem> _items = [];

  // ── Add product panel ──────────────────────
  bool _showAddPanel = false;
  ItemDetails? _newProduct;
  final TextEditingController _newQtyCtrl = TextEditingController();
  final TextEditingController _newRateCtrl = TextEditingController();

  bool _isFetching = true;
  bool _isSubmitting = false;

  final List<String> _statusOptions = [
    'DRAFT',
    'APPROVED',
    'CLOSED',
    'CANCELLED',
  ];

  @override
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      // Clear stale data first
      Provider.of<PurchaseOrderProvider>(context, listen: false)
          .clearSelectedOrder();

      // Load suppliers in parallel
      Provider.of<SupplierProvider>(context, listen: false).loadSuppliers();

      // Fetch order — await until HTTP completes
      await Provider.of<PurchaseOrderProvider>(context, listen: false)
          .fetchSinglePurchaseOrder(widget.orderId);

      // Now read the result
      final order = Provider.of<PurchaseOrderProvider>(context, listen: false)
          .selectedOrder;

      if (order != null && mounted) {
        setState(() {
          _poNo = order.poNo;
          _supplierId = order.supplierId;
          _selectedStatus = order.status;
          _poDate = order.poDate;
          _items = order.details
              .map((d) => _EditItem(
            itemId: d.itemId,
            itemName: d.itemName,
            qty: d.qty,
            rate: d.rate,
          ))
              .toList();
          _isFetching = false;
        });
      } else {
        if (mounted) setState(() => _isFetching = false);
      }
    });
  }

  @override
  void dispose() {
    _newQtyCtrl.dispose();
    _newRateCtrl.dispose();
    super.dispose();
  }

  // ── Computed ─────────────────────────────────
  double get _grandTotal =>
      _items.fold(0.0, (s, i) => s + i.qty * i.rate);

  // ── Snack ────────────────────────────────────
  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── Status color ─────────────────────────────
  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'APPROVED':
        return const Color(0xFF00C896);
      case 'CLOSED':
        return const Color(0xFF4A90D9);
      case 'CANCELLED':
        return const Color(0xFFFF4D4F);
      default:
        return const Color(0xFFFFAB00);
    }
  }

  // ── Date picker ──────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _poDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: AppColors.primary, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _poDate = picked);
  }

  // ── Add product ──────────────────────────────
  void _addProduct() {
    if (_newProduct == null) {
      _snack("Please select a product", const Color(0xFFFFAB00));
      return;
    }
    final qty = double.tryParse(_newQtyCtrl.text.trim()) ?? 0;
    final rate = double.tryParse(_newRateCtrl.text.trim()) ?? 0;
    if (qty <= 0) {
      _snack("Enter a valid quantity", const Color(0xFFFFAB00));
      return;
    }
    if (rate <= 0) {
      _snack("Enter a valid rate", const Color(0xFFFFAB00));
      return;
    }
    setState(() {
      _items.add(_EditItem(
        itemId: int.tryParse(_newProduct!.id.toString()) ?? 0,
        itemName: _newProduct!.name ?? 'Product',
        qty: qty,
        rate: rate,
      ));
      _newProduct = null;
      _newQtyCtrl.clear();
      _newRateCtrl.clear();
      _showAddPanel = false;
    });
  }

  void _removeItem(int index) => setState(() => _items.removeAt(index));

  // ── Submit ───────────────────────────────────
  Future<void> _submit() async {
    if (_supplierId == null) {
      _snack("Please select a supplier", const Color(0xFFFFAB00));
      return;
    }
    if (_items.isEmpty) {
      _snack("Add at least one product", const Color(0xFFFFAB00));
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await Provider.of<PurchaseOrderProvider>(
        context,
        listen: false)
        .updatePurchaseOrder(
      orderId: widget.orderId,
      poNo: _poNo,
      supplierId: _supplierId!,
      status: _selectedStatus,
      poDate: _poDate,
      details: _items
          .map((i) => {
        "item_id": i.itemId,
        "qty": i.qty,
        "rate": i.rate,
      })
          .toList(),
    );

    setState(() => _isSubmitting = false);

    if (success) {
      _snack("Purchase order updated successfully", const Color(0xFF00C896));
      if (mounted) Navigator.pop(context, true);
    } else {
      final err = Provider.of<PurchaseOrderProvider>(context, listen: false)
          .error ??
          "Update failed";
      _snack(err, const Color(0xFFFF4D4F));
    }
  }

  // ── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: _buildAppBar(),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : _isSubmitting
          ? _buildSubmittingOverlay()
          : _buildBody(),
    );
  }

  // ── AppBar ────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
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
            const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Edit Purchase Order",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 17)),
                      Text(_poNo,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12)),
                    ],
                  ),
                ),
                // Status chip in appbar
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.35)),
                  ),
                  child: Text(_selectedStatus,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmittingOverlay() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text("Updating order...",
              style: TextStyle(
                  fontSize: 15, color: Color(0xFF888899))),
        ],
      ),
    );
  }

  // ── Body ─────────────────────────────────────
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Order banner ──
          _buildOrderBanner(),
          const SizedBox(height: 16),

          // ── Supplier ──
          _buildSectionLabel("Supplier"),
          const SizedBox(height: 8),
          _buildSupplierDropdown(),
          const SizedBox(height: 14),

          // ── Date + Status row ──
          Row(
            children: [
              Expanded(child: _buildDatePicker()),
              const SizedBox(width: 10),
              Expanded(child: _buildStatusDropdown()),
            ],
          ),
          const SizedBox(height: 18),

          // ── Items header ──
          _buildItemsHeader(),
          const SizedBox(height: 10),

          // ── Item cards ──
          ..._items.asMap().entries.map(
                (e) => _buildItemCard(e.value, e.key),
          ),

          // ── Add product panel ──
          if (_showAddPanel) ...[
            const SizedBox(height: 8),
            _buildAddPanel(),
          ],

          const SizedBox(height: 16),

          // ── Grand total ──
          _buildGrandTotal(),
          const SizedBox(height: 16),

          // ── Submit ──
          _buildSubmitButton(),
        ],
      ),
    );
  }

  // ── Order Banner ──────────────────────────────
  Widget _buildOrderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.primary.withOpacity(0.07),
          AppColors.secondary.withOpacity(0.07),
        ]),
        borderRadius: BorderRadius.circular(18),
        border:
        Border.all(color: AppColors.primary.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_poNo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary)),
                Text(_dateFmt.format(_poDate),
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF888899))),
              ],
            ),
          ),
          _statusChip(_selectedStatus),
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
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 7,
              height: 7,
              decoration:
              BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(status,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11)),
        ],
      ),
    );
  }

  // ── Section Label ─────────────────────────────
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

  // ── Supplier Dropdown ─────────────────────────
  Widget _buildSupplierDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.09),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.storefront_rounded,
                color: AppColors.primary, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SupplierDropdown(
              selectedSupplierId: _supplierId?.toString(),
              onSelected: (value) {
                setState(() => _supplierId = int.tryParse(value));
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Date Picker ───────────────────────────────
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_dateFmt.format(_poDate),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.edit_rounded,
                size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ── Status Dropdown ───────────────────────────
  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down,
              color: Colors.grey.shade500),
          items: _statusOptions
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
            if (val != null) setState(() => _selectedStatus = val);
          },
        ),
      ),
    );
  }

  // ── Items Header ──────────────────────────────
  Widget _buildItemsHeader() {
    return Row(
      children: [
        const Text("Order Items",
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.09),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text("${_items.length}",
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700)),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() {
            _showAddPanel = !_showAddPanel;
            if (!_showAddPanel) {
              _newProduct = null;
              _newQtyCtrl.clear();
              _newRateCtrl.clear();
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _showAddPanel
                  ? const Color(0xFFFF4D4F).withOpacity(0.08)
                  : AppColors.primary.withOpacity(0.09),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _showAddPanel
                    ? const Color(0xFFFF4D4F).withOpacity(0.3)
                    : AppColors.primary.withOpacity(0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _showAddPanel ? Icons.close : Icons.add,
                  size: 14,
                  color: _showAddPanel
                      ? const Color(0xFFFF4D4F)
                      : AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  _showAddPanel ? "Cancel" : "Add Product",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _showAddPanel
                          ? const Color(0xFFFF4D4F)
                          : AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Item Card ─────────────────────────────────
  Widget _buildItemCard(_EditItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Index
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(9)),
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
              // Delete
              GestureDetector(
                onTap: () => _removeItem(index),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFF4D4F).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFFF4D4F), size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _inlineField(
                  label: "Qty",
                  initial: item.qty
                      .toStringAsFixed(item.qty % 1 == 0 ? 0 : 2),
                  icon: Icons.format_list_numbered_rounded,
                  onChanged: (v) => setState(
                          () => item.qty = double.tryParse(v) ?? item.qty),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _inlineField(
                  label: "Rate (Rs)",
                  initial: item.rate
                      .toStringAsFixed(item.rate % 1 == 0 ? 0 : 2),
                  icon: Icons.money_rounded,
                  onChanged: (v) => setState(
                          () => item.rate = double.tryParse(v) ?? item.rate),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _totalBadge(item.qty * item.rate)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Add Product Panel ─────────────────────────
  Widget _buildAddPanel() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border:
        Border.all(color: AppColors.primary.withOpacity(0.18)),
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add_shopping_cart_rounded,
                    color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              const Text("Add New Product",
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),

          // Product search
          Container(
            decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(14),
                border:
                Border.all(color: const Color(0xFFE8E8F0))),
            child: ItemDetailsDropdown(
              onItemSelected: (item) {
                setState(() => _newProduct = item);
                if (item != null) {
                  _newRateCtrl.text =
                      item.salePrice?.toString() ?? '';
                }
              },
            ),
          ),

          // Selected product preview
          if (_newProduct != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _newProduct!.name ?? 'Product',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFF00C896)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      'Rs ${_newProduct!.salePrice?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                          color: Color(0xFF00C896),
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Qty + Rate
          Row(
            children: [
              Expanded(
                child: _inlineFieldCtrl(
                    controller: _newQtyCtrl,
                    label: "Quantity",
                    icon: Icons.format_list_numbered_rounded),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _inlineFieldCtrl(
                    controller: _newRateCtrl,
                    label: "Rate (Rs)",
                    icon: Icons.money_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _addProduct,
              icon: const Icon(Icons.add_rounded, size: 18),
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

  // ── Grand Total ───────────────────────────────
  Widget _buildGrandTotal() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.secondary, AppColors.primary]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
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
            "Rs ${_fmt.format(_grandTotal)}",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ── Submit Button ─────────────────────────────
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submit,
        icon: const Icon(Icons.check_circle_outline_rounded,
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

  // ── Reusable widgets ──────────────────────────

  Widget _inlineField({
    required String label,
    required String initial,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8F0)),
      ),
      child: TextFormField(
        initialValue: initial,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              color: Color(0xFF9E9EB0), fontSize: 11),
          prefixIcon: Icon(icon,
              size: 14, color: const Color(0xFF9E9EB0)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: const Color(0xFFF5F6FA),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 10),
          isDense: true,
        ),
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _inlineFieldCtrl({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8F0)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              fontSize: 12, color: Color(0xFF9E9EB0)),
          prefixIcon:
          Icon(icon, size: 16, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }

  Widget _totalBadge(double amount) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FBF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB2EDD8)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total",
              style: TextStyle(
                  color: Color(0xFF00C896),
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
          Text(
            "Rs ${_fmt.format(amount)}",
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: Color(0xFF00875A)),
          ),
        ],
      ),
    );
  }

  Widget _skeleton(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(16)),
    );
  }
}

// ── Local editable item model ─────────────────────────────────────────────────
class _EditItem {
  final int itemId;
  final String itemName;
  double qty;
  double rate;

  _EditItem({
    required this.itemId,
    required this.itemName,
    required this.qty,
    required this.rate,
  });
}