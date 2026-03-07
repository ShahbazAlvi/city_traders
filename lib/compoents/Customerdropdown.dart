


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/CustomerProvider/CustomerProvider.dart';
import '../model/CustomerModel/CustomerModel.dart';
import '../model/CustomerModel/CustomersDefineModel.dart';

class CustomerDropdown extends StatefulWidget {
  final int? selectedCustomerId;
  final ValueChanged<CustomerData?> onChanged;
  //final String label;
  final bool showDetails;

  const CustomerDropdown({
    super.key,
    required this.onChanged,
    this.selectedCustomerId,
    //this.label = "Select Customer",
    this.showDetails = true,
  });

  @override
  State<CustomerDropdown> createState() => _CustomerDropdownState();
}

class _CustomerDropdownState extends State<CustomerDropdown>
    with SingleTickerProviderStateMixin {
  CustomerData? selectedCustomer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    Future.microtask(() =>
        Provider.of<CustomerProvider>(context, listen: false).fetchCustomers());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomerProvider>(context);

    if (provider.isLoading) {
      return _buildShimmerLoading();
    }

    if (provider.error!.isNotEmpty) {
      return _buildErrorWidget(provider.error!);
    }

    if (provider.customers.isEmpty) {
      return _buildEmptyState();
    }

    // Set initial selection if needed
    if (widget.selectedCustomerId != null && selectedCustomer == null) {
      try {
        selectedCustomer = provider.customers.firstWhere(
              (c) => c.id == widget.selectedCustomerId,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _animationController.forward();
        });
      } catch (e) {
        selectedCustomer = provider.customers.isNotEmpty
            ? provider.customers.first
            : null;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<int>(
            isExpanded: true,
            value: selectedCustomer?.id,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
              ),
              prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade600, size: 20),
              suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            ),
            icon: const SizedBox.shrink(),
            hint: Text(
              "Choose Customer",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
              ),
            ),
            items: provider.customers.map((customer) {
              return DropdownMenuItem<int>(
                value: customer.id,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (id) {
              if (id != null) {
                setState(() {
                  selectedCustomer = provider.customers
                      .firstWhere((c) => c.id == id);
                });
                widget.onChanged(selectedCustomer);
                _animationController.forward(from: 0.0);
              }
            },
          ),
        ),

        // Animated customer details section
        if (widget.showDetails && selectedCustomer != null)
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              child: _buildCustomerInfo(selectedCustomer!),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomerInfo(CustomerData customer) {
    final openingBalance = double.tryParse(customer.openingBalance) ?? 0.0;
    final creditLimit = double.tryParse(customer.creditLimit) ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.business_center,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Customer Details",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Info grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildInfoCard(
                  icon: Icons.phone_outlined,
                  label: "Phone",
                  value: customer.phone.isEmpty ? "N/A" : customer.phone,
                  color: Colors.blue,
                ),
                _buildInfoCard(
                  icon: Icons.location_on_outlined,
                  label: "Address",
                  value: customer.address.isEmpty ? "N/A" : customer.address,
                  color: Colors.orange,
                ),
                _buildInfoCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: "Balance",
                  value: "Rs ${openingBalance.toStringAsFixed(2)}",
                  color: Colors.green,
                ),
                _buildInfoCard(
                  icon: Icons.credit_card_outlined,
                  label: "Credit Limit",
                  value: "Rs ${creditLimit.toStringAsFixed(2)}",
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 16),


          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8, left: 4),
          child: Container(
            width: 120,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const ShimmerEffect(),
          ),
        ),
        Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey.shade300,
          ),
          child: const ShimmerEffect(),
        ),
        if (widget.showDetails) ...[
          const SizedBox(height: 16),
          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade300,
            ),
            child: const ShimmerEffect(),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200, width: 1),
        color: Colors.red.shade50,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Error loading customers",
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  error,
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            "No customers found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Add customers to get started",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// Shimmer Effect Widget
class ShimmerEffect extends StatefulWidget {
  const ShimmerEffect({super.key});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade100,
                  Colors.grey.shade300,
                ],
                stops: const [0.3, 0.5, 0.7],
                transform:
                SlidingGradientTransform(slidePercent: _animation.value),
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcOver,
            child: Container(
              color: Colors.grey.shade200,
            ),
          ),
        );
      },
    );
  }
}

class SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}