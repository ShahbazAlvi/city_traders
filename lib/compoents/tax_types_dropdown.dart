// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../Provider/setup/tax_types_provider.dart';
// import '../../model/setup/tax_Types_model.dart';
//
// class TaxTypeDropdown extends StatefulWidget {
//   final Function(TaxModel) onSelected;
//   final int? selectedTaxId;
//
//   const TaxTypeDropdown({
//     super.key,
//     required this.onSelected,
//     this.selectedTaxId,
//   });
//
//   @override
//   State<TaxTypeDropdown> createState() => _TaxTypeDropdownState();
// }
//
// class _TaxTypeDropdownState extends State<TaxTypeDropdown> {
//
//   @override
//   void initState() {
//     super.initState();
//
//     Future.microtask(() {
//       Provider.of<TaxTypesProvider>(context, listen: false).fetchTax();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<TaxTypesProvider>(
//       builder: (context, provider, child) {
//
//         if (provider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         return DropdownButtonFormField<int>(
//           decoration: const InputDecoration(
//             labelText: "Select Tax Type",
//             border: OutlineInputBorder(),
//           ),
//
//           value: widget.selectedTaxId,
//
//           items: provider.taxList.map((tax) {
//             return DropdownMenuItem<int>(
//               value: tax.id,
//               child: Text("${tax.name} (${tax.ratePercent}%)"),
//             );
//           }).toList(),
//
//           onChanged: (value) {
//             final selectedTax =
//             provider.taxList.firstWhere((tax) => tax.id == value);
//
//             widget.onSelected(selectedTax);
//           },
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../Provider/setup/tax_types_provider.dart';
import '../../model/setup/tax_Types_model.dart';

class TaxTypeDropdown extends StatefulWidget {
  final Function(TaxModel) onSelected;
  final int? selectedTaxId;
  final String? labelText;
  final String? hintText;
  final bool isRequired;
  final Color? primaryColor;
  final EdgeInsets? margin;
  final double borderRadius;

  const TaxTypeDropdown({
    super.key,
    required this.onSelected,
    this.selectedTaxId,
    this.labelText = 'Tax Type',
    this.hintText = 'Select tax type',
    this.isRequired = false,
    this.primaryColor,
    this.margin,
    this.borderRadius = 12,
  });

  @override
  State<TaxTypeDropdown> createState() => _TaxTypeDropdownState();
}

class _TaxTypeDropdownState extends State<TaxTypeDropdown> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<TaxTypesProvider>(context, listen: false).fetchTax();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.primaryColor;

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: Consumer<TaxTypesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildShimmerLoader();
          }

          if (provider.taxList.isEmpty) {
            return _buildEmptyState(theme);
          }

          return Column(
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
              Container(
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
                  value: widget.selectedTaxId,
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
                    // prefixIcon: Icon(
                    // //  Icons.tax_alert,
                    //   //color: primaryColor.withOpacity(0.7),
                    //   //size: 22,
                    // ),
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
                  items: provider.taxList.map((tax) {
                    return DropdownMenuItem<int>(
                      value: tax.id,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${tax.ratePercent}%",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tax.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final selectedTax = provider.taxList.firstWhere(
                            (tax) => tax.id == value,
                      );
                      widget.onSelected(selectedTax);

                      // Optional: Show a quick snackbar or animation
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Selected: ${selectedTax.name} (${selectedTax.ratePercent}%)',
                            style: const TextStyle(fontSize: 14),
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
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.labelText != null) ...[
            Container(
              width: 100,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No tax types available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TaxTypesProvider>(context, listen: false).fetchTax();
            },
            style: TextButton.styleFrom(
              foregroundColor: widget.primaryColor ?? theme.primaryColor,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}