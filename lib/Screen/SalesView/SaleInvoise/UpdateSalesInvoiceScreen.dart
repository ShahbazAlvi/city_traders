import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../ApiLink/ApiEndpoint.dart';
import '../../../Provider/CustomerProvider/CustomerProvider.dart';
import '../../../Provider/SaleInvoiceProvider/SaleInvoicesProvider.dart';
import '../../../Provider/SaleManProvider/SaleManProvider.dart';
import '../../../Provider/setup/Delivery_boy_provider.dart';
import '../../../Provider/setup/location_provider.dart';
import '../../../compoents/AppColors.dart';
import '../../../compoents/ProductDropdown.dart';
import '../../../compoents/SalesAreaDropdown.dart';
import '../../../compoents/DeliveryBoyDropdown.dart';
import '../../../Provider/setup/SalesAreasProvider.dart';
import '../../../model/ProductModel/itemsdetailsModel.dart';
import '../../../model/SaleInvoiceModel/SaleInvoiceDetailsModel.dart';

class UpdateSalesInvoiceScreen extends StatefulWidget {
  final int invoiceId;
  final String invNo;

  const UpdateSalesInvoiceScreen({
    super.key,
    required this.invoiceId,
    required this.invNo,
  });

  @override
  State<UpdateSalesInvoiceScreen> createState() =>
      _UpdateSalesInvoiceScreenState();
}

class _UpdateSalesInvoiceScreenState extends State<UpdateSalesInvoiceScreen> {
  final formatter = NumberFormat('#,##,###');
  final dateFormat = DateFormat('yyyy-MM-dd');

  // Form state
  int? selectedCustomerId;
  int? selectedSalesmanId;
  int? selectedLocationId;
  int? selectedSalesAreaId;
  int? selectedDeliveryBoyId;
  String selectedStatus = 'POSTED';
  String selectedInvoiceType = 'CASH';
  late TextEditingController dateController;

  // Items
  List<_EditableInvoiceItem> editableItems = [];

  // Add product panel
  bool _showAddProduct = false;
  ItemDetails? _newProduct;
  final TextEditingController _newQtyController = TextEditingController();
  final TextEditingController _newRateController = TextEditingController();

  bool isLoading = false;
  bool isFetchingInvoice = true;

  final List<String> statusOptions = ['POSTED', 'DRAFT', 'CANCELLED'];
  final List<String> invoiceTypeOptions = ['CASH', 'CREDIT'];

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController();

    Future.microtask(() async {
      // Load all dropdowns
      Provider.of<CustomerProvider>(context, listen: false).fetchCustomers();
      Provider.of<SaleManProvider>(context, listen: false).fetchEmployees();
      Provider.of<LocationProvider>(context, listen: false).getLocations();
      Provider.of<SalesAreasProvider>(context, listen: false).fetchSalesAreas();
      Provider.of<DeliveryBoyProvider>(context, listen: false).fetchDeliveryBoys();

      // Load invoice detail
      await Provider.of<SaleInvoicesProvider>(context, listen: false)
          .fetchSingleInvoice(widget.invoiceId);

      final invoice =
          Provider.of<SaleInvoicesProvider>(context, listen: false)
              .selectedInvoice;

      if (invoice != null && mounted) {
        setState(() {
          selectedCustomerId = invoice.customerId;
          selectedSalesmanId = invoice.salesmanId;
          selectedLocationId = invoice.locationId;
          selectedSalesAreaId = invoice.salesAreaId;
          selectedDeliveryBoyId = invoice.deliveryBoyId;
          selectedStatus = invoice.status;
          selectedInvoiceType = invoice.invoiceType;
          dateController.text = dateFormat.format(invoice.invoiceDate);
          editableItems = invoice.details
              .map((d) => _EditableInvoiceItem(
            itemId: d.itemId,
            itemName: d.itemName,
            itemSku: d.itemSku,
            qty: d.qty,
            rate: d.rate,
            unitName: d.unitName,
          ))
              .toList();
          isFetchingInvoice = false;
        });
      } else {
        setState(() => isFetchingInvoice = false);
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

  // ── Helpers ──────────────────────────────────

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
      case 'POSTED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // ── Add product ──────────────────────────────

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
      editableItems.add(_EditableInvoiceItem(
        itemId: int.tryParse(_newProduct!.id.toString()) ?? 0,
        itemName: _newProduct!.name ?? 'Product',
        itemSku: _newProduct!.sku ?? '',
        qty: qty,
        rate: rate,
        unitName: '',
      ));
      _newProduct = null;
      _newQtyController.clear();
      _newRateController.clear();
      _showAddProduct = false;
    });
  }

  void _removeItem(int index) => setState(() => editableItems.removeAt(index));

  // ── Submit ───────────────────────────────────

  Future<void> _submitUpdate() async {
    if (editableItems.isEmpty) {
      _showSnack("Add at least one product", Colors.orange);
      return;
    }
    if (selectedCustomerId == null) {
      _showSnack("Please select a customer", Colors.orange);
      return;
    }
    if (selectedSalesmanId == null) {
      _showSnack("Please select a salesman", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final body = {
        "inv_no": widget.invNo,
        "sales_order_id": null,
        "customer_id": selectedCustomerId,
        "salesman_id": selectedSalesmanId,
        "load_id": null,
        "location_id": selectedLocationId,
        "sales_area_id": selectedSalesAreaId,
        "delivery_boy_id": selectedDeliveryBoyId,
        "invoice_date": DateFormat('dd MMMM yyyy').format(DateTime.parse(dateController.text)),
        "invoice_type": selectedInvoiceType,
        "status": selectedStatus,
        "details": editableItems
            .map((i) => {
          "item_id": i.itemId,
          "qty": i.qty,
          "rate": i.rate,
        })
            .toList(),
      };

      debugPrint("📦 Update Invoice Body: ${jsonEncode(body)}");

      final response = await http.put(
        Uri.parse(
            "${ApiEndpoints.baseUrl}/sales-invoices-notax/${widget.invoiceId}"),
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
        await Provider.of<SaleInvoicesProvider>(context, listen: false)
            .fetchOrders();
        if (!mounted) return;
        _showSnack("Invoice updated successfully", Colors.green);
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
    final initial = DateTime.tryParse(dateController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
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
      body: isFetchingInvoice
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
      title: const Text("Update Invoice",
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
          Text("Updating invoice...",
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
          // ── Invoice Banner ──
          _buildInvoiceBanner(),
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

          // ── Location ──
          _buildSectionLabel("Location"),
          const SizedBox(height: 8),
          _buildLocationDropdown(),
          const SizedBox(height: 14),

          // ── Sales Area ──
          _buildSectionLabel("Sales Area"),
          const SizedBox(height: 8),
          _buildSalesAreaDropdown(),
          const SizedBox(height: 14),

          // ── Delivery Boy ──
          _buildSectionLabel("Delivery Boy"),
          const SizedBox(height: 8),
          _buildDeliveryBoyDropdown(),
          const SizedBox(height: 14),

          // ── Date + Invoice Type ──
          _buildSectionLabel("Invoice Details"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildDateField()),
              const SizedBox(width: 10),
              Expanded(child: _buildInvoiceTypeDropdown()),
            ],
          ),
          const SizedBox(height: 10),
          _buildStatusDropdown(),
          const SizedBox(height: 18),

          // ── Items ──
          _buildItemsHeader(),
          const SizedBox(height: 10),

          ...editableItems.asMap().entries.map(
                (e) => _buildItemCard(e.value, e.key),
          ),

          if (_showAddProduct) ...[
            const SizedBox(height: 8),
            _buildAddProductPanel(),
          ],

          const SizedBox(height: 16),
          _buildGrandTotal(),
          const SizedBox(height: 16),
          _buildSubmitButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Invoice Banner ───────────────────────────

  Widget _buildInvoiceBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.primary.withOpacity(0.08),
          AppColors.secondary.withOpacity(0.08),
        ]),
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
            child: const Icon(Icons.receipt_long,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.invNo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: AppColors.primary)),
                Text(dateController.text,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
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
            icon:
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
            items: cp.customers
                .map((c) => DropdownMenuItem<int>(
              value: c.id,
              child: Text(c.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13)),
            ))
                .toList(),
            onChanged: (id) => setState(() => selectedCustomerId = id),
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
            icon:
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
            items: sp.employees
                .map((e) => DropdownMenuItem<int>(
              value: e.id,
              child: Text(e.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13)),
            ))
                .toList(),
            onChanged: (id) => setState(() => selectedSalesmanId = id),
          ),
        );
      },
    );
  }

  // ── Location Dropdown ────────────────────────

  Widget _buildLocationDropdown() {
    return Consumer<LocationProvider>(
      builder: (context, lp, _) {
        if (lp.locationList.isEmpty) return _skeleton(50);
        return _dropdownCard(
          icon: Icons.location_on_outlined,
          child: DropdownButtonFormField<int>(
            value: selectedLocationId,
            isExpanded: true,
            decoration: _innerDecoration("Select Location"),
            icon:
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
            items: lp.locationList
                .map((l) => DropdownMenuItem<int>(
              value: l.id,
              child: Text(l.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13)),
            ))
                .toList(),
            onChanged: (id) => setState(() => selectedLocationId = id),
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

  // ── Delivery Boy Dropdown ────────────────────

  Widget _buildDeliveryBoyDropdown() {
    return Consumer<DeliveryBoyProvider>(
      builder: (context, dp, _) {
        if (dp.isLoading) return _skeleton(50);
        return _dropdownCard(
          icon: Icons.delivery_dining_outlined,
          child: DeliveryBoyDropdown(
            selectedId: selectedDeliveryBoyId?.toString(),
            onChanged: (id) {
              setState(() {
                selectedDeliveryBoyId = id != null ? int.tryParse(id) : null;
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
            Icon(Icons.edit, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ── Invoice Type Dropdown ────────────────────

  Widget _buildInvoiceTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedInvoiceType,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down,
              color: Colors.grey.shade500),
          items: invoiceTypeOptions
              .map((t) => DropdownMenuItem<String>(
            value: t,
            child: Row(
              children: [
                Icon(
                  t == 'CASH'
                      ? Icons.money
                      : Icons.credit_card,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(t,
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
          ))
              .toList(),
          onChanged: (val) {
            if (val != null)
              setState(() => selectedInvoiceType = val);
          },
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
                const SizedBox(width: 8),
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
        _buildSectionLabel("Invoice Items"),
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

  Widget _buildItemCard(_EditableInvoiceItem item, int index) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.itemName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                    if (item.itemSku.isNotEmpty)
                      Text(item.itemSku,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500)),
                  ],
                ),
              ),
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
              Expanded(
                child: _buildInlineField(
                  label: "Qty",
                  value: item.qty
                      .toStringAsFixed(item.qty % 1 == 0 ? 0 : 2),
                  icon: Icons.format_list_numbered,
                  onChanged: (val) => setState(
                          () => item.qty = double.tryParse(val) ?? item.qty),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInlineField(
                  label: "Rate (Rs)",
                  value: item.rate
                      .toStringAsFixed(item.rate % 1 == 0 ? 0 : 2),
                  icon: Icons.money,
                  onChanged: (val) => setState(
                          () => item.rate = double.tryParse(val) ?? item.rate),
                ),
              ),
              const SizedBox(width: 8),
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
              label: const Text("Add to Invoice",
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
        label: const Text("Update Invoice",
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

  // ── Reusable helpers ─────────────────────────

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
            child: Icon(icon, color: AppColors.primary, size: 16),
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
class _EditableInvoiceItem {
  final int itemId;
  final String itemName;
  final String itemSku;
  final String unitName;
  double qty;
  double rate;

  _EditableInvoiceItem({
    required this.itemId,
    required this.itemName,
    required this.itemSku,
    required this.unitName,
    required this.qty,
    required this.rate,
  });
}