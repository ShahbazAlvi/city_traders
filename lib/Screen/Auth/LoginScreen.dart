


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Provider/AuthProvider/LoginProvider.dart';
import '../../compoents/AppButton.dart';
import '../../compoents/AppTextfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [

          /// ✅ Background Image
          SizedBox(
            height: screenHeight,
            width: screenWidth,
            child: Image.asset(
              "assets/images/login-bg.png", // Add your image path
              fit: BoxFit.cover,
            ),
          ),

          /// ✅ Dark Overlay (Improves text visibility)
          Container(
            height: screenHeight,
            width: screenWidth,
            color: Colors.black.withOpacity(0.4),
          ),

          /// ✅ Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      SizedBox(height: screenHeight * 0.1),

                      /// Title
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Login to continue",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.white70,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.05),

                      /// Email Field
                      const Text(
                        "Username or Email",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),

                      buildGlassTextField(
                        hintText: "admin or admin@crm.com",
                        controller: loginProvider.emailController,
                        icon: Icons.email_outlined,
                      ),

                      const SizedBox(height: 20),

                      /// Password Field
                      const Text(
                        "Password",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),

                      buildGlassTextField(
                        hintText: "••••••••",
                        controller: loginProvider.passwordController,
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      /// Login Button / Loader
                      loginProvider.isLoading
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                          : AppButton(
                        title: 'Login',
                        press: () {
                          loginProvider.login(context);
                        },
                        width: double.infinity,
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      /// Error Message
                      if (loginProvider.message.isNotEmpty)
                        Center(
                          child: Text(
                            loginProvider.message,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget buildGlassTextField({
    required String hintText,
    required IconData icon,
    bool isPassword = false, required TextEditingController controller,
  }) {
    return TextField(
      obscureText: isPassword,
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.white60,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.25),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 1.2,
          ),
        ),
      ),
    );

  }
}