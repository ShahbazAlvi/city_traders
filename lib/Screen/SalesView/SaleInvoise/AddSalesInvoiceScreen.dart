
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Provider/OrderTakingProvider/OrderTakingProvider.dart';
import '../../../Provider/setup/location_provider.dart';
import '../../../compoents/location_dropdown.dart';
import '../../../compoents/tax_types_dropdown.dart';
import '../../../model/SaleInvoiceModel/InvoiceOrderUpdate.dart';
import '../../../ApiLink/ApiEndpoint.dart';
import 'package:http/http.dart' as http;

import '../../../model/setup/tax_Types_model.dart';

class AddSalesInvoiceScreen extends StatefulWidget {
  final String nextOrderId;
  const AddSalesInvoiceScreen({super.key, required this.nextOrderId});

  @override
  State<AddSalesInvoiceScreen> createState() => _AddSalesInvoiceScreenState();
}

class _AddSalesInvoiceScreenState extends State<AddSalesInvoiceScreen>
    with SingleTickerProviderStateMixin {
  int? selectedOrderId;
  int? selectedLocationId;
  TaxModel? selectedTax;
  late AnimationController _shimmerController;
  List<DropdownMenuItem<int>> _dropdownItems = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<LocationProvider>(context, listen: false).getLocations();
    });
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: 0, max: 1, period: const Duration(milliseconds: 1500));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    final provider = Provider.of<OrderTakingProvider>(context, listen: false);
    await provider.FetchOrderTaking();

    // Update dropdown items after data is loaded
    if (provider.orderData?.data != null && provider.orderData!.data.isNotEmpty) {
      setState(() {
        _dropdownItems = provider.orderData!.data.map((order) {
          return DropdownMenuItem<int>(
            value: int.parse(order.id),
            child: Container(
              width: MediaQuery.of(context).size.width - 80,
              //padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // Container(
                  //   width: 40,
                  //   height: 40,
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFF2563EB).withOpacity(0.1),
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: const Center(
                  //     child: Icon(
                  //       Icons.receipt_outlined,
                  //       color: Color(0xFF2563EB),
                  //       size: 20,
                  //     ),
                  //   ),
                  // ),
                 // const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          order.soNo,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          order.customerName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.bold
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList();
      });
    }
  }

  void onOrderSelected(int orderId) async {
    setState(() {
      selectedOrderId = orderId;
    });

    await Provider.of<OrderTakingProvider>(context, listen: false)
        .fetchSingleOrder(orderId);
  }

  void updateLineTotal(OrderDetail item) {
    item.lineTotal = item.qty * item.rate;
  }

  Future<void> createInvoice() async {
    final provider = Provider.of<OrderTakingProvider>(context, listen: false);
    if (provider.selectedOrder == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final body = {
      "inv_no": widget.nextOrderId,
      "sales_order_id": provider.selectedOrder!.id,
      "customer_id": provider.selectedOrder!.customerId,
      "salesman_id": provider.selectedOrder!.salesmanId,
      "location_id": selectedLocationId,//int? selectedLocationId;
      "invoice_date": DateTime.now().toIso8601String().split("T").first,
      "invoice_type": "CASH",
      "status": "DRAFT",
      "details": provider.selectedOrder!.details.map((item) => {
        "item_id": item.itemId,
        "qty": item.qty,
        "rate": item.rate,
        "tax_type_id":selectedTax?.id,
      }).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse("${ApiEndpoints.baseUrl}/sales-invoices-notax"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "x-company-id": "2",
        },
        body: jsonEncode(body),
      );

      print("STATUS => ${response.statusCode}");
      print("BODY => ${response.body}");

      final res = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res["message"] ?? "Invoice created successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res["message"] ?? "Failed to create invoice"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

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
          transform:
          GradientRotation(_shimmerController.value * 2 * 3.14159),
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: child,
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderTakingProvider>(context);
    final total = provider.selectedOrder?.details
        .fold(0.0, (sum, item) => sum + item.lineTotal) ??
        0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1E293B),
        title: const Text(
          "Create Sales Invoice",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
      body: provider.isLoading
          ? _buildShimmerEffect(child: _buildShimmerLoading())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Selection Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: DropdownButtonFormField<int>(
                value: selectedOrderId,
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.search,
                          color: Color(0xFF2563EB),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Select Sales Order",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                icon: const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF2563EB),
                    size: 28,
                  ),
                ),
                isExpanded: true,
                items: _dropdownItems.isEmpty && provider.orderData?.data != null
                    ? provider.orderData!.data.map((order) {
                  return DropdownMenuItem<int>(
                    value: int.parse(order.id),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 80,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.receipt_outlined,
                                color: Color(0xFF2563EB),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.soNo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  order.customerName,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList()
                    : _dropdownItems,
                onChanged: (id) {
                  if (id != null) onOrderSelected(id);
                },
              ),
            ),
            const SizedBox(height: 20),
            // tax types dropdown
            TaxTypeDropdown(
              onSelected: (tax) {
                setState(() {
                  selectedTax = tax;
                });
              },
            ),

            const SizedBox(height: 20),
           // locsation drop down
            Consumer<LocationProvider>(
              builder: (context, provider, child) {

                return LocationDropdown(
                  locations: provider.locationList,
                  selectedId: selectedLocationId,
                  onChanged: (value) {

                    setState(() {
                      selectedLocationId = value;
                    });

                  },
                );
              },
            ),
            const SizedBox(height: 15),

            // Show message if no orders available
            if (provider.orderData?.data == null || provider.orderData!.data.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No Orders Available",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "There are no sales orders to create invoices",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            // Selected Order Info Card
            if (provider.selectedOrder != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF3B82F6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.selectedOrder!.customerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  provider.selectedOrder!.salesmanName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.receipt_long,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Order #: ${provider.selectedOrder!.soNo}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "${provider.selectedOrder!.details.length} Items",
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Items Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Order Items",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Rs${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Items List
              Expanded(
                child: ListView.builder(
                  itemCount: provider.selectedOrder!.details.length,
                  itemBuilder: (context, index) {
                    final item = provider.selectedOrder!.details[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  color: Color(0xFF2563EB),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.itemName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // Quantity Field
                              Expanded(
                                child: _buildInputField(
                                  label: "Qty",
                                  value: item.qty.toString(),
                                  icon: Icons.production_quantity_limits,
                                  onChanged: (val) {
                                    item.qty = double.tryParse(val) ?? 0;
                                    setState(
                                            () => updateLineTotal(item));
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Rate Field
                              Expanded(
                                child: _buildInputField(
                                  label: "Rate (Rs)",
                                  value: item.rate.toString(),
                                  icon: Icons.money,
                                  onChanged: (val) {
                                    item.rate = double.tryParse(val) ?? 0;
                                    setState(
                                            () => updateLineTotal(item));
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Total Display
                              Expanded(
                                child: Container(
                                  height: 56,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.green.shade50,
                                        Colors.green.shade100,
                                      ],
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total",
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "Rs${item.lineTotal.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Color(0xFF166534),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Grand Total & Create Button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Grand Total",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          "Rs:${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: createInvoice,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2563EB),
                                Color(0xFF3B82F6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB)
                                    .withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Create Invoice",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
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
              ),
            ],

            // Empty State
            if (provider.selectedOrder == null && !provider.isLoading && provider.orderData?.data != null && provider.orderData!.data.isNotEmpty)
              Expanded(
                child: Center(
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
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "No Order Selected",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Please select a sales order from\nthe dropdown above",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String value,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: TextFormField(
        initialValue: value,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
          floatingLabelStyle: const TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            size: 18,
            color: Colors.grey.shade500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}