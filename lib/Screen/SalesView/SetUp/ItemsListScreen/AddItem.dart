



import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../Provider/ProductProvider/ItemCategoriesProvider.dart';
import '../../../../Provider/ProductProvider/ItemListsProvider.dart';
import '../../../../Provider/ProductProvider/ItemTypeProvider.dart';
import '../../../../Provider/ProductProvider/ItemUnitProvider.dart';
import '../../../../Provider/ProductProvider/manufactures_provider.dart';
import '../../../../compoents/AppButton.dart';
import '../../../../compoents/AppColors.dart';
import '../../../../compoents/AppTextfield.dart';
import '../../../../compoents/ItemCategoriesDropDown.dart';
import '../../../../compoents/ItemTypeDropDown.dart';
import '../../../../compoents/ItemUnitsDropDown.dart';
import '../../../../compoents/SupplierDropdown.dart';
import '../../../../compoents/manufactures_dropdown.dart';

class AddItemScreen extends StatefulWidget {
  final String nextItemId;

  const AddItemScreen({super.key, required this.nextItemId});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // ── Dropdown selections ──────────────────────────────────────────────────
  String? selectedCategoryId;
  String? selectedSupplierId;
  String? selectedTypeId;
  String? selectedUnitId;
  String? selectedManufacturerId;

  // ── Text controllers ─────────────────────────────────────────────────────
  final TextEditingController nameCtrl         = TextEditingController();
  final TextEditingController phoneCtrl        = TextEditingController();
  final TextEditingController codeCtrl         = TextEditingController();
  final TextEditingController coaCodeCtrl      = TextEditingController();
  final TextEditingController itemDateCtrl     = TextEditingController();
  final TextEditingController openingDateCtrl  = TextEditingController();
  final TextEditingController unitQtyCtrl      = TextEditingController();
  final TextEditingController minLevelQtyCtrl  = TextEditingController();
  final TextEditingController purchaseCtrl     = TextEditingController();
  final TextEditingController salesCtrl        = TextEditingController();
  final TextEditingController manualBarcodeCtrl = TextEditingController();

  File? pickedImage;

  @override
  void initState() {
    super.initState();

    // Set today as default item_date
    itemDateCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final unitProvider = Provider.of<ItemUnitProvider>(context, listen: false);
      if (unitProvider.units.isEmpty) unitProvider.fetchItemUnits();

      Provider.of<CategoriesProvider>(context, listen: false).fetchCategories();
      Provider.of<ItemTypeProvider>(context, listen: false).fetchItemTypes();

      final mfgProvider = Provider.of<ManufacturesProvider>(context, listen: false);
      if (mfgProvider.manufactures.isEmpty) mfgProvider.fetchManufactures();
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    codeCtrl.dispose();
    coaCodeCtrl.dispose();
    itemDateCtrl.dispose();
    openingDateCtrl.dispose();
    unitQtyCtrl.dispose();
    minLevelQtyCtrl.dispose();
    purchaseCtrl.dispose();
    salesCtrl.dispose();
    manualBarcodeCtrl.dispose();
    super.dispose();
  }

  // ── Date picker helper ───────────────────────────────────────────────────
  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(ctrl.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  // ── Image picker ─────────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final permission = source == ImageSource.camera
        ? await Permission.camera.request()
        : await Permission.photos.request();

    if (!permission.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied")),
      );
      return;
    }

    final XFile? image = await ImagePicker().pickImage(source: source);
    if (image == null) return;

    final ext = image.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png'].contains(ext)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Only JPG or PNG images are allowed")),
      );
      return;
    }

    setState(() => pickedImage = File(image.path));
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Pick from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Validation ────────────────────────────────────────────────────────────
  String? _validator(String? value) {
    if (value == null || value.trim().isEmpty) return "This field is required";
    return null;
  }

  bool _validate() {
    if (nameCtrl.text.trim().isEmpty) return _fail("Name is required");
    if (codeCtrl.text.trim().isEmpty) return _fail("Code is required");
    if (coaCodeCtrl.text.trim().isEmpty) return _fail("COA Code is required");
    if (itemDateCtrl.text.trim().isEmpty) return _fail("Item Date is required");
    if (selectedTypeId == null) return _fail("Select Item Type");
    if (selectedCategoryId == null) return _fail("Select Category");
    if (selectedManufacturerId == null) return _fail("Select Manufacturer");
    if (selectedSupplierId == null) return _fail("Select Supplier");
    if (selectedUnitId == null) return _fail("Select Unit");
    if (unitQtyCtrl.text.trim().isEmpty) return _fail("Unit Qty is required");
    if (minLevelQtyCtrl.text.trim().isEmpty) return _fail("Min Level Qty is required");
    if (purchaseCtrl.text.trim().isEmpty) return _fail("Purchase Price is required");
    if (salesCtrl.text.trim().isEmpty) return _fail("Sale Price is required");
    if (pickedImage == null) return _fail("Please select an image");
    return true;
  }

  bool _fail(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    return false;
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_validate()) return;

    final provider = Provider.of<ItemDetailsProvider>(context, listen: false);

    final success = await provider.addItem(
      context: context,
      name:             nameCtrl.text.trim(),
      phone:            phoneCtrl.text.trim(),
      code:             codeCtrl.text.trim(),
      coaCode:          coaCodeCtrl.text.trim(),
      itemDate:         itemDateCtrl.text.trim(),
      openingDate:      openingDateCtrl.text.trim(),
      itemTypeId:       selectedTypeId!,
      categoryId:       selectedCategoryId!,
      manufacturerId:   selectedManufacturerId!,
      supplierId:       selectedSupplierId!,
      unitId:           selectedUnitId!,
      unitQty:          unitQtyCtrl.text.trim(),
      minLevelQty:      minLevelQtyCtrl.text.trim(),
      purchasePrice:    purchaseCtrl.text.trim(),
      salePrice:        salesCtrl.text.trim(),
      manualBarcode:    manualBarcodeCtrl.text.trim(),
      image:            pickedImage!,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item added successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage.isNotEmpty ? provider.errorMessage : "Failed to add item")),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Item",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
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
      body: Consumer<ItemDetailsProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Basic Info ───────────────────────────────────────────
                _sectionLabel("Basic Information"),
                AppTextField(controller: nameCtrl, label: "Name *", validator: null),
                const SizedBox(height: 10),
                AppTextField(controller: phoneCtrl, label: "Phone", validator: null),
                const SizedBox(height: 10),
                AppTextField(controller: codeCtrl, label: "Code *", validator: null),
                const SizedBox(height: 10),
                AppTextField(controller: coaCodeCtrl, label: "COA Code *", validator: null),
                const SizedBox(height: 10),

                // ── Dates ────────────────────────────────────────────────
                _sectionLabel("Dates"),
                _dateField(ctrl: itemDateCtrl, label: "Item Date *"),
                const SizedBox(height: 10),
                _dateField(ctrl: openingDateCtrl, label: "Opening Date (optional)"),
                const SizedBox(height: 10),

                // ── Dropdowns ────────────────────────────────────────────
                _sectionLabel("Classification"),
                ItemTypeDropdown(
                  selectedId: selectedTypeId,
                  onSelected: (id) => setState(() => selectedTypeId = id),
                ),
                const SizedBox(height: 10),
                CategoriesDropdown(
                  selectedId: selectedCategoryId,
                  onChanged: (id) => setState(() => selectedCategoryId = id),
                ),
                const SizedBox(height: 10),
                ManufacturesDropdown(
                  selectedManufactureId: selectedManufacturerId != null
                      ? int.tryParse(selectedManufacturerId!)
                      : null,
                  isRequired: true,
                  onChanged: (value) =>
                      setState(() => selectedManufacturerId = value?.toString()),
                ),
                const SizedBox(height: 10),
                SupplierDropdown(
                    onSelected: (id) => setState(() => selectedSupplierId = id),
                  ),

                const SizedBox(height: 10),
                ItemUnitDropdown(
                  selectedId: selectedUnitId,
                  onSelected: (id) => setState(() => selectedUnitId = id),
                ),
                const SizedBox(height: 10),

                // ── Quantities & Prices ──────────────────────────────────
                _sectionLabel("Quantities & Prices"),
                AppTextField(controller: unitQtyCtrl, label: "Unit Qty *", validator: null),
                const SizedBox(height: 10),
                AppTextField(controller: minLevelQtyCtrl, label: "Min Level Qty *", validator: null),
                const SizedBox(height: 10),
                AppTextField(controller: purchaseCtrl, label: "Purchase Price *", validator: null),
                const SizedBox(height: 10),
                AppTextField(controller: salesCtrl, label: "Sale Price *", validator: null),
                const SizedBox(height: 10),

                // ── Other ────────────────────────────────────────────────
                _sectionLabel("Other"),
                AppTextField(controller: manualBarcodeCtrl, label: "Manual Barcode (optional)", validator: null),
                const SizedBox(height: 10),

                // ── Image ────────────────────────────────────────────────
                _sectionLabel("Item Image *"),
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: pickedImage == null
                      ? const Center(child: Text("No Image Selected"))
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(pickedImage!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _showImageSourceSheet,
                  icon: const Icon(Icons.image),
                  label: const Text("Select Image"),
                ),

                const SizedBox(height: 30),
                provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton(
                  title: "Save Item",
                  press: _submit,
                  width: double.infinity,
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    ),
  );

  Widget _dateField({required TextEditingController ctrl, required String label}) {
    return GestureDetector(
      onTap: () => _pickDate(ctrl),
      child: AbsorbPointer(
        child: AppTextField(
          controller: ctrl,
          label: label,
          validator: null,
        ),
      ),
    );
  }

  Widget _styledWrapper({required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8F0), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [Expanded(child: child)]),
      ),
    );
  }
}