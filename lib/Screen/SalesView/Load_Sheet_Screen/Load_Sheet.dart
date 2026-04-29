

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
        onPressed: () async {
          // Show loading dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          try {
            final nextNo = await provider.fetchNextLoadNo();
            if (context.mounted) {
              Navigator.pop(context); // Close loading dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateLoadSheetScreen(initialLoadNo: nextNo),
                ),
              ).then((_) => provider.fetchLoadSheets());
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context); // Close loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        },
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
  void _confirmDelete(BuildContext context, Map<String, dynamic> sheet) {
    final provider = Provider.of<LoadSheetProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Delete Load Sheet'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${sheet['load_no']}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
              await provider.deleteLoadSheet(sheet['id'] as int);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? 'Load sheet deleted' : (provider.error ?? 'Failed'),
                  ),
                  backgroundColor: success ? const Color(0xFF16A34A) : Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
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
                    // After the status chip Container in the Row:
                    const SizedBox(width: 8),
                    if (canDeletesheet)
                      GestureDetector(
                        onTap: () => _confirmDelete(context, sheet),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: Colors.red.shade400,
                          ),
                        ),
                      ),
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
//  CREATE LOAD SHEET SCREEN  (Multi‐step wizard)
// ─────────────────────────────────────────────────────────────────────────────

class CreateLoadSheetScreen extends StatefulWidget {
  final String? initialLoadNo;
  const CreateLoadSheetScreen({super.key, this.initialLoadNo});

  @override
  State<CreateLoadSheetScreen> createState() =>
      _CreateLoadSheetScreenState();
}

class _CreateLoadSheetScreenState extends State<CreateLoadSheetScreen> {
  // ── Step tracking (0 = Info, 1 = Select Orders, 2 = Items/Submit) ──
  int _currentStep = 0;

  // Controllers
  final _formKey = GlobalKey<FormState>();
  final _loadNoController = TextEditingController();
  final _dateController = TextEditingController();

  // State
  String? _selectedSalesmanId;
  String? _selectedSalesmanName;
  DateTime _selectedDate = DateTime.now();
  bool _isSalesmanLocked = false;

  // Step 1: selected sales order IDs
  final Set<int> _selectedSOIds = {};

  // Step 2: editable qty map (item_id → qty)
  final Map<int, double> _editableQty = {};

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _checkSalesmanLock();

    Future.microtask(() async {
      Provider.of<SaleManProvider>(context, listen: false).fetchEmployees();
      final lsProvider = Provider.of<LoadSheetProvider>(context, listen: false);
      await lsProvider.fetchLoadSheets();

      String? finalLoadNo = widget.initialLoadNo;
      if (finalLoadNo == null) {
        finalLoadNo = await lsProvider.fetchNextLoadNo();
      }

      if (mounted) {
        setState(() {
          _loadNoController.text = finalLoadNo!;
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
      final provider =
      Provider.of<SaleManProvider>(context, listen: false);
      setState(() {
        _selectedSalesmanId = salesmanId.toString();
        _isSalesmanLocked = true;
      });
      _resolveSalesmanName(provider, salesmanId.toString());
      // Auto-fetch sales orders for locked salesman
      _fetchOrdersForSalesman(salesmanId);
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

  void _fetchOrdersForSalesman(int salesmanId) {
    Provider.of<LoadSheetProvider>(context, listen: false)
        .fetchSalesOrdersBySalesman(salesmanId);
  }

  @override
  void dispose() {
    _loadNoController.dispose();
    _dateController.dispose();
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

  void _goToStep1() {
    if (_selectedSalesmanId == null) {
      _showSnack('Please select a salesman first');
      return;
    }
    setState(() => _currentStep = 1);
  }

  void _goToStep2() async {
    if (_selectedSOIds.isEmpty) {
      _showSnack('Please select at least one sales order');
      return;
    }
    // Fetch items for selected orders
    final provider = Provider.of<LoadSheetProvider>(context, listen: false);
    await provider.fetchSOItems(_selectedSOIds.toList());

    // Populate editable qty from fetched items
    _editableQty.clear();
    for (final item in provider.soItems) {
      final itemId = item['item_id'] as int;
      final qty = item['so_qty'] is double
          ? item['so_qty'] as double
          : double.tryParse(item['so_qty']?.toString() ?? '0') ?? 0;
      _editableQty[itemId] = qty;
    }

    setState(() => _currentStep = 2);
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submit() async {
    final provider = Provider.of<LoadSheetProvider>(context, listen: false);

    // Build details from items
    final details = <LoadSheetDetail>[];
    for (final item in provider.soItems) {
      final itemId = item['item_id'] as int;
      final qty = _editableQty[itemId] ?? 0;
      if (qty > 0) {
        details.add(LoadSheetDetail(
          itemId: itemId,
          itemName: item['item_name'] ?? '',
          qtyLoaded: qty,
        ));
      }
    }

    if (details.isEmpty) {
      _showSnack('No items with valid quantity');
      return;
    }

    final success = await provider.createLoadSheet(
      loadNo: _loadNoController.text.trim(),
      loadDate: _dateController.text.trim(),
      salesmanId: int.parse(_selectedSalesmanId!),
      details: details,
      selectedSoIds: _selectedSOIds.toList(),
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
      _showSnack(provider.error ?? 'Failed to create');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

    return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 0) {
          _goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: _buildAppBar(),
        body: _buildBody(provider),
        bottomNavigationBar: _buildBottomBar(provider),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final titles = ['New Load Sheet', 'Select Orders', 'Confirm Items'];
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: _goBack,
      ),
      title: Text(
        titles[_currentStep],
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 1.0,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(LoadSheetProvider provider) {
    switch (_currentStep) {
      case 0:
        return _buildStep0(provider);
      case 1:
        return _buildStep1(provider);
      case 2:
        return _buildStep2(provider);
      default:
        return const SizedBox.shrink();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  STEP 0: Load Info (Load No, Date, Salesman)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildStep0(LoadSheetProvider provider) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
        children: [
          // Step indicator
          _buildStepIndicator(),
          const SizedBox(height: 20),

          _SectionCard(
            title: 'Load Information',
            icon: Icons.assignment_outlined,
            children: [
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

              _FieldLabel(label: 'Salesman'),
              SalesmanDropdown(
                selectedId: _selectedSalesmanId,
                isLocked: _isSalesmanLocked,
                onChanged: (id) {
                  if (!_isSalesmanLocked) {
                    setState(() {
                      _selectedSalesmanId = id;
                      _selectedSOIds.clear();
                      _editableQty.clear();
                    });
                    if (id != null) {
                      _fetchOrdersForSalesman(int.parse(id));
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  STEP 1: Select Sales Orders (checkboxes)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildStep1(LoadSheetProvider provider) {
    return Column(
      children: [
        // Step indicator
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _buildStepIndicator(),
        ),

        // Select All bar
        if (!provider.isLoadingSO && provider.salesOrders.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    '${_selectedSOIds.length} of ${provider.salesOrders.length} selected',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (_selectedSOIds.length == provider.salesOrders.length) {
                          _selectedSOIds.clear();
                        } else {
                          _selectedSOIds.clear();
                          for (final so in provider.salesOrders) {
                            _selectedSOIds.add(so['id'] as int);
                          }
                        }
                      });
                    },
                    child: Text(
                      _selectedSOIds.length == provider.salesOrders.length
                          ? 'Deselect All'
                          : 'Select All',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 8),

        // Orders list
        Expanded(
          child: provider.isLoadingSO
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : provider.soError != null
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 12),
                Text(provider.soError!, style: const TextStyle(color: Color(0xFF6B7280))),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _fetchOrdersForSalesman(int.parse(_selectedSalesmanId!)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
              : provider.salesOrders.isEmpty
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_rounded, size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text(
                  'No approved orders found',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'This salesman has no pending orders',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            itemCount: provider.salesOrders.length,
            itemBuilder: (context, index) {
              final so = provider.salesOrders[index];
              final soId = so['id'] as int;
              final isSelected = _selectedSOIds.contains(soId);
              final orderDate = so['order_date'] != null
                  ? DateFormat('dd MMM yyyy').format(DateTime.parse(so['order_date']))
                  : '—';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.04) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary.withOpacity(0.4) : const Color(0xFFE5E7EB),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedSOIds.remove(soId);
                      } else {
                        _selectedSOIds.add(soId);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Checkbox
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 14),

                        // Order info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      so['so_no'] ?? '—',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      so['status'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF16A34A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                so['customer_name'] ?? '—',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF374151),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    orderDate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  STEP 2: Review & Edit Items
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildStep2(LoadSheetProvider provider) {
    return Column(
      children: [
        // Step indicator
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _buildStepIndicator(),
        ),

        // Summary bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.08),
                  AppColors.secondary.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  '${provider.soItems.length} Items from ${_selectedSOIds.length} Orders',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Items list
        Expanded(
          child: provider.isLoadingItems
              ? const Center(child: CircularProgressIndicator())
              : provider.itemsError != null
              ? Center(
            child: Text(provider.itemsError!,
                style: const TextStyle(color: Colors.red)),
          )
              : provider.soItems.isEmpty
              ? const Center(
            child: Text('No items found',
                style: TextStyle(
                    fontSize: 16, color: Color(0xFF6B7280))),
          )
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            itemCount: provider.soItems.length,
            itemBuilder: (context, index) {
              final item = provider.soItems[index];
              final itemId = item['item_id'] as int;
              final itemName = item['item_name'] ?? '—';
              final sku = item['item_sku'] ?? '';
              final unitName = item['unit_name'] ?? '';
              final categoryName = item['category_name'] ?? '';
              final qty = _editableQty[itemId] ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Index
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Item info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (sku.isNotEmpty) ...[
                                Text(
                                  sku,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              if (unitName.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    unitName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Qty field
                    SizedBox(
                      width: 75,
                      child: TextFormField(
                        initialValue: qty % 1 == 0
                            ? qty.toInt().toString()
                            : qty.toStringAsFixed(2),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                        ],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onChanged: (v) {
                          final parsed = double.tryParse(v);
                          if (parsed != null && parsed >= 0) {
                            _editableQty[itemId] = parsed;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  void _confirmDelete(BuildContext context, Map<String, dynamic> sheet) {
    final provider = Provider.of<LoadSheetProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Delete Load Sheet'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${sheet['load_no']}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
              await provider.deleteLoadSheet(sheet['id'] as int);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? 'Load sheet deleted' : (provider.error ?? 'Failed'),
                  ),
                  backgroundColor: success ? const Color(0xFF16A34A) : Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BOTTOM BAR
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBottomBar(LoadSheetProvider provider) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16, 12, 16, 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: [
          // Back button (except step 0)
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _goBack,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),

          // Next / Submit button
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: provider.isSubmitting
                    ? null
                    : _currentStep == 0
                    ? _goToStep1
                    : _currentStep == 1
                    ? _goToStep2
                    : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
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
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentStep == 2 ? 'Create Load Sheet' : 'Next',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_currentStep < 2) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  STEP INDICATOR
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    final labels = ['Info', 'Orders', 'Items'];
    return Row(
      children: List.generate(3, (i) {
        final isActive = i == _currentStep;
        final isCompleted = i < _currentStep;
        return Expanded(
          child: Row(
            children: [
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? AppColors.primary : Colors.grey.shade300,
                  ),
                ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primary
                      : isActive
                      ? AppColors.primary.withOpacity(0.15)
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                  border: isActive
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isActive ? AppColors.primary : Colors.grey.shade500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                labels[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? AppColors.primary
                      : isCompleted
                      ? AppColors.primary
                      : Colors.grey.shade500,
                ),
              ),
              if (i < 2)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? AppColors.primary : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }),
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