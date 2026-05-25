import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'providers/app_provider.dart';
import 'screens/screens/splashscreen.dart';
import 'constants/app_icons.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// PRECACHE SVGS
  AppIcons.precacheSVGs();

  /// HIVE INIT
  await Hive.initFlutter();
  await Hive.openBox('robo_cache');

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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const RoboCellApp(),
    ),
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

      title: 'Robo Cell',

      theme: AppTheme.darkTheme,

      home:
          const SplashScreen(),
    );
  }
}