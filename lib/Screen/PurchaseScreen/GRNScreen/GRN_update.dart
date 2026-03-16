import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Provider/Purchase_Provider/GRNProvider/GRN_Provider.dart';
import '../../../Provider/setup/location_provider.dart';
import '../../../compoents/ProductDropdown.dart';
import '../../../compoents/SupplierDropdown.dart';
import '../../../compoents/location_dropdown.dart';
import '../../../model/ProductModel/itemsdetailsModel.dart';
import '../../../model/Purchase_Model/GNRModel/GNR_Model.dart';

class GrnUpdate extends StatefulWidget {
  final GRNModel grn;
  
  const GrnUpdate({super.key, required this.grn});

  @override
  State<GrnUpdate> createState() => _GrnUpdateState();
}

class _GrnUpdateState extends State<GrnUpdate> {

  String? selectedSupplierId;
  ItemDetails? selectedProduct;

  final qtyController = TextEditingController();
  final rateController = TextEditingController();
  int? selectedLocationId;

  double productTotal = 0;

  List<Map<String, dynamic>> selectedProducts = [];
  double grandTotal = 0;
  late GRNProvider grnProvider;

  /// CALCULATE TOTAL
  void calculateTotal() {
    int qty = int.tryParse(qtyController.text) ?? 0;
    double rate = double.tryParse(rateController.text) ?? 0;

    setState(() {
      productTotal = qty * rate;
    });
  }

  /// ADD PRODUCT
  void addProductToList() {

    if (selectedProduct == null ||
        qtyController.text.isEmpty ||
        rateController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    selectedProducts.add({
      "item_id": selectedProduct!.id,
      "name": selectedProduct!.name,
      "qty_received": int.parse(qtyController.text),
      "unit_cost": double.parse(rateController.text),
      "total": productTotal
    });

    grandTotal = selectedProducts.fold(
        0, (sum, item) => sum + (item["total"] as double));

    qtyController.clear();
    rateController.clear();

    productTotal = 0;

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    grnProvider = Provider.of<GRNProvider>(context, listen: false); // ✅ fix

    selectedSupplierId = widget.grn.supplierId.toString();
    selectedLocationId = widget.grn.locationId;

    Future.microtask(() {
      Provider.of<LocationProvider>(context, listen: false).getLocations();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GRN Update"),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(widget.grn.grnNo),
            const SizedBox(height: 15),

            /// SUPPLIER
            /// SUPPLIER
            SupplierDropdown(
              selectedSupplierId: selectedSupplierId,  // ✅ correct parameter name
              onSelected: (id) {
                setState(() => selectedSupplierId = id);
              },
            ),

            /// LOCATION
            Consumer<LocationProvider>(
              builder: (context, locationProvider, child) {  // ✅ renamed to locationProvider
                return LocationDropdown(
                  locations: locationProvider.locationList,
                  selectedId: selectedLocationId,
                  onChanged: (value) {
                    setState(() => selectedLocationId = value);
                  },
                );
              },
            ),
            const SizedBox(height: 15),

            /// PRODUCT
            ItemDetailsDropdown(
              onItemSelected: (item) {
                selectedProduct = item;
                setState(() {});
              },
            ),

            const SizedBox(height: 20),

            /// QTY RATE
            if (selectedProduct != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text("Quantity"),

                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => calculateTotal(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter Quantity",
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text("Rate"),

                  TextField(
                    controller: rateController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => calculateTotal(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter Rate",
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Total: Rs $productTotal",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    onPressed: addProductToList,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Product"),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            /// PRODUCT TABLE
            if (selectedProducts.isNotEmpty)
              Column(
                children: [

                  const Text(
                    "Products",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),

                  const SizedBox(height: 10),

                  Table(
                    border: TableBorder.all(),

                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                    },

                    children: [

                      const TableRow(
                        decoration: BoxDecoration(color: Colors.black12),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(6),
                            child: Text("Item",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6),
                            child: Text("Qty",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6),
                            child: Text("Rate",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6),
                            child: Text("Total",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),

                      ...selectedProducts.map((p) {

                        return TableRow(children: [

                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(p["name"]),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(p["qty_received"].toString()),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(p["unit_cost"].toString()),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(p["total"].toString()),
                          ),

                        ]);

                      }).toList(),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Grand Total: Rs $grandTotal",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  )
                ],
              ),

            const SizedBox(height: 20),

            /// SAVE BUTTON
            ElevatedButton(

              onPressed: () async {

                if (selectedSupplierId == null ||
                    selectedLocationId == null ||
                    selectedProducts.isEmpty) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Select supplier, location & add product")),
                  );
                  return;
                }

                final date = DateFormat("yyyy-MM-dd").format(DateTime.now());

                /// DETAILS FORMAT FOR API
                List<Map<String, dynamic>> details =
                selectedProducts.map((e) => {
                  "item_id": e["item_id"] is String ? int.parse(e["item_id"]) : e["item_id"],
                  "qty_received": e["qty_received"],
                  "unit_cost": e["unit_cost"],
                }).toList();

                bool success = await grnProvider.addNewGRN(
                  supplierId: int.parse(selectedSupplierId!),
                  grnDate: date,
                  products: details,
                  totalAmount: grandTotal,
                  grnNo: widget.grn.grnNo,      // ✅ dynamic from widget
                  locationId: selectedLocationId!, // ✅ dynamic from dropdown
                  details: details,
                );

                if (success) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("GRN Added Successfully")),
                  );

                  Navigator.pop(context);

                } else {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Failed to Add GRN")),
                  );
                }
              },

              child: const Text("Save GRN"),
            ),
          ],
        ),


      ),
    );
  }
}
