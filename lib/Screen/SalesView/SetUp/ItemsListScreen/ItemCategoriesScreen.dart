import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Provider/ProductProvider/ItemCategoriesProvider.dart';
import '../../../../compoents/AppColors.dart';
import '../../../../model/ProductModel/ItemCategoriesModel.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _categoryCtrl = TextEditingController();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoriesProvider>(context, listen: false).fetchCategories();
    });
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _showAddCategoryDialog() async {
    _categoryCtrl.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: _categoryCtrl,
          decoration: const InputDecoration(
            hintText: 'Enter category name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _categoryCtrl.text.trim();
              if (name.isEmpty) return;

              final token = await getToken();
              if (token == null) return;

              // Call provider to add category
              await Provider.of<CategoriesProvider>(context, listen: false)
                  .addCategory(name, token);

              Navigator.pop(context); // Close dialog
            },
            child: const Text('Save'),
          ),
        ],
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
            "Categories List",
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
        //       onPressed: _showAddCategoryDialog,
        //       icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        //       label: const Text(
        //         " Add Category",
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
      body: Consumer<CategoriesProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.categories.isEmpty) {
            return const Center(
              child: Text(
                'No Categories Found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchCategories(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final cat = provider.categories[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left color status indicator
                        Container(
                          width: 8,
                          height: 60,
                          decoration: BoxDecoration(
                            color: cat.isActive == true
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Main content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.name ?? '-',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    cat.isActive == true
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: cat.isActive == true
                                        ? Colors.green
                                        : Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat.isActive == true
                                        ? "Enabled"
                                        : "Disabled",
                                    style: TextStyle(
                                      color: cat.isActive == true
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Created: ${cat.createdAt != null ? cat.createdAt!.split('T').first : '-'}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action buttons
                        Row(
                          children: [
                            // IconButton(
                            //   icon:
                            //   const Icon(Icons.edit, color: AppColors.secondary),
                            //   onPressed: () {
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //       const SnackBar(
                            //         content:
                            //         Text('Update feature coming soon...'),
                            //       ),
                            //     );
                            //   },
                            // ),
                            // Update the edit IconButton's onPressed
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.secondary),
                              onPressed: () => _showEditCategoryDialog(cat),
                            ),

                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                bool? confirm = await showDialog<bool>(
                                  context: context,  // Assuming this is inside a widget with access to context
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: const Text('Are you sure you want to delete this category?'),
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
                                  provider.deleteCategory(cat.id.toString()!);
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
  // In your CategoriesScreen, add this method inside _CategoriesScreenState
  void _showEditCategoryDialog(CategoriesModel cat) async {
    _categoryCtrl.text = cat.name ?? '';
    bool isEnabled = cat.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter category name',
                ),
              ),
              Row(
                children: [
                  const Text('Enable'),
                  Switch(
                    value: isEnabled,
                    onChanged: (value) {
                      setState(() {
                        isEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _categoryCtrl.text.trim();
                if (name.isEmpty) return;

                final token = await getToken();
                if (token == null) return;

                await Provider.of<CategoriesProvider>(context, listen: false)
                    .updateCategory(cat.id.toString()!, name, isEnabled,);

                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
