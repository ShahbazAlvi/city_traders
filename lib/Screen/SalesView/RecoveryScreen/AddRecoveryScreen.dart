

import 'package:demo_distribution/Provider/BankProvider/BankListProvider.dart';
import 'package:demo_distribution/compoents/AppTextfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../Provider/RecoveryProvider/RecoveryProvider.dart';
import '../../../Provider/SaleManProvider/SaleManProvider.dart';
import '../../../compoents/AppColors.dart';
import '../../../compoents/BankDropDown.dart';
import '../../../compoents/Customerdropdown.dart';
import '../../../compoents/SaleManDropdown.dart';
import '../../../model/BankModel/BankListModel.dart';
import '../../../model/CustomerModel/CustomersDefineModel.dart';
import '../../../model/SaleRecoveryModel/RecoveryCustomerInvoice.dart';

class AddRecoveryScreen extends StatefulWidget {
  final String nextOrderId;
  const AddRecoveryScreen({super.key, required this.nextOrderId});

  @override
  State<AddRecoveryScreen> createState() => _AddRecoveryScreenState();
}

class _AddRecoveryScreenState extends State<AddRecoveryScreen> {
  CustomerData? selectedCustomer;
  CustomerInvoice? selectedInvoice;
  String? selectedSalesmanId;
  BankData? selectedBank;
  String selectedMode = "CASH"; // ✅ default to CASH
  bool isLoading = false;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController invoiceAmountController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    Provider.of<SaleManProvider>(context, listen: false).fetchEmployees();
    Provider.of<BankProvider>(context, listen: false).fetchBanks();
  }

  @override
  void dispose() {
    amountController.dispose();
    invoiceAmountController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────

  bool _isFormValid() {
    if (selectedCustomer == null) return false;
    if (selectedInvoice == null) return false;
    if (selectedSalesmanId == null) return false;
    if (amountController.text.trim().isEmpty) return false;
    if (selectedMode == "BANK" && selectedBank == null) return false;
    return true;
  }

  String _getMissingFieldsMessage() {
    final List<String> missing = [];
    if (selectedCustomer == null) missing.add("Customer");
    if (selectedInvoice == null) missing.add("Invoice");
    if (selectedSalesmanId == null) missing.add("Salesman");
    if (amountController.text.trim().isEmpty) missing.add("Amount");
    if (selectedMode == "BANK" && selectedBank == null) missing.add("Bank");
    return "Please fill: ${missing.join(', ')}";
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          "Add Recovery",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Colors.white,
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 24),
              const Text("Recovery Details",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B))),
              const SizedBox(height: 4),
              const Text(
                  "Fill in the information below to create a new recovery",
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              const SizedBox(height: 24),

              // ── Customer ──────────────────────────────────────────
              _buildCustomerField(),
              const SizedBox(height: 16),

              // ── Invoice ───────────────────────────────────────────
              _buildInvoiceField(),
              const SizedBox(height: 16),

              // ── Invoice Amount + Balance ───────────────────────────
              _buildInvoiceInfoRow(),
              const SizedBox(height: 16),

              // ── Salesman ──────────────────────────────────────────
              _buildSectionCard(
                icon: Icons.business_center_outlined,
                title: "Salesman Information",
                child: SalesmanDropdown(
                  selectedId: selectedSalesmanId,
                  onChanged: (v) => setState(() => selectedSalesmanId = v),
                ),
              ),
              const SizedBox(height: 16),

              // ── Payment Mode Toggle ───────────────────────────────
              _buildPaymentModeCard(),
              const SizedBox(height: 16),

              // ── Bank Dropdown — only visible when BANK selected ───
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => SizeTransition(
                  sizeFactor: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: selectedMode == "BANK"
                    ? Column(
                  key: const ValueKey("bank_section"),
                  children: [
                    _buildSectionCard(
                      icon: Icons.account_balance_outlined,
                      title: "Bank Information",
                      child: BankDropdown(
                        selectedBank: selectedBank,
                        onChanged: (bank) =>
                            setState(() => selectedBank = bank),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                )
                    : const SizedBox.shrink(key: ValueKey("no_bank")),
              ),

              // ── Amount & Date ─────────────────────────────────────
              _buildSectionCard(
                icon: Icons.payment_outlined,
                title: "Payment Details",
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.grey.shade200, width: 1.5),
                      ),
                      child: AppTextField(
                        controller: amountController,
                        label: 'Amount',
                        validator: (v) =>
                        v!.isEmpty ? "Enter amount" : null,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Warning ───────────────────────────────────────────
              if (!_isFormValid()) _buildWarningBanner(),
              const SizedBox(height: 16),

              // ── Submit ────────────────────────────────────────────
              _buildSubmitButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section Widgets ───────────────────────────────────────────────────────

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recovery Voucher Number",
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.nextOrderId,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_chart, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text("New Entry",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: CustomerDropdown(
        selectedCustomerId: selectedCustomer?.id,
        onChanged: (customer) {
          setState(() {
            selectedCustomer = customer;
            selectedInvoice = null;
            invoiceAmountController.clear();
            balanceController.clear();
          });
          if (customer != null) {
            context.read<RecoveryProvider>().fetchCustomerInvoices(customer.id);
          }
        },
      ),
    );
  }

  Widget _buildInvoiceField() {
    final provider = context.watch<RecoveryProvider>();

    return provider.isLoading
        ? _buildShimmer()
        : Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CustomerInvoice>(
          hint: Row(
            children: [
              Icon(Icons.receipt_rounded,
                  color: Colors.grey.shade400, size: 20),
              const SizedBox(width: 12),
              Text("Select Invoice",
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
          value: selectedInvoice,
          isExpanded: true,
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary),
          ),
          items: provider.customerInvoices.map((inv) {
            return DropdownMenuItem(
              value: inv,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(inv.invNo,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(inv.invType,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Rs ${inv.effectiveAmount.toStringAsFixed(0)}",
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (invoice) {
            setState(() {
              selectedInvoice = invoice;
              invoiceAmountController.text =
                  invoice!.netTotal.toStringAsFixed(0);
              balanceController.text =
                  invoice.effectiveAmount.toStringAsFixed(0);
            });
          },
        ),
      ),
    );
  }

  /// Invoice Amount + Balance Due side by side
  Widget _buildInvoiceInfoRow() {
    return Row(
      children: [
        Expanded(
          child: _buildReadonlyField(
            controller: invoiceAmountController,
            label: "Invoice Amount",
            icon: Icons.receipt_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildReadonlyField(
            controller: balanceController,
            label: "Balance Due",
            icon: Icons.account_balance_wallet_outlined,
            highlight: true,
          ),
        ),
      ],
    );
  }

  Widget _buildReadonlyField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool highlight = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: highlight
            ? AppColors.primary.withOpacity(0.05)
            : Colors.grey.shade100,
        border: Border.all(
          color: highlight
              ? AppColors.primary.withOpacity(0.3)
              : Colors.grey.shade300,
        ),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: highlight ? AppColors.primary : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 12,
            color: highlight ? AppColors.primary : Colors.grey.shade600,
          ),
          prefixIcon: Icon(icon,
              color: highlight ? AppColors.primary : Colors.grey.shade500,
              size: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  /// ✅ CASH / BANK animated toggle
  Widget _buildPaymentModeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.payment_outlined,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              const Text("Payment Mode",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: ["CASH", "BANK"].map((mode) {
              final isSelected = selectedMode == mode;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMode = mode;
                      // ✅ Clear bank when switching to CASH
                      if (mode == "CASH") selectedBank = null;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.only(
                        right: mode == "CASH" ? 8 : 0,
                        left: mode == "BANK" ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : null,
                      color: isSelected ? null : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          mode == "CASH"
                              ? Icons.money_rounded
                              : Icons.account_balance_outlined,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade500,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          mode,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Color(0xFF1E293B),
                ),
              ),
              child: child!,
            ),
          );
          if (picked != null) setState(() => selectedDate = picked);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_today_outlined,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Recovery Date",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(
                      selectedDate != null
                          ? DateFormat('dd MMMM yyyy').format(selectedDate!)
                          : "Select Date",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: selectedDate != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selectedDate != null
                            ? const Color(0xFF1E293B)
                            : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _getMissingFieldsMessage(),
              style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final enabled = !isLoading && _isFormValid();
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: enabled ? _submitRecovery : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: EdgeInsets.zero,
          disabledBackgroundColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary])
                : LinearGradient(
                colors: [Colors.grey.shade300, Colors.grey.shade400]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text("Creating...",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ],
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline,
                    color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text("Create Recovery",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submitRecovery() async {
    setState(() => isLoading = true);

    try {
      final provider = Provider.of<RecoveryProvider>(context, listen: false);

      // ✅ payment_balance = invoice effective amount - entered amount
      final double entered = double.tryParse(amountController.text) ?? 0;
      final double balance = selectedInvoice!.effectiveAmount - entered;

      final message = await provider.addRecovery(
        rvNo: widget.nextOrderId,
        salesmanId: selectedSalesmanId!,
        customerId: selectedCustomer!.id.toString(),
        // ✅ CASH → null, BANK → bank id
        bankId: selectedMode == "BANK" ? selectedBank!.id.toString() : null,
        amount: amountController.text.trim(),
        recoveryDate: DateFormat('yyyy-MM-dd')
            .format(selectedDate ?? DateTime.now()),
        mode: selectedMode,
        invoiceId: selectedInvoice!.id.toString(),
        invoiceNo: selectedInvoice!.invNo,
        invoiceType: selectedInvoice!.sourceTable, // "NOTAX" or "TAX"
        invoiceAmount: selectedInvoice!.netTotal.toStringAsFixed(2),
        paymentBalance: balance.toStringAsFixed(2),
        paymentDueDate: selectedInvoice!.paymentDueDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedInvoice!.paymentDueDate!)
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message ?? "Recovery added successfully")),
          ]),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text("Error: $e")),
          ]),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}