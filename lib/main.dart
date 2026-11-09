import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'providers/app_provider.dart';
import 'screens/screens/splashscreen.dart';
import 'constants/app_icons.dart';
import 'constants/app_icon_registry.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Reference icon registry to guarantee icon tree shaking retention in release mode
  const _ = AppIconRegistry.preservedIcons;

  /// PRECACHE SVGS
  AppIcons.precacheSVGs();

  /// HIVE INIT
  await Hive.initFlutter();
  await Hive.openBox('robo_cache');

  /// LOAD ENV (for mobile fallback)
  await dotenv.load(fileName: ".env");

  /// SUPABASE INIT
  const webUrl = String.fromEnvironment('SUPABASE_URL');
  const webKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  final supabaseUrl = webUrl.isNotEmpty ? webUrl : dotenv.env['SUPABASE_URL']!;
  final supabaseKey = webKey.isNotEmpty
      ? webKey
      : dotenv.env['SUPABASE_ANON_KEY']!;

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppProvider())],
      child: const RoboCellApp(),
    ),
  );
}

class RoboCellApp extends StatelessWidget {
  const RoboCellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Robo Cell',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
    );
  }
}
