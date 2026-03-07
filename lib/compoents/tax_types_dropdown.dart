import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Provider/setup/tax_types_provider.dart';
import '../../model/setup/tax_Types_model.dart';

class TaxTypeDropdown extends StatefulWidget {
  final Function(TaxModel) onSelected;
  final int? selectedTaxId;

  const TaxTypeDropdown({
    super.key,
    required this.onSelected,
    this.selectedTaxId,
  });

  @override
  State<TaxTypeDropdown> createState() => _TaxTypeDropdownState();
}

class _TaxTypeDropdownState extends State<TaxTypeDropdown> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<TaxTypesProvider>(context, listen: false).fetchTax();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaxTypesProvider>(
      builder: (context, provider, child) {

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: "Select Tax Type",
            border: OutlineInputBorder(),
          ),

          value: widget.selectedTaxId,

          items: provider.taxList.map((tax) {
            return DropdownMenuItem<int>(
              value: tax.id,
              child: Text("${tax.name} (${tax.ratePercent}%)"),
            );
          }).toList(),

          onChanged: (value) {
            final selectedTax =
            provider.taxList.firstWhere((tax) => tax.id == value);

            widget.onSelected(selectedTax);
          },
        );
      },
    );
  }
}