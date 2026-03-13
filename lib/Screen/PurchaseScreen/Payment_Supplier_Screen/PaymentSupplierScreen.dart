import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Provider/Purchase_Provider/Payment_TO_Supplier_Provider/PaymentSupplierProvider.dart';
import '../../../compoents/AppColors.dart';

class PaymentToSupplierScreen extends StatefulWidget {
  final String? supplierId;       // ✅ new
  final String? supplierName;
  const PaymentToSupplierScreen({super.key, this.supplierId, this.supplierName});

  @override
  State<PaymentToSupplierScreen> createState() =>
      _PaymentToSupplierScreenState();
}

class _PaymentToSupplierScreenState extends State<PaymentToSupplierScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentToSupplierProvider>(context, listen: false)
          .loadPayments();  // ✅ just load payments normally
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Payment To Supplier",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
            ),
          ),
        ),
      ),

      body: Consumer<PaymentToSupplierProvider>(
        builder: (context, provider, _) {

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.paymentList.isEmpty) {
            return const Center(child: Text("No Payments Found"));
          }

          return ListView.builder(
            itemCount: provider.paymentList.length,
            itemBuilder: (context, index) {

              final data = provider.paymentList[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                child: ListTile(

                  title: Text(
                    "${data.paymentNo}   ${data.supplierName}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text("Mode: ${data.paymentMode}"),
                      Text("Rs : ${NumberFormat('#,##0').format(double.parse(data.amount.toString()))}",),

                    ],
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      /// Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          provider.deletePayment(data.id);
                        },
                      ),

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