import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Mental Health App Color Palette
  static const Color primaryGreen = Color(0xFF56AB2F);
  static const Color lightGreen = Color(0xFFA8E6A3);
  static const Color softBlue = Color(0xFF6BB6FF);
  static const Color lightBlue = Color(0xFFB3D9FF);
  static const Color softPurple = Color(0xFF9B59B6);
  static const Color lightPurple = Color(0xFFD1C4E9);
  static const Color warmGray = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF2C2C2C);
  static const Color textLight = Color(0xFF757575);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2D2D2D);
  static const Color darkText = Color(0xFFE1E1E1);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Roboto',
    
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: softBlue,
      surface: cardBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textDark,
      tertiary: softPurple,
      outline: Color(0xFFE0E0E0),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textDark,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
    ),
    
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textDark, fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: textDark, fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: textDark, fontSize: 24, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: textDark, fontSize: 22, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(color: textDark, fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: primaryGreen, fontSize: 20, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: textLight, fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(color: textLight, fontSize: 14, fontWeight: FontWeight.normal),
      bodySmall: TextStyle(color: textLight, fontSize: 12, fontWeight: FontWeight.normal),
      labelLarge: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryGreen,
      unselectedItemColor: textLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      filled: true,
      fillColor: warmGray,
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: lightGreen,
    scaffoldBackgroundColor: darkBackground,
    fontFamily: 'Roboto',
    
    colorScheme: const ColorScheme.dark(
      primary: lightGreen,
      secondary: lightBlue,
      surface: darkSurface,
      onPrimary: darkBackground,
      onSecondary: darkBackground,
      onSurface: darkText,
      tertiary: lightPurple,
      outline: Color(0xFF404040),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkText,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkText,
      ),
    ),
    
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightGreen,
        foregroundColor: darkBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: darkText, fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: darkText, fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: darkText, fontSize: 24, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: darkText, fontSize: 22, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(color: darkText, fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: darkText, fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: lightGreen, fontSize: 20, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: darkText, fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: darkTextSecondary, fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: darkText, fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(color: darkTextSecondary, fontSize: 14, fontWeight: FontWeight.normal),
      bodySmall: TextStyle(color: darkTextSecondary, fontSize: 12, fontWeight: FontWeight.normal),
      labelLarge: TextStyle(color: darkBackground, fontSize: 16, fontWeight: FontWeight.w600),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: lightGreen,
      unselectedItemColor: darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF404040)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF404040)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightGreen, width: 2),
      ),
      filled: true,
      fillColor: darkSurface,
    ),
  );
  
  // Custom gradients for meditation screens
  static const LinearGradient calmingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softBlue, lightBlue],
  );
  
  static const LinearGradient meditationGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryGreen, lightGreen],
  );
  
  static const LinearGradient sleepGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [softPurple, lightPurple],
  );
}
