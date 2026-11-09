import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/biometric_service.dart';
import '../../services/security_service.dart';
import '../../theme/design_system.dart';
import '../../navigation.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bgFade;
  late Animation<double> _logoScale;
  late Animation<double> _glowPulse;
  late Animation<double> _roboFade;
  late Animation<double> _roboSlide;
  late Animation<double> _cellFade;
  late Animation<double> _cellSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _taglineSlide;

  final BiometricService _biometricService = BiometricService();
  final SecurityService _securityService = SecurityService();
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    initializeAnimations();
    _securityService.initialize();
    _startParallelStartup();
  }

  void initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 1. Background Grid Fade
    _bgFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    // 2. Logo Scale & Glow Pulse
    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    _glowPulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.65, curve: Curves.easeInOut),
      ),
    );

    // 3. Staggered Word Reveal: "ROBO" (First)
    _roboSlide = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _roboFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.50, curve: Curves.easeOut),
      ),
    );

    // 4. Staggered Word Reveal: "CELL" (Second)
    _cellSlide = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    _cellFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.65, curve: Curves.easeOut),
      ),
    );

    // 5. Staggered Tagline Badge Reveal (Third)
    _taglineSlide = Tween<double>(begin: 14.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.80, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  Future<void> _startParallelStartup() async {
    final startTime = DateTime.now();
    const minimumSplashDuration = Duration(milliseconds: 1200);

    Future<void> ensureMinimumSplashTime() async {
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed < minimumSplashDuration) {
        await Future.delayed(minimumSplashDuration - elapsed);
      }
    }

    void goLogin() {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          opaque: false,
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, __) =>
              FadeTransition(opacity: animation, child: const LoginScreen()),
          transitionsBuilder: (_, animation, __, child) => Stack(
            children: [
              FadeTransition(
                opacity: Tween<double>(begin: 1, end: 0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 8 * animation.value,
                    sigmaY: 8 * animation.value,
                  ),
                  child: Container(color: AppColors.background),
                ),
              ),
              FadeTransition(opacity: animation, child: child),
            ],
          ),
        ),
      );
    }

    void goMain(dynamic user) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          opaque: false,
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: MainNavigation(user: Map<String, dynamic>.from(user)),
          ),
          transitionsBuilder: (_, animation, __, child) => Stack(
            children: [
              FadeTransition(
                opacity: Tween<double>(begin: 1, end: 0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 8 * animation.value,
                    sigmaY: 8 * animation.value,
                  ),
                  child: Container(color: AppColors.background),
                ),
              ),
              FadeTransition(opacity: animation, child: child),
            ],
          ),
        ),
      );
    }

    // Concurrently start biometric status check and auth session check
    final biometricEnabledFuture = _biometricService.isBiometricEnabled();
    final session = supabase.auth.currentSession;

    // 1. Authoritative Supabase Auth session check
    if (session == null || session.isExpired) {
      await ensureMinimumSplashTime();
      goLogin();
      return;
    }

    // 2. Profile Cache Fast Path: Check Hive cache first
    final box = Hive.box('robo_cache');
    final cachedProfile = box.get('logged_in_user');
    Map<String, dynamic>? userProfile;

    if (cachedProfile != null) {
      userProfile = Map<String, dynamic>.from(cachedProfile as Map);

      // Asynchronously refresh profile in background without delaying splash navigation
      supabase
          .rpc('get_current_user_profile')
          .then((updatedProfile) {
            if (updatedProfile != null) {
              box.put(
                'logged_in_user',
                Map<String, dynamic>.from(updatedProfile as Map),
              );
            }
          })
          .catchError((_) {});
    } else {
      // Profile Cache Miss: fetch via RPC with fast-path budget (1200ms timeout)
      try {
        final authUser = supabase.auth.currentUser;
        if (authUser == null) {
          await ensureMinimumSplashTime();
          goLogin();
          return;
        }

        final profileData = await supabase
            .rpc('get_current_user_profile')
            .timeout(
              const Duration(milliseconds: 1200),
              onTimeout: () {
                return null;
              },
            );

        if (profileData == null) {
          await ensureMinimumSplashTime();
          goLogin();
          return;
        }

        userProfile = Map<String, dynamic>.from(profileData as Map);
        box.put('logged_in_user', userProfile);
      } catch (_) {
        await ensureMinimumSplashTime();
        goLogin();
        return;
      }
    }

    final biometricEnabled = await biometricEnabledFuture;

    await ensureMinimumSplashTime();

    if (!biometricEnabled) {
      goMain(userProfile);
      return;
    }

    try {
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Verify your identity to access Robo Cell',
      );
      if (authenticated) {
        goMain(userProfile);
      } else {
        goLogin();
      }
    } catch (_) {
      goLogin();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const neon = AppColors.primaryCyan;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Technical HUD Background Grid
          AnimatedBuilder(
            animation: _bgFade,
            builder: (context, child) {
              return Opacity(
                opacity: _bgFade.value,
                child: CustomPaint(
                  size: size,
                  painter: CleanHudPainter(color: neon),
                ),
              );
            },
          ),

          // 2. Ambient Radial Glowing Orbs (Matching About Page Style)
          Positioned(
            top: -120,
            right: -60,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [neon.withValues(alpha: 0.16), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondaryTeal.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Center Hero Logo & Staggered Word Reveal
          Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hero Logo Container with Dual-Layered Glowing Aura
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final glowVal = _glowPulse.value;

                        return Hero(
                          tag: "rcell_logo",
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Container(
                              width: 148,
                              height: 148,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surface,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  // Inner Core Cyan Glow
                                  BoxShadow(
                                    color: neon.withValues(
                                      alpha: 0.35 + (0.15 * glowVal),
                                    ),
                                    blurRadius: 36 + (12 * glowVal),
                                    spreadRadius: 2,
                                  ),
                                  // Outer Secondary Teal Ambient Aura Glow
                                  BoxShadow(
                                    color: AppColors.secondaryTeal.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 60,
                                    spreadRadius: 6,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/rcell.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 36),

                    // Staggered Title Reveal ("ROBO" -> "CELL")
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // First Word: "ROBO"
                                Opacity(
                                  opacity: _roboFade.value,
                                  child: Transform.translate(
                                    offset: Offset(0, _roboSlide.value),
                                    child: const Text(
                                      "ROBO",
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 7,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Second Word: "CELL"
                                Opacity(
                                  opacity: _cellFade.value,
                                  child: Transform.translate(
                                    offset: Offset(0, _cellSlide.value),
                                    child: Text(
                                      "CELL",
                                      style: TextStyle(
                                        color: neon,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 7,
                                        shadows: [
                                          Shadow(
                                            color: neon.withValues(alpha: 0.45),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Tagline Badge Reveal (Third)
                            Opacity(
                              opacity: _taglineFade.value,
                              child: Transform.translate(
                                offset: Offset(0, _taglineSlide.value),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated.withValues(
                                      alpha: 0.85,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: neon.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: neon,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: neon,
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "TECH • TRANSFORM • THRIVE",
                                        style: TextStyle(
                                          color: neon,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 2.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Clean Footer Information
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Opacity(
                opacity: 0.4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 14, height: 1, color: AppColors.textMuted),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "© 2026 ROBO CELL",
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 8.5,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                    Container(width: 14, height: 1, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter rendering a clean technical HUD grid & corner brackets
class CleanHudPainter extends CustomPainter {
  final Color color;

  CleanHudPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.035)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final bracketPaint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // 1. Grid Lines (44px grid spacing)
    const double step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Corner HUD Brackets
    const double bracketSize = 20.0;
    const double margin = 28.0;

    // Top-Left Bracket
    canvas.drawLine(
      const Offset(margin, margin),
      const Offset(margin + bracketSize, margin),
      bracketPaint,
    );
    canvas.drawLine(
      const Offset(margin, margin),
      const Offset(margin, margin + bracketSize),
      bracketPaint,
    );

    // Top-Right Bracket
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(size.width - margin - bracketSize, margin),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(size.width - margin, margin + bracketSize),
      bracketPaint,
    );

    // Bottom-Left Bracket
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(margin + bracketSize, size.height - margin),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(margin, size.height - margin - bracketSize),
      bracketPaint,
    );

    // Bottom-Right Bracket
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin),
      Offset(size.width - margin - bracketSize, size.height - margin),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin),
      Offset(size.width - margin, size.height - margin - bracketSize),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
