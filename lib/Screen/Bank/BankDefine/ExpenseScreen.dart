// screens/Expense/ExpenseVoucherScreen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Provider/BankProvider/BankListProvider.dart';
import '../../../Provider/BankProvider/ExpenseVoucherProvider.dart';
import '../../../compoents/AppColors.dart';
import '../../../model/BankModel/BankListModel.dart';
import '../../../model/BankModel/ExpenseModel.dart';



class ExpenseVoucherScreen extends StatefulWidget {
  const ExpenseVoucherScreen({super.key});

  @override
  State<ExpenseVoucherScreen> createState() => _ExpenseVoucherScreenState();
}

class _ExpenseVoucherScreenState extends State<ExpenseVoucherScreen> {
  final _currencyFormat = NumberFormat('#,##0', 'en_PK');

  static const _appGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseVoucherProvider>().fetchVouchers();
      context.read<ExpenseVoucherProvider>().fetchExpenseHeads();
      context.read<BankProvider>().fetchBanks();
    });
  }

  void _openAddSheet() {
    context.read<ExpenseVoucherProvider>().resetSubmitState();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddExpenseSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Expense Vouchers',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () =>
                context.read<ExpenseVoucherProvider>().refresh(),
          ),
        ],
      ),
      body: Consumer<ExpenseVoucherProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // ── Sub-header with total ──────────────────────────────────────
              _buildSubHeader(provider),
              // ── Body ──────────────────────────────────────────────────────
              Expanded(
                child: provider.isListLoading
                    ? _buildShimmer()
                    : provider.hasListError
                    ? _buildError(provider)
                    : provider.vouchers.isEmpty
                    ? _buildEmpty()
                    : _buildList(provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ── Sub-header ─────────────────────────────────────────────────────────────
  Widget _buildSubHeader(ExpenseVoucherProvider provider) {
    final total = provider.vouchers
        .fold<double>(0, (sum, v) => sum + v.amount);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: _appGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: provider.isListLoading
          ? _buildHeaderShimmer()
          : Row(
        children: [
          _StatChip(
            label: 'Total Vouchers',
            value: '${provider.vouchers.length}',
            icon: Icons.receipt_long_outlined,
            accentColor: Colors.white,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Total Amount',
            value: _currencyFormat.format(total),
            icon: Icons.payments_outlined,
            accentColor: const Color(0xFFB2FFEE),
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Next Voucher',
            value: provider.nextEvNo,
            icon: Icons.tag,
            accentColor: const Color(0xFFFFE8A1),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.25),
      highlightColor: Colors.white.withOpacity(0.55),
      child: Row(
        children: List.generate(
          3,
              (_) => Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Shimmer list ───────────────────────────────────────────────────────────
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────
  Widget _buildError(ExpenseVoucherProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFE74C3C), size: 52),
          const SizedBox(height: 10),
          Text('Failed to load',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700])),
          const SizedBox(height: 6),
          Text(provider.listError,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center),
          const SizedBox(height: 18),
          _GradientButton(
            label: 'Retry',
            icon: Icons.refresh,
            onTap: provider.refresh,
            gradient: _appGradient,
          ),
        ],
      ),
    );
  }

  // ── Empty ──────────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('No expense vouchers yet',
              style: TextStyle(fontSize: 15, color: Colors.grey[500])),
          const SizedBox(height: 6),
          Text('Tap + to add one',
              style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }

  // ── Voucher list ───────────────────────────────────────────────────────────
  Widget _buildList(ExpenseVoucherProvider provider) {
    return RefreshIndicator(
      color: AppColors.secondary,
      onRefresh: provider.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 90),
        itemCount: provider.vouchers.length,
        itemBuilder: (_, i) => _buildVoucherCard(provider.vouchers[i]),
      ),
    );
  }

  // ── Voucher card ───────────────────────────────────────────────────────────
  Widget _buildVoucherCard(ExpenseVoucher v) {
    final isCash = v.mode == 'CASH';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFEAECEF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // ── Left icon ─────────────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: _appGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isCash
                    ? Icons.money_rounded
                    : Icons.account_balance_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // ── Middle info ────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        v.evNo,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _Badge(
                        label: v.mode,
                        color: isCash
                            ? const Color(0xFFD5F5E3)
                            : const Color(0xFFDEEAFD),
                        textColor: isCash
                            ? const Color(0xFF1E8449)
                            : const Color(0xFF1A5FB4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    v.expenseHeadName,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF555555)),
                  ),
                  if (v.bankName != null)
                    Text(
                      v.bankName!,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFFAAAAAA)),
                    ),
                ],
              ),
            ),

            // ── Right: amount + date ───────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ShaderMask(
                  shaderCallback: (b) => _appGradient.createShader(b),
                  child: Text(
                    _currencyFormat.format(v.amount),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('dd MMM yy').format(v.voucherDate),
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFFAAAAAA)),
                ),
                const SizedBox(height: 3),
                _Badge(
                  label: v.status,
                  color: const Color(0xFFD5F5E3),
                  textColor: const Color(0xFF1E8449),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── FAB ────────────────────────────────────────────────────────────────────
  Widget _buildFab() {
    return Container(
      decoration: BoxDecoration(
        gradient: _appGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Expense',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ADD EXPENSE BOTTOM SHEET
// ══════════════════════════════════════════════════════════════════════════════

class _AddExpenseSheet extends StatefulWidget {
  const _AddExpenseSheet();

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _mode = 'CASH'; // 'CASH' | 'BANK'
  ExpenseHead? _selectedHead;
  BankData? _selectedBank;

  static const _appGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void dispose() {
    _amountCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.secondary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHead == null) {
      _showSnack('Please select an expense head');
      return;
    }
    if (_mode == 'BANK' && _selectedBank == null) {
      _showSnack('Please select a bank');
      return;
    }

    final provider = context.read<ExpenseVoucherProvider>();
    final request = ExpenseVoucherRequest(
      evNo: provider.nextEvNo,
      voucherDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      expenseHeadId: _selectedHead!.id,
      mode: _mode,
      bankId: _mode == 'BANK' ? _selectedBank!.id : null,
      amount: double.parse(_amountCtrl.text),
      remarks: _remarksCtrl.text.trim(),
    );

    final success = await provider.addVoucher(request);
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Expense voucher added successfully'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseVoucherProvider>();
    final bankProvider = context.watch<BankProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 8,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle ──────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Title + EV number ────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Expense Voucher',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C3E50)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: _appGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      provider.nextEvNo,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Date picker ──────────────────────────────────────────────
              _SectionLabel(label: 'Voucher Date'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD0D7DE)),
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFF8F9FA),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF2C3E50)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Expense Head dropdown ────────────────────────────────────
              _SectionLabel(label: 'Expense Head'),
              const SizedBox(height: 6),
              DropdownButtonFormField<ExpenseHead>(
                value: _selectedHead,
                hint: const Text('Select expense head',
                    style: TextStyle(fontSize: 13)),
                decoration: _inputDecoration(),
                items: provider.expenseHeads.map((head) {
                  return DropdownMenuItem(
                    value: head,
                    child: Text(head.name, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedHead = v),
                validator: (v) =>
                v == null ? 'Please select expense head' : null,
              ),
              const SizedBox(height: 14),

              // ── Payment Mode toggle ──────────────────────────────────────
              _SectionLabel(label: 'Payment Mode'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _ModeChip(
                    label: 'CASH',
                    icon: Icons.money_rounded,
                    selected: _mode == 'CASH',
                    onTap: () => setState(() {
                      _mode = 'CASH';
                      _selectedBank = null;
                    }),
                  ),
                  const SizedBox(width: 10),
                  _ModeChip(
                    label: 'BANK',
                    icon: Icons.account_balance_rounded,
                    selected: _mode == 'BANK',
                    onTap: () => setState(() => _mode = 'BANK'),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Bank dropdown (only when mode == BANK) ───────────────────
              if (_mode == 'BANK') ...[
                _SectionLabel(label: 'Select Bank'),
                const SizedBox(height: 6),
                bankProvider.loading
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                    : DropdownButtonFormField<BankData>(
                  value: _selectedBank,
                  hint: const Text('Select bank',
                      style: TextStyle(fontSize: 13)),
                  decoration: _inputDecoration(),
                  items: bankProvider.bankListModel.map((bank) {
                    return DropdownMenuItem(
                      value: bank,
                      child: Text(bank.name,
                          style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedBank = v),
                  validator: (v) =>
                  _mode == 'BANK' && v == null
                      ? 'Please select a bank'
                      : null,
                ),
                const SizedBox(height: 14),
              ],

              // ── Amount ───────────────────────────────────────────────────
              _SectionLabel(label: 'Amount (PKR)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration(hint: 'Enter amount'),
                style: const TextStyle(fontSize: 14),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Amount is required';
                  if (double.tryParse(v) == null) return 'Enter valid number';
                  if (double.parse(v) <= 0) return 'Amount must be > 0';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── Remarks ──────────────────────────────────────────────────
              _SectionLabel(label: 'Remarks (optional)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _remarksCtrl,
                maxLines: 2,
                decoration: _inputDecoration(hint: 'Add any notes...'),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),

              // ── Submit button ─────────────────────────────────────────────
              if (provider.submitState == ExpenseSubmitState.error)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    provider.submitError,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFFE74C3C)),
                    textAlign: TextAlign.center,
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: provider.isSubmitting
                    ? Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: _appGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    ),
                  ),
                )
                    : _GradientButton(
                  label: 'Save Voucher',
                  icon: Icons.save_alt_rounded,
                  onTap: _submit,
                  gradient: _appGradient,
                  height: 50,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
      const TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD0D7DE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD0D7DE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
        const BorderSide(color: AppColors.secondary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE74C3C)),
      ),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SMALL REUSABLE WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.white.withOpacity(0.4), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: accentColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 9,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: accentColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  static const _gradient = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? _gradient : null,
          color: selected ? null : const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : const Color(0xFFD0D7DE),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color:
                selected ? Colors.white : const Color(0xFF888888)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : const Color(0xFF555555))),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Badge(
      {required this.label,
        required this.color,
        required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(5)),
      child: Text(label,
          style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: textColor)),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555)));
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final LinearGradient gradient;
  final double height;
  final double fontSize;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.gradient,
    this.height = 44,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}