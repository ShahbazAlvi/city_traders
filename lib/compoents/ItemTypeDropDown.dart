//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../Provider/ProductProvider/ItemTypeProvider.dart';
//
//
// class ItemTypeDropdown extends StatelessWidget {
//   final String? selectedId;
//   final Function(String) onSelected;
//
//   const ItemTypeDropdown({
//     super.key,
//     required this.onSelected,
//     this.selectedId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ItemTypeProvider>(context);
//
//     return provider.loading
//         ? const Center(child: CircularProgressIndicator())
//         : DropdownButtonFormField<String>(
//       decoration: const InputDecoration(
//         labelText: "Select Item Type",
//         border: OutlineInputBorder(),
//       ),
//       value: selectedId,
//       items: provider.itemTypes.map((item) {
//         return DropdownMenuItem<String>(
//           value: item.id.toString(),
//           child: Text(item.name ?? "Unknown"),
//         );
//       }).toList(),
//       onChanged: (value) {
//         if (value != null) onSelected(value);
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../Provider/ProductProvider/ItemTypeProvider.dart';
import '../model/ProductModel/ItemTypeModel.dart'; // Import your actual model

class ItemTypeDropdown extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Consumer<ItemTypeProvider>(
      builder: (context, provider, child) {
        if (provider.loading) {
          return _buildShimmerLoader(isDark);
        }

        if (provider.itemTypes.isEmpty) {
          return _buildEmptyState(isDark);
        }

        return _buildDropdown(provider.itemTypes, isDark, primaryColor);
      },
    );
  }

  Widget _buildShimmerLoader(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.category_outlined,
              size: 18,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "No item types available",
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
      List<ItemTypeModel> itemTypes,
      bool isDark,
      Color primaryColor
      ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedId,
        decoration: InputDecoration(
          labelText: labelText ?? hintText ?? "Select Item Type",
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintText: hintText ?? "Choose item type",
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[600] : Colors.grey[400],
            fontSize: 14,
          ),
          errorText: errorText,
          errorStyle: const TextStyle(
            color: Color(0xFFE53935),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: isDark ? Colors.grey[900] : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE53935),
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE53935),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: showSearchIcon
              ? Icon(
            Icons.category_outlined,
            size: 20,
            color: selectedId != null
                ? primaryColor
                : (isDark ? Colors.grey[500] : Colors.grey[400]),
          )
              : null,
          suffixIcon: const Icon(Icons.arrow_drop_down, size: 24),
          suffixIconColor: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        items: itemTypes.map((ItemTypeModel item) {
          final isSelected = item.id.toString() == selectedId;
          final isActive = item.isActive ?? true;

          return DropdownMenuItem<String>(
            value: item.id.toString(),
            enabled: isActive, // Disable inactive items if needed
            child: Row(
              children: [
                // Status indicator
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor
                        : (isActive ? Colors.green : Colors.grey),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // Item name and details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.name ?? "Unnamed Type",
                        style: TextStyle(
                          color: !isActive
                              ? (isDark ? Colors.grey[600] : Colors.grey[400])
                              : (isDark ? Colors.white : Colors.grey[900]),
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          decoration: !isActive ? TextDecoration.lineThrough : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.id != null)
                        const SizedBox(height: 2),
                    ],
                  ),
                ),
                // Selected checkmark
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.check_circle,
                      size: 18,
                      color: primaryColor,
                    ),
                  ),
                // Inactive badge
                if (!isActive && !isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Inactive',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) onSelected(value);
        },
        validator: isRequired
            ? (value) {
          if (value == null || value.isEmpty) {
            return "Please select item type";
          }
          return null;
        }
            : null,
        icon: const SizedBox.shrink(),
        isExpanded: true,
        dropdownColor: isDark ? Colors.grey[900] : Colors.white,
        menuMaxHeight: 400,
        borderRadius: BorderRadius.circular(12),
        selectedItemBuilder: (context) {
          return itemTypes.map((item) {
            final isActive = item.isActive ?? true;

            return Row(
              children: [
                Expanded(
                  child: Text(
                    item.name ?? "Unnamed Type",
                    style: TextStyle(
                      color: !isActive
                          ? (isDark ? Colors.grey[600] : Colors.grey[400])
                          : (isDark ? Colors.white : Colors.grey[900]),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: !isActive ? TextDecoration.lineThrough : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isActive)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '(Inactive)',
                      style: TextStyle(
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            );
          }).toList();
        },
      ),
    );
  }
}