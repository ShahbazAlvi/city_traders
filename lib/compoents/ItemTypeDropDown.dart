import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/ProductProvider/ItemTypeProvider.dart';
import '../model/ProductModel/ItemTypeModel.dart';

class ItemTypeDropdown extends StatefulWidget {
  final String? selectedId;
  final Function(String) onSelected;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool isRequired;
  final bool showSearchIcon;

  const ItemTypeDropdown({
    super.key,
    required this.onSelected,
    this.selectedId,
    this.labelText,
    this.hintText,
    this.errorText,
    this.isRequired = false,
    this.showSearchIcon = true,
  });

  @override
  State<ItemTypeDropdown> createState() => _ItemTypeDropdownState();
}

class _ItemTypeDropdownState extends State<ItemTypeDropdown>
    with SingleTickerProviderStateMixin {
  ItemTypeModel? selectedItemType;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    Future.microtask(() {
      final provider = Provider.of<ItemTypeProvider>(context, listen: false);
      if (provider.itemTypes.isEmpty) {
        provider.fetchItemTypes();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _openSearchSheet(List<ItemTypeModel> itemTypes) async {
    final result = await showModalBottomSheet<ItemTypeModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItemTypeSearchSheet(
        itemTypes: itemTypes,
        label: widget.labelText ?? widget.hintText ?? "Select Item Type",
      ),
    );

    if (result != null) {
      setState(() => selectedItemType = result);
      widget.onSelected(result.id.toString());
      _animationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemTypeProvider>(
      builder: (context, provider, child) {
        if (provider.loading) return _buildShimmerLoading();
        if (provider.itemTypes.isEmpty) return _buildEmptyState();

        // Apply alphabetical sorting
        final itemTypes = List<ItemTypeModel>.from(provider.itemTypes);
        itemTypes.sort((a, b) => (a.name ?? "")
            .toLowerCase()
            .compareTo((b.name ?? "").toLowerCase()));

        // Set initial selection if provided
        if (widget.selectedId != null && selectedItemType == null) {
          try {
            selectedItemType = itemTypes.firstWhere(
              (i) => i.id.toString() == widget.selectedId,
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _animationController.forward();
            });
          } catch (_) {}
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _openSearchSheet(itemTypes),
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
                  child: InputDecorator(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
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
                      prefixIcon: Icon(Icons.category_outlined,
                          color: Colors.grey.shade600, size: 20),
                      suffixIcon: Icon(Icons.arrow_drop_down,
                          color: Colors.grey.shade600),
                      errorText: widget.errorText,
                    ),
                    child: selectedItemType == null
                        ? Text(
                            widget.labelText ?? widget.hintText ?? "Select Item Type",
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 15),
                          )
                        : Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.deepPurple,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedItemType!.name ?? "Unnamed Type",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade300,
      ),
      child: const ShimmerEffect(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Icon(Icons.category_outlined, size: 24, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Text(
            "No item types found",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _ItemTypeSearchSheet extends StatefulWidget {
  final List<ItemTypeModel> itemTypes;
  final String label;
  const _ItemTypeSearchSheet({required this.itemTypes, required this.label});

  @override
  State<_ItemTypeSearchSheet> createState() => _ItemTypeSearchSheetState();
}

class _ItemTypeSearchSheetState extends State<_ItemTypeSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<ItemTypeModel> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.itemTypes;
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? widget.itemTypes
          : widget.itemTypes
              .where((i) => (i.name ?? "").toLowerCase().contains(query))
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
      height: MediaQuery.of(context).size.height * 0.75 + bottomInset,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.category_outlined,
                    color: Colors.grey.shade700, size: 22),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child:
                      Icon(Icons.close, color: Colors.grey.shade500, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Search item type…",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                prefixIcon:
                    Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () => _searchController.clear(),
                        child: Icon(Icons.clear,
                            color: Colors.grey.shade400, size: 18),
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${_filtered.length} type${_filtered.length == 1 ? '' : 's'}",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
          ),
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
                          "No item types match\n'${_searchController.text}'",
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
                      final itemType = _filtered[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(context).pop(itemType),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.primaries[(itemType.id ?? 0) %
                                          Colors.primaries.length]
                                      .withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  (itemType.name ?? "?").isNotEmpty
                                      ? itemType.name![0].toUpperCase()
                                      : "?",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.primaries[(itemType.id ?? 0) %
                                        Colors.primaries.length],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _HighlightText(
                                      text: itemType.name ?? "Unnamed Type",
                                      query: _searchController.text,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: itemType.isActive == true
                                      ? Colors.green
                                      : Colors.grey,
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

class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  const _HighlightText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87));
    }
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);
    if (matchIndex == -1) {
      return Text(text,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87));
    }
    return RichText(
      text: TextSpan(
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
        children: [
          TextSpan(text: text.substring(0, matchIndex)),
          TextSpan(
            text: text.substring(matchIndex, matchIndex + query.length),
            style: TextStyle(
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.18),
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w700),
          ),
          TextSpan(text: text.substring(matchIndex + query.length)),
        ],
      ),
    );
  }
}

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
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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