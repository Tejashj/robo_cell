import 'package:flutter/material.dart';
import 'package:robo_cell/screens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController
      controller;

  late Animation<double>
      fadeAnimation;

  final supabase =
      Supabase.instance.client;

  @override
  void initState() {

    super.initState();

    initializeAnimation();

    navigate();
  }

  void initializeAnimation() {

    controller =
        AnimationController(

      vsync: this,

      duration:
          const Duration(
        seconds: 2,
      ),
    );

    fadeAnimation =
        Tween<double>(

      begin: 0,

      end: 1,
    ).animate(

      CurvedAnimation(

        parent: controller,

        curve:
            Curves.easeInOut,
      ),
    );

    controller.forward();
  }

  Future<void> navigate()
  async {

    await Future.delayed(

      const Duration(
        seconds: 3,
      ),
    );

    if (!mounted) return;

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder: (_) {

          return const LoginScreen();
        },
      ),
    );
  }

  @override
  void dispose() {

    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.black,

      body: Center(

        child: FadeTransition(

          opacity:
              fadeAnimation,

          child: Column(

            mainAxisAlignment:
                MainAxisAlignment
                    .center,

            children: [

              /// LOGO
              Container(

                padding:
                    const EdgeInsets.all(
                  20,
                ),

                decoration:
                    BoxDecoration(

                  color:
                      Colors.white
                          .withOpacity(
                    0.03,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    32,
                  ),

                  border: Border.all(
                    color:
                        Colors.white10,
                  ),

                  boxShadow: [

                    BoxShadow(

                      color:
                          const Color(
                        0xFF16A085,
                      ).withOpacity(
                        0.25,
                      ),

                      blurRadius:
                          40,
                    ),
                  ],
                ),

                child: ClipRRect(

                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),

                  child: Image.asset(

                    'assets/rcell.jpg',

                    height: 150,

                    width: 150,

                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              const Text(

                "ROBO CELL",

                style:
                    TextStyle(

                  color:
                      Color(
                    0xFFD8CFB4,
                  ),

                  fontSize: 34,

                  fontWeight:
                      FontWeight.bold,

                  letterSpacing:
                      3,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              const Text(

                "Department of Robotics & Artificial Intelligence",

                textAlign:
                    TextAlign.center,

                style:
                    TextStyle(

                  color:
                      Colors.white70,

                  fontSize: 14,

                  letterSpacing:
                      1,
                ),
              ),

              const SizedBox(
                height: 60,
              ),

              /// LOADER
              Column(

                children: [

                  const SizedBox(

                    height: 26,

                    width: 26,

                    child:
                        CircularProgressIndicator(

                      strokeWidth: 2.5,

                      color:
                          Color(
                        0xFF16A085,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  Text(

                    "Initializing Secure Environment",

                    style:
                        TextStyle(

                      color:
                          Colors.grey
                              .shade500,

                      fontSize: 11,

                      letterSpacing:
                          1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}