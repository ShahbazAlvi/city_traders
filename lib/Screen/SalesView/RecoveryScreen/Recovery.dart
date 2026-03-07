//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../../Provider/RecoveryProvider/RecoveryProvider.dart';
// import '../../../compoents/AppColors.dart';
// import '../../../compoents/Customerdropdown.dart';
// import '../../../compoents/SaleManDropdown.dart';
// import '../../../model/CustomerModel/CustomerModel.dart';
// import '../../../model/SaleRecoveryModel/SaleRecoveryModel.dart';
// import 'AddRecoveryScreen.dart';
//
// class RecoveryListScreen extends StatefulWidget {
//   const RecoveryListScreen({super.key});
//
//   @override
//   State<RecoveryListScreen> createState() => _RecoveryListScreenState();
// }
//
// class _RecoveryListScreenState extends State<RecoveryListScreen> {
//   String? selectedDate;
//   CustomerModel? selectedCustomer;
// @override
// @override
// void initState() {
//   super.initState();
//
//   final provider = Provider.of<RecoveryProvider>(context, listen: false);
//   provider.fetchRecoveryReport();
// }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<RecoveryProvider>(context);
//
//     final List<RecoveryVoucher> records =
//         provider.recoveryReport?.data.vouchers ?? [];
//
//
//
//     return Scaffold(
//       backgroundColor: Color(0xFFEEEEEE),
//       appBar: AppBar(
//         title: const Text("Recovery Report",
//             style: TextStyle(color: Colors.white, fontSize: 22)),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [AppColors.secondary, AppColors.primary],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 final provider = Provider.of<RecoveryProvider>(context, listen: false);
//
//                 String nextRvNo = "RV-0001"; // default
//
//                 if (provider.recoveryReport != null &&
//                     provider.recoveryReport!.data.vouchers.isNotEmpty) {
//                   final allNumbers = provider.recoveryReport!.data.vouchers.map((voucher) {
//                     final regex = RegExp(r'RV-(\d+)$');
//                     final match = regex.firstMatch(voucher.rvNo);
//                     return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
//                   }).toList();
//
//                   final maxNumber =
//                   allNumbers.isNotEmpty ? allNumbers.reduce((a, b) => a > b ? a : b) : 0;
//                   nextRvNo = "RV-${(maxNumber + 1).toString().padLeft(4, '0')}";
//                 }
//
//
//                 print("Next RV No: $nextRvNo");
//
//
//                 print("Next RV No: $nextRvNo");
//
//
//
//
//
//                 // ✅ Navigate to AddOrderScreen with incremented ID
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => AddRecoveryScreen(nextOrderId: nextRvNo),
//                   ),
//                 );
//               },
//               icon: const Icon(Icons.add_circle_outline, color: Colors.white),
//               label: const Text(
//                 "Add Order",
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 shadowColor: Colors.transparent,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               children: [
//                 GestureDetector(
//                   onTap: () async {
//                     DateTime? picked = await showDatePicker(
//                       context: context,
//                       initialDate: DateTime.now(),
//                       firstDate: DateTime(2020),
//                       lastDate: DateTime(2030),
//                     );
//
//                     if (picked != null) {
//                       selectedDate = DateFormat('yyyy-MM-dd').format(picked);
//                       setState(() {});
//                       provider.fetchRecoveryReport(
//                         // selectedCustomer?.id ?? "",
//                         // selectedDate ?? "",
//                       );
//                     }
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       color: Colors.grey.shade200,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(selectedDate ?? "Select Date"),
//                         const Icon(Icons.calendar_today),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 // CustomerDropdown(
//                 //   showDetails: false,
//                 //   selectedCustomerId: selectedCustomer?.id,
//                 //   onChanged: (customer) {
//                 //     setState(() => selectedCustomer = customer);
//                 //     provider.fetchRecoveryReport(
//                 //       selectedCustomer?.id ?? "",
//                 //       selectedDate ?? "",
//                 //     );
//                 //   },
//                 // ),
//               ],
//             ),
//           ),
//
//           if (provider.isLoading)
//             const Expanded(
//               child: Center(child: CircularProgressIndicator()),
//             )
//           else
//             Expanded(
//               child: records.isEmpty
//                   ? const Center(child: Text("No Recovery Records Found"))
//                   : ListView.builder(
//                 itemCount: records.length,
//                 itemBuilder: (context, index) {
//                   final item = records[index];
//
//                   return Card(
//                     margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     shadowColor: Colors.grey.withOpacity(0.3),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Invoice Header
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 "Invoice: ${item.rvNo}",
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 8, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: item.status == "Pending"
//                                       ? Colors.orange
//                                       : Colors.green,
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Text(
//                                   item.status ?? "N/A",
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               )
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//
//                           // Customer & Salesman
//                           Row(
//                             children: [
//                               const Icon(Icons.person, size: 16, color: Colors.grey),
//                               const SizedBox(width: 4),
//                               Expanded(
//                                 child: Text(
//                                   item.customerName,
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                               ),
//                               const Icon(Icons.work, size: 16, color: Colors.grey),
//                               const SizedBox(width: 4),
//                               Expanded(
//                                 child: Text(
//                                   item.salesmanName,
//                                   style: const TextStyle(fontSize: 14),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//
//                           // Financial Info Row
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               _infoChip("Amount", item.amount.toString()),
//                               _infoChip("Mode", item.mode),
//                               _infoChip("Date", DateFormat('dd-MM-yyyy').format(item.createdAt)),
//
//
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//
//                           // Days Info Row
//                           _infoChip("Recovery Date", DateFormat('dd-MM-yyyy').format(item.recoveryDate)),
//
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//
//         ],
//       ),
//     );
//   }
//   Widget _infoChip(String title, dynamic value) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         "$title: $value",
//         style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//       ),
//     );
//   }
//
// }
//
//

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Provider/RecoveryProvider/RecoveryProvider.dart';
import '../../../compoents/AppColors.dart';
import '../../../compoents/Customerdropdown.dart';
import '../../../compoents/SaleManDropdown.dart';
import '../../../model/CustomerModel/CustomerModel.dart';
import '../../../model/SaleRecoveryModel/SaleRecoveryModel.dart';
import '../../../utils/access_control.dart';
import 'AddRecoveryScreen.dart';

class RecoveryListScreen extends StatefulWidget {
  const RecoveryListScreen({super.key});

  @override
  State<RecoveryListScreen> createState() => _RecoveryListScreenState();
}

class _RecoveryListScreenState extends State<RecoveryListScreen>
    with SingleTickerProviderStateMixin {  // ✅ Added this mixin
  String? selectedDate;
  CustomerModel? selectedCustomer;

  // Animation controller for shimmer effect
  late AnimationController _shimmerController;

  // @override
  // void initState() {
  //   super.initState();
  //   _shimmerController = AnimationController.unbounded(vsync: this)
  //     ..repeat(min: 0, max: 1, period: const Duration(milliseconds: 1500));
  //
  //   final provider = Provider.of<RecoveryProvider>(context, listen: false);
  //   provider.fetchRecoveryReport();
  // }
  // ✅ Permission Variables
  bool canAddOrder    = false;
  bool canEditOrder   = false;
  bool canDeleteOrder = false;
  bool canViewOrder   = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: 0, max: 1, period: const Duration(milliseconds: 1500));

    final provider = Provider.of<RecoveryProvider>(context, listen: false);
    provider.fetchRecoveryReport();
    _loadPermissions(); // ✅ Load permissions
  }
  Future<void> _loadPermissions() async {
    final add    = await AccessControl.canDo("can_add_recovery_voucher");


    setState(() {
      canAddOrder    = add;

    });
  }


  @override
  void dispose() {
    _shimmerController.dispose();  // ✅ Don't forget to dispose
    super.dispose();
  }

  // Shimmer effect builder
  Widget _buildShimmerEffect({required Widget child}) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: const [
            Color(0xFFE0E0E0),
            Color(0xFFF5F5F5),
            Color(0xFFE0E0E0),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment(-1.0, -0.5),
          end: Alignment(1.0, 0.5),
          transform: GradientRotation(_shimmerController.value * 2 * 3.14159),
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: child,
    );
  }

  // Shimmer loading cards
  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildShimmerChip(),
                  const SizedBox(width: 8),
                  _buildShimmerChip(),
                  const SizedBox(width: 8),
                  _buildShimmerChip(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerChip() {
    return Container(
      width: 80,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecoveryProvider>(context);
    final List<RecoveryVoucher> records = provider.recoveryReport?.data.vouchers ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          "Recovery Report",
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
        actions: [
          if(canAddOrder)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.2),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final provider = Provider.of<RecoveryProvider>(context, listen: false);
                  String nextRvNo = "RV-0001";

                  if (provider.recoveryReport != null &&
                      provider.recoveryReport!.data.vouchers.isNotEmpty) {
                    final allNumbers = provider.recoveryReport!.data.vouchers.map((voucher) {
                      final regex = RegExp(r'RV-(\d+)$');
                      final match = regex.firstMatch(voucher.rvNo);
                      return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
                    }).toList();

                    final maxNumber = allNumbers.isNotEmpty ? allNumbers.reduce((a, b) => a > b ? a : b) : 0;
                    nextRvNo = "RV-${(maxNumber + 1).toString().padLeft(4, '0')}";
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddRecoveryScreen(nextOrderId: nextRvNo),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Add Order",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Date Filter Card
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: Color(0xFF1E293B),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (picked != null) {
                        setState(() {
                          selectedDate = DateFormat('yyyy-MM-dd').format(picked);
                        });
                        provider.fetchRecoveryReport();
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Date",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  selectedDate ?? "Select Date",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: selectedDate != null ? FontWeight.w600 : FontWeight.w400,
                                    color: selectedDate != null ? const Color(0xFF1E293B) : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Customer Dropdown (commented as in original)
                // CustomerDropdown(
                //   showDetails: false,
                //   selectedCustomerId: selectedCustomer?.id,
                //   onChanged: (customer) {
                //     setState(() => selectedCustomer = customer);
                //     provider.fetchRecoveryReport();
                //   },
                // ),
              ],
            ),
          ),

          // Stats Card
          if (!provider.isLoading && records.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.receipt_long,
                    label: "Total",
                    value: records.length.toString(),
                  ),
                  _buildStatItem(
                    icon: Icons.pending_actions,
                    label: "Pending",
                    value: records.where((r) => r.status == "Pending").length.toString(),
                  ),
                  _buildStatItem(
                    icon: Icons.check_circle,
                    label: "Completed",
                    value: records.where((r) => r.status != "Pending").length.toString(),
                  ),
                ],
              ),
            ),

          // Records List
          if (provider.isLoading)
            Expanded(
              child: _buildShimmerEffect(child: _buildShimmerLoading()),
            )
          else
            Expanded(
              child: records.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_outlined,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "No Recovery Records Found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Add a new recovery order to get started",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final item = records[index];
                  final isPending = item.status == "Pending";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: () {
                          // Optional: Add tap functionality
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.receipt,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Invoice Number",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item.rvNo,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isPending
                                          ? Colors.orange.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isPending
                                                ? Colors.orange
                                                : Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          item.status ?? "N/A",
                                          style: TextStyle(
                                            color: isPending
                                                ? Colors.orange
                                                : Colors.green,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Customer & Salesman Row
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoRow(
                                      icon: Icons.person_outline,
                                      label: "Customer",
                                      value: item.customerName,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoRow(
                                      icon: Icons.business_center_outlined,
                                      label: "Salesman",
                                      value: item.salesmanName,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Financial Info Row
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildChip(
                                      label: "Amount",
                                      value: "Rs:${item.amount.toStringAsFixed(2)}",
                                      icon: Icons.currency_rupee,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildChip(
                                      label: "Mode",
                                      value: item.mode,
                                      icon: Icons.payment,
                                      color: Colors.purple,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Dates Row
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildChip(
                                      label: "Created",
                                      value: DateFormat('dd MMM yyyy').format(item.createdAt),
                                      icon: Icons.calendar_today,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildChip(
                                      label: "Recovery",
                                      value: DateFormat('dd MMM yyyy').format(item.recoveryDate),
                                      icon: Icons.event_available,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: color.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
