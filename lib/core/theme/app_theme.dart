import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Flip7 Design System Colors
  static const Color primaryTeal = Color(0xFF2BA8A2);
  static const Color primaryLight = Color(0xFF3CC4BD);
  static const Color primaryDark = Color(0xFF1E8C86);
  static const Color primaryBg = Color(0xFFE8F6F5);
  
  static const Color accentGold = Color(0xFFFFD23F);
  static const Color accentLight = Color(0xFFFFE47A);
  static const Color accentDark = Color(0xFFE6B800);
  
  static const Color coral = Color(0xFFEF6C4A);
  static const Color coralLight = Color(0xFFFF8A6A);
  static const Color coralDark = Color(0xFFD45233);
  
  static const Color cream = Color(0xFFFFF8E7);
  static const Color skyBlue = Color(0xFF5DADE2);
  
  static const Color surfaceBase = Color(0xFFEFF8F7);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE74C3C);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryTeal,
        secondary: accentGold,
        error: error,
        surface: surfaceBase,
        onPrimary: Colors.white,
        onSecondary: Colors.black87,
        onSurface: Colors.black87,
      ),
      scaffoldBackgroundColor: surfaceBase,
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.nunito(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        displayMedium: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        displaySmall: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        bodyLarge: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
        bodyMedium: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceBase,
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.nunito(
          color: primaryDark,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: primaryDark),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.transparent, width: 0),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentGold,
        foregroundColor: primaryDark,
        elevation: 8,
        shape: StadiumBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: primaryDark,
          elevation: 4,
          shadowColor: accentGold.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: primaryDark,
          elevation: 4,
          shadowColor: accentGold.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: cream,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: const TextStyle(color: primaryDark),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceCard,
        selectedItemColor: primaryTeal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: primaryTeal,
        secondary: accentGold,
        error: error,
        surface: Color(0xFF121212),
        onPrimary: Colors.white,
        onSecondary: Colors.black87,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.nunito(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Colors.white),
        displayMedium: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Colors.white),
        displaySmall: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Colors.white),
        bodyLarge: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        bodyMedium: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF121212),
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E1E1E),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.transparent, width: 0),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentGold,
        foregroundColor: primaryDark,
        elevation: 8,
        shape: StadiumBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: primaryDark,
          elevation: 4,
          shadowColor: accentGold.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: primaryDark,
          elevation: 4,
          shadowColor: accentGold.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: primaryTeal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }
}
