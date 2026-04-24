// import 'dart:async';
// import 'package:demo_distribution/Screen/splashview/splashOne.dart';
// import 'package:flutter/material.dart';
//
// import '../../compoents/AppButton.dart';
//
// class SplashLogo extends StatefulWidget {
//   const SplashLogo({super.key});
//
//   @override
//   State<SplashLogo> createState() => _SplashLogoState();
// }
//
// class _SplashLogoState extends State<SplashLogo> {
//   @override
//   void initState() {
//     super.initState();
//     // Auto-navigate after 2 seconds
//   }
//
//   void _goNext() {
//     // Prevent multiple navigations
//     if (!mounted) return;
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const SplashOne()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _goNext, // 👈 User can tap anywhere to go next
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Column(
//           children: [
//             const Spacer(),
//             Center(
//               child: Image.asset(
//                 "assets/images/siddiquitd.png",
//                 width: 180,
//                 height: 180,
//               ),
//             ),
//             const Spacer(),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 40),
//               child: AppButton(title: "Get Started", press:_goNext, width: 200)
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:math' as math;
import 'package:demo_distribution/Screen/splashview/splashOne.dart';
import 'package:flutter/material.dart';
import '../../compoents/AppButton.dart';
import '../Auth/LoginScreen.dart';
import '../DashBoardScreen.dart';

class SplashLogo extends StatefulWidget {
  final String? token;
  final bool isFirstTime;
  const SplashLogo({super.key, this.token, this.isFirstTime = false});

  @override
  State<SplashLogo> createState() => _SplashLogoState();
}

class _SplashLogoState extends State<SplashLogo> with TickerProviderStateMixin {
  // ── Controllers ────────────────────────────────────────────────────────────
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;

  // ── Animations ─────────────────────────────────────────────────────────────
  late final Animation<double>  _logoFade;
  late final Animation<double>  _logoScale;
  late final Animation<Offset>  _taglineSlide;
  late final Animation<double>  _taglineFade;
  late final Animation<double>  _buttonFade;
  late final Animation<Offset>  _buttonSlide;
  late final Animation<double>  _pulse;
  late final Animation<double>  _ringRotate;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _logoFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
    ));
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
      ),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.7),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
    ));
    _buttonFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.55, 0.95, curve: Curves.easeOut),
      ),
    );
    _pulse = Tween<double>(begin: 0.88, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _ringRotate = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  // ── Navigation (UPDATED) ─────────────────────────────────────────────────
  void _goNext() {
    if (!mounted) return;

    if (widget.token != null && widget.token!.isNotEmpty) {
      // ✅ If logged in → Dashboard
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const DashboardScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      // ❌ Not logged in
      if (widget.isFirstTime) {
        // First time → Onboarding (SplashOne)
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const SplashOne(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      } else {
        // Not first time → Login Screen
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    }
  }

  // ── Palette (Pure White theme) ─────────────────────────────────────────────
  static const Color _indigo      = Color(0xFF3B5BDB);
  static const Color _indigoLight = Color(0xFF748FFC);
  static const Color _amber       = Color(0xFFF59F00);
  static const Color _textDark    = Color(0xFF1C2340);
  static const Color _textMuted   = Color(0xFF8C98B8);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: _goNext,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // ── Soft background blobs ──────────────────────────────────────
            Positioned.fill(
              child: CustomPaint(painter: _BlobPainter()),
            ),

            // ── Top-right decorative circle ────────────────────────────────
            Positioned(
              top: -size.width * 0.32,
              right: -size.width * 0.22,
              child: Container(
                width: size.width * 0.80,
                height: size.width * 0.80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _indigo.withOpacity(0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Rotating dashed ring ───────────────────────────────────────
            Positioned(
              top: size.height * 0.19,
              left: size.width / 2 - 135,
              child: AnimatedBuilder(
                animation: _ringRotate,
                builder: (_, __) => Transform.rotate(
                  angle: _ringRotate.value,
                  child: SizedBox(
                    width: 270,
                    height: 270,
                    child: CustomPaint(
                      painter: _DashedRingPainter(
                        color: _indigo.withOpacity(0.10),
                        accentColor: _amber.withOpacity(0.35),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Main column ────────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_logoFade, _logoScale, _pulse]),
                    builder: (_, __) => FadeTransition(
                      opacity: _logoFade,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer pulse halo
                              Transform.scale(
                                scale: _pulse.value,
                                child: Container(
                                  width: 230,
                                  height: 230,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        _indigo.withOpacity(0.09),
                                        _indigoLight.withOpacity(0.03),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // White card circle
                              Container(
                                width: 178,
                                height: 178,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: _indigo.withOpacity(0.15),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _indigo.withOpacity(0.13),
                                      blurRadius: 45,
                                      spreadRadius: 4,
                                      offset: const Offset(0, 14),
                                    ),
                                    BoxShadow(
                                      color: _amber.withOpacity(0.08),
                                      blurRadius: 55,
                                      spreadRadius: 8,
                                      offset: const Offset(0, -4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Padding(
                                    padding: const EdgeInsets.all(22),
                                    child: Image.asset(
                                      "assets/images/siddiquitd.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              // Orbit dots
                              ..._orbitDots(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Brand name
                  SlideTransition(
                    position: _taglineSlide,
                    child: FadeTransition(
                      opacity: _taglineFade,
                      child: Column(
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "SIDDIQUI",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: _textDark,
                                    letterSpacing: 5,
                                  ),
                                ),
                                TextSpan(
                                  text: " TD",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: _indigo,
                                    letterSpacing: 5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 1.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      _indigo.withOpacity(0.3),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _amber,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _amber.withOpacity(0.55),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 40,
                                height: 1.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: LinearGradient(
                                    colors: [
                                      _indigo.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "PREMIUM DISTRIBUTION PLATFORM",
                            style: TextStyle(
                              fontSize: 10,
                              color: _textMuted,
                              letterSpacing: 2.8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Get Started button
                  SlideTransition(
                    position: _buttonSlide,
                    child: FadeTransition(
                      opacity: _buttonFade,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 52),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _goNext,
                              child: Container(
                                width: 220,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF3B5BDB),
                                      Color(0xFF4DABF7),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _indigo.withOpacity(0.35),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Get Started",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.22),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              "Tap anywhere to continue",
                              style: TextStyle(
                                color: _textMuted.withOpacity(0.55),
                                fontSize: 11,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  List<Widget> _orbitDots() {
    const r = 100.0;
    final configs = <(double, Color, double)>[
      (0.0,              const Color(0xFFF59F00), 10.0),
      (math.pi / 2,      const Color(0xFF748FFC),  7.0),
      (math.pi,          const Color(0xFF3B5BDB),  8.0),
      (3 * math.pi / 2,  const Color(0xFFFCC419),  6.0),
    ];
    return configs.map((c) {
      final (angle, color, dotSize) = c;
      return Transform.translate(
        offset: Offset(r * math.cos(angle), r * math.sin(angle)),
        child: Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.55),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

// ── Painters ────────────────────────────────────────────────────────────────

class _BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );
    // Top-right indigo haze
    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.06),
      180,
      Paint()
        ..color = const Color(0xFF3B5BDB).withOpacity(0.055)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80),
    );
    // Bottom-left sky haze
    canvas.drawCircle(
      Offset(size.width * 0.06, size.height * 0.93),
      200,
      Paint()
        ..color = const Color(0xFF74C0FC).withOpacity(0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90),
    );
    // Centre amber glow
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.42),
      140,
      Paint()
        ..color = const Color(0xFFF59F00).withOpacity(0.045)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70),
    );
  }

  @override
  bool shouldRepaint(_BlobPainter _) => false;
}

class _DashedRingPainter extends CustomPainter {
  final Color color;
  final Color accentColor;
  _DashedRingPainter({required this.color, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    const dashCount = 28;
    const dashAngle = 2 * math.pi / dashCount;
    final radius = size.width / 2 - 1;
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < dashCount; i++) {
      final isAccent = i % 7 == 0;
      final paint = Paint()
        ..color = isAccent ? accentColor : color
        ..strokeWidth = isAccent ? 2.5 : 1.2
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * dashAngle,
        dashAngle * 0.55,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) =>
      old.color != color || old.accentColor != accentColor;
}