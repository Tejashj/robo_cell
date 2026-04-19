import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔐 Load ENV
  await dotenv.load(fileName: ".env");

  // 🔥 Initialize Firebase
  await Firebase.initializeApp();

  // 🚀 Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const RoboCellApp());
}

class RoboCellApp extends StatelessWidget {
  const RoboCellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF16A085),
        hintColor: const Color(0xFFD8CFB4),

        // 🔤 Fonts
        textTheme: GoogleFonts.lexendTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          titleLarge: GoogleFonts.lexend(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          bodyMedium: GoogleFonts.lexend(
            fontWeight: FontWeight.w400,
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Color(0xFFD8CFB4),
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 1.2,
            color: Color(0xFFD8CFB4),
          ),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}