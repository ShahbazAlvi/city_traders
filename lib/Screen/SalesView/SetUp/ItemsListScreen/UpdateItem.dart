// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../Provider/ProductProvider/ItemCategoriesProvider.dart';
// import '../../../../Provider/ProductProvider/ItemListsProvider.dart';
// import '../../../../Provider/ProductProvider/ItemTypeProvider.dart';
// import '../../../../Provider/ProductProvider/ItemUnitProvider.dart';
// import '../../../../compoents/AppButton.dart';
// import '../../../../compoents/AppColors.dart';
// import '../../../../compoents/AppTextfield.dart';
// import '../../../../compoents/ItemCategoriesDropDown.dart';
// import '../../../../compoents/ItemTypeDropDown.dart';
// import '../../../../compoents/ItemUnitsDropDown.dart';
// import '../../../../model/ProductModel/itemsdetailsModel.dart';
//
// class UpdateItemScreen extends StatefulWidget {
//   final ItemDetails item;
//
//   const UpdateItemScreen({super.key, required this.item});
//
//   @override
//   State<UpdateItemScreen> createState() => _UpdateItemScreenState();
// }
//
// class _UpdateItemScreenState extends State<UpdateItemScreen> {
//   String? selectedCategoryId;
//   String? selectedTypeId;
//   String? selectedUnitId;
//
//   final TextEditingController itemNameCtrl = TextEditingController();
//   final TextEditingController perUnitCtrl = TextEditingController();
//   final TextEditingController reorderCtrl = TextEditingController();
//   final TextEditingController itemKindCtrl = TextEditingController();
//
//   File? pickedImage;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Prefill fields
//     itemNameCtrl.text = widget.item.name;
//     perUnitCtrl.text = widget.item.purchasePrice.toString();
//     reorderCtrl.text = widget.item.isActive.toString();
//
//
//     // selectedCategoryId = widget.item.categoryId?.id;
//     // selectedTypeId = widget.item.itemTypeId?.id;
//     // selectedUnitId = widget.item.unitId?.id;
//
//     Future.microtask(() {
//       Provider.of<CategoriesProvider>(context, listen: false).fetchCategories();
//       Provider.of<ItemTypeProvider>(context, listen: false).fetchItemTypes();
//       Provider.of<ItemUnitProvider>(context, listen: false).fetchItemUnits();
//     });
//   }
//
//   Future pickImage() async {
//     if (await Permission.photos.request().isGranted) {
//       final ImagePicker picker = ImagePicker();
//       final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//
//       if (image != null) {
//         setState(() => pickedImage = File(image.path));
//       }
//     }
//   }
//
//   void submit() async {
//     final provider = Provider.of<ItemDetailsProvider>(context, listen: false);
//
//     if (itemNameCtrl.text.isEmpty ||
//         selectedCategoryId == null ||
//         selectedTypeId == null ||
//         selectedUnitId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("All fields are required")));
//       return;
//     }
//
//     bool success = await provider.updateItem(
//       context: context,
//       id: widget.item.id,
//       itemName: itemNameCtrl.text,
//       itemCategory: selectedCategoryId!,
//       itemType: selectedTypeId!,
//       itemUnit: selectedUnitId!,
//       perUnit: perUnitCtrl.text,
//       reorder: reorderCtrl.text,
//       itemKind: itemKindCtrl.text,
//       itemImage: pickedImage, // nullable (optional update)
//     );
//
//     if (success) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Item updated successfully")));
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text(provider.errorMessage ?? "Error")));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           "Update Item",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [AppColors.secondary, AppColors.primary],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//
//       body: Consumer<ItemDetailsProvider>(
//         builder: (context, provider, child) {
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(children: [
//               AppTextField(label: "Item Name", controller: itemNameCtrl, validator: (value) {  },),
//               const SizedBox(height: 10),
//
//               CategoriesDropdown(
//                 selectedId: selectedCategoryId,
//                 onChanged: (id) => setState(() => selectedCategoryId = id),
//               ),
//               const SizedBox(height: 10),
//
//               ItemTypeDropdown(
//                 selectedId: selectedTypeId,
//                 onSelected: (id) => setState(() => selectedTypeId = id),
//               ),
//               const SizedBox(height: 10),
//
//               ItemUnitDropdown(
//                 selectedId: selectedUnitId,
//                 onSelected: (id) => setState(() => selectedUnitId = id),
//               ),
//               const SizedBox(height: 10),
//
//               AppTextField(label: "Per Unit Price", controller: perUnitCtrl, validator: (value) {  },),
//               const SizedBox(height: 10),
//
//               AppTextField(label: "Reorder Level", controller: reorderCtrl, validator: (value) {  },),
//               const SizedBox(height: 10),
//
//               AppTextField(label: "Item Kind", controller: itemKindCtrl, validator: (value) {  },),
//               const SizedBox(height: 20),
//
//               // Image Picker
//               // Row(
//               //   children: [
//               //     ElevatedButton(
//               //       onPressed: pickImage,
//               //       child: const Text("Change Image"),
//               //     ),
//               //     const SizedBox(width: 10),
//               //     Expanded(
//               //       child: pickedImage != null
//               //           ? Text(pickedImage!.path)
//               //           : Text(widget.item.itemImage?.url ?? "No image"),
//               //     ),
//               //   ],
//               // ),
//               // IMAGE PREVIEW + PICKER
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Item Image",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                   const SizedBox(height: 10),
//
//                   // IMAGE PREVIEW BOX
//
//                   const SizedBox(height: 10),
//
//                   // PICK IMAGE BUTTON
//                   ElevatedButton.icon(
//                     onPressed: pickImage,
//                     icon: const Icon(Icons.image),
//                     label: const Text("Change Image"),
//                   ),
//                 ],
//               ),
//
//
//               const SizedBox(height: 30),
//
//               provider.isLoading
//                   ? const CircularProgressIndicator()
//                   : AppButton(
//                 title: "Update Item",
//                 width: double.infinity,
//                 press: submit,
//               ),
//             ]),
//           );
//         },
//       ),
//     );
//   }
// }
