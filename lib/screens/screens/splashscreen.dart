import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
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
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    initializeAnimations();
  }

  void initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.82, end: 1.06).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _rotationAnimation = Tween<double>(begin: -0.08, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _blurAnimation = Tween<double>(begin: 14, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 3300), () {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 800));
        await _authenticate();
      });
    });
  }

  Future<void> _authenticate() async {
    if (!mounted) return;
    HapticFeedback.mediumImpact();

    final box = Hive.box('robo_cache');
    final cachedUser = box.get('logged_in_user');
    final biometricEnabled = box.get('biometric_enabled') ?? false;

    void goLogin() {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          opaque: false,
          transitionDuration: const Duration(milliseconds: 1200),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: const LoginScreen(),
          ),
          transitionsBuilder: (_, animation, __, child) => Stack(
            children: [
              FadeTransition(
                opacity: Tween<double>(begin: 1, end: 0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12 * animation.value, sigmaY: 12 * animation.value),
                  child: Container(color: Colors.black),
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
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          opaque: false,
          transitionDuration: const Duration(milliseconds: 1200),
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
                  filter: ImageFilter.blur(sigmaX: 12 * animation.value, sigmaY: 12 * animation.value),
                  child: Container(color: Colors.black),
                ),
              ),
              FadeTransition(opacity: animation, child: child),
            ],
          ),
        ),
      );
    }

    if (cachedUser == null) {
      goLogin();
      return;
    }

    if (!biometricEnabled) {
      await box.delete('logged_in_user');
      await box.delete('biometric_enabled');
      goLogin();
      return;
    }

    final localAuth = LocalAuthentication();
    try {
      final authenticated = await localAuth.authenticate(
        localizedReason: 'Verify your identity to access Robo Cell',
        biometricOnly: false, // allows PIN/pattern fallback
      );
      if (authenticated) {
        goMain(cachedUser);
      } else {
        await box.delete('logged_in_user');
        await box.delete('biometric_enabled');
        goLogin();
      }
    } catch (e) {
      debugPrint('Auth error: $e');
      await box.delete('logged_in_user');
      await box.delete('biometric_enabled');
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
    const neon = Color(0xFF16A085);
    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      body: Stack(
        children: [
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [neon.withOpacity(0.22), Colors.transparent]),
              ),
            ),
          ),
          Positioned(
            bottom: -180,
            left: -120,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Colors.blueGrey.withOpacity(0.22), Colors.transparent]),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.02,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=100&auto=format&fit=crop'),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: _blurAnimation.value, sigmaY: _blurAnimation.value),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                              tag: "rcell_logo",
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 220,
                                    height: 220,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: neon.withOpacity(0.1), width: 1),
                                    ),
                                  ),
                                  RotationTransition(
                                    turns: Tween<double>(begin: 0, end: 0.08).animate(
                                      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
                                    ),
                                    child: Container(
                                      width: 190,
                                      height: 190,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: neon.withOpacity(0.18), width: 2),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF0B0B0B),
                                      border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: neon.withOpacity(0.28),
                                          blurRadius: 40,
                                          spreadRadius: -5,
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.asset('assets/rcell.jpg', fit: BoxFit.cover),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 50),
                            const Text(
                              "ROBO CELL",
                              style: TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 10,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: neon.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: neon.withOpacity(0.18)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: neon, shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "TECH TRANSFORM THRIVE",
                                    style: TextStyle(
                                      color: neon,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Opacity(
                opacity: 0.3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 16, height: 1, color: Colors.white),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("© 2026 ROBO CELL", style: TextStyle(color: Colors.white, fontSize: 8, letterSpacing: 3)),
                    ),
                    Container(width: 16, height: 1, color: Colors.white),
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