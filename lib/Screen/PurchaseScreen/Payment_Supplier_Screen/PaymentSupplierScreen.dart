// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../../Provider/Purchase_Provider/Payment_TO_Supplier_Provider/PaymentSupplierProvider.dart';
// import '../../../compoents/AppColors.dart';
//
// class PaymentToSupplierScreen extends StatefulWidget {
//   final String? supplierId;       // ✅ new
//   final String? supplierName;
//   const PaymentToSupplierScreen({super.key, this.supplierId, this.supplierName});
//
//   @override
//   State<PaymentToSupplierScreen> createState() =>
//       _PaymentToSupplierScreenState();
// }
//
// class _PaymentToSupplierScreenState extends State<PaymentToSupplierScreen> {
//
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<PaymentToSupplierProvider>(context, listen: false)
//           .loadPayments();  // ✅ just load payments normally
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           "Payment To Supplier",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//         centerTitle: true,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [AppColors.secondary, AppColors.primary],
//             ),
//           ),
//         ),
//       ),
//
//       body: Consumer<PaymentToSupplierProvider>(
//         builder: (context, provider, _) {
//
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (provider.paymentList.isEmpty) {
//             return const Center(child: Text("No Payments Found"));
//           }
//
//           return ListView.builder(
//             itemCount: provider.paymentList.length,
//             itemBuilder: (context, index) {
//
//               final data = provider.paymentList[index];
//
//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 elevation: 3,
//                 child: ListTile(
//
//                   title: Text(
//                     "${data.paymentNo}   ${data.supplierName}",
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//
//                       Text("Mode: ${data.paymentMode}"),
//                       Text("Rs : ${NumberFormat('#,##0').format(double.parse(data.amount.toString()))}",),
//
//                     ],
//                   ),
//
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//
//                       /// Delete Button
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () {
//                           provider.deletePayment(data.id);
//                         },
//                       ),
//
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Provider/Purchase_Provider/Payment_TO_Supplier_Provider/PaymentSupplierProvider.dart';
import '../../../compoents/AppColors.dart';

class PaymentToSupplierScreen extends StatefulWidget {
  final String? supplierId;
  final String? supplierName;

  const PaymentToSupplierScreen({
    super.key,
    this.supplierId,
    this.supplierName,
  });

  @override
  State<PaymentToSupplierScreen> createState() =>
      _PaymentToSupplierScreenState();
}

class _PaymentToSupplierScreenState extends State<PaymentToSupplierScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentToSupplierProvider>(context, listen: false)
          .loadPayments();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Consumer<PaymentToSupplierProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
              );
            }

            if (provider.paymentList.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                _buildSummaryBanner(provider),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: provider.paymentList.length,
                    itemBuilder: (context, index) {
                      final data = provider.paymentList[index];
                      return _PaymentCard(
                        index: index,
                        data: data,
                        onDelete: () => _confirmDelete(context, provider, data.id),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Column(
        children: [
          const Text(
            "Payment To Supplier",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 0.3,
            ),
          ),
          if (widget.supplierName != null)
            Text(
              widget.supplierName!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
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
    );
  }

  Widget _buildSummaryBanner(PaymentToSupplierProvider provider) {
    final total = provider.paymentList.fold<double>(
      0,
          (sum, item) => sum + double.tryParse(item.amount.toString())!,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payments_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Paid",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "₨ ${NumberFormat('#,##0.00').format(total)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Records",
                style: TextStyle(color: Colors.white60, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                "${provider.paymentList.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          Text(
            "No payments found",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, PaymentToSupplierProvider provider, dynamic id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Payment",
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text("Are you sure you want to delete this payment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade500,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              provider.deletePayment(id);
            },
            child: const Text("Delete",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Payment Card Widget ──────────────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  final int index;
  final dynamic data;
  final VoidCallback onDelete;

  const _PaymentCard({
    required this.index,
    required this.data,
    required this.onDelete,
  });

  Color get _modeColor {
    final mode = data.paymentMode?.toString().toLowerCase() ?? '';
    if (mode.contains('cash')) return const Color(0xFF48BB78);
    if (mode.contains('bank') || mode.contains('transfer'))
      return const Color(0xFF4299E1);
    if (mode.contains('cheque') || mode.contains('check'))
      return const Color(0xFFED8936);
    return const Color(0xFF6C63FF);
  }

  IconData get _modeIcon {
    final mode = data.paymentMode?.toString().toLowerCase() ?? '';
    if (mode.contains('cash')) return Icons.money_rounded;
    if (mode.contains('bank') || mode.contains('transfer'))
      return Icons.account_balance_rounded;
    if (mode.contains('cheque') || mode.contains('check'))
      return Icons.edit_document;
    return Icons.payment_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(data.amount.toString()) ?? 0.0;
    final formattedAmount = NumberFormat('#,##0').format(amount);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Mode icon circle
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _modeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_modeIcon, color: _modeColor, size: 22),
            ),

            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment No + Supplier
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${data.paymentNo}",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          data.supplierName ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: Color(0xFF2D3748),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Mode badge + Amount
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _modeColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data.paymentMode ?? '',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: _modeColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "₨ $formattedAmount",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Delete button
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.delete_outline_rounded,
                    color: Colors.red.shade400, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}