import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splashscreen.dart';

void main() => runApp(const RoboCellApp());

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
  
  // CLEANER, MODERN FONT
  textTheme: GoogleFonts.lexendTextTheme(
    ThemeData.dark().textTheme,
  ).copyWith(
    // 2. Customize Lexend specific styles (Headings)
    displayLarge: GoogleFonts.lexend(
      fontWeight: FontWeight.bold, 
      letterSpacing: -0.5,
    ),
    
    // 3. Override specific styles with Roboto (Body/Title)
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