import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../../ApiLink/ApiEndpoint.dart';
import '../../Screen/HomeScreen.dart';



class LoginProvider with ChangeNotifier{

  bool isLoading = false;
  String message="";


//gets
  bool get _isLoading=>isLoading;
  String get _message=>message;
  final TextEditingController emailController=TextEditingController();
  final TextEditingController passwordController=TextEditingController();
  Future<void>login(BuildContext context)async{
    final email= emailController.text.trim();
    final password=passwordController.text.trim();
    if(email.isEmpty||password.isEmpty) {
      message = "Please enter email and password";
      notifyListeners();
      return;
    }
    isLoading= true;
    message="";
    notifyListeners();

    try{

      final client = http.Client(); // ek baar client create karo

      final response = await client.post(
        Uri.parse('${ApiEndpoints.baseUrl}/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'identifier': email, 'password': password}),
      ).timeout(Duration(seconds: 15));
      client.close();


      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        message = "Login successful!";
        emailController.clear();
        passwordController.clear();

        final prefs = await SharedPreferences.getInstance();

        // 🔹 Clear old session data to prevent leaking permissions
        await prefs.remove('token');
        await prefs.remove('user');
        await prefs.remove('salesman_id');
        await prefs.remove('is_owner');
        await prefs.remove('roles');
        await prefs.remove('permission_codes');
        await prefs.remove('user_type');
        await prefs.remove('assigned_area_ids');
        await prefs.remove('delivery_boy_id');

        final access = data["data"]["access"];
        final user = data["data"]["user"];
        final accessToken = data["data"]["accessToken"];
        final companies = data["data"]["companies"];

        // 1. Core Auth Data
        await prefs.setString('token', accessToken);
        await prefs.setString('user', jsonEncode(user));
        
        // 2. Companies Data
        if (companies != null) {
          await prefs.setString('companies', jsonEncode(companies));
        }

        // 3. Roles (Save as List for easy check)
        if (access["roles"] != null) {
          await prefs.setStringList(
              'roles',
              List<String>.from(access["roles"].map((e) => e["name"]))
          );
        }

        // 4. Permissions (Codes are most important)
        if (access["permission_codes"] != null) {
          await prefs.setStringList(
              'permission_codes',
              List<String>.from(access["permission_codes"])
          );
        }

        // 5. Specific IDs for Convenience
        // 5. Specific IDs (Clear if null to prevent data overlap from previous login)
        if (user["salesman_id"] != null) {
          await prefs.setInt('salesman_id', user["salesman_id"]);
        } else {
          await prefs.remove('salesman_id');
        }

        if (user["delivery_boy_id"] != null) {
          await prefs.setInt('delivery_boy_id', user["delivery_boy_id"]);
        } else {
          await prefs.remove('delivery_boy_id');
        }

        if (user["user_type"] != null) {
          await prefs.setString('user_type', user["user_type"]);
        }

        // 6. Assigned Areas (Clear if null or empty)
        if (user["assigned_area_ids"] != null && (user["assigned_area_ids"] as List).isNotEmpty) {
          await prefs.setStringList(
              'assigned_area_ids',
              List<String>.from(user["assigned_area_ids"].map((e) => e.toString()))
          );
        } else {
          await prefs.remove('assigned_area_ids');
        }

        // 7. Owner/Admin Check
        bool isOwner = access["is_owner"] == true;
        if (!isOwner && companies != null && companies.isNotEmpty) {
          // Check if first company has owner flag
          isOwner = companies[0]["is_owner"] == 1 || companies[0]["is_owner"] == true;
        }
        await prefs.setBool('is_owner', isOwner);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
      else {
        // ⭐ YEH ADD KARO - server ka message show karo
        message = data["message"] ?? "Login failed. Please try again.";
        notifyListeners();
      }


    }catch(e){
      print(e);
      message = "Something went wrong: $e";

    }
    isLoading=false;
    notifyListeners();



  }
}