import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../../ApiLink/ApiEndpoint.dart';
import '../../Screen/DashBoardScreen.dart';



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

        final prefs = await SharedPreferences.getInstance();

        // 🔹 Clear old session data to prevent leaking permissions
        await prefs.remove('token');
        await prefs.remove('user');
        await prefs.remove('salesman_id');
        await prefs.remove('is_owner');
        await prefs.remove('roles');
        await prefs.remove('permission_codes');
        await prefs.remove('user_type');

        final access = data["data"]["access"];
        final user = data["data"]["user"];
        final accessToken = data["data"]["accessToken"];

        await prefs.setString('token', accessToken);
        await prefs.setString('user', jsonEncode(user));

        // ⭐ SAVE ROLES
        if (access["roles"] != null) {
          await prefs.setStringList(
              'roles',
              List<String>.from(access["roles"].map((e) => e["name"]))
          );
        }

        // ⭐ SAVE PERMISSIONS
        if (access["permission_codes"] != null) {
          await prefs.setStringList(
              'permission_codes',
              List<String>.from(access["permission_codes"])
          );
        }

        // ⭐ SAVE SALESMAN ID
        final salesmanId = user["salesman_id"];
        if (salesmanId != null) {
          await prefs.setInt('salesman_id', salesmanId);
        }

        // ⭐ SAVE USER TYPE
        final userType = user["user_type"];
        if (userType != null) {
          await prefs.setString('user_type', userType);
        }

        // ⭐ OWNER CHECK (ADMIN)
        bool isOwner = access["is_owner"] == true;
        // Fallback: also check companies list
        if (!isOwner &&
            data["data"]["companies"] != null &&
            data["data"]["companies"].isNotEmpty) {
          isOwner = data["data"]["companies"][0]["is_owner"] == 1;
        }
        await prefs.setBool('is_owner', isOwner);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }


    }catch(e){
      print(e);
      message = "Something went wrong: $e";

    }
    isLoading=false;
    notifyListeners();



  }
}