import 'package:flutter/material.dart';

import '../model/setup/location.dart';


class LocationDropdown extends StatelessWidget {

  final List<LocationModel> locations;
  final int? selectedId;
  final Function(int?) onChanged;

  const LocationDropdown({
    super.key,
    required this.locations,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    return DropdownButtonFormField<int>(

      value: selectedId,

      decoration: const InputDecoration(
        labelText: "Select Location",
        border: OutlineInputBorder(),
      ),

      items: locations.map((location) {

        return DropdownMenuItem<int>(
          value: location.id,
          child: Text(location.name),
        );

      }).toList(),

      onChanged: onChanged,
    );
  }
}