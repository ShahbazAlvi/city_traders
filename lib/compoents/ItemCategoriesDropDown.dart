// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../model/ProductModel/ItemCategoriesModel.dart';
// import '../Provider/ProductProvider/ItemCategoriesProvider.dart';
//
// class CategoriesDropdown extends StatefulWidget {
//   final String? selectedId;         // Selected Category ID
//   final ValueChanged<String?> onChanged;  // Returns selected ID
//   final String label;
//
//   const CategoriesDropdown({
//     super.key,
//     required this.onChanged,
//     this.selectedId,
//     this.label = "Select Category",
//   });
//
//   @override
//   State<CategoriesDropdown> createState() => _CategoriesDropdownState();
// }
//
// class _CategoriesDropdownState extends State<CategoriesDropdown> {
//   @override
//   void initState() {
//     super.initState();
//
//     // Fetch categories only once
//     final provider = Provider.of<CategoriesProvider>(context, listen: false);
//     if (provider.categories.isEmpty) {
//       provider.fetchCategories();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CategoriesProvider>(
//       builder: (context, provider, child) {
//         if (provider.loading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.grey.shade400),
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: widget.selectedId,
//               isExpanded: true,
//               hint: Text(widget.label),
//               items: provider.categories.map((CategoriesModel category) {
//                 return DropdownMenuItem<String>(
//                   value: category.id.toString(),
//                   child: Text(category.name ?? ''),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 widget.onChanged(value);
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../model/ProductModel/ItemCategoriesModel.dart';
import '../Provider/ProductProvider/ItemCategoriesProvider.dart';

class CategoriesDropdown extends StatefulWidget {
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final String label;
  final String? hintText;
  final String? errorText;
  final bool isRequired;
  final bool showSearchIcon;

  const CategoriesDropdown({
    super.key,
    required this.onChanged,
    this.selectedId,
    this.label = "Select Category",
    this.hintText,
    this.errorText,
    this.isRequired = false,
    this.showSearchIcon = true,
  });

  @override
  State<CategoriesDropdown> createState() => _CategoriesDropdownState();
}

class _CategoriesDropdownState extends State<CategoriesDropdown> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CategoriesProvider>(context, listen: false);
      if (provider.categories.isEmpty) {
        provider.fetchCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Consumer<CategoriesProvider>(
      builder: (context, provider, child) {
        if (provider.loading) {
          return _buildShimmerLoader(isDark);
        }

        if (provider.categories.isEmpty) {
          return _buildEmptyState(isDark);
        }

        return _buildDropdown(provider.categories, isDark, primaryColor);
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
              "No categories available",
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
      List<CategoriesModel> categories,
      bool isDark,
      Color primaryColor
      ) {
    // Find selected category name for better display
    final selectedCategory = categories.firstWhere(
          (category) => category.id.toString() == widget.selectedId,
      orElse: () => CategoriesModel(id: 0, name: ''),
    );

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
        value: widget.selectedId,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintText: widget.hintText ?? "Choose a category",
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[600] : Colors.grey[400],
            fontSize: 14,
          ),
          errorText: widget.errorText,
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
          prefixIcon: widget.showSearchIcon
              ? Icon(
            Icons.category_outlined,
            size: 20,
            color: widget.selectedId != null
                ? primaryColor
                : (isDark ? Colors.grey[500] : Colors.grey[400]),
          )
              : null,
          suffixIcon: const Icon(Icons.arrow_drop_down, size: 24),
          suffixIconColor: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        items: categories.map((CategoriesModel category) {
          final isSelected = category.id.toString() == widget.selectedId;
          return DropdownMenuItem<String>(
            value: category.id.toString(),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.name ?? 'Unnamed Category',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.grey[900],
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.check_circle,
                      size: 18,
                      color: primaryColor,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          widget.onChanged(value);
        },
        validator: widget.isRequired
            ? (value) {
          if (value == null || value.isEmpty) {
            return "Please select a category";
          }
          return null;
        }
            : null,
        icon: const SizedBox.shrink(),
        isExpanded: true,
        dropdownColor: isDark ? Colors.grey[900] : Colors.white,
        menuMaxHeight: 400,
        borderRadius: BorderRadius.circular(12),
        // Show selected item with better visual feedback
        selectedItemBuilder: (context) {
          return categories.map((category) {
            return Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 18,
                  color: primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.name ?? '',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.grey[900],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }).toList();
        },
      ),
    );
  }

  @override
  void didUpdateWidget(CategoriesDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh if needed when widget updates
    if (oldWidget.selectedId != widget.selectedId) {
      setState(() {});
    }
  }
}