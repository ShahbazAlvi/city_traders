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

        final access = data["data"]["access"];
        //print(access.permissions_ids);

        await prefs.setString('token', data["data"]["accessToken"]);
        await prefs.setString('user', jsonEncode(data["data"]["user"]));

        // ⭐ SAVE ROLE + PERMISSIONS
        await prefs.setStringList(
            'roles',
            List<String>.from(access["roles"].map((e) => e["name"]))
        );

        await prefs.setStringList(
            'permission_codes',
            List<String>.from(access["permission_codes"] ?? [])
        );

        // ⭐ OWNER CHECK (ADMIN)
        // Replace your is_owner block with this:
        //final access = data["data"]["access"];

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
          MaterialPageRoute(builder: (_) => const Dashboardscreen()),
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