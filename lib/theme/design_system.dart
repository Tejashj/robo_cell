import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central Design System tokens for Robo Cell v2.0
class AppColors {
  // Strict Core Palette
  static const Color background = Colors.black;
  static const Color surface = Color(0xFF121214);
  static const Color surfaceElevated = Color(0xFF1A1A1E);
  static const Color surfaceGlass = Color(0x0DFFFFFF);

  // Brand Accents
  static const Color primaryEmerald = Color(0xFF16A085);
  static const Color primaryCyan = Color(0xFF16A085);
  static const Color secondaryTeal = Color(0xFF1ABC9C);
  static const Color headingGold = Color(0xFFD8CFB4);
  static const Color accentGold = Color(0xFFD8CFB4);
  static const Color accentPurple = Color(0xFF16A085);

  // Neutral Text Tokens
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B8);
  static const Color textMuted = Color(0xFF71717A);

  // Borders & Glow
  static const Color borderSubtle = Color(0x1FFFFFFF);
  static const Color borderGlow = Color(0x3316A085);

  // Status Colors
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);

  // Gradient & Glow Helper Aliases
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryEmerald, secondaryTeal],
  );

  static List<BoxShadow> get glowCyan => AppShadows.primaryGlow;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;

  static const double buttonHeight = 54.0;
  static const double minTouchTarget = 48.0;
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 18.0;
  static const double xl = 24.0;

  static const double card = 18.0;
  static const double button = 18.0;
  static const double input = 14.0;
  static const double sheet = 24.0;
  static const double chip = 8.0;
  static const double circular = 999.0;
}

class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
}

class AppCurves {
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
}

class AppShadows {
  static List<BoxShadow> get cardElevation => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: AppColors.primaryEmerald.withValues(alpha: 0.25),
      blurRadius: 16,
      spreadRadius: 1,
    ),
  ];
}

class AppTypography {
  static TextStyle get display => GoogleFonts.poppins(
    color: AppColors.headingGold,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  static TextStyle get heading => GoogleFonts.poppins(
    color: AppColors.headingGold,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.8,
  );

  static TextStyle get title => GoogleFonts.poppins(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get body => GoogleFonts.poppins(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get caption => GoogleFonts.poppins(
    color: AppColors.textMuted,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get button => GoogleFonts.poppins(
    color: Colors.black,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );
}
