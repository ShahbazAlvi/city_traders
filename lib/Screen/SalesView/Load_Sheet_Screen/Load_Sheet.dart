
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../compoents/AppColors.dart';

import '../../../Provider/LoadingSheetProvider.dart';
import '../../../Provider/ProductProvider/ItemListsProvider.dart';
import '../../../Provider/SaleManProvider/SaleManProvider.dart';
import '../../../compoents/ProductDropdown.dart';
import '../../../compoents/SaleManDropdown.dart';
import '../../../model/load_sheet_model/Loading_sheet_model.dart';
import '../../../utils/access_control.dart';

class LoadSheetScreen extends StatefulWidget {
  const LoadSheetScreen({super.key});

  @override
  State<LoadSheetScreen> createState() => _LoadSheetScreenState();
}

class _LoadSheetScreenState extends State<LoadSheetScreen> {
  bool canAddsheet    = false;
  bool canEditsheet   = false;
  bool canDeletesheet = false;
  bool canViewsheet   = false;
 // String? _loggedInSalesmanId;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
    Future.microtask(
          () => Provider.of<LoadSheetProvider>(context, listen: false)
          .fetchLoadSheets(),
    );
  }

  Future<void> _loadPermissions() async {
    final add    = await AccessControl.canDo("can_add_load_sheet");
    final edit   = await AccessControl.canDo("can_edit_load_sheet");
    final delete = await AccessControl.canDo("can_delete_load_sheet");
    final view   = await AccessControl.canDo("can_view_load_sheet");

    setState(() {
      canAddsheet    = add;
      canEditsheet   = edit;
      canDeletesheet = delete;
      canViewsheet   = view;
    });
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return const Color(0xFF16A34A);
      case 'PENDING':
        return const Color(0xFFD97706);
      case 'REJECTED':
        return const Color(0xFFDC2626);
      default:
        return Colors.grey;
    }
  }

  Color _statusBg(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return const Color(0xFFDCFCE7);
      case 'PENDING':
        return const Color(0xFFFEF3C7);
      case 'REJECTED':
        return const Color(0xFFFEE2E2);
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoadSheetProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.text),
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
          'Load Sheets',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 22),
            onPressed: provider.fetchLoadSheets,
          ),
          const SizedBox(width: 4),
        ],
      ),

      floatingActionButton: canAddsheet?
      FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const CreateLoadSheetScreen()),
        ).then((_) => provider.fetchLoadSheets()),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Load Sheet',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        elevation: 2,
      ):null,
      body: provider.isLoading
          ? _buildLoadingList()
          : provider.error != null
          ? _buildError(provider)
          : provider.loadSheets.isEmpty
          ? _buildEmpty()
          : _buildList(provider.loadSheets),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> sheets) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: sheets.length,
      itemBuilder: (context, index) {
        final sheet = sheets[index];
        final status = (sheet['status'] ?? 'PENDING') as String;
        final loadDate = sheet['load_date'] != null
            ? DateFormat('dd MMM yyyy')
            .format(DateTime.parse(sheet['load_date']))
            : '—';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Load No badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sheet['load_no'] ?? '—',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusBg(status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.person_outline_rounded,
                      label: sheet['salesman_name'] ?? '—',
                    ),
                    const SizedBox(width: 10),
                    _InfoChip(
                      icon: Icons.calendar_today_rounded,
                      label: loadDate,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _StatItem(
                      label: 'Total Items',
                      value:
                      '${sheet['total_items'] ?? 0}',
                    ),
                    Container(
                      width: 1,
                      height: 28,
                      color: const Color(0xFFE5E7EB),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    _StatItem(
                      label: 'Total Qty',
                      value: double.tryParse(
                          sheet['total_qty_loaded']?.toString() ??
                              '0')
                          ?.toStringAsFixed(0) ??
                          '0',
                    ),
                    const Spacer(),
                    if (sheet['vehicle_name'] != null)
                      _InfoChip(
                        icon: Icons.local_shipping_outlined,
                        label: sheet['vehicle_name'],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        height: 130,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const _ShimmerBox(),
      ),
    );
  }

  Widget _buildError(LoadSheetProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 56, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(provider.error!,
              style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.fetchLoadSheets,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.assignment_outlined,
                size: 40, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 16),
          const Text('No load sheets yet',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827))),
          const SizedBox(height: 6),
          const Text('Tap + to create your first load sheet',
              style:
              TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CREATE LOAD SHEET SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class CreateLoadSheetScreen extends StatefulWidget {
  const CreateLoadSheetScreen({super.key});

  @override
  State<CreateLoadSheetScreen> createState() =>
      _CreateLoadSheetScreenState();
}

class _CreateLoadSheetScreenState extends State<CreateLoadSheetScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _loadNoController = TextEditingController();
  final _dateController = TextEditingController();

  // State
  String? _selectedSalesmanId;
  String? _selectedSalesmanName;
  DateTime _selectedDate = DateTime.now();
  final List<LoadSheetDetail> _details = [];

  // For "add item" row (temporary)
  int? _pendingItemId;
  String? _pendingItemName;
  final _qtyController = TextEditingController();

  bool _isSalesmanLocked = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _checkSalesmanLock();

    // Fetch items, employees, and load sheets (for auto load_no)
    Future.microtask(() async {
      Provider.of<ItemDetailsProvider>(context, listen: false).fetchItems();
      Provider.of<SaleManProvider>(context, listen: false).fetchEmployees();
      final lsProvider = Provider.of<LoadSheetProvider>(context, listen: false);
      await lsProvider.fetchLoadSheets();
      if (mounted) {
        setState(() {
          _loadNoController.text = lsProvider.nextLoadNo;
        });
      }
    });
  }

  Future<void> _checkSalesmanLock() async {
    final prefs = await SharedPreferences.getInstance();
    final salesmanId = prefs.containsKey('salesman_id')
        ? prefs.getInt('salesman_id')
        : null;

    if (salesmanId != null && mounted) {
      // Get salesman name from provider after it loads
      final provider =
      Provider.of<SaleManProvider>(context, listen: false);
      setState(() {
        _selectedSalesmanId = salesmanId.toString();
        _isSalesmanLocked = true;
      });
      // Try to resolve name immediately if employees already loaded
      _resolveSalesmanName(provider, salesmanId.toString());
    }
  }

  void _resolveSalesmanName(SaleManProvider provider, String id) {
    if (provider.employees.isNotEmpty) {
      try {
        final emp =
        provider.employees.firstWhere((e) => e.id.toString() == id);
        if (mounted) setState(() => _selectedSalesmanName = emp.name);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _loadNoController.dispose();
    _dateController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
          ColorScheme.light(primary: Theme.of(context).primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _addItem() {
    final qty = double.tryParse(_qtyController.text.trim());
    if (_pendingItemId == null || qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product and enter valid qty'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _details.add(LoadSheetDetail(
        itemId: _pendingItemId!,
        itemName: _pendingItemName ?? '',
        qtyLoaded: qty,
      ));
      _pendingItemId = null;
      _pendingItemName = null;
      _qtyController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() => _details.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSalesmanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a salesman'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider =
    Provider.of<LoadSheetProvider>(context, listen: false);
    final success = await provider.createLoadSheet(
      loadNo: _loadNoController.text.trim(),
      loadDate: _dateController.text.trim(),
      salesmanId: int.parse(_selectedSalesmanId!),
      details: _details,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Load sheet created successfully!'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to create'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoadSheetProvider>(context);
    final salesmanProvider = Provider.of<SaleManProvider>(context);

    // Auto-resolve salesman name once employees load
    if (_isSalesmanLocked &&
        _selectedSalesmanId != null &&
        _selectedSalesmanName == null) {
      _resolveSalesmanName(salesmanProvider, _selectedSalesmanId!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.text),
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
          'New Load Sheet',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
          children: [
            // ── Section: Load Info ─────────────────────────────────────────
            _SectionCard(
              title: 'Load Information',
              icon: Icons.assignment_outlined,
              children: [
                // Load No
                _FieldLabel(label: 'Load Number'),
                TextFormField(
                  controller: _loadNoController,
                  readOnly: true,
                  decoration: _inputDecoration(
                    hint: 'Auto-generated',
                    prefixIcon: Icons.tag_rounded,
                  ),
                ),
                const SizedBox(height: 14),

                // Load Date
                _FieldLabel(label: 'Load Date'),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: _inputDecoration(
                    hint: 'Select date',
                    prefixIcon: Icons.calendar_today_rounded,
                    suffixIcon: Icons.edit_calendar_rounded,
                  ),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),

                // Salesman
                _FieldLabel(label: 'Salesman'),
                SalesmanDropdown(
                  selectedId: _selectedSalesmanId,
                  isLocked: _isSalesmanLocked,
                  onChanged: (id) {
                    if (!_isSalesmanLocked) {
                      setState(() => _selectedSalesmanId = id);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Section: Products ──────────────────────────────────────────
            _SectionCard(
              title: 'Products',
              icon: Icons.inventory_2_outlined,
              trailing: Text(
                '${_details.length} item${_details.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                // Add item row
                _FieldLabel(label: 'Select Product'),
                ItemDetailsDropdown(
                  onItemSelected: (item) {
                    if (item != null) {
                      setState(() {
                        _pendingItemId = int.tryParse(item.id);
                        _pendingItemName = item.name;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Qty + Add button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel(label: 'Qty to Load'),
                          TextFormField(
                            controller: _qtyController,
                            keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,3}'))
                            ],
                            decoration: _inputDecoration(
                              hint: '0',
                              prefixIcon: Icons.numbers_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 22),
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Items list
                if (_details.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFE5E7EB), width: 1),
                    ),
                    child: Column(
                      children: [
                        // Header row
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          child: Row(
                            children: const [
                              Expanded(
                                flex: 4,
                                child: Text('Product',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF9CA3AF))),
                              ),
                              SizedBox(
                                width: 70,
                                child: Text('Qty',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF9CA3AF))),
                              ),
                              SizedBox(width: 32),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _details.length,
                          separatorBuilder: (_, __) => const Divider(
                              height: 1, color: Color(0xFFE5E7EB)),
                          itemBuilder: (context, index) {
                            final detail = _details[index];
                            return _DetailRow(
                              detail: detail,
                              index: index,
                              onRemove: () => _removeItem(index),
                              onQtyChanged: (newQty) {
                                setState(() =>
                                _details[index].qtyLoaded = newQty);
                              },
                            );
                          },
                        ),
                        // Total row
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 4,
                                child: Text('Total',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827))),
                              ),
                              SizedBox(
                                width: 70,
                                child: Text(
                                  _details
                                      .fold<double>(
                                      0,
                                          (sum, d) => sum + d.qtyLoaded)
                                      .toStringAsFixed(1),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 32),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),

      // ── Bottom Submit Button ───────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border:
          Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: provider.isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
              AppColors.primary.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: provider.isSubmitting
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
                : const Text(
              'Create Load Sheet',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
      TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon:
      Icon(prefixIcon, size: 18, color: Colors.grey.shade500),
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, size: 18, color: Colors.grey.shade400)
          : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: Theme.of(context).primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: Color(0xFFDC2626), width: 1),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DETAIL ROW  (editable qty inline)
// ─────────────────────────────────────────────────────────────────────────────

class _DetailRow extends StatefulWidget {
  final LoadSheetDetail detail;
  final int index;
  final VoidCallback onRemove;
  final ValueChanged<double> onQtyChanged;

  const _DetailRow({
    required this.detail,
    required this.index,
    required this.onRemove,
    required this.onQtyChanged,
  });

  @override
  State<_DetailRow> createState() => _DetailRowState();
}

class _DetailRowState extends State<_DetailRow> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.detail.qtyLoaded.toStringAsFixed(
            widget.detail.qtyLoaded % 1 == 0 ? 0 : 2));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          // Index badge
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${widget.index + 1}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Name
          Expanded(
            flex: 4,
            child: Text(
              widget.detail.itemName,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Qty field
          SizedBox(
            width: 70,
            child: TextFormField(
              controller: _ctrl,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,3}'))
              ],
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: Colors.grey.shade300, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 1.5),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) {
                final parsed = double.tryParse(v);
                if (parsed != null && parsed > 0) {
                  widget.onQtyChanged(parsed);
                }
              },
            ),
          ),
          // Remove
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFEF4444), size: 18),
            onPressed: widget.onRemove,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    this.trailing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon,
                      size: 16, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                if (trailing != null) ...[
                  const Spacer(),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827))),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF9CA3AF))),
      ],
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox();

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade200,
              Colors.grey.shade100,
              Colors.grey.shade200,
            ],
            stops: [0.0, _anim.value, 1.0],
          ),
        ),
      ),
    );
  }
}