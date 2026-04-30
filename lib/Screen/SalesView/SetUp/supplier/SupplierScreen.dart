
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Provider/SupplierProvider/supplierProvider.dart';
import '../../../../compoents/AppColors.dart';
import 'AddSupplier.dart';
import 'UpdateSupplier.dart';


class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupplierProvider>(context, listen: false).loadSuppliers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Center(child: const Text("Supplier List",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 1.2,
            )),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //     child: ElevatedButton.icon(
        //       onPressed: () {
        //         Navigator.push(context,MaterialPageRoute(builder:(context)=>AddSupplierScreen()));
        //       },
        //       icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        //       label: const Text(
        //         "Add Supplier",
        //         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        //       ),
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Colors.transparent,
        //         shadowColor: Colors.transparent,
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(20),
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
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
      ),
      body: Consumer<SupplierProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: provider.suppliers.length,
            itemBuilder: (context, index) {
              final data = provider.suppliers[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email: ${data.email}"),
                      Text("Address: ${data.address}"),
                      Text("Address: ${data.phone}"),
                      Text("Payment: ${data.openingBalance}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ Update
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateSupplierScreen(supplier: data),
                            ),
                          );
                        },

                      ),

                      // ✅ Delete
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: const Text("Are you sure you want to delete this supplier?"),
                              actions: [
                                TextButton(
                                  child: const Text("No"),
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                  },
                                ),
                                TextButton(
                                  child: const Text("Yes", style: TextStyle(color: Colors.red)),
                                  onPressed: () async {
                                    Navigator.pop(context); // close popup
                                    provider.deleteSupplier(data.id.toString()); // delete supplier
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      )

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
