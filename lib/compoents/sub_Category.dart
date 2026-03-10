// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../Provider/ProductProvider/sub_category.dart';
// import '../model/ProductModel/Sub_Category_model.dart';
//
//
//
// class SubCategoryDropdown extends StatelessWidget {
//   final int? selectedSubCategoryId;
//   final int? categoryId; // 👈 optional filter
//   final Function(int?) onChanged;
//   final bool isRequired;
//   final String? hintText;
//
//   const SubCategoryDropdown({
//     super.key,
//     required this.selectedSubCategoryId,
//     required this.onChanged,
//     this.categoryId,
//     this.isRequired = false,
//     this.hintText,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<SubCategory>(
//       builder: (context, provider, child) {
//         if (provider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         // 👇 category filter (Purchase Order screen ke liye perfect)
//         List<SubCategoryModel> list = provider.subCategories;
//
//         if (categoryId != null) {
//           list = list
//               .where((e) => e.categoryId == categoryId)
//               .toList();
//         }
//
//         if (list.isEmpty) {
//           return const Text("No sub categories available");
//         }
//
//         return DropdownButtonFormField<int>(
//           value: selectedSubCategoryId,
//           decoration: InputDecoration(
//             labelText: hintText ?? "Select Sub Category",
//             border: const OutlineInputBorder(),
//           ),
//           items: list.map((SubCategoryModel sub) {
//             return DropdownMenuItem<int>(
//               value: sub.id,
//               child: Text(sub.name),
//             );
//           }).toList(),
//           onChanged: onChanged,
//           validator: isRequired
//               ? (value) {
//             if (value == null) {
//               return "Please select sub category";
//             }
//             return null;
//           }
//               : null,
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../Provider/ProductProvider/sub_category.dart';
import '../model/ProductModel/Sub_Category_model.dart';

class SubCategoryDropdown extends StatelessWidget {
  final int? selectedSubCategoryId;
  final int? categoryId;
  final Function(int?) onChanged;
  final bool isRequired;
  final String? hintText;
  final String? labelText;
  final String? errorText;

  const SubCategoryDropdown({
    super.key,
    required this.selectedSubCategoryId,
    required this.onChanged,
    this.categoryId,
    this.isRequired = false,
    this.hintText,
    this.labelText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Consumer<SubCategory>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildShimmerLoader(isDark);
        }

        List<SubCategoryModel> list = provider.subCategories;

        if (categoryId != null) {
          list = list.where((e) => e.categoryId == categoryId).toList();
        }

        if (list.isEmpty) {
          return _buildEmptyState(isDark);
        }

        return _buildDropdown(list, isDark, primaryColor);
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
          Icon(
            Icons.info_outline,
            size: 20,
            color: isDark ? Colors.grey[600] : Colors.grey[500],
          ),
          const SizedBox(width: 12),
          Text(
            "No sub categories available",
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(List<SubCategoryModel> list, bool isDark, Color primaryColor) {
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
      child: DropdownButtonFormField<int>(
        value: selectedSubCategoryId,
        decoration: InputDecoration(
          labelText: labelText ?? hintText ?? "Select Sub Category",
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintText: hintText,
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
          suffixIcon: const Icon(Icons.arrow_drop_down, size: 24),
          suffixIconColor: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        items: list.map((SubCategoryModel sub) {
          return DropdownMenuItem<int>(
            value: sub.id,
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sub.name,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.grey[900],
                      fontSize: 14,
                      fontWeight: selectedSubCategoryId == sub.id
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: isRequired
            ? (value) {
          if (value == null) {
            return "Please select sub category";
          }
          return null;
        }
            : null,
        icon: const SizedBox.shrink(),
        isExpanded: true,
        dropdownColor: isDark ? Colors.grey[900] : Colors.white,
        menuMaxHeight: 300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}