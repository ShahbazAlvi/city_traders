// import 'package:flutter/material.dart';
//
// import '../model/setup/location.dart';
//
//
// class LocationDropdown extends StatelessWidget {
//
//   final List<LocationModel> locations;
//   final int? selectedId;
//   final Function(int?) onChanged;
//
//   const LocationDropdown({
//     super.key,
//     required this.locations,
//     required this.selectedId,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//
//     return DropdownButtonFormField<int>(
//
//       value: selectedId,
//
//       decoration: const InputDecoration(
//         labelText: "Select Location",
//         border: OutlineInputBorder(),
//       ),
//
//       items: locations.map((location) {
//
//         return DropdownMenuItem<int>(
//           value: location.id,
//           child: Text(location.name),
//         );
//
//       }).toList(),
//
//       onChanged: onChanged,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../model/setup/location.dart';

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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.primaryColor;

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          if (widget.isLoading)
            _buildShimmerLoader()
          else if (widget.locations.isEmpty)
            _buildEmptyState(theme, primaryColor)
          else
            _buildDropdown(theme, primaryColor),
        ],
      ),
    );
  }

  Widget _buildDropdown(ThemeData theme, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<int>(
        value: widget.selectedId,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: theme.dividerColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: Icon(
            Icons.location_on_outlined,
            color: primaryColor.withOpacity(0.7),
            size: 22,
          ),
          suffixIcon: Icon(
            Icons.keyboard_arrow_down,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        icon: const SizedBox.shrink(), // Hide default icon
        isExpanded: true,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        dropdownColor: theme.cardColor,
        items: widget.locations.map((location) {
          return DropdownMenuItem<int>(
            value: location.id,
            child: Row(
              children: [
                // Container(
                //   padding: const EdgeInsets.all(6),
                //   decoration: BoxDecoration(
                //     color: primaryColor.withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: Icon(
                //     Icons.location_on,
                //     size: 16,
                //     color: primaryColor,
                //   ),
                // ),
                // const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // if (location.code != null) ...[
                      //   const SizedBox(height: 2),
                      //   Text(
                      //     location.code!,
                      //     style: theme.textTheme.bodySmall?.copyWith(
                      //       color: theme.colorScheme.onSurface.withOpacity(0.5),
                      //     ),
                      //   ),
                      // ],
                    ],
                  ),
                ),
                if (location.isActive == false)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Inactive',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            widget.onChanged(value);

            // Optional: Show selection feedback
            _showSelectionFeedback(theme, primaryColor, value);
          }
        },
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, Color primaryColor) {
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

  void _showSelectionFeedback(ThemeData theme, Color primaryColor, int value) {
    final selectedLocation = widget.locations.firstWhere(
          (location) => location.id == value,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.location_on,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Selected: ${selectedLocation.name}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}