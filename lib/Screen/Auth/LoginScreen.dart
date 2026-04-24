import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Provider/AuthProvider/LoginProvider.dart';

// ─── Design Theme ────────────────────────────────────────────────────────────
class _Colors {
  static const primary = Color(0xFF5B86E5); // Modern Indigo
  static const accent = Color(0xFF36D1DC);  // Purple Accent
  static const bgDark = Color(0xFF0F172A);  // Deep Slate
  
  static const gradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _formCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _formCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _formCtrl, curve: Curves.easeOutBack),
    );

    _fadeCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () => _formCtrl.forward());
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _formCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _Colors.bgDark,
      body: Stack(
        children: [
          // ── 1. Background Image ──────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              "assets/images/login-bg2.png",
              fit: BoxFit.cover,
            ),
          ),

          // ── 2. Subtle Gradient Overlay ───────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _Colors.bgDark.withOpacity(0.3),
                    _Colors.bgDark.withOpacity(0.7),
                    _Colors.bgDark,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ── 3. Main Content ──────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.12),
                      
                      // Logo / Brand

                      
                     // const SizedBox(height: 10),
                      
                      Text(
                        "Siddiquitd Traders",
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        "Premium Distribution Services",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                      
                      SizedBox(height: size.height * 0.04),

                      // ── 4. Login Form (Glassmorphism) ─────────────────────────
                      SlideTransition(
                        position: _slideAnim,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Login",
                                    style: GoogleFonts.outfit(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Please sign in to continue",
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.white60,
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Username Field
                                  _buildTextField(
                                    label: "Username or Email",
                                    hint: "Enter your username",
                                    icon: Icons.person_outline_rounded,
                                    controller: loginProvider.emailController,
                                  ),
                                  
                                  const SizedBox(height: 20),

                                  // Password Field
                                  _buildTextField(
                                    label: "Password",
                                    hint: "••••••••",
                                    icon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    obscure: _obscurePassword,
                                    controller: loginProvider.passwordController,
                                    onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),



                                  const SizedBox(height: 24),

                                  // Login Button
                                  loginProvider.isLoading
                                      ? const Center(child: CircularProgressIndicator(color: _Colors.primary))
                                      : _buildLoginButton(context, loginProvider),
                                  
                                  // if (loginProvider.message.isNotEmpty) ...[
                                  //   const SizedBox(height: 16),
                                  //   Center(
                                  //     child: Text(
                                  //       loginProvider.message,
                                  //       textAlign: TextAlign.center,
                                  //       style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                  //     ),
                                  //   ),
                                  // ],
                                  if (loginProvider.message.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: loginProvider.message.contains("successful")
                                            ? Colors.greenAccent.withOpacity(0.15)
                                            : Colors.redAccent.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: loginProvider.message.contains("successful")
                                              ? Colors.greenAccent.withOpacity(0.4)
                                              : Colors.redAccent.withOpacity(0.4),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            loginProvider.message.contains("successful")
                                                ? Icons.check_circle_outline_rounded
                                                : Icons.error_outline_rounded,
                                            color: loginProvider.message.contains("successful")
                                                ? Colors.greenAccent
                                                : Colors.redAccent,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              loginProvider.message,
                                              style: GoogleFonts.inter(
                                                color: loginProvider.message.contains("successful")
                                                    ? Colors.greenAccent
                                                    : Colors.redAccent,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      

                      GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse("https://www.afaqtechnologies.com.pk");
                          try {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } catch (e) {
                            debugPrint("Could not launch URL: $e");
                          }
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Developed by ",
                                style: GoogleFonts.inter(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: "Afaq Technologies",
                                style: GoogleFonts.inter(
                                  color: _Colors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: _Colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 14),
              prefixIcon: Icon(icon, color: Colors.white60, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.white38,
                        size: 20,
                      ),
                      onPressed: onToggle,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context, LoginProvider provider) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: _Colors.gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _Colors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => provider.login(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: _roundedRectangleCircular(16),
        ),
        child: Text(
          "LOGIN",
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Helper for rounded rectangle since it's commonly used
  RoundedRectangleBorder _roundedRectangleCircular(double radius) {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  }
}
