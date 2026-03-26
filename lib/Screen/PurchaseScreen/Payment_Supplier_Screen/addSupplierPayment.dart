import 'package:flutter/material.dart';

import '../../../compoents/AppColors.dart';

class AddSupplierPayment extends StatefulWidget {
  const AddSupplierPayment({super.key});

  @override
  State<AddSupplierPayment> createState() => _AddSupplierPaymentState();
}

class _AddSupplierPaymentState extends State<AddSupplierPayment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
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
}
