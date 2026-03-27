// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../ApiLink/ApiEndpoint.dart';
// import '../../model/ProductModel/itemsdetailsModel.dart';
// import '../DashBoardProvider.dart';
// import 'package:http_parser/http_parser.dart';
//
//
// class ItemDetailsProvider with ChangeNotifier {
//   List<ItemDetails> _items = [];
//   bool _isLoading = false;
//   String _errorMessage='';
//
//   List<ItemDetails> get items=> _items;
//   bool get isLoading=> _isLoading;
//   String get errorMessage=> _errorMessage;
//   String baseUrl = "${ApiEndpoints.baseUrl}/items";
//   String token = "";   // ✅ Put your token here
//
//   Future<void> fetchItems({String? categoryName, bool? isEnable}) async {
//     try {
//       _isLoading = true;
//       notifyListeners();
//
//       final storedToken = await getToken();
//       if (storedToken == null) {
//         _errorMessage = "Token not found";
//         _isLoading = false;
//         notifyListeners();
//         print("Fetch Error: Token not found");
//         return;
//       }
//
//       final uri = Uri.parse(baseUrl);
//
//       final response = await http.get(
//         uri,
//         headers: {
//           "Authorization": "Bearer $storedToken",
//           "Content-Type": "application/json",
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> decoded = jsonDecode(response.body);
//         final List dataList = decoded['data']['data'] ?? [];
//         _items = dataList.map((e) => ItemDetails.fromJson(e)).toList();
//       } else if (response.statusCode == 401) {
//         _errorMessage = "Unauthorized: Please login again";
//         print("Fetch Error: Unauthorized");
//       } else if (response.statusCode == 404) {
//         _errorMessage = "Endpoint not found";
//         print("Fetch Error: 404 Not Found");
//       } else {
//         _errorMessage = "Error: ${response.body}";
//         print("Fetch Error: ${response.body}");
//       }
//     } catch (e) {
//       _errorMessage = "Fetch Error: $e";
//       print("Fetch Exception: $e");
//     }
//
//     _isLoading = false;
//     notifyListeners();
//   }
//
//
//
//
//   Future<String?> getToken() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       return prefs.getString('token');
//     } catch (e) {
//       print("Error getting token: $e");
//       return null;
//     }
//   }
//
//
//
//       // Add pagination to URL
//
//
//
//
//
//   ItemDetails? getItemById(int id) {
//     try {
//       return _items.firstWhere((item) => item.id == id);
//     } catch (e) {
//       return null;
//     }
//   }
//
//   List<ItemDetails> searchItems(String query) {
//     if (query.isEmpty) return _items;
//
//     return _items.where((item) {
//       return item.name.toLowerCase().contains(query.toLowerCase()) ;
//          // (item.itemCode?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
//           //(item.categoryName?.toLowerCase().contains(query.toLowerCase()) ?? false);
//     }).toList();
//   }
//
//
//
//
//
//   Future<void> deleteItem(String id,BuildContext context) async {
//     final storedToken = await getToken();
//     // 🔥 load token from SharedPreferences
//
//     if (storedToken == null) {
//       print("Delete Error: Token is null");
//       return;
//     }
//
//     final uri = Uri.parse("${ApiEndpoints.baseUrl}/item-details/$id");
//
//     try {
//       final res = await http.delete(
//         uri,
//         headers: {
//           "Authorization": "Bearer $storedToken",
//         },
//       );
//
//       print("Delete response: ${res.body}");
//
//       if (res.statusCode == 200) {
//         items.removeWhere((item) => item.id == id);
//
//
//         // refresh list from server
//         fetchItems();
//         final dashboardProvider =
//         Provider.of<DashboardProvider>(context, listen: false);
//         await dashboardProvider.fetch();
//         notifyListeners();
//       }
//     } catch (e) {
//       print("Delete error: $e");
//     }
//   }
//
//
//
//
//   // Future<String?> getToken() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   return prefs.getString("token");
//   // }
//
//   Future<bool> addItem({
//     required BuildContext context,
//     required String code,
//     required String coa_code,
//     required String name,
//     required String itemTypeId,
//     required String categoryId,
//     required int subCategoryId,
//     required int manufacturerId,
//     required String unitId,
//     required String minQty,
//     required String purchasePrice,
//     required String salePrice,
//     required File image,
//   }) async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();
//
//     final token = await getToken();
//     if (token == null) {
//       _errorMessage = "Token not found";
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//
//     final uri = Uri.parse("${ApiEndpoints.baseUrl}/items");
//     final request = http.MultipartRequest("POST", uri);
//
//     request.headers['Authorization'] = 'Bearer $token';
//
//     request.fields['code'] = code;
//     request.fields['coa_code'] = coa_code;
//
//     request.fields['name'] = name;
//     request.fields['item_type_id'] = itemTypeId;
//     request.fields['category_id'] = categoryId;
//
//     request.fields['manufacturer_id'] = manufacturerId.toString();
//     request.fields['unit_id'] = unitId;
//     request.fields['min_level_qty'] = minQty;
//     request.fields['purchase_price'] = purchasePrice;
//     request.fields['sale_price'] = salePrice;
//     request.fields['is_active'] = "1";
//     request.fields['remove_image'] = "0";
//
//     request.files.add(
//       await http.MultipartFile.fromPath(
//         'image',
//         image.path,
//         contentType: MediaType(
//           'image',
//           image.path.split('.').last.toLowerCase(), // jpeg, png, etc
//         ),
//       ),
//     );
//
//     try {
//       final response = await request.send();
//       final body = await response.stream.bytesToString();
//
//       print("Status: ${response.statusCode}");
//       print("Response: $body");
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         await fetchItems();
//         final dashboardProvider =
//         Provider.of<DashboardProvider>(context, listen: false);
//         await dashboardProvider.fetch();
//
//         _isLoading = false;
//         notifyListeners();
//         return true;
//       } else {
//         _errorMessage = body;
//       }
//     } catch (e) {
//       _errorMessage = e.toString();
//     }
//
//     _isLoading = false;
//     notifyListeners();
//     return false;
//   }
//   Future<bool> updateItem({
//     required BuildContext context,
//     required String id,
//     required String itemName,
//     required String itemCategory,
//     required String itemType,
//     required String itemUnit,
//     required String perUnit,
//     required String reorder,
//     required String itemKind,
//     File? itemImage, // OPTIONAL
//   }) async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();
//
//     final storedToken = await getToken();
//     if (storedToken == null) {
//       _errorMessage = "Token not found";
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//
//     final uri = Uri.parse("${ApiEndpoints.baseUrl}/item-details/$id");
//     final request = http.MultipartRequest("PUT", uri);
//
//     request.headers["Authorization"] = "Bearer $storedToken";
//
//     request.fields["itemName"] = itemName;
//     request.fields["itemCategory"] = itemCategory;
//     request.fields["itemType"] = itemType;
//     request.fields["itemUnit"] = itemUnit;
//     request.fields["perUnit"] = perUnit;
//     request.fields["reorder"] = reorder;
//     request.fields["itemKind"] = itemKind;
//
//     if (itemImage != null) {
//       request.files.add(
//           await http.MultipartFile.fromPath("itemImage", itemImage.path));
//     }
//
//     try {
//       final response = await request.send();
//       final body = await response.stream.bytesToString();
//
//       if (response.statusCode == 200) {
//         await fetchItems();
//
//         final dashboardProvider =
//         Provider.of<DashboardProvider>(context, listen: false);
//         await dashboardProvider.fetch();
//
//         _isLoading = false;
//         notifyListeners();
//         return true;
//       } else {
//         _errorMessage = body;
//       }
//     } catch (e) {
//       _errorMessage = e.toString();
//     }
//
//     _isLoading = false;
//     notifyListeners();
//     return false;
//   }
//
//
//
//
// }


import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ApiLink/ApiEndpoint.dart';
import '../../model/ProductModel/itemsdetailsModel.dart';
import '../DashBoardProvider.dart';
import 'package:http_parser/http_parser.dart';

class ItemDetailsProvider with ChangeNotifier {
  List<ItemDetails> _items = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<ItemDetails> get items => _items;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  String get baseUrl => "${ApiEndpoints.baseUrl}/items";

  // ─── FETCH ALL ITEMS ────────────────────────────────────────────────────────
  Future<void> fetchItems() async {
    try {
      _isLoading = true;
      notifyListeners();

      final storedToken = await getToken();
      if (storedToken == null) {
        _errorMessage = "Token not found";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $storedToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final List dataList = decoded['data']['data'] ?? [];
        _items = dataList.map((e) => ItemDetails.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        _errorMessage = "Unauthorized: Please login again";
      } else if (response.statusCode == 404) {
        _errorMessage = "Endpoint not found";
      } else {
        _errorMessage = "Error: ${response.body}";
      }
    } catch (e) {
      _errorMessage = "Fetch Error: $e";
      print("Fetch Exception: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── GET TOKEN ───────────────────────────────────────────────────────────────
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print("Error getting token: $e");
      return null;
    }
  }

  // ─── GET ITEM BY ID ──────────────────────────────────────────────────────────
  ItemDetails? getItemById(int id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // ─── SEARCH ITEMS ────────────────────────────────────────────────────────────
  List<ItemDetails> searchItems(String query) {
    if (query.isEmpty) return _items;
    return _items.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // ─── DELETE ITEM ─────────────────────────────────────────────────────────────
  Future<void> deleteItem(String id, BuildContext context) async {
    final storedToken = await getToken();
    if (storedToken == null) {
      print("Delete Error: Token is null");
      return;
    }

    final uri = Uri.parse("${ApiEndpoints.baseUrl}/items/$id");

    try {
      final res = await http.delete(
        uri,
        headers: {"Authorization": "Bearer $storedToken"},
      );

      print("Delete response: ${res.body}");

      if (res.statusCode == 200) {
        _items.removeWhere((item) => item.id.toString() == id);
        await fetchItems();
        final dashboardProvider =
        Provider.of<DashboardProvider>(context, listen: false);
        await dashboardProvider.fetch();
        notifyListeners();
      }
    } catch (e) {
      print("Delete error: $e");
    }
  }

  // ─── ADD ITEM ────────────────────────────────────────────────────────────────
  /// Field mapping matches the confirmed API:
  /// POST https://api.citytradersmis.com/api/items
  ///
  /// name, phone, code, coa_code, item_date, item_type_id, category_id,
  /// manufacturer_id, supplier_id, unit_id, unit_qty, min_level_qty,
  /// purchase_price, sale_price, opening_date, is_active,
  /// manual_barcode, remove_image, image (binary)
  Future<bool> addItem({
    required BuildContext context,

    // Basic info
    required String name,
    required String phone,
    required String code,
    required String coaCode,

    // Dates
    required String itemDate,       // e.g. "2026-03-27"
    String openingDate = '',        // optional, send empty string if not used

    // IDs
    required String itemTypeId,
    required String categoryId,
    required String manufacturerId,
    required String supplierId,
    required String unitId,

    // Quantities & prices
    required String unitQty,        // unit_qty
    required String minLevelQty,    // min_level_qty
    required String purchasePrice,
    required String salePrice,

    // Flags
    String isActive = "1",
    String manualBarcode = '',
    String removeImage = "0",

    // Image
    required File image,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final token = await getToken();
    if (token == null) {
      _errorMessage = "Token not found";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final uri = Uri.parse(baseUrl); // POST /api/items
    final request = http.MultipartRequest("POST", uri);

    request.headers['Authorization'] = 'Bearer $token';

    // ── Text fields (exact API field names) ──────────────────────────────────
    request.fields['name']            = name;
    request.fields['phone']           = phone;
    request.fields['code']            = code;
    request.fields['coa_code']        = coaCode;
    request.fields['item_date']       = itemDate;
    request.fields['item_type_id']    = itemTypeId;
    request.fields['category_id']     = categoryId;
    request.fields['manufacturer_id'] = manufacturerId;
    request.fields['supplier_id']     = supplierId;
    request.fields['unit_id']         = unitId;
    request.fields['unit_qty']        = unitQty;
    request.fields['min_level_qty']   = minLevelQty;
    request.fields['purchase_price']  = purchasePrice;
    request.fields['sale_price']      = salePrice;
    request.fields['opening_date']    = openingDate;
    request.fields['is_active']       = isActive;
    request.fields['manual_barcode']  = manualBarcode;
    request.fields['remove_image']    = removeImage;

    // ── Image file ───────────────────────────────────────────────────────────
    final ext = image.path.split('.').last.toLowerCase();
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('image', ext),
      ),
    );

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();

      print("Add Item Status: ${response.statusCode}");
      print("Add Item Response: $body");

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchItems();
        final dashboardProvider =
        Provider.of<DashboardProvider>(context, listen: false);
        await dashboardProvider.fetch();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = body;
      }
    } catch (e) {
      _errorMessage = e.toString();
      print("Add Item Exception: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ─── UPDATE ITEM ─────────────────────────────────────────────────────────────
  Future<bool> updateItem({
    required BuildContext context,
    required String id,
    required String name,
    required String phone,
    required String code,
    required String coaCode,
    required String itemDate,
    required String itemTypeId,
    required String categoryId,
    required String manufacturerId,
    required String supplierId,
    required String unitId,
    required String unitQty,
    required String minLevelQty,
    required String purchasePrice,
    required String salePrice,
    String openingDate = '',
    String isActive = "1",
    String manualBarcode = '',
    String removeImage = "0",
    File? image,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final storedToken = await getToken();
    if (storedToken == null) {
      _errorMessage = "Token not found";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final uri = Uri.parse("${ApiEndpoints.baseUrl}/items/$id");
    final request = http.MultipartRequest("PUT", uri);

    request.headers["Authorization"] = "Bearer $storedToken";

    request.fields['name']            = name;
    request.fields['phone']           = phone;
    request.fields['code']            = code;
    request.fields['coa_code']        = coaCode;
    request.fields['item_date']       = itemDate;
    request.fields['item_type_id']    = itemTypeId;
    request.fields['category_id']     = categoryId;
    request.fields['manufacturer_id'] = manufacturerId;
    request.fields['supplier_id']     = supplierId;
    request.fields['unit_id']         = unitId;
    request.fields['unit_qty']        = unitQty;
    request.fields['min_level_qty']   = minLevelQty;
    request.fields['purchase_price']  = purchasePrice;
    request.fields['sale_price']      = salePrice;
    request.fields['opening_date']    = openingDate;
    request.fields['is_active']       = isActive;
    request.fields['manual_barcode']  = manualBarcode;
    request.fields['remove_image']    = removeImage;

    if (image != null) {
      final ext = image.path.split('.').last.toLowerCase();
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType('image', ext),
        ),
      );
    }

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();

      print("Update Item Status: ${response.statusCode}");
      print("Update Item Response: $body");

      if (response.statusCode == 200) {
        await fetchItems();
        final dashboardProvider =
        Provider.of<DashboardProvider>(context, listen: false);
        await dashboardProvider.fetch();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = body;
      }
    } catch (e) {
      _errorMessage = e.toString();
      print("Update Item Exception: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}