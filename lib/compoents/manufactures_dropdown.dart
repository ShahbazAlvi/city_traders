// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../Provider/ProductProvider/manufactures_provider.dart';
// import '../model/ProductModel/manufactures_Model.dart';
//
// class ManufacturesDropdown extends StatelessWidget {
//   final int? selectedManufactureId;
//   final Function(int?) onChanged;
//   final bool isRequired;
//   final String? hintText;
//
//   const ManufacturesDropdown({
//     super.key,
//     required this.selectedManufactureId,
//     required this.onChanged,
//     this.isRequired = false,
//     this.hintText,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ManufacturesProvider>(
//       builder: (context, provider, child) {
//         if (provider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (provider.manufactures.isEmpty) {
//           return const Text("No manufacturers available");
//         }
//
//         return DropdownButtonFormField<int>(
//           value: selectedManufactureId,
//           decoration: InputDecoration(
//             labelText: hintText ?? "Select Manufacturer",
//             border: const OutlineInputBorder(),
//           ),
//           items: provider.manufactures.map((ManufacturesModel m) {
//             return DropdownMenuItem<int>(
//               value: m.id,
//               child: Text(m.name),
//             );
//           }).toList(),
//           onChanged: onChanged,
//           validator: isRequired
//               ? (value) {
//             if (value == null) {
//               return "Please select manufacturer";
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

import '../Provider/ProductProvider/manufactures_provider.dart';
import '../model/ProductModel/manufactures_Model.dart';

class ManufacturesDropdown extends StatelessWidget {
  final int? selectedManufactureId;
  final Function(int?) onChanged;
  final bool isRequired;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final bool showSearchIcon;

  const ManufacturesDropdown({
    super.key,
    required this.selectedManufactureId,
    required this.onChanged,
    this.isRequired = false,
    this.hintText,
    this.labelText,
    this.errorText,
    this.showSearchIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Consumer<ManufacturesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildShimmerLoader(isDark);
        }

        if (provider.manufactures.isEmpty) {
          return _buildEmptyState(isDark);
        }

        return _buildDropdown(provider.manufactures, isDark, primaryColor);
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
              Icons.business_outlined,
              size: 18,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "No manufacturers available",
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
      List<ManufacturesModel> manufacturers,
      bool isDark,
      Color primaryColor
      ) {
    // Find selected manufacturer for better display
    final selectedManufacturer = manufacturers.firstWhere(
          (m) => m.id == selectedManufactureId,
      orElse: () => ManufacturesModel(id: 0, name: '', phone: '', address: '', isActive: 1, createdAt: '', updatedAt: ''),
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
      child: DropdownButtonFormField<int>(
        value: selectedManufactureId,
        decoration: InputDecoration(
          labelText: labelText ?? hintText ?? "Select Manufacturer",
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintText: hintText ?? "Choose a manufacturer",
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
         // prefixIcon: showSearchIcon

          suffixIcon: const Icon(Icons.arrow_drop_down, size: 24),
          suffixIconColor: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        items: manufacturers.map((ManufacturesModel m) {
          final isSelected = m.id == selectedManufactureId;
          return DropdownMenuItem<int>(
            value: m.id,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        m.name,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.grey[900],
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (m.id != null && m.id! > 0)
                        const SizedBox(height: 2),
                      // if (m.id != null && m.id! > 0)
                      //   Text(
                      //     'ID: ${m.id}',
                      //     style: TextStyle(
                      //       color: isDark ? Colors.grey[500] : Colors.grey[500],
                      //       fontSize: 11,
                      //       fontWeight: FontWeight.w400,
                      //     ),
                      //   ),
                    ],
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
        onChanged: onChanged,
        validator: isRequired
            ? (value) {
          if (value == null) {
            return "Please select manufacturer";
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
          return manufacturers.map((m) {
            return Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 18,
                  color: primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    m.name,
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
}