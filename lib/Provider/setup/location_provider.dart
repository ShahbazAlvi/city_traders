import 'dart:convert';
import 'package:demo_distribution/ApiLink/ApiEndpoint.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import '../../model/setup/location.dart';

class LocationProvider with ChangeNotifier {

  List<LocationModel> locationList = [];
  bool isLoading = false;

  Future<void> getLocations() async {

    isLoading = true;
    notifyListeners();

    final url = Uri.parse("${ApiEndpoints.baseUrl}/locations");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer YOUR_TOKEN",
        "Accept": "application/json"
      },
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      final List list = data['data']['data'];

      locationList = list
          .map((e) => LocationModel.fromJson(e))
          .toList();

    }

    isLoading = false;
    notifyListeners();
  }
}