//
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../Provider/Purchase_Provider/PayaAmountProvider/PayaAmountProvider.dart';
// import '../../../compoents/AppColors.dart';
// import '../SupplierLedgerScreen/SupplierLedgerScreen.dart';
//
// class PayableAmountScreen extends StatefulWidget {
//   const PayableAmountScreen({super.key});
//
//   @override
//   State<PayableAmountScreen> createState() => _PayableAmountScreenState();
// }
//
// class _PayableAmountScreenState extends State<PayableAmountScreen> {
//
//   bool withZero = true;
//
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<PayableAmountProvider>().fetchPayables();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           "Payable Amount Details",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [AppColors.secondary, AppColors.primary],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Consumer<PayableAmountProvider>(
//           builder: (context, provider, child) {
//
//             if (provider.isLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (provider.payables.isEmpty) {
//               return const Center(child: Text("No data found"));
//             }
//
//             return Column(
//               children: [
//
//                 /// ---------------- TABLE ----------------
//                 Expanded(
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.vertical,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: DataTable(
//
//                         headingRowColor: MaterialStateProperty.all(
//                           Colors.grey.shade200,
//                         ),
//
//                         columns: const [
//
//                           DataColumn(
//                             label: Text(
//                               "S.No",
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                           ),
//
//                           DataColumn(
//                             label: Text(
//                               "Supplier",
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                           ),
//
//                           DataColumn(
//                             label: Text(
//                               "Balance",
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         ],
//
//                         rows: provider.payables.asMap().entries.map((entry) {
//
//                           int index = entry.key;
//                           var p = entry.value;
//
//                           return DataRow(
//                             cells: [
//
//                               DataCell(Text("${index + 1}")),
//
//                               DataCell(
//                                 GestureDetector(
//                                   onTap: () {
//
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (_) => SupplierLedgerScreen(
//                                           supplierId: p.supplierId.toString(),
//                                           supplierName: p.supplierName,
//                                         ),
//                                       ),
//                                     );
//
//                                   },
//                                   child: Text(
//                                     p.supplierName.toUpperCase(),
//                                     style: const TextStyle(
//                                       // color: Colors.blue,
//                                       // fontWeight: FontWeight.w600,
//                                       // decoration: TextDecoration.underline,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//
//                               DataCell(
//                                 Text(
//                                   "₨ ${p.grandBalance.toStringAsFixed(2)}",
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//
//                             ],
//                           );
//
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 /// ---------------- TOTAL CARD ----------------
//                 Card(
//                   color: Colors.grey.shade200,
//                   margin: const EdgeInsets.only(top: 10),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//
//                         const Text(
//                           "Total Payable",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//
//                         Text(
//                           "₨ ${provider.totalGrandBalance.toStringAsFixed(2)}",
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                             color: Colors.red,
//                           ),
//                         ),
//
//                       ],
//                     ),
//                   ),
//                 )
//
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Provider/Purchase_Provider/PayaAmountProvider/PayaAmountProvider.dart';
import '../../../compoents/AppColors.dart';
import '../SupplierLedgerScreen/SupplierLedgerScreen.dart';

class PayableAmountScreen extends StatefulWidget {
  const PayableAmountScreen({super.key});

  @override
  State<PayableAmountScreen> createState() => _PayableAmountScreenState();
}

class _PayableAmountScreenState extends State<PayableAmountScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PayableAmountProvider>().fetchPayables();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Consumer<PayableAmountProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                );
              }

              if (provider.payables.isEmpty) {
                return _buildEmptyState();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryHeader(provider),
                  const SizedBox(height: 20),
                  _buildTableHeader(),
                  const SizedBox(height: 8),
                  Expanded(child: _buildPayablesList(provider)),
                  const SizedBox(height: 12),
                  _buildTotalCard(provider),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        "Payable Details",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 19,
          letterSpacing: 0.4,
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.white.withOpacity(0.15),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(PayableAmountProvider provider) {
    return Container(
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
            color: AppColors.primary.withOpacity(0.30),
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
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Outstanding",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "₨ ${provider.totalGrandBalance.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Suppliers",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "${provider.payables.length}",
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

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              "#",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: Text(
              "SUPPLIER",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Text(
            "BALANCE",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayablesList(PayableAmountProvider provider) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: provider.payables.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final p = provider.payables[index];
        return _PayableListItem(
          index: index,
          supplierName: p.supplierName,
          grandBalance: p.grandBalance,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SupplierLedgerScreen(
                  supplierId: p.supplierId.toString(),
                  supplierName: p.supplierName,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTotalCard(PayableAmountProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade100, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.summarize_rounded,
                    color: Colors.red.shade400, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                "Total Payable",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          Text(
            "₨ ${provider.totalGrandBalance.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: Colors.red.shade600,
              letterSpacing: 0.3,
            ),
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
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          Text(
            "No payable records found",
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
}

// ─── Extracted list tile widget ──────────────────────────────────────────────

class _PayableListItem extends StatelessWidget {
  final int index;
  final String supplierName;
  final double grandBalance;
  final VoidCallback onTap;

  const _PayableListItem({
    required this.index,
    required this.supplierName,
    required this.grandBalance,
    required this.onTap,
  });

  Color get _avatarColor {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF43A8C7),
      const Color(0xFFFF6B6B),
      const Color(0xFF48BB78),
      const Color(0xFFED8936),
      const Color(0xFF667EEA),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        splashColor: AppColors.primary.withOpacity(0.06),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Index badge
              SizedBox(
                width: 44,
                child: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),

              // Avatar + name
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: _avatarColor.withOpacity(0.12),
                      child: Text(
                        supplierName.isNotEmpty
                            ? supplierName[0].toUpperCase()
                            : "?",
                        style: TextStyle(
                          color: _avatarColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        supplierName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Balance + chevron
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₨ ${grandBalance.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: grandBalance > 0
                              ? Colors.red.shade500
                              : Colors.green.shade600,
                        ),
                      ),
                      Text(
                        grandBalance > 0 ? "Payable" : "Clear",
                        style: TextStyle(
                          fontSize: 10,
                          color: grandBalance > 0
                              ? Colors.red.shade300
                              : Colors.green.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.grey.shade300, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}