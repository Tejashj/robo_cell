import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/screens/splashscreen.dart';

Future<void> main() async {

  WidgetsFlutterBinding
      .ensureInitialized();

  /// LOAD ENV
  await dotenv.load(
    fileName: ".env",
  );

  /// SUPABASE INIT
  await Supabase.initialize(

    url:
        dotenv.env[
            'SUPABASE_URL']!,

    anonKey:
        dotenv.env[
            'SUPABASE_ANON_KEY']!,
  );

  runApp(
    const RoboCellApp(),
  );
}

class RoboCellApp
    extends StatelessWidget {

  const RoboCellApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner:
          false,

      title: 'ROBO CELL',

      theme: ThemeData(

        brightness:
            Brightness.dark,

        scaffoldBackgroundColor:
            Colors.black,

        primaryColor:
            const Color(
          0xFF16A085,
        ),

        textTheme:
            GoogleFonts.poppinsTextTheme(
          ThemeData.dark()
              .textTheme,
        ),

        appBarTheme:
            const AppBarTheme(

          backgroundColor:
              Colors.black,

          elevation: 0,

          centerTitle: true,

          foregroundColor:
              Color(
            0xFFD8CFB4,
          ),
        ),

        snackBarTheme:
            const SnackBarThemeData(

          backgroundColor:
              Color(
            0xFF16A085,
          ),

          contentTextStyle:
              TextStyle(
            color: Colors.black,
          ),
        ),

        elevatedButtonTheme:
            ElevatedButtonThemeData(

          style:
              ElevatedButton.styleFrom(

            backgroundColor:
                const Color(
              0xFF16A085,
            ),

            foregroundColor:
                Colors.black,

            elevation: 0,

            shape:
                RoundedRectangleBorder(

              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
          ),
        ),

        inputDecorationTheme:
            InputDecorationTheme(

          filled: true,

          fillColor:
              Colors.white
                  .withOpacity(
            0.03,
          ),

          hintStyle:
              const TextStyle(
            color: Colors.grey,
          ),

          border:
              OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(
              18,
            ),

            borderSide:
                BorderSide.none,
          ),

          enabledBorder:
              OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(
              18,
            ),

            borderSide:
                BorderSide.none,
          ),

          focusedBorder:
              OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(
              18,
            ),

            borderSide:
                const BorderSide(

              color:
                  Color(
                0xFF16A085,
              ),
            ),
          ),
        ),

        bottomNavigationBarTheme:
            BottomNavigationBarThemeData(

          backgroundColor:
              Colors.black,

          selectedItemColor:
              const Color(
            0xFF16A085,
          ),

          unselectedItemColor:
              Colors.grey.shade600,

          selectedLabelStyle:
              const TextStyle(

            fontWeight:
                FontWeight.bold,

            fontSize: 11,
          ),

          unselectedLabelStyle:
              const TextStyle(
            fontSize: 10,
          ),
        ),
      ),

      home:
          const SplashScreen(),
    );
  }
}