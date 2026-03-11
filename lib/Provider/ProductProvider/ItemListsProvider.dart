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
  String _errorMessage='';

  List<ItemDetails> get items=> _items;
  bool get isLoading=> _isLoading;
  String get errorMessage=> _errorMessage;
  String baseUrl = "${ApiEndpoints.baseUrl}/items";
  String token = "";   // ✅ Put your token here

  Future<void> fetchItems({String? categoryName, bool? isEnable}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final storedToken = await getToken();
      if (storedToken == null) {
        _errorMessage = "Token not found";
        _isLoading = false;
        notifyListeners();
        print("Fetch Error: Token not found");
        return;
      }

      final uri = Uri.parse(baseUrl);

      final response = await http.get(
        uri,
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
        print("Fetch Error: Unauthorized");
      } else if (response.statusCode == 404) {
        _errorMessage = "Endpoint not found";
        print("Fetch Error: 404 Not Found");
      } else {
        _errorMessage = "Error: ${response.body}";
        print("Fetch Error: ${response.body}");
      }
    } catch (e) {
      _errorMessage = "Fetch Error: $e";
      print("Fetch Exception: $e");
    }

    _isLoading = false;
    notifyListeners();
  }




  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print("Error getting token: $e");
      return null;
    }
  }



      // Add pagination to URL





  ItemDetails? getItemById(int id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  List<ItemDetails> searchItems(String query) {
    if (query.isEmpty) return _items;

    return _items.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase()) ;
         // (item.itemCode?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          //(item.categoryName?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }





  Future<void> deleteItem(String id,BuildContext context) async {
    final storedToken = await getToken();
    // 🔥 load token from SharedPreferences

    if (storedToken == null) {
      print("Delete Error: Token is null");
      return;
    }

    final uri = Uri.parse("${ApiEndpoints.baseUrl}/item-details/$id");

    try {
      final res = await http.delete(
        uri,
        headers: {
          "Authorization": "Bearer $storedToken",
        },
      );

      print("Delete response: ${res.body}");

      if (res.statusCode == 200) {
        items.removeWhere((item) => item.id == id);


        // refresh list from server
        fetchItems();
        final dashboardProvider =
        Provider.of<DashboardProvider>(context, listen: false);
        await dashboardProvider.fetch();
        notifyListeners();
      }
    } catch (e) {
      print("Delete error: $e");
    }
  }




  // Future<String?> getToken() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString("token");
  // }

  Future<bool> addItem({
    required BuildContext context,
    required String sku,
    required String name,
    required String itemTypeId,
    required String categoryId,
    required int subCategoryId,
    required int manufacturerId,
    required String unitId,
    required String minQty,
    required String purchasePrice,
    required String salePrice,
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

    final uri = Uri.parse("${ApiEndpoints.baseUrl}/items");
    final request = http.MultipartRequest("POST", uri);

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['sku'] = sku;
    request.fields['name'] = name;
    request.fields['item_type_id'] = itemTypeId;
    request.fields['category_id'] = categoryId;
    request.fields['subcategory_id'] = subCategoryId.toString();
    request.fields['manufacturer_id'] = manufacturerId.toString();
    request.fields['unit_id'] = unitId;
    request.fields['min_level_qty'] = minQty;
    request.fields['purchase_price'] = purchasePrice;
    request.fields['sale_price'] = salePrice;
    request.fields['is_active'] = "1";
    request.fields['remove_image'] = "0";

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType(
          'image',
          image.path.split('.').last.toLowerCase(), // jpeg, png, etc
        ),
      ),
    );

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();

      print("Status: ${response.statusCode}");
      print("Response: $body");

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
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
  Future<bool> updateItem({
    required BuildContext context,
    required String id,
    required String itemName,
    required String itemCategory,
    required String itemType,
    required String itemUnit,
    required String perUnit,
    required String reorder,
    required String itemKind,
    File? itemImage, // OPTIONAL
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

    final uri = Uri.parse("${ApiEndpoints.baseUrl}/item-details/$id");
    final request = http.MultipartRequest("PUT", uri);

    request.headers["Authorization"] = "Bearer $storedToken";

    request.fields["itemName"] = itemName;
    request.fields["itemCategory"] = itemCategory;
    request.fields["itemType"] = itemType;
    request.fields["itemUnit"] = itemUnit;
    request.fields["perUnit"] = perUnit;
    request.fields["reorder"] = reorder;
    request.fields["itemKind"] = itemKind;

    if (itemImage != null) {
      request.files.add(
          await http.MultipartFile.fromPath("itemImage", itemImage.path));
    }

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();

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
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }




}
