import 'package:demo_distribution/Screen/PurchaseScreen/PurchaseOrder/AddPurchaseOrder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


import '../../../Provider/Purchase_Order_Provider/Purchase_order_provider.dart';
import '../../../compoents/AppColors.dart';

class PurchaseOrderScreen extends StatefulWidget {
  const PurchaseOrderScreen({super.key});

  @override
  State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends State<PurchaseOrderScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PurchaseOrderProvider>().fetchPurchaseOrder();
    });
  }


  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "APPROVED":
        return Colors.green;
      case "PENDING":
        return Colors.orange;
      case "REJECTED":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PurchaseOrderProvider>();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Center(child: const Text("Purchase Order",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.2,
            )),
        ),
        centerTitle: true,
        elevation: 6,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                final provider =
                Provider.of<PurchaseOrderProvider>(context, listen: false);

                String nextOrderId = "PO-0001";

                if (provider.orders.isNotEmpty) {
                  final allNumbers = provider.orders.map((order) {
                    final id = order.poNo;
                    final regex = RegExp(r'PO-(\d+)$');
                    final match = regex.firstMatch(id);
                    return match != null
                        ? int.tryParse(match.group(1)!) ?? 0
                        : 0;
                  }).toList();

                  final maxNumber = allNumbers.reduce((a, b) => a > b ? a : b);
                  final incremented = maxNumber + 1;

                  nextOrderId = "PO-${incremented.toString().padLeft(4, '0')}";
                }

                print("✅ Next Order ID: $nextOrderId");

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddPurchaseOrder(nextOrderId: nextOrderId),
                  ),
                );
              },

              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text(
                "Add Order",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],





      ),

      body: Builder(
        builder: (_) {

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(child: Text(provider.error));
          }

          if (provider.orders.isEmpty) {
            return const Center(child: Text("No Purchase Orders"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.orders.length,
            itemBuilder: (context, index) {
              final order = provider.orders[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// PO Number + Status
                      Row(
                    children: [
                          Text(order.poNo,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(width: 5,),

                      Text(
                        (order.supplierName ?? '').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )

                        ],
                      ),

                      const SizedBox(height: 6),

                      /// Supplier


                      /// Date
                      Row(
                        children: [
                          Text("${DateFormat('dd MMM yyyy').format(order.poDate)}"),
                          SizedBox(width: 10,),
                          Text("Rs.${order.totalAmount}",
                              ),
                        ],
                      ),

                      /// Quantity


                      /// Amount


                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
