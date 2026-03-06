//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../Provider/Purchase_Provider/PayaAmountProvider/PayaAmountProvider.dart';
// import '../../../compoents/AppColors.dart';
//
// class PayableAmountScreen extends StatefulWidget {
//   const PayableAmountScreen({super.key});
//
//   @override
//   State<PayableAmountScreen> createState() => _PayableAmountScreenState();
// }
//
// class _PayableAmountScreenState extends State<PayableAmountScreen> {
//   bool withZero = true;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<PayableAmountProvider>(context, listen: false)
//           .fetchPayables(withZero: withZero);
//     });
//   }
//
//   void _onFilterChanged(bool value) {
//     setState(() => withZero = value);
//     Provider.of<PayableAmountProvider>(context, listen: false)
//         .fetchPayables(withZero: value);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Center(
//           child: Text(
//             "Payable Amount Details",
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 22,
//               letterSpacing: 1.2,
//             ),
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
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             /// ---------------- RADIO FILTER ----------------
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Row(
//                   children: [
//                     Radio(value: true, groupValue: withZero, onChanged: (v) => _onFilterChanged(v!)),
//                     const Text("With Zero"),
//                   ],
//                 ),
//                 const SizedBox(width: 20),
//                 Row(
//                   children: [
//                     Radio(value: false, groupValue: withZero, onChanged: (v) => _onFilterChanged(v!)),
//                     const Text("Without Zero"),
//                   ],
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 10),
//
//             /// ---------------- TABLE VIEW ----------------
//             Expanded(
//               child: Consumer<PayableAmountProvider>(
//                 builder: (context, provider, child) {
//                   if (provider.isLoading) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   if (provider.payables.isEmpty) {
//                     return const Center(child: Text("No data found"));
//                   }
//
//                   return Column(
//                     children: [
//                       // Expanded(
//                       //   child: SingleChildScrollView(
//                       //     scrollDirection: Axis.horizontal,
//                       //     child: DataTable(
//                       //       columns: const [
//                       //         DataColumn(label: Text("S.No", style: TextStyle(fontWeight: FontWeight.bold))),
//                       //         DataColumn(label: Text("Supplier", style: TextStyle(fontWeight: FontWeight.bold))),
//                       //         DataColumn(label: Text("Balance", style: TextStyle(fontWeight: FontWeight.bold))),
//                       //       ],
//                       //       rows: provider.payables.asMap().entries.map((entry) {
//                       //         int index = entry.key;
//                       //         var p = entry.value;
//                       //
//                       //         return DataRow(
//                       //           cells: [
//                       //             DataCell(Text("${index + 1}")),
//                       //             DataCell(Text(p.supplier ?? "N/A")),
//                       //             DataCell(Text(p.balance?.toStringAsFixed(2) ?? "0.00")),
//                       //
//                       //           ],
//                       //         );
//                       //       }).toList(),
//                       //     ),
//                       //   ),
//                       // ),
//                       Expanded(
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.vertical,   // ⬆⬇ Vertical Scroll
//                           child: SingleChildScrollView(
//                             scrollDirection: Axis.horizontal, // ⬅➡ Horizontal Scroll
//                             child: DataTable(
//                               columns: const [
//                                 DataColumn(label: Text("S.No", style: TextStyle(fontWeight: FontWeight.bold))),
//                                 DataColumn(label: Text("Supplier", style: TextStyle(fontWeight: FontWeight.bold))),
//                                 DataColumn(label: Text("Balance", style: TextStyle(fontWeight: FontWeight.bold))),
//                                // DataColumn(label: Text("SR", style: TextStyle(fontWeight: FontWeight.bold))),
//                               ],
//                               rows: provider.payables.asMap().entries.map((entry) {
//                                 int index = entry.key;
//                                 var p = entry.value;
//                                 return DataRow(
//                                   cells: [
//                                     DataCell(Text("${index + 1}")),
//                                     DataCell(Text(p.supplier ?? "N/A")),
//                                     DataCell(Text(p.balance?.toStringAsFixed(2) ?? "0.00")),
//                                    // DataCell(Text(p.sr ?? "-")),
//                                   ],
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         ),
//                       )
//
//
//                       /// ---------------- TOTAL PAYABLE ----------------
//                       // Card(
//                       //   color: Colors.grey[200],
//                       //   margin: const EdgeInsets.only(top: 12),
//                       //   child: Padding(
//                       //     padding: const EdgeInsets.all(16),
//                       //     child: Text(
//                       //       "Total Payable: ${provider.totalPayable.toStringAsFixed(2)}",
//                       //       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                       //     ),
//                       //   ),
//                       // ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Provider/Purchase_Provider/PayaAmountProvider/PayaAmountProvider.dart';
import '../../../compoents/AppColors.dart';

class PayableAmountScreen extends StatefulWidget {
  const PayableAmountScreen({super.key});

  @override
  State<PayableAmountScreen> createState() => _PayableAmountScreenState();
}

class _PayableAmountScreenState extends State<PayableAmountScreen> {

  bool withZero = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PayableAmountProvider>().fetchPayables();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Payable Amount Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
        padding: const EdgeInsets.all(16),
        child: Consumer<PayableAmountProvider>(
          builder: (context, provider, child) {

            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.payables.isEmpty) {
              return const Center(child: Text("No data found"));
            }

            return Column(
              children: [

                /// ---------------- TABLE ----------------
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(

                        headingRowColor: MaterialStateProperty.all(
                          Colors.grey.shade200,
                        ),

                        columns: const [

                          DataColumn(
                            label: Text(
                              "S.No",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),

                          DataColumn(
                            label: Text(
                              "Supplier",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),

                          DataColumn(
                            label: Text(
                              "Balance",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],

                        rows: provider.payables.asMap().entries.map((entry) {

                          int index = entry.key;
                          var p = entry.value;

                          return DataRow(
                            cells: [

                              DataCell(Text("${index + 1}")),

                              DataCell(Text(p.supplierName)),

                              DataCell(
                                Text(
                                  "₨ ${p.grandBalance.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                            ],
                          );

                        }).toList(),
                      ),
                    ),
                  ),
                ),

                /// ---------------- TOTAL CARD ----------------
                Card(
                  color: Colors.grey.shade200,
                  margin: const EdgeInsets.only(top: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        const Text(
                          "Total Payable",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        Text(
                          "₨ ${provider.totalGrandBalance.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.red,
                          ),
                        ),

                      ],
                    ),
                  ),
                )

              ],
            );
          },
        ),
      ),
    );
  }
}