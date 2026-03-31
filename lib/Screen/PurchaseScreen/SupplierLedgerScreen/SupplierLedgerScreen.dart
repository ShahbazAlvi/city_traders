import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Provider/Purchase_Provider/SupplierLedgerProvider/SupplierLedgerProvider.dart';
import '../../../compoents/SupplierDropdown.dart';
import '../../../compoents/AppColors.dart';

class SupplierLedgerScreen extends StatefulWidget {

  final String? supplierId;
  final String? supplierName;

  const SupplierLedgerScreen({
    super.key,
    this.supplierId,
    this.supplierName,
  });

  @override
  State<SupplierLedgerScreen> createState() => _SupplierLedgerScreenState();
}

class _SupplierLedgerScreenState extends State<SupplierLedgerScreen> {

  String? selectedSupplierId;
  final formatted=NumberFormat("#,##,###");
  final formattedDate=DateFormat("dd,MMM,yyyy");
  DateTime? fromDate;
  DateTime? toDate;
  @override
  void initState() {
    super.initState();

    selectedSupplierId = widget.supplierId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedSupplierId != null) {
        _fetchLedger();
      }
    });
  }



  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<SupplierLedgerProvider>(context);

    return Scaffold(

      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.supplierName ?? "Supplier Ledger",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [

            /// Supplier Dropdown
            SupplierDropdown(
              selectedSupplierId: selectedSupplierId,
              onSelected: (id) {
                setState(() => selectedSupplierId = id);
                _fetchLedger();
              },
            ),

            const SizedBox(height: 10),

            /// Date Filters
            Row(
              children: [

                Expanded(
                  child: _buildDateField(
                    label: "From Date",
                    selectedDate: fromDate,
                    onTap: () async {
                      DateTime? picked = await _pickDate();
                      if (picked != null) {
                        setState(() => fromDate = picked);
                        _fetchLedger();
                      }
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _buildDateField(
                    label: "To Date",
                    selectedDate: toDate,
                    onTap: () async {
                      DateTime? picked = await _pickDate();
                      if (picked != null) {
                        setState(() => toDate = picked);
                        _fetchLedger();
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            /// Ledger Table
            Expanded(
              child: provider.loading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.ledgerList.isEmpty
                  ? const Center(child: Text("No Ledger Data Found"))
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 640,
                  child: Column(
                    children: [
                      // Header — unchanged
                      Container(
                        color: Colors.grey.shade200,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: const Row(
                          children: [
                            _HeaderCell("Date", 120),
                            _HeaderCell("Ref No", 200),
                            _HeaderCell("Debit", 100),
                            _HeaderCell("Credit", 100),
                            _HeaderCell("Balance", 120),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      // ✅ ListView now inside Expanded properly
                      Expanded(
                        child: ListView.builder(
                          itemCount: provider.ledgerList.length,
                          itemBuilder: (context, index) {
                            final data = provider.ledgerList[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _Cell(_formatDate(data.date), 120),
                                  _Cell(data.refNo, 200),
                                  _Cell(data.debit.toString(), 100, color: Colors.red),
                                  _Cell(data.credit.toString(), 100, color: Colors.green),
                                  _Cell(data.balance.toString(), 120, isBold: true),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fetch Ledger
  void _fetchLedger() {

    if (selectedSupplierId == null) return;

    final provider = Provider.of<SupplierLedgerProvider>(context, listen: false);

    final from = fromDate != null
        ? fromDate!.toIso8601String().split("T").first
        : DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String()
        .split("T")
        .first;

    final to = toDate != null
        ? toDate!.toIso8601String().split("T").first
        : DateTime.now().toIso8601String().split("T").first;

    provider.fetchSupplierLedger(
      supplierId: selectedSupplierId!,
      fromDate: from,
      toDate: to,
    );
  }

  /// Date Picker
  Future<DateTime?> _pickDate() async {

    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
  }

  String _formatDate(String rawDate) {
    // Try ISO format first: "2025-03-13"
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(rawDate));
    } catch (_) {}

    // Try "Fri Mar 13" or "Fri Mar 13 2025" style
    try {
      // Append current year if missing
      final parts = rawDate.trim().split(' ');
      final withYear = parts.length == 3
          ? '$rawDate ${DateTime.now().year}'
          : rawDate;
      return DateFormat('dd MMM yyyy')
          .format(DateFormat('EEE MMM d yyyy').parse(withYear));
    } catch (_) {}

    // Final fallback — return as-is
    return rawDate;
  }

  /// Date Field
  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(
            text: selectedDate == null
                ? ''
                : "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
          ),
        ),
      ),
    );
  }
}

/// Header Cell
class _HeaderCell extends StatelessWidget {

  final String text;
  final double width;

  const _HeaderCell(this.text, this.width);

  @override
  Widget build(BuildContext context) {

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Table Cell
class _Cell extends StatelessWidget {

  final String text;
  final double width;
  final Color? color;
  final bool isBold;

  const _Cell(
      this.text,
      this.width, {
        this.color,
        this.isBold = false,
      });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? Colors.black,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}