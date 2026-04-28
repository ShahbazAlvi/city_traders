


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../ApiLink/ApiEndpoint.dart';
import '../../../Provider/OrderTakingProvider/OrderTakingProvider.dart';
import '../../../Provider/SaleManProvider/SaleManProvider.dart';
import '../../../compoents/AppColors.dart';
import '../../../compoents/Customerdropdown.dart';
import '../../../compoents/ProductDropdown.dart';
import '../../../compoents/SaleManDropdown.dart';

import '../../../compoents/SalesAreaDropdown.dart';
import '../../../model/CustomerModel/CustomerModel.dart';
import '../../../model/CustomerModel/CustomersDefineModel.dart';
import '../../../model/OrderTakingModel/OrderTakingModel.dart';
import '../../../model/ProductModel/itemsdetailsModel.dart';
import '../../../utils/access_control.dart';
import '../../../Provider/setup/SalesAreasProvider.dart';

class AddOrderScreen extends StatefulWidget {
  final String nextOrderId;
  final OrderData? existingOrder;
  final bool isUpdate;

  const AddOrderScreen({
    super.key,
    required this.nextOrderId,
    this.existingOrder,
    this.isUpdate = false,
  });

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  late String currentDate;
  bool isLoading = false;
  String selectedStatus = "APPROVED";
  bool _isLocked = false;
// stock qunty
  int? _stockQty;
  bool _isFetchingStock = false;

  Future<void> _fetchStockQty(int itemId) async {
    debugPrint('📦 Fetching stock for item: $itemId');  // ← add this
    setState(() { _isFetchingStock = true; _stockQty = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/stock-position/item/$itemId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint('📦 Stock response: ${response.statusCode} - ${response.body}'); // ← add this
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final totalBalance = data['data']['total_balance'];
        setState(() { _stockQty = (totalBalance as num).toInt(); });
      }
    } catch (e) {
      debugPrint('Stock fetch error: $e');
    } finally {
      setState(() { _isFetchingStock = false; });
    }
  }



 // String? selectedSalesmanId;
  String? _salesmanId;
  String?  _selectedAreaId;
  List<int>? _allowedAreaIds;
  CustomerData? selectedCustomer;
  ItemDetails? selectedProduct;
  final formatted=NumberFormat("#,##,###");

  final TextEditingController qtyController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  List<Map<String, dynamic>> orderItems = [];

  @override
  void dispose() {
    qtyController.dispose();
    rateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSalesmanFromPrefs();
    currentDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());

    Future.microtask(() {
      context.read<SaleManProvider>().fetchEmployees();
      context.read<SalesAreasProvider>().fetchSalesAreas();
    });

    if (widget.isUpdate && widget.existingOrder != null) {
      final order = widget.existingOrder!;
     // selectedSalesmanId
      _salesmanId= order.salesmanId?.toString();
    }
  }

  double get grandTotal {
    return orderItems.fold(0.0, (sum, item) {
      bool isNew = item.containsKey("product");
      double total = isNew ? item["total"] : item["totalAmount"];
      return sum + total;
    });
  }
  Future<void> _loadSalesmanFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('salesman_id');
    final assignedAreas = await AccessControl.getAssignedAreaIds();

    setState(() {
      if (!widget.isUpdate || _salesmanId == null) {
        _salesmanId = id?.toString();
      }
      _isLocked = id != null;
      _allowedAreaIds = assignedAreas.isNotEmpty ? assignedAreas : null;

      // If salesman has exactly one area, pre-select it
      if (_allowedAreaIds != null && _allowedAreaIds!.length == 1) {
        _selectedAreaId = _allowedAreaIds!.first.toString();
      }
    });
  }


  void addProductToOrder() {
    if (selectedProduct != null && qtyController.text.isNotEmpty) {
      final qty = double.tryParse(qtyController.text) ?? 0;

      // Stock check
      if (_stockQty != null && qty > _stockQty!) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Insufficient stock! Available: $_stockQty, Requested: ${qty.toInt()}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return; // ← block adding
      }

      final price = double.tryParse(rateController.text) ??
          selectedProduct!.salePrice?.toDouble() ?? 0;
      final total = price * qty;

      setState(() {
        orderItems.add({
          "product": selectedProduct!,
          "qty": qty,
          "price": price,
          "total": total,
        });
      });

      qtyController.clear();
      rateController.clear();
      selectedProduct = null;
      _stockQty = null;
    }
  }

  void removeProduct(int index) {
    setState(() {
      orderItems.removeAt(index);
    });
  }



  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderTakingProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: isLoading
          ? _buildLoadingIndicator()
          : _buildMainContent(orderProvider),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      title: Text(
        widget.isUpdate ? "Update Order" : "Create New Order",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Processing...',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(OrderTakingProvider orderProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Info Card
          _buildOrderInfoCard(),
          const SizedBox(height: 24),

          // Salesman Section
          _buildSectionTitle('Salesman Information'),
          const SizedBox(height: 12),
          _buildSalesmanField(),
          const SizedBox(height: 24),

          // Sales Area Section
          if (_salesmanId != null) ...[
            _buildSectionTitle('Sales Area'),
            const SizedBox(height: 12),
            _buildSalesAreaField(),
            const SizedBox(height: 24),
          ],

          // Customer Section
          if (_selectedAreaId != null) ...[
            _buildSectionTitle('Customer Information'),
            const SizedBox(height: 12),
            _buildCustomerField(),
            const SizedBox(height: 24),
          ],


          _buildSectionTitle('Add Products'),
          const SizedBox(height: 12),
          _buildProductSelection(),
          const SizedBox(height: 24),

          // Products List Section
          if (orderItems.isNotEmpty) ...[
            _buildSectionTitle('Order Items (${orderItems.length})'),
            const SizedBox(height: 12),
            _buildProductsList(),
            const SizedBox(height: 16),
            _buildOrderSummary(),
            const SizedBox(height: 24),
          ],

          // Submit Button
          _buildSubmitButton(orderProvider),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.receipt_long,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order ID',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.nextOrderId,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  currentDate,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSalesmanField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SalesmanDropdown(
        selectedId: _salesmanId,
        isLocked: _isLocked,
        onChanged: (id) {
          setState(() {
            _salesmanId = id;
            _selectedAreaId = null;
            selectedCustomer = null;
          });
        },
      ),
    );
  }

  Widget _buildSalesAreaField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SalesAreaDropdown(
        selectedId: _selectedAreaId,
        allowedAreaIds: _allowedAreaIds,
        onChanged: (id) {
          setState(() {
            _selectedAreaId = id;
            selectedCustomer = null;
          });
        },
      ),
    );
  }

  Widget _buildCustomerField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomerDropdown(
        selectedCustomerId: selectedCustomer?.id,
        salesmanId: _salesmanId != null ? int.tryParse(_salesmanId!) : null,
        areaId: _selectedAreaId != null ? int.tryParse(_selectedAreaId!) : null,
        onChanged: (customer) {
          setState(() => selectedCustomer = customer);
        },
      ),
    );
  }


  Widget _buildProductSelection() {
    return Column(
      children: [
        // Product Dropdown
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ItemDetailsDropdown(
            // onItemSelected: (item) {
            //   setState(() => selectedProduct = item);
            //   if (item != null) {
            //     rateController.text = item.salePrice?.toString() ?? '';
            //   }
            // },
            onItemSelected: (item) {
              setState(() {
                selectedProduct = item;
                _stockQty = null;
              });
              if (item != null) {
                rateController.text = item.salePrice?.toString() ?? '';

                // Handle both int and String id types safely
                final rawId = item.id;
                final int? id = rawId is int
                    ? rawId as int          // ← add explicit cast
                    : int.tryParse(rawId?.toString() ?? '');

                if (id != null) {
                  _fetchStockQty(id);
                } else {
                  debugPrint('❌ Could not parse item id: ${item.id}');
                }
              }
            },
          ),
        ),

        if (selectedProduct != null) ...[
          const SizedBox(height: 16),

          // Selected Product Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedProduct!.name ?? 'Selected Product',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _isFetchingStock
                              ? Row(children: [
                            SizedBox(width: 12, height: 12,
                                child: CircularProgressIndicator(strokeWidth: 1.5,
                                    color: AppColors.primary)),
                            const SizedBox(width: 6),
                            Text('Fetching stock...', style: TextStyle(fontSize: 12,
                                color: Colors.grey.shade500)),
                          ])
                              : Text(
                            'Stock: ${_stockQty ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: (_stockQty != null && _stockQty! < 10)
                                  ? Colors.red.shade600   // low stock = red
                                  : Colors.grey.shade600,
                              fontWeight: (_stockQty != null && _stockQty! < 10)
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Rs${formatted.format(selectedProduct!.salePrice?? '0.00')}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quantity and Rate Fields
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: qtyController,
                  label: 'Quantity',
                  icon: Icons.format_list_numbered,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  controller: rateController,
                  label: 'Rate (Rs)',
                  icon: Icons.money,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Add Product Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: addProductToOrder,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text(
                'Add to Order',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
          prefixIcon: Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orderItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = orderItems[index];
        final isNew = item.containsKey("product");

        String itemName;
        double qty;
        double price;
        double total;

        if (isNew) {
          final product = item["product"] as ItemDetails;
          itemName = product.name ?? 'Product';
          qty = item["qty"];
          price = item["price"];
          total = item["total"];
        } else {
          itemName = item["itemName"];
          qty = item["qty"];
          price = item["rate"].toDouble();
          total = item["totalAmount"];
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Qty: $qty',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Rate: ${formatted.format(price)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                    onPressed: () => removeProduct(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${formatted.format(total)}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
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

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Grand Total:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            '${formatted.format(grandTotal)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(OrderTakingProvider orderProvider) {
    debugPrint('🔍 isFormValid check: salesman=$_salesmanId, customer=$selectedCustomer, items=${orderItems.length}');
    // final isFormValid = _salesmanId != null &&    //selectedSalesmanId
    //     selectedCustomer != null &&
    //     orderItems.isNotEmpty;
    final isFormValid = _salesmanId != null &&
        selectedCustomer != null &&
        orderItems.isNotEmpty;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isFormValid
            ? const LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        )
            : LinearGradient(
          colors: [Colors.grey.shade300, Colors.grey.shade400],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: isFormValid
            ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isFormValid && !isLoading
            ? () async {
          setState(() => isLoading = true);

          try {
            await orderProvider.createOrder(
              orderId: widget.nextOrderId,
              salesmanId: _salesmanId!,//selectedSalesmanId!,
              customerId: selectedCustomer!.id.toString(),
              status: selectedStatus,
              products: orderItems,
              salesAreaId: _selectedAreaId,
            );

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.isUpdate
                            ? "Order updated successfully!"
                            : "Order created successfully!",
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );

            Navigator.pop(context, true);
          } catch (e) {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.error,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text("Error: ${e.toString()}"),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } finally {
            if (mounted) {
              setState(() => isLoading = false);
            }
          }
        }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isFormValid ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.isUpdate ? "Updating..." : "Creating...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isFormValid ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        )
            : Text(
          widget.isUpdate ? "Update Order" : "Create Order",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isFormValid ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}