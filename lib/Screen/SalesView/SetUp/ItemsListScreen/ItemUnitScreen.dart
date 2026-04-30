import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Provider/ProductProvider/ItemUnitProvider.dart';
import '../../../../compoents/AppColors.dart';
import '../../../../model/ProductModel/ItemUnitModel.dart';


class ItemUnitScreen extends StatefulWidget {
  const ItemUnitScreen({super.key});

  @override
  State<ItemUnitScreen> createState() => _ItemUnitScreenState();
}

class _ItemUnitScreenState extends State<ItemUnitScreen> {
  @override
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemUnitProvider>(context, listen: false).fetchItemUnits();
    });
  }

  void _showAddItemUnitDialog() {
    final TextEditingController unitNameCtrl = TextEditingController();
    final TextEditingController descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Item Unit'),
          content: SizedBox(
            height: 150,
            child: Column(
              children: [
                TextField(
                  controller: unitNameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Enter Unit Name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Enter Description',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (unitNameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unit Name is required')),
                  );
                  return;
                }

                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token');
                if (token == null) return;

                await Provider.of<ItemUnitProvider>(context, listen: false)
                    .addItemUnit(
                  unitName: unitNameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  token: token,
                );

                Navigator.pop(context); // Close dialog
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Center(
          child: Text(
            "Item Units",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 1.2,
            ),
          ),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //     child: ElevatedButton.icon(
        //       onPressed: () {
        //         _showAddItemUnitDialog();
        //         // Navigator.push(context,MaterialPageRoute(builder:(context)=>AddCustomerScreen()));
        //       },
        //       icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        //       label: const Text(
        //         " Add item Units",
        //         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        //       ),
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Colors.transparent,
        //         shadowColor: Colors.transparent,
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(20),
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
        centerTitle: true,
        elevation: 6,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: Consumer<ItemUnitProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.units.isEmpty) {
            return const Center(child: Text('No Units Found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.units.length,
            itemBuilder: (context, index) {
              ItemUnitModel unit = provider.units[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.settings, color: Colors.blue),
                  ),
                  title: Text(
                    unit.name ?? "-",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(unit.shortName ?? "-"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Update the edit IconButton's onPressed
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.secondary),
                        onPressed: () => _showEditUnitDialog(unit),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, unit.id.toString()!, provider);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  void _showDeleteConfirmationDialog(BuildContext context, String unitId, ItemUnitProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this item unit?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        provider.deleteItemUnit(unitId);
      }
    });
  }



  // In your ItemUnitScreen, add this method inside _ItemUnitScreenState
  void _showEditUnitDialog(ItemUnitModel unit) async {
    final TextEditingController unitNameCtrl = TextEditingController(text: unit.name ?? '');
    final TextEditingController descCtrl = TextEditingController(text: unit.shortName ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item Unit'),
        content: SizedBox(
          height: 150,
          child: Column(
            children: [
              TextField(
                controller: unitNameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter Unit Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter Description',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = unitNameCtrl.text.trim();
              final desc = descCtrl.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unit Name is required')),
                );
                return;
              }

              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('token');
              if (token == null) return;

              await Provider.of<ItemUnitProvider>(context, listen: false)
                  .updateItemUnit(unit.id.toString()!, name, desc, token);

              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }


}
