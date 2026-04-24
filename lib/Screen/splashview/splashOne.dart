


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Auth/LoginScreen.dart';
import '../DashBoardScreen.dart';

class AppColors {
  static const Color primary = Color(0xFF5B86E5);
  static const Color secondary = Color(0xFF36D1DC);
  static const Color white = Colors.white;
  static const Color dark = Color(0xFF1C1C2E);
  static const Color textGrey = Color(0xFF8A8A9A);
  static const Color lightGrey = Color(0xFFF4F6FB);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradientSoft = LinearGradient(
    colors: [Color(0xFFE8FAFB), Color(0xFFECF1FD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class SplashOne extends StatefulWidget {
  const SplashOne({super.key});

  @override
  State<SplashOne> createState() => _SplashOneState();
}

class _SplashOneState extends State<SplashOne> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  late AnimationController _contentAnimController;
  late AnimationController _bgShapeController;
  late AnimationController _buttonGlowController;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _bgShapeAnim;
  late Animation<double> _glowAnim;

  final List<Map<String, dynamic>> splashData = [
    {
      "image": "assets/images/splash1.png",
      "label": "DISCOVER",
      "title": "Find Products\nYou Love",
      "subtitle":
      "Discover top-quality products from trusted suppliers — all in one place. Seamless distribution, fast delivery, and the best deals.",
    },
    {
      "image": "assets/images/splash2.png",
      "label": "DELIVERY",
      "title": "Fast &\nReliable Delivery",
      "subtitle":
      "Experience excellence in every order. Our efficient delivery network ensures products arrive fresh, flawless, and right on time.",
    },
    {
      "image": "assets/images/splash3.png",
      "label": "WELCOME",
      "title": "Welcome to\nQuickBit",
      "subtitle":
      "Elevate your shopping experience. Premium selections, seamless ordering, and lightning-fast delivery redefine convenience.",
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _contentAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _bgShapeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _buttonGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(
      parent: _contentAnimController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentAnimController,
      curve: Curves.easeOutCubic,
    ));
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _contentAnimController, curve: Curves.easeOut),
    );
    _bgShapeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bgShapeController, curve: Curves.easeInOut),
    );
    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _buttonGlowController, curve: Curves.easeInOut),
    );

    _contentAnimController.forward();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _contentAnimController.reset();
    _contentAnimController.forward();
  }

  Future<void> _navigateAfterSplash(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    await Future.delayed(const Duration(milliseconds: 400));
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
  void dispose() {
    _contentAnimController.dispose();
    _bgShapeController.dispose();
    _buttonGlowController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackgroundDecor(size),
            Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: splashData.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (ctx, i) => _buildPage(size, splashData[i]),
                  ),
                ),
                _buildBottomBar(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Animated background blobs ──
  Widget _buildBackgroundDecor(Size size) {
    return AnimatedBuilder(
      animation: _bgShapeAnim,
      builder: (_, __) {
        final t = _bgShapeAnim.value;
        return Stack(
          children: [
            // Top-right large soft blob
            Positioned(
              top: -size.width * 0.25 + (t * 14),
              right: -size.width * 0.20,
              child: Container(
                width: size.width * 0.72,
                height: size.width * 0.72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.13),
                      AppColors.secondary.withOpacity(0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            // Bottom-left blob
            Positioned(
              bottom: 90 + (t * 12),
              left: -40,
              child: Container(
                width: size.width * 0.48,
                height: size.width * 0.48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withOpacity(0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Tiny floating dots
            Positioned(
              top: 55 - (t * 8),
              left: 22,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.45),
                ),
              ),
            ),
            Positioned(
              top: 88,
              right: 36 + (t * 7),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(0.35),
                ),
              ),
            ),
            Positioned(
              top: 140 + (t * 5),
              left: 50,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.25),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Top bar ──
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand mark
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 9),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.brandGradient.createShader(bounds),
                child: const Text(
                  "QuickBit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          // Skip button
          GestureDetector(
            onTap: () => _navigateAfterSplash(context),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Skip",
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Splash page content ──
  Widget _buildPage(Size size, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 22),

          // Image with layered glow rings
          ScaleTransition(
            scale: _scaleAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow ring
                    Container(
                      width: size.width * 0.76,
                      height: size.width * 0.76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.brandGradientSoft,
                      ),
                    ),
                    // Inner ring
                    Container(
                      width: size.width * 0.68,
                      height: size.width * 0.68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.08),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    // Image card
                    Container(
                      width: size.width * 0.70,
                      height: size.height * 0.33,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.16),
                            blurRadius: 48,
                            offset: const Offset(0, 18),
                          ),
                          BoxShadow(
                            color: AppColors.secondary.withOpacity(0.10),
                            blurRadius: 24,
                            offset: const Offset(8, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(36),
                        child: Image.asset(
                          data['image'] as String,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    // Gradient border overlay
                    IgnorePointer(
                      child: Container(
                        width: size.width * 0.70,
                        height: size.height * 0.33,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.18),
                              AppColors.secondary.withOpacity(0.08),
                              Colors.transparent,
                              Colors.transparent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: const [0.0, 0.3, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 34),

          // Label chip
          SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.13),
                      AppColors.secondary.withOpacity(0.10),
                    ],
                  ),
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.brandGradient.createShader(bounds),
                  child: Text(
                    data['label'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.2,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Title
          SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Text(
                data['title'] as String,
                style: const TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dark,
                  height: 1.18,
                  letterSpacing: -0.8,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Subtitle
          SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Text(
                data['subtitle'] as String,
                style: const TextStyle(
                  fontSize: 14.5,
                  color: AppColors.textGrey,
                  height: 1.68,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom controls ──
  Widget _buildBottomBar(BuildContext context) {
    final isLast = _currentIndex == splashData.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Dot indicators
          Row(
            children: List.generate(
              splashData.length,
                  (i) => _buildDot(i),
            ),
          ),

          // Animated CTA button
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, child) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(
                        isLast ? 0.38 * _glowAnim.value : 0.22),
                    blurRadius: isLast ? 30 * _glowAnim.value : 14,
                    offset: const Offset(0, 8),
                    spreadRadius: isLast ? 1 * _glowAnim.value : 0,
                  ),
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              child: child,
            ),
            child: GestureDetector(
              onTap: () {
                if (isLast) {
                  _navigateAfterSplash(context);
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                  );
                }
              },
              // ── Use TweenAnimationBuilder so width always stays finite ──
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: isLast ? 54 : 172, end: isLast ? 172 : 54),
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeInOutCubic,
                builder: (context, width, _) {
                  // progress: 0 = icon-only size, 1 = full label size
                  final progress = ((width - 54) / (172 - 54)).clamp(0.0, 1.0);
                  return Container(
                    height: 54,
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(27),
                      gradient: AppColors.brandGradient,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Center(
                      child: progress < 0.5
                      // Show icon while container is still small
                          ? Opacity(
                        opacity: (1.0 - progress * 2).clamp(0.0, 1.0),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      )
                      // Show label once container is wide enough
                          : Opacity(
                        opacity: ((progress - 0.5) * 2).clamp(0.0, 1.0),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Get Started",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(width: 7),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dot indicator ──
  Widget _buildDot(int index) {
    final isActive = _currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      height: 8,
      width: isActive ? 30 : 8,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: isActive ? AppColors.brandGradient : null,
        color: isActive ? null : const Color(0xFFDDE3F0),
      ),
    );
  }
}