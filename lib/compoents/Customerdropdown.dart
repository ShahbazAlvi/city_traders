

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/CustomerProvider/CustomerProvider.dart';
import '../model/CustomerModel/CustomerModel.dart';
import '../model/CustomerModel/CustomersDefineModel.dart';

class CustomerDropdown extends StatefulWidget {
  final int? selectedCustomerId;
  final ValueChanged<CustomerData?> onChanged;
  final bool showDetails;
  final int? salesmanId;
  final int? areaId;

  const CustomerDropdown({
    super.key,
    required this.onChanged,
    this.selectedCustomerId,
    this.showDetails = true,
    this.salesmanId,
    this.areaId,
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

  /// Opens a searchable bottom sheet and returns the selected customer.
  Future<void> _openSearchSheet(List<CustomerData> customers) async {
    final result = await showModalBottomSheet<CustomerData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomerSearchSheet(customers: customers),
    );

    if (result != null) {
      setState(() => selectedCustomer = result);
      widget.onChanged(result);
      _animationController.forward(from: 0.0);
    }
  }

  /// Returns the customer list filtered by salesmanId (if provided).
  List<CustomerData> _applyFilter(List<CustomerData> all) {
    List<CustomerData> filtered = all;
    if (widget.salesmanId != null) {
      filtered = filtered.where((c) => c.salesmanId == widget.salesmanId).toList();
    }
    if (widget.areaId != null) {
      filtered = filtered.where((c) => c.salesAreaId == widget.areaId).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomerProvider>(context);

    if (provider.isLoading) return _buildShimmerLoading();
    if (provider.error!.isNotEmpty) return _buildErrorWidget(provider.error!);
    if (provider.accessFilteredCustomers.isEmpty) return _buildEmptyState();

    // Apply salesman filter and sort alphabetically
    final customers = _applyFilter(provider.accessFilteredCustomers);
    customers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (customers.isEmpty) return _buildEmptyState();

    // Set initial selection if provided
    if (widget.selectedCustomerId != null && selectedCustomer == null) {
      try {
        selectedCustomer = customers
            .firstWhere((c) => c.id == widget.selectedCustomerId);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _animationController.forward();
        });
      } catch (_) {
        selectedCustomer =
        customers.isNotEmpty
            ? customers.first
            : null;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Tappable field that triggers the search sheet ──────────────────
        GestureDetector(
          onTap: () => _openSearchSheet(customers),
          child: Container(
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
            child: AbsorbPointer(
              // Prevent Flutter's own tap handling; we handle it above.
              child: InputDecorator(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                    BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                    BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor, width: 1.5),
                  ),
                  prefixIcon: Icon(Icons.person_outline,
                      color: Colors.grey.shade600, size: 20),
                  suffixIcon: Icon(Icons.arrow_drop_down,
                      color: Colors.grey.shade600),
                ),
                child: selectedCustomer == null
                    ? Text(
                  "Choose Customer",
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 15),
                )
                    : Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      selectedCustomer!.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

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
            child: Icon(Icons.error_outline,
                color: Colors.red.shade700, size: 20),
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
                  style:
                  TextStyle(color: Colors.red.shade600, fontSize: 12),
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
          Icon(Icons.people_outline,
              size: 48, color: Colors.grey.shade400),
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
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ── Search Sheet ─────────────────────────────────────────────────────────────

class _CustomerSearchSheet extends StatefulWidget {
  final List<CustomerData> customers;
  const _CustomerSearchSheet({required this.customers});

  @override
  State<_CustomerSearchSheet> createState() => _CustomerSearchSheetState();
}

class _CustomerSearchSheetState extends State<_CustomerSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CustomerData> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.customers;
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? widget.customers
          : widget.customers
          .where((c) => c.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // Sheet takes up to 80 % of screen height + keyboard space
      height: MediaQuery.of(context).size.height * 0.75 + bottomInset,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Handle bar ────────────────────────────────────────────────────
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Title ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.people_outline,
                    color: Colors.grey.shade700, size: 22),
                const SizedBox(width: 10),
                Text(
                  "Select Customer",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close,
                      color: Colors.grey.shade500, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Search field ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style:
              const TextStyle(fontSize: 15, color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Search customer…",
                hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 15),
                prefixIcon: Icon(Icons.search,
                    color: Colors.grey.shade500, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                  child: Icon(Icons.clear,
                      color: Colors.grey.shade400, size: 18),
                )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Result count ──────────────────────────────────────────────────
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${_filtered.length} customer${_filtered.length == 1 ? '' : 's'}",
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
          ),

          // ── List ──────────────────────────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    "No customers match\n${_searchController.text}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.grey.shade100,
              ),
              itemBuilder: (context, index) {
                final customer = _filtered[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () =>
                      Navigator.of(context).pop(customer),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 12),
                    child: Row(
                      children: [
                        // Avatar circle
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.primaries[
                            customer.id %
                                Colors.primaries.length]
                                .withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            customer.name.isNotEmpty
                                ? customer.name[0].toUpperCase()
                                : "?",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.primaries[customer.id %
                                  Colors.primaries.length],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Name + optional phone
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              _HighlightText(
                                text: customer.name,
                                query: _searchController.text,
                              ),
                              // Uncomment if phone is available:
                              // if (customer.phone.isNotEmpty)
                              //   Text(customer.phone,
                              //       style: TextStyle(
                              //           fontSize: 12,
                              //           color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                        // Active dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Highlight matching text ───────────────────────────────────────────────────

class _HighlightText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex == -1) {
      return Text(
        text,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87),
      );
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87),
        children: [
          TextSpan(text: text.substring(0, matchIndex)),
          TextSpan(
            text: text.substring(matchIndex, matchIndex + query.length),
            style: TextStyle(
              backgroundColor:
              Theme.of(context).primaryColor.withOpacity(0.18),
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: text.substring(matchIndex + query.length)),
        ],
      ),
    );
  }
}

// ── Shimmer Effect ────────────────────────────────────────────────────────────

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
            child: Container(color: Colors.grey.shade200),
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