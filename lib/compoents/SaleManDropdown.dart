//
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../Provider/SaleManProvider/SaleManProvider.dart';
//
// class SalesmanDropdown extends StatelessWidget {
//   final String? selectedId;
//   final ValueChanged<String?> onChanged;
//
//   const SalesmanDropdown({
//     super.key,
//     this.selectedId,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<SaleManProvider>(context);
//
//     if (provider.isLoading) {
//       return _buildShimmerLoading();
//     }
//
//     if (provider.error != null && provider.error!.isNotEmpty) {
//       return _buildErrorWidget(provider.error!);
//     }
//
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: DropdownButtonFormField<String>(
//         value: selectedId,
//         isExpanded: true,
//         hint: Text(
//           "Select Salesman",
//           style: TextStyle(
//             color: Colors.grey.shade600,
//             fontSize: 14,
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//         decoration: InputDecoration(
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.red.shade300, width: 1),
//           ),
//           suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
//         ),
//         icon: const SizedBox.shrink(), // Hide default icon
//         items: provider.employees.map((emp) {
//           return DropdownMenuItem<String>(
//             value: emp.id.toString(),
//             child: Row(
//               children: [
//                 Container(
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     color: Colors.green,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     emp.name,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//         onChanged: onChanged,
//       ),
//     );
//   }
//
//   Widget _buildShimmerLoading() {
//     return Container(
//       height: 48,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.grey.shade300,
//       ),
//       child: const ShimmerEffect(),
//     );
//   }
//
//   Widget _buildErrorWidget(String error) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.red.shade200, width: 1),
//         color: Colors.red.shade50,
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               "Error loading salesmen",
//               style: TextStyle(
//                 color: Colors.red.shade700,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Shimmer Effect Widget
// class ShimmerEffect extends StatefulWidget {
//   const ShimmerEffect({super.key});
//
//   @override
//   State<ShimmerEffect> createState() => _ShimmerEffectState();
// }
//
// class _ShimmerEffectState extends State<ShimmerEffect>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     )..repeat(reverse: true);
//
//     _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) {
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: ShaderMask(
//             shaderCallback: (bounds) {
//               return LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.grey.shade300,
//                   Colors.grey.shade100,
//                   Colors.grey.shade300,
//                 ],
//                 stops: const [0.3, 0.5, 0.7],
//                 transform:
//                 SlidingGradientTransform(slidePercent: _animation.value),
//               ).createShader(bounds);
//             },
//             blendMode: BlendMode.srcOver,
//             child: Container(
//               color: Colors.grey.shade200,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class SlidingGradientTransform extends GradientTransform {
//   final double slidePercent;
//
//   SlidingGradientTransform({required this.slidePercent});
//
//   @override
//   Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
//     return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Provider/SaleManProvider/SaleManProvider.dart';

class SalesmanDropdown extends StatefulWidget {
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const SalesmanDropdown({
    super.key,
    this.selectedId,
    required this.onChanged,
  });

  @override
  State<SalesmanDropdown> createState() => _SalesmanDropdownState();
}

class _SalesmanDropdownState extends State<SalesmanDropdown> {
  String? _selectedId;
  String? _selectedName;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedId;
  }

  Future<void> _openSearchSheet(SaleManProvider provider) async {
    final result = await showModalBottomSheet<_SalesmanResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SalesmanSearchSheet(
        employees: provider.employees,
        selectedId: _selectedId,
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SaleManProvider>(context);

    // Sync selectedId from parent if changed externally
    if (widget.selectedId != _selectedId && _selectedName == null) {
      _selectedId = widget.selectedId;
      if (_selectedId != null && provider.employees.isNotEmpty) {
        try {
          final emp = provider.employees
              .firstWhere((e) => e.id.toString() == _selectedId);
          _selectedName = emp.name;
        } catch (_) {}
      }
    }

    if (provider.isLoading) return _buildShimmerLoading();
    if (provider.error != null && provider.error!.isNotEmpty) {
      return _buildErrorWidget(provider.error!);
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
              suffixIcon:
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ),
            child: _selectedName == null
                ? Text(
              "Select Salesman",
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
              "Error loading salesmen",
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
}

// ── Result model ──────────────────────────────────────────────────────────────

class _SalesmanResult {
  final String id;
  final String name;
  const _SalesmanResult({required this.id, required this.name});
}

// ── Search Sheet ──────────────────────────────────────────────────────────────

class _SalesmanSearchSheet extends StatefulWidget {
  final List<dynamic> employees; // your employee model list
  final String? selectedId;

  const _SalesmanSearchSheet({
    required this.employees,
    this.selectedId,
  });

  @override
  State<_SalesmanSearchSheet> createState() => _SalesmanSearchSheetState();
}

class _SalesmanSearchSheetState extends State<_SalesmanSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.employees;
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? widget.employees
          : widget.employees
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
          // ── Handle ────────────────────────────────────────────────────────
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
                Icon(Icons.badge_outlined,
                    color: Theme.of(context).primaryColor, size: 22),
                const SizedBox(width: 10),
                Text(
                  "Select Salesman",
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
                hintText: "Search salesman…",
                hintStyle: TextStyle(
                    color: Colors.grey.shade400, fontSize: 15),
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
                "${_filtered.length} salesman${_filtered.length == 1 ? '' : 's'}",
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
                    'No salesmen match\n"${_searchController.text}"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding:
              const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.grey.shade100,
              ),
              itemBuilder: (context, index) {
                final emp = _filtered[index];
                final isSelected =
                    emp.id.toString() == widget.selectedId;

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).pop(
                    _SalesmanResult(
                      id: emp.id.toString(),
                      name: emp.name,
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
                      borderRadius:
                      BorderRadius.circular(12),
                    )
                        : null,
                    child: Row(
                      children: [
                        // Avatar circle with initial
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
                            emp.name.isNotEmpty
                                ? emp.name[0].toUpperCase()
                                : "?",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Theme.of(context)
                                  .primaryColor
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Name with highlight
                        Expanded(
                          child: _HighlightText(
                            text: emp.name,
                            query: _searchController.text,
                            isSelected: isSelected,
                            context: context,
                          ),
                        ),

                        // Active dot + checkmark
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.check_circle,
                                  color: Theme.of(context)
                                      .primaryColor,
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
      color: isSelected
          ? Theme.of(context).primaryColor
          : Colors.black87,
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
                transform: SlidingGradientTransform(
                    slidePercent: _animation.value),
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