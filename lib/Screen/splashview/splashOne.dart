// import 'package:distribution/Screen/DashBoardScreen.dart';
// import 'package:flutter/material.dart';
// // Import your dashboard screen file
//
// class SplashOne extends StatefulWidget {
//   const SplashOne({super.key});
//
//   @override
//   State<SplashOne> createState() => _SplashOneState();
// }
//
// class _SplashOneState extends State<SplashOne> {
//   final PageController _pageController = PageController();
//   int _currentIndex = 0;
//
//   final List<Map<String, String>> splashData = [
//     {
//       "image": "assets/images/splash1.png",
//       "title": "Find Products You Love",
//       "subtitle":
//       "Discover top-quality products from trusted suppliers—all in one place. Enjoy seamless distribution with fast delivery, reliable partners, and the best deals on every order."
//     },
//     {
//       "image": "assets/images/splash2.png",
//       "title": "Fast Delivery",
//       "subtitle":
//       "Experience the art of excellence in every order. Our fast and efficient delivery network ensures your order reaches you fresh, flawless, and on time."
//     },
//     {
//       "image": "assets/images/splash3.png",
//       "title": "Welcome to QuickBit",
//       "subtitle":
//       "Elevate your shopping experience. Discover premium selections, seamless ordering, and lightning-fast delivery that redefine convenience."
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: PageView.builder(
//                 controller: _pageController,
//                 itemCount: splashData.length,
//                 onPageChanged: (index) {
//                   setState(() {
//                     _currentIndex = index;
//                   });
//                 },
//                 itemBuilder: (context, index) => buildSplashContent(
//                   image: splashData[index]['image']!,
//                   title: splashData[index]['title']!,
//                   subtitle: splashData[index]['subtitle']!,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                   splashData.length,
//                       (index) => buildDot(index: index),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (_) => const Dashboardscreen()),
//                       );
//                     },
//                     child: const Text(
//                       "Skip",
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 30, vertical: 12),
//                     ),
//                     onPressed: () {
//                       if (_currentIndex == splashData.length - 1) {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (_) => const Dashboardscreen()),
//                         );
//                       } else {
//                         _pageController.nextPage(
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.easeIn,
//                         );
//                       }
//                     },
//                     child: Text(
//                       _currentIndex == splashData.length - 1
//                           ? "Get Started"
//                           : "Next",
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildSplashContent({
//     required String image,
//     required String title,
//     required String subtitle,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//       child: Column(
//         children: [
//           const SizedBox(height: 50),
//           Image.asset(image, height: 350),
//           const SizedBox(height: 30),
//           Text(
//             title,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(height: 15),
//           Text(
//             subtitle,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 15,
//               color: Colors.grey,
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildDot({required int index}) {
//     return Container(
//       height: 8,
//       width: _currentIndex == index ? 20 : 8,
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       decoration: BoxDecoration(
//         color: _currentIndex == index ? Colors.blue : Colors.grey.shade400,
//         borderRadius: BorderRadius.circular(4),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Auth/LoginScreen.dart';
import '../DashBoardScreen.dart';

class SplashOne extends StatefulWidget {
  const SplashOne({super.key});

  @override
  State<SplashOne> createState() => _SplashOneState();
}

class _SplashOneState extends State<SplashOne> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> splashData = [
    {
      "image": "assets/images/splash1.png",
      "title": "Find Products You Love",
      "subtitle":
      "Discover top-quality products from trusted suppliers—all in one place. Enjoy seamless distribution with fast delivery, reliable partners, and the best deals on every order."
    },
    {
      "image": "assets/images/splash2.png",
      "title": "Fast Delivery",
      "subtitle":
      "Experience the art of excellence in every order. Our fast and efficient delivery network ensures your order reaches you fresh, flawless, and on time."
    },
    {
      "image": "assets/images/splash3.png",
      "title": "Welcome to QuickBit",
      "subtitle":
      "Elevate your shopping experience. Discover premium selections, seamless ordering, and lightning-fast delivery that redefine convenience."
    },
  ];

  // ✅ Move token check here (only after pressing Get Started)
  Future<void> _navigateAfterSplash(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Add a small delay for smoother transition
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: splashData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) => buildSplashContent(
                  image: splashData[index]['image']!,
                  title: splashData[index]['title']!,
                  subtitle: splashData[index]['subtitle']!,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  splashData.length,
                      (index) => buildDot(index: index),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🩶 Skip → directly to Login
                  TextButton(
                    onPressed: () {
                      _navigateAfterSplash(context);
                    },
                    child: const Text(
                      "Skip",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                  // 🖤 Next / Get Started
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      if (_currentIndex == splashData.length - 1) {
                        // ✅ When on last screen → check token & navigate
                        _navigateAfterSplash(context);
                      } else {
                        // Move to next splash page
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    child: Text(
                      _currentIndex == splashData.length - 1
                          ? "Get Started"
                          : "Next",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSplashContent({
    required String image,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Image.asset(image, height: 350),
          const SizedBox(height: 30),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: _currentIndex == index ? 20 : 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: _currentIndex == index ? Colors.blue : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
