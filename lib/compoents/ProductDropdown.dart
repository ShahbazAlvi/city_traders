


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart'; // Add this to pubspec.yaml

import '../../model/ProductModel/itemsdetailsModel.dart';
import '../Provider/ProductProvider/ItemListsProvider.dart';

class ItemDetailsDropdown extends StatefulWidget {
  final Function(ItemDetails) onItemSelected;

  const ItemDetailsDropdown({super.key, required this.onItemSelected});

  @override
  State<ItemDetailsDropdown> createState() => _ItemDetailsDropdownState();
}

class _ItemDetailsDropdownState extends State<ItemDetailsDropdown> {
  ItemDetails? selectedItem;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ItemDetailsProvider>(context, listen: false).fetchItems());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemDetailsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern label with better styling
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 4),
        //   child: Row(
        //     children: [
        //       Container(
        //         width: 4,
        //         height: 20,
        //         decoration: BoxDecoration(
        //           gradient: const LinearGradient(
        //             colors: [Colors.blue, Colors.purple],
        //             begin: Alignment.topCenter,
        //             end: Alignment.bottomCenter,
        //           ),
        //           borderRadius: BorderRadius.circular(4),
        //         ),
        //       ),
        //       // const SizedBox(width: 8),
        //       // const Text(
        //       //   "Select Product",
        //       //   style: TextStyle(
        //       //     fontWeight: FontWeight.w600,
        //       //     fontSize: 16,
        //       //     letterSpacing: 0.5,
        //       //   ),
        //       // ),
        //     ],
        //   ),
        // ),
        //const SizedBox(height: 10),

        // Modern dropdown with shimmer loading effect
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: provider.isLoading
              ? _buildShimmerDropdown()
              : DropdownButtonFormField<ItemDetails>(
            value: selectedItem,
            isExpanded: true,
            hint: _buildHint(),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.blue,
            ),
           // dropdownSearch: _buildSearchDelegate(), // Add search functionality
            items: provider.items.map((item) {
              return DropdownMenuItem<ItemDetails>(
                value: item,
                child: _buildDropdownItem(item),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedItem = value;
              });
              if (value != null) widget.onItemSelected(value);
            },
            decoration: _buildInputDecoration(),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }

  // Modern input decoration
  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.blue,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.red.shade300,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      suffixIcon: selectedItem != null
          ? IconButton(
        icon: Icon(
          Icons.close_rounded,
          color: Colors.grey.shade600,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            selectedItem = null;
          });
          widget.onItemSelected(null as ItemDetails);
        },
      )
          : null,
    );
  }

  // Modern hint widget
  Widget _buildHint() {
    return Row(
      children: [
        Text(
          "Choose Product",
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // Modern dropdown item design
  Widget _buildDropdownItem(ItemDetails item) {
    return Container(
     // padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Product details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

            ],
          ),


        ],
      ),
    );
  }

  // Shimmer loading effect
  Widget _buildShimmerDropdown() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 60,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}