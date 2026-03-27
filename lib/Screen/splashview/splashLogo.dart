import 'dart:async';
import 'package:demo_distribution/Screen/splashview/splashOne.dart';
import 'package:flutter/material.dart';

import '../../compoents/AppButton.dart';

class SplashLogo extends StatefulWidget {
  const SplashLogo({super.key});

  @override
  State<SplashLogo> createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo> {
  @override
  void initState() {
    super.initState();
    // Auto-navigate after 2 seconds
  }

  void _goNext() {
    // Prevent multiple navigations
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SplashOne()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goNext, // 👈 User can tap anywhere to go next
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const Spacer(),
            Center(
              child: Image.asset(
                "assets/images/logo.jpg",
                width: 180,
                height: 180,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: AppButton(title: "Get Started", press:_goNext, width: 200)
            ),

          ],
        ),
      ),
    );
  }
}
