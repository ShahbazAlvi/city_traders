
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/setup/SalesAreasProvider.dart';
import '../Screen/appTheme.dart';
import '../model/setup/SalesAreasModel/SalesAreasModel.dart';

// ── Main Widget ───────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/setup/SalesAreasProvider.dart';
import '../model/setup/SalesAreasModel/SalesAreasModel.dart';

class SalesAreaDropdown extends StatefulWidget {
  final String? selectedId;
  final List<int>? allowedAreaIds;
  final ValueChanged<String?> onChanged;

  const SalesAreaDropdown({
    super.key,
    this.selectedId,
    this.allowedAreaIds,
    required this.onChanged,
  });

  @override
  State<SalesAreaDropdown> createState() => _SalesAreaDropdownState();
}

class _SalesAreaDropdownState extends State<SalesAreaDropdown> {
  String? _selectedId;
  String? _selectedName;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedId;
  }

  @override
  void didUpdateWidget(SalesAreaDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedId != oldWidget.selectedId) {
      _selectedId = widget.selectedId;
      _selectedName = null;
    }
  }

  Future<void> _openSearchSheet(SalesAreasProvider provider) async {
    final result = await showModalBottomSheet<_SalesAreaResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SalesAreaSearchSheet(
        areas: provider.areas,
        selectedId: _selectedId,
        allowedAreaIds: widget.allowedAreaIds,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedId = result.id;
        _selectedName = result.name;
      });
      widget.onChanged(result.id);
    }
  }

  Widget _buildShimmerLoading() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade300,
      ),
      child: const ShimmerEffect(),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200, width: 1),
        color: Colors.red.shade50,
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Error loading areas",
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SalesAreasProvider>(context);

    // Auto-resolve name when areas load
    if (_selectedId != null &&
        _selectedName == null &&
        provider.areas.isNotEmpty) {
      try {
        final area = provider.areas
            .firstWhere((e) => e.id.toString() == _selectedId);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _selectedName = area.name);
          }
        });
      } catch (_) {}
    }

    if (provider.isLoading) return _buildShimmerLoading();
    if (provider.error != null && provider.error.isNotEmpty) {
      return _buildErrorWidget(provider.error);
    }

    return GestureDetector(
      onTap: () => _openSearchSheet(provider),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AbsorbPointer(
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
             // fillColor:
             // widget.isLocked ? Colors.grey.shade100 : Colors.white,
              fillColor: Colors.white,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: Theme.of(context).primaryColor, width: 1.5),
              ),
              suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),),
            child: _selectedName == null
                ? Text(
              "Select Area",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
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
                Expanded(
                  child: Text(
                    _selectedName!,
                    style: const TextStyle(
                      fontSize: 14,
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
    );
  }
}

// ── Result model ──────────────────────────────────────────────────────────────

class _SalesAreaResult {
  final String id;
  final String name;
  const _SalesAreaResult({required this.id, required this.name});
}

// ── Search Sheet ──────────────────────────────────────────────────────────────

class _SalesAreaSearchSheet extends StatefulWidget {
  final List<SalesAreaModel> areas;
  final String? selectedId;
  final List<int>? allowedAreaIds;

  const _SalesAreaSearchSheet({
    required this.areas,
    this.selectedId,
    this.allowedAreaIds,
  });

  @override
  State<_SalesAreaSearchSheet> createState() => _SalesAreaSearchSheetState();
}

class _SalesAreaSearchSheetState extends State<_SalesAreaSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<SalesAreaModel> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.areas;
    if (widget.allowedAreaIds != null) {
      _filtered = _filtered.where((area) => widget.allowedAreaIds!.contains(area.id)).toList();
    }
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      final baseList = widget.allowedAreaIds != null
          ? widget.areas.where((area) => widget.allowedAreaIds!.contains(area.id)).toList()
          : widget.areas;

      _filtered = query.isEmpty
          ? baseList
          : baseList
          .where((e) => e.name.toLowerCase().contains(query))
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

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.map_outlined,
                    color: Theme.of(context).primaryColor, size: 22),
                const SizedBox(width: 10),
                Text(
                  "Select Area",
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

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Search area…",
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

          // Result count
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${_filtered.length} area${_filtered.length == 1 ? '' : 's'}",
                style:
                TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
          ),

          // List
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
                    'No areas match\n"${_searchController.text}"',
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
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, index) {
                final area = _filtered[index];
                final isSelected =
                    area.id.toString() == widget.selectedId;

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).pop(
                    _SalesAreaResult(
                      id: area.id.toString(),
                      name: area.name,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 12),
                    decoration: isSelected
                        ? BoxDecoration(
                      color: Theme.of(context)
                          .primaryColor
                          .withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    )
                        : null,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context)
                                .primaryColor
                                .withOpacity(0.15)
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            area.name.isNotEmpty
                                ? area.name[0].toUpperCase()
                                : "?",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _HighlightText(
                            text: area.name,
                            query: _searchController.text,
                            isSelected: isSelected,
                            context: context,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: area.isActive == 1 ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.check_circle,
                                  color:
                                  Theme.of(context).primaryColor,
                                  size: 18),
                            ],
                          ],
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
  final bool isSelected;
  final BuildContext context;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.isSelected,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    final baseStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
    );

    if (query.isEmpty) return Text(text, style: baseStyle);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex == -1) return Text(text, style: baseStyle);

    return RichText(
      text: TextSpan(
        style: baseStyle,
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
