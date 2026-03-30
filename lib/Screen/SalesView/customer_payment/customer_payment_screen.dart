



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../Provider/customer_Payment/customer_payment_provider.dart';
import '../../../compoents/AppColors.dart';
import '../../../utils/access_control.dart';
import 'AddCustomerPaymentScreen.dart';

class CustomerPaymentScreen extends StatefulWidget {
  const CustomerPaymentScreen({super.key});

  @override
  State<CustomerPaymentScreen> createState() => _CustomerPaymentScreenState();
}

class _CustomerPaymentScreenState extends State<CustomerPaymentScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  // @override
  // void initState() {
  //   super.initState();
  //   Future.microtask(() =>
  //       context.read<CustomerPaymentProvider>().fetchCustomerPayments());
  // }

  bool canAddOrder    = false;
  bool canEditOrder   = false;
  bool canDeleteOrder = false;
  bool canViewOrder   = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<CustomerPaymentProvider>().fetchCustomerPayments());
    _loadPermissions(); // ✅ Load permissions
  }
  Future<void> _loadPermissions() async {
    final add    = await AccessControl.canDo("can_add_customer_payments");


    setState(() {
      canAddOrder    = add;

    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerPaymentProvider>();
    final payments = provider.paymentModel?.data.payments ?? [];

    final filtered = payments.where((p) {
      return p.customerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.paymentNo.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.invoiceNo.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: _buildAppBar(),

      floatingActionButton: canAddOrder
          ? FloatingActionButton.extended(
        elevation: 3,
        backgroundColor: AppColors.primary,
        // onPressed: () {
        //   final nextNo = provider.getNextPaymentNumber();
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (_) => AddCustomerPaymentScreen(paymentNo: nextNo),
        //     ),
        //   );
        // },
        onPressed: () async {
          final nextNo = provider.getNextPaymentNumber();

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddCustomerPaymentScreen(paymentNo: nextNo),
            ),
          );

          if (result == true) {
            context.read<CustomerPaymentProvider>().fetchCustomerPayments();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("New Payment"),
      )
          : null,  // ← null means no FAB shown
      body: provider.isLoading
          ? _buildShimmerList()
          : filtered.isEmpty
          ? _emptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (_, index) => _paymentCard(filtered[index]),
      ),
    );
  }

  // ================= SHIMMER =================

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.white,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  // ================= CARD =================

  Widget _paymentCard(payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xfff9fafc)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row
          Row(
            children: [
              Expanded(
                child: Text(
                  payment.paymentNo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              _statusBadge(payment.status),
            ],
          ),

          const SizedBox(height: 10),

          // Customer
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  payment.customerName,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Bottom Row
          Row(
            children: [
              const Icon(Icons.receipt_long,
                  size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text("Invoice ${payment.invoiceNo}"),

              const Spacer(),

              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Rs ${payment.paymentAmount}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= STATUS =================

  Widget _statusBadge(String status) {
    Color color;
    if (status == "POSTED") {
      color = Colors.green;
    } else if (status == "CANCELLED") {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= EMPTY =================

  Widget _emptyState() {
    return const Center(
      child: Text(
        "No Payments Found",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  // ================= APPBAR =================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
      ),
      title: const Text(
        "Customer Payments",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 8,
                )
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: const InputDecoration(
                hintText: "Search payments...",
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}