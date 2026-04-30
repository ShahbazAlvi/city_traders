import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Provider/ProductProvider/ItemTypeProvider.dart';
import '../../../../compoents/AppColors.dart';
import '../../../../compoents/ItemCategoriesDropDown.dart';
import '../../../../model/ProductModel/ItemTypeModel.dart';


class ItemTypeScreen extends StatefulWidget {
  const ItemTypeScreen({super.key});

  @override
  State<ItemTypeScreen> createState() => _ItemTypeScreenState();
}

class _ItemTypeScreenState extends State<ItemTypeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemTypeProvider>(context, listen: false).fetchItemTypes();
    });
  }

  void _showAddItemTypeDialog() async {
    final TextEditingController itemTypeCtrl = TextEditingController();
    String? selectedCategoryId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Item Type'),
          content: SizedBox(
            height: 150,
            child: Column(
              children: [
                // Category dropdown
                CategoriesDropdown(
                  selectedId: selectedCategoryId,
                  onChanged: (id) {
                    setState(() {
                      selectedCategoryId = id; // Update selected value
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Item type name
                TextField(
                  controller: itemTypeCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Enter Item Type Name',
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
                if (selectedCategoryId == null || itemTypeCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token');
                if (token == null) return;

                await Provider.of<ItemTypeProvider>(context, listen: false).addItemType(
                  categoryId: selectedCategoryId!,
                  itemTypeName: itemTypeCtrl.text.trim(),
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
            "Items Type",
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
        //       onPressed: _showAddItemTypeDialog,
        //       icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        //       label: const Text(
        //         " Add item type ",
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
      body: Consumer<ItemTypeProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.itemTypes.isEmpty) {
            return const Center(child: Text('No Item Types Found'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchItemTypes(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.itemTypes.length,
              itemBuilder: (context, index) {
                final item = provider.itemTypes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 60,
                          decoration: BoxDecoration(
                            color: item.isActive == true
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name ?? '-',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    item.isActive == true
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: item.isActive == true
                                        ? Colors.green
                                        : Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.isActive == true
                                        ? "Enabled"
                                        : "Disabled",
                                    style: TextStyle(
                                      color: item.isActive == true
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Created: ${item.createdAt != null ? item.createdAt!.split('T').first : '-'}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.secondary),
                              onPressed: () {
                                _showEditItemTypeDialog(item);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                bool? confirm = await showDialog<bool>(
                                  context: context,  // Assuming this is inside a widget with access to context
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: const Text('Are you sure you want to delete this item type?'),
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
                                );
                                if (confirm == true) {
                                  provider.deleteItemType(item.id.toString()!);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
  void _showEditItemTypeDialog(ItemTypeModel item) async {
    final TextEditingController itemTypeCtrl = TextEditingController(text: item.name);
    String? selectedCategoryId = item.id as String?;
    bool isEnable = item.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Item Type'),
          content: SizedBox(
            height: 200,
            child: Column(
              children: [
                // Category dropdown
                CategoriesDropdown(
                  selectedId: selectedCategoryId,
                  onChanged: (id) {
                    setState(() {
                      selectedCategoryId = id;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Item type name
                TextField(
                  controller: itemTypeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Item Type Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Enable/Disable toggle
                Row(
                  children: [
                    const Text('Status:'),
                    const SizedBox(width: 16),
                    Switch(
                      value: isEnable,
                      onChanged: (value) {
                        setState(() {
                          isEnable = value;
                        });
                      },
                    ),
                    Text(
                      isEnable ? 'Enabled' : 'Disabled',
                      style: TextStyle(
                        color: isEnable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
                if (selectedCategoryId == null || itemTypeCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(width: 10),
                        Text('Updating item type...'),
                      ],
                    ),
                    duration: Duration(seconds: 30),
                  ),
                );

                final success = await Provider.of<ItemTypeProvider>(context, listen: false).updateItemType(
                  id: item.id.toString()!,
                  categoryId: selectedCategoryId!,
                  itemTypeName: itemTypeCtrl.text.trim(),
                  isEnable: isEnable,
                );

                // Hide loading
                ScaffoldMessenger.of(context).hideCurrentSnackBar();

                if (context.mounted) {
                  Navigator.pop(context); // Close dialog

                  // Show result
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            success ? Icons.check_circle : Icons.error,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(success
                              ? 'Item type updated successfully!'
                              : 'Failed to update item type'
                          ),
                        ],
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
