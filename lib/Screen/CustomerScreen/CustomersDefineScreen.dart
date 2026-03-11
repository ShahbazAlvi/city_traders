import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Provider/CustomerProvider/CustomerProvider.dart';
import '../../Provider/DashBoardProvider.dart';
import '../../compoents/AppColors.dart';
import '../../model/CustomerModel/CustomersDefineModel.dart';
import 'AddCustomerScreen.dart';
import 'Update customer.dart';

class CustomersDefineScreen extends StatefulWidget {
  const CustomersDefineScreen({super.key});

  @override
  State<CustomersDefineScreen> createState() => _CustomersDefineScreenState();
}

class _CustomersDefineScreenState extends State<CustomersDefineScreen> {
  @override
  void initState() {
    super.initState();

    /// Fetch data on screen load
    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomers());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomerProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Center(
          child: Text(
            "Customers",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 1.2,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                 Navigator.push(context,MaterialPageRoute(builder:(context)=>AddCustomerScreen()));
              },
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text(
                "Add Customer",
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

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator()) // ✅ Loader
          : provider.error != null && provider.error!.isNotEmpty
          ? Center(
        child: Text(
          provider.error!,
          style: const TextStyle(color: Colors.red),
        ),
      ) // ✅ Error UI
          : provider.customers.isEmpty
          ? const Center(child: Text("No customers found")) // ✅ Empty UI
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: provider.customers.length,
        itemBuilder: (context, index) {
          final CustomerData customer = provider.customers[index];


          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),

              title: Text(
                customer.name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                 // Text("Person: ${customer.contactPerson ?? "N/A"}"),
                  Text("Address: ${customer.address}"),
                 // Text("Balance: ${(customer.salesBalance ?? 0) - (customer.paidBalance ?? 0)}"),
                ],
              ),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ Update Button
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateCustomerScreen(
                            customer: {
                              "_id": customer.id,
                              "salesArea": customer.salesAreaId,
                              "customerName": customer.name,
                              "address": customer.address,
                              "phoneNumber": customer.phone,
                             // "salesBalance": customer.salesBalance,
                              "creditLimit": customer.creditLimit,
                              "creditTime": customer.creditLimit,
                              //"salesman": customer.salesman,
                              "openingBalanceDate": customer.openingBalance,
                              //"paymentTerms": customer.paymentTerms,
                            },
                          ),
                        ),
                      );


                      // TODO: Add update screen navigation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Update pressed")),
                      );
                    },
                  ),

                  // ✅ Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      //_confirmDelete(context, customer.id);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// ✅ Delete Confirmation Dialog


  void _confirmDelete(BuildContext context, String customerId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Customer"),
        content: const Text("Are you sure you want to delete this customer?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context);

              final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
              final dashProvider = Provider.of<DashboardProvider>(context, listen: false);

              bool success = await customerProvider.DeleteCustomer(customerId, dashProvider);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Deleted successfully")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(customerProvider.error ?? "Failed to delete")),
                );
              }
            },
          ),
        ],
      ),
    );
  }


}
