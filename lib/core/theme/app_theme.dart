import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors (Light Warm Theme)
  static const Color primaryColor = Color(0xFFE07A7A); // Soft coral-rose
  static const Color secondaryColor = Color(0xFF5FA8A6); // Soft sage-teal
  static const Color accentColor = Color(
    0xFFE07A7A,
  ); // Using primary as default accent

  static const Color surfaceColor = Color(
    0xFFFFFFFF,
  ); // Pure white for cards/surfaces
  static const Color surfaceSolid = Color(
    0xFFECE8E1,
  ); // Light gray pill/bubbles

  static const Color backgroundColor = Color(0xFFF5F3EE); // Warm neutral base
  static const Color backgroundAlternate = Color(
    0xFFF1EEE8,
  ); // Alternate layered bg

  static const Color dividerColor = Color(0xFFE5E7EB); // Soft gray line

  // Text Colors
  static const Color textPrimary = Color(
    0xFF1F2937,
  ); // Dark gray, no pure black
  static const Color textSecondary = Color(0xFF4B5563); // Mid gray
  static const Color textMuted = Color(0xFF9CA3AF); // Muted gray

  // Intent Colors
  static const Color intentRomantic = Color(0xFFE07A7A); // Soft coral-rose tone
  static const Color intentFriendship = Color(0xFF5FA8A6); // Soft sage-teal
  static const Color intentCollaborate = Color(
    0xFF6B7FD7,
  ); // Academic blue-indigo
  static const Color intentPass = Color(0xFFB8B5AF); // Warm gray

  // Assets
  static const String defaultUserImage = 'lib/images/Intent_logo.png';

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      cardColor: surfaceColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme.copyWith(
          displayLarge: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600, // Headings semi-bold
            letterSpacing: -0.5,
          ),
          titleLarge: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600, // Headings semi-bold
          ),
          titleMedium: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w400, // Body regular
          ),
          bodyMedium: const TextStyle(
            color: textSecondary,
            fontWeight: FontWeight.w400, // Body regular
          ),
          labelLarge: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w500, // Chips medium
            letterSpacing: 0.2, // Slight letter spacing
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // Gradual Reveal Logic Mapping
  static double getRevealBlurLevel(double progress) {
    if (progress >= 1.0) return 0.0; // Stage 2/3: Fully clear
    if (progress >= 0.5) return 0.2; // Stage 1/2: ~20% softness (Increased)
    return 0.8; // Stage 0/1: ~80% softness (Increased from 0.15)
  }
}
