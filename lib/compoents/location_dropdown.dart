//
//
// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';
// import '../model/setup/location.dart';
//
// class LocationDropdown extends StatefulWidget {
//   final List<LocationModel> locations;
//   final int? selectedId;
//   final Function(int?) onChanged;
//   final String? labelText;
//   final String? hintText;
//   final bool isLoading;
//   final bool isRequired;
//   final Color? primaryColor;
//   final EdgeInsets? margin;
//   final double borderRadius;
//
//   const LocationDropdown({
//     super.key,
//     required this.locations,
//     required this.selectedId,
//     required this.onChanged,
//     this.labelText = 'Location',
//     this.hintText = 'Select location',
//     this.isLoading = false,
//     this.isRequired = false,
//     this.primaryColor,
//     this.margin,
//     this.borderRadius = 12,
//   });
//
//   @override
//   State<LocationDropdown> createState() => _LocationDropdownState();
// }
//
// class _LocationDropdownState extends State<LocationDropdown> {
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final primaryColor = widget.primaryColor ?? theme.primaryColor;
//
//     return Container(
//       margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (widget.labelText != null) ...[
//             Row(
//               children: [
//                 Text(
//                   widget.labelText!,
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                     color: theme.colorScheme.onSurface.withOpacity(0.8),
//                   ),
//                 ),
//                 if (widget.isRequired) ...[
//                   const SizedBox(width: 4),
//                   Text(
//                     '*',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       color: theme.colorScheme.error,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//             const SizedBox(height: 8),
//           ],
//           if (widget.isLoading)
//             _buildShimmerLoader()
//           else if (widget.locations.isEmpty)
//             _buildEmptyState(theme, primaryColor)
//           else
//             _buildDropdown(theme, primaryColor),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDropdown(ThemeData theme, Color primaryColor) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(widget.borderRadius),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: DropdownButtonFormField<int>(
//         value: widget.selectedId,
//         decoration: InputDecoration(
//           hintText: widget.hintText,
//           hintStyle: theme.textTheme.bodyMedium?.copyWith(
//             color: theme.colorScheme.onSurface.withOpacity(0.4),
//           ),
//           filled: true,
//           fillColor: theme.cardColor,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(widget.borderRadius),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(widget.borderRadius),
//             borderSide: BorderSide(
//               color: theme.dividerColor.withOpacity(0.2),
//               width: 1,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(widget.borderRadius),
//             borderSide: BorderSide(
//               color: primaryColor,
//               width: 2,
//             ),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(widget.borderRadius),
//             borderSide: BorderSide(
//               color: theme.colorScheme.error,
//               width: 1.5,
//             ),
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 16,
//           ),
//           prefixIcon: Icon(
//             Icons.location_on_outlined,
//             color: primaryColor.withOpacity(0.7),
//             size: 22,
//           ),
//           suffixIcon: Icon(
//             Icons.keyboard_arrow_down,
//             color: theme.colorScheme.onSurface.withOpacity(0.5),
//           ),
//         ),
//         style: theme.textTheme.bodyLarge?.copyWith(
//           fontWeight: FontWeight.w500,
//         ),
//         icon: const SizedBox.shrink(), // Hide default icon
//         isExpanded: true,
//         borderRadius: BorderRadius.circular(widget.borderRadius),
//         dropdownColor: theme.cardColor,
//         items: widget.locations.map((location) {
//           return DropdownMenuItem<int>(
//             value: location.id,
//             child: Row(
//               children: [
//                 // Container(
//                 //   padding: const EdgeInsets.all(6),
//                 //   decoration: BoxDecoration(
//                 //     color: primaryColor.withOpacity(0.1),
//                 //     borderRadius: BorderRadius.circular(8),
//                 //   ),
//                 //   child: Icon(
//                 //     Icons.location_on,
//                 //     size: 16,
//                 //     color: primaryColor,
//                 //   ),
//                 // ),
//                 // const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         location.name,
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       // if (location.code != null) ...[
//                       //   const SizedBox(height: 2),
//                       //   Text(
//                       //     location.code!,
//                       //     style: theme.textTheme.bodySmall?.copyWith(
//                       //       color: theme.colorScheme.onSurface.withOpacity(0.5),
//                       //     ),
//                       //   ),
//                       // ],
//                     ],
//                   ),
//                 ),
//                 if (location.isActive == false)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: theme.colorScheme.error.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       'Inactive',
//                       style: theme.textTheme.labelSmall?.copyWith(
//                         color: theme.colorScheme.error,
//                         fontSize: 10,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           );
//         }).toList(),
//         onChanged: (value) {
//           if (value != null) {
//             widget.onChanged(value);
//
//             // Optional: Show selection feedback
//             _showSelectionFeedback(theme, primaryColor, value);
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildShimmerLoader() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: Container(
//         height: 56,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(widget.borderRadius),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState(ThemeData theme, Color primaryColor) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(widget.borderRadius),
//         border: Border.all(
//           color: theme.dividerColor.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primary.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.location_off_outlined,
//               color: theme.colorScheme.onSurface.withOpacity(0.4),
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'No locations available',
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Please add locations first',
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: theme.colorScheme.onSurface.withOpacity(0.5),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showSelectionFeedback(ThemeData theme, Color primaryColor, int value) {
//     final selectedLocation = widget.locations.firstWhere(
//           (location) => location.id == value,
//     );
//
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               Icons.location_on,
//               size: 18,
//               color: Colors.white,
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 'Selected: ${selectedLocation.name}',
//                 style: const TextStyle(fontSize: 14),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: primaryColor,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 1),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../model/setup/location.dart';

// ── Main Widget ───────────────────────────────────────────────────────────────

class LocationDropdown extends StatefulWidget {
  final List<LocationModel> locations;
  final int? selectedId;
  final Function(int?) onChanged;
  final String? labelText;
  final String? hintText;
  final bool isLoading;
  final bool isRequired;
  final Color? primaryColor;
  final EdgeInsets? margin;
  final double borderRadius;

  const LocationDropdown({
    super.key,
    required this.locations,
    required this.selectedId,
    required this.onChanged,
    this.labelText = 'Location',
    this.hintText = 'Select location',
    this.isLoading = false,
    this.isRequired = false,
    this.primaryColor,
    this.margin,
    this.borderRadius = 12,
  });

  @override
  State<LocationDropdown> createState() => _LocationDropdownState();
}

class _LocationDropdownState extends State<LocationDropdown> {
  int? _selectedId;
  String? _selectedName;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedId;
  }

  @override
  void didUpdateWidget(LocationDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedId != oldWidget.selectedId) {
      _selectedId = widget.selectedId;
      _selectedName = null;
    }
  }

  Future<void> _openSearchSheet() async {
    final primaryColor =
        widget.primaryColor ?? Theme.of(context).primaryColor;

    final result = await showModalBottomSheet<_LocationResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LocationSearchSheet(
        locations: widget.locations,
        selectedId: _selectedId,
        primaryColor: primaryColor,
        borderRadius: widget.borderRadius,
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

  Widget _buildShimmerLoader() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: Colors.grey.shade300,
      ),
      child: const _ShimmerEffect(),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No locations available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please add locations first',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.primaryColor;

    // Auto-resolve name when locations load
    if (_selectedId != null &&
        _selectedName == null &&
        widget.locations.isNotEmpty) {
      try {
        final loc =
        widget.locations.firstWhere((l) => l.id == _selectedId);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedName = loc.name);
        });
      } catch (_) {}
    }

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label ──────────────────────────────────────────────────
          if (widget.labelText != null) ...[
            Row(
              children: [
                Text(
                  widget.labelText!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                if (widget.isRequired) ...[
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
          ],

          // ── Body ───────────────────────────────────────────────────
          if (widget.isLoading)
            _buildShimmerLoader()
          else if (widget.locations.isEmpty)
            _buildEmptyState(theme)
          else
            GestureDetector(
              onTap: _openSearchSheet,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(widget.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AbsorbPointer(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      //fillColor: theme.cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(widget.borderRadius),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(widget.borderRadius),
                        borderSide: BorderSide(
                          color: theme.dividerColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                      //  color: primaryColor.withOpacity(0.7),
                        size: 20,
                      ),
                      suffixIcon: Icon(
                        Icons.arrow_drop_down_outlined,
                        color:
                        theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    child: _selectedName == null
                        ? Text(
                      widget.hintText ?? 'Select location',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withOpacity(0.4),
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
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
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
      ),
    );
  }
}

// ── Result model ──────────────────────────────────────────────────────────────

class _LocationResult {
  final int id;
  final String name;
  const _LocationResult({required this.id, required this.name});
}

// ── Search Sheet ──────────────────────────────────────────────────────────────

class _LocationSearchSheet extends StatefulWidget {
  final List<LocationModel> locations;
  final int? selectedId;
  final Color primaryColor;
  final double borderRadius;

  const _LocationSearchSheet({
    required this.locations,
    this.selectedId,
    required this.primaryColor,
    required this.borderRadius,
  });

  @override
  State<_LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<_LocationSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<LocationModel> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.locations;
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? widget.locations
          : widget.locations
          .where((l) => l.name.toLowerCase().contains(query))
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

          // ── Drag handle ────────────────────────────────────────────
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

          // ── Title row ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined,
                     size: 22),
                const SizedBox(width: 10),
                Text(
                  "Select Location",
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

          // ── Search field ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style:
              const TextStyle(fontSize: 15, color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Search location…",
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

          // ── Result count ───────────────────────────────────────────
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${_filtered.length} location${_filtered.length == 1 ? '' : 's'}",
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
          ),

          // ── List ───────────────────────────────────────────────────
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
                    'No locations match\n"${_searchController.text}"',
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
                final loc = _filtered[index];
                final isSelected = loc.id == widget.selectedId;

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).pop(
                    _LocationResult(id: loc.id, name: loc.name),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 12),
                    decoration: isSelected
                        ? BoxDecoration(
                      color: widget.primaryColor
                          .withOpacity(0.06),
                      borderRadius:
                      BorderRadius.circular(12),
                    )
                        : null,
                    child: Row(
                      children: [
                        // ── Avatar ───────────────────────────
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? widget.primaryColor
                                .withOpacity(0.15)
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            loc.name.isNotEmpty
                                ? loc.name[0].toUpperCase()
                                : "?",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? widget.primaryColor
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // ── Name + highlight ─────────────────
                        Expanded(
                          child: _HighlightText(
                            text: loc.name,
                            query: _searchController.text,
                            isSelected: isSelected,
                            primaryColor: widget.primaryColor,
                          ),
                        ),

                        // ── Inactive badge ───────────────────
                        if (loc.isActive == false)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Inactive',
                              style: TextStyle(
                                color: Colors.red.shade400,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        // ── Selected check ───────────────────
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.check_circle,
                              color: widget.primaryColor,
                              size: 18),
                        ],
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
  final Color primaryColor;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.isSelected,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: isSelected ? primaryColor : Colors.black87,
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
            text:
            text.substring(matchIndex, matchIndex + query.length),
            style: TextStyle(
              backgroundColor: primaryColor.withOpacity(0.18),
              color: primaryColor,
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

class _ShimmerEffect extends StatefulWidget {
  const _ShimmerEffect();

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
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
                transform: _SlidingGradientTransform(
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

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}