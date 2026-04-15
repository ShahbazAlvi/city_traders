
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Provider/CustomerProvider/CustomerProvider.dart';
import '../../Provider/SaleManProvider/SaleManProvider.dart';
import '../../compoents/AppButton.dart';
import '../../compoents/AppColors.dart';
import '../../compoents/AppTextfield.dart';
import '../../compoents/SaleManDropdown.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  String? Function(dynamic value) get validator => (value) => null;
  String paymentType = "credit";
  String? selectedDate;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //selectedSalesmanId = order.salesmanId?.id;
    Future.microtask(() =>
        Provider.of<SaleManProvider>(context, listen: false).fetchEmployees());
  }


  @override
  Widget build(BuildContext context) {
    final provider=Provider.of<CustomerProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFFEEEEEE),
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.text),
        title:  Center(
          child: Text("Add Customer",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 1.2,
            ),),
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(controller: provider.AreaNameController, label: "Area Name", validator: validator),
              SizedBox(height: 10,),
              AppTextField(controller: provider.CustomerNameController, label: "Customer Name", validator: validator),
              SizedBox(height: 10,),
              AppTextField(controller: provider.ContactNumberController, label: "Contact Number", validator: validator),
              SizedBox(height: 10,),
              AppTextField(controller: provider.AddressController, label: "Address", validator: validator),
              SizedBox(height: 10,),
              AppTextField(controller: provider.OpeningBalanceController, label: "Opening Balance", validator: validator),
              SizedBox(height: 10,),
              AppTextField(
                controller: provider.EmailController,
                label: "Email",
                validator: validator,
              ),
              SizedBox(height: 10,),
              AppTextField(
                controller: provider.SubAreaController,
                label: "Sub Area ID",
                validator: validator,
              ),


              SizedBox(height: 10,),
              Text("Payment Terms"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: const Text("Credit"),
                        value: "credit",
                        groupValue: paymentType,
                        activeColor: AppColors.secondary,
                        onChanged: (value) {
                          setState(() {
                            paymentType = value.toString();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        title: const Text("Cash"),
                        value: "cash",
                        groupValue: paymentType,
                        activeColor: AppColors.secondary,
                        onChanged: (value) {
                          setState(() {
                            paymentType = value.toString();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10,),
              AppTextField(controller: provider.CreditDaysLimitController, label: "Credit Days Limit", validator: validator),
              SizedBox(height: 10,),
              AppTextField(controller: provider.CreditCashLimitController, label: "credit cash Limit", validator: validator),
              SizedBox(height: 10,),
              AppButton(
                title: provider.isLoading?"Loading...": "Save Customer",
                press: () async {


                  final success = await provider.addCustomer(
                    context: context,
                    paymentType: paymentType,
                  );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Customer Added Successfully!")),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed: ${provider.error}")),
                    );
                  }
                },
                width: double.infinity,
              )


            ],
          ),
        ),
      ),
    );
  }
}
