import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemeData {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;
  final Color errorColor;

  const AppThemeData({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.errorColor,
  });

  ThemeData get lightTheme => _buildTheme(Brightness.light);
  ThemeData get darkTheme => _buildTheme(Brightness.dark);

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    final surfaceBase = isDark ? const Color(0xFF121212) : surfaceColor;
    final surfaceCard = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final textSubColor = isDark ? Colors.white70 : Colors.black54;
    final cream = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFFFF8E7);
    
    // We adjust secondary for dark mode slightly if it's too bright, but we keep it close.
    // For simplicity, we'll use the provided colors.
    
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: isDark ? Colors.black87 : Colors.black87,
      error: errorColor,
      onError: Colors.white,
      surface: surfaceBase,
      onSurface: textColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceBase,
      textTheme: GoogleFonts.nunitoTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme
      ).copyWith(
        displayLarge: GoogleFonts.nunito(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: textColor),
        displayMedium: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: textColor),
        displaySmall: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: textColor),
        bodyLarge: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
        bodyMedium: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500, color: textSubColor),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceBase,
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.nunito(
          color: isDark ? Colors.white : primaryColor,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : primaryColor),
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
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: isDark ? Colors.black87 : Colors.black87,
        elevation: 8,
        shape: const StadiumBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: isDark ? Colors.black87 : Colors.black87,
          elevation: 4,
          shadowColor: secondaryColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: isDark ? Colors.black87 : Colors.black87,
          elevation: 4,
          shadowColor: secondaryColor.withOpacity(0.4),
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
        labelStyle: TextStyle(color: isDark ? Colors.white70 : primaryColor),
        hintStyle: TextStyle(color: isDark ? Colors.white54 : primaryColor.withOpacity(0.5)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceCard,
        selectedItemColor: primaryColor,
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

class AppThemeManager {
  static const List<AppThemeData> themes = [
    AppThemeData(
      id: 'mintly_default',
      name: 'Mintly Default',
      primaryColor: Color(0xFF2BA8A2),
      secondaryColor: Color(0xFFFFD23F),
      surfaceColor: Color(0xFFEFF8F7),
      errorColor: Color(0xFFE74C3C),
    ),
    AppThemeData(
      id: 'ocean_blue',
      name: 'Ocean Blue',
      primaryColor: Color(0xFF1E88E5),
      secondaryColor: Color(0xFFFFB300),
      surfaceColor: Color(0xFFE3F2FD),
      errorColor: Color(0xFFE53935),
    ),
    AppThemeData(
      id: 'sunset_orange',
      name: 'Sunset Orange',
      primaryColor: Color(0xFFF4511E),
      secondaryColor: Color(0xFFFFCA28),
      surfaceColor: Color(0xFFFBE9E7),
      errorColor: Color(0xFFD32F2F),
    ),
    AppThemeData(
      id: 'forest_green',
      name: 'Forest Green',
      primaryColor: Color(0xFF43A047),
      secondaryColor: Color(0xFFFF9800),
      surfaceColor: Color(0xFFE8F5E9),
      errorColor: Color(0xFFE53935),
    ),
    AppThemeData(
      id: 'purple_haze',
      name: 'Purple Haze',
      primaryColor: Color(0xFF8E24AA),
      secondaryColor: Color(0xFFFDD835),
      surfaceColor: Color(0xFFF3E5F5),
      errorColor: Color(0xFFD32F2F),
    ),
    AppThemeData(
      id: 'rose_pink',
      name: 'Rose Pink',
      primaryColor: Color(0xFFE91E63),
      secondaryColor: Color(0xFF4FC3F7),
      surfaceColor: Color(0xFFFCE4EC),
      errorColor: Color(0xFFD32F2F),
    ),
  ];

  static AppThemeData getTheme(String id) {
    return themes.firstWhere((theme) => theme.id == id, orElse: () => themes.first);
  }
}
