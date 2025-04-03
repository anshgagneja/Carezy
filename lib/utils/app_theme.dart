import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🔹 Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      bodyLarge: GoogleFonts.poppins(color: Colors.black87),
      bodyMedium: GoogleFonts.poppins(color: Colors.black87),
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 4,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        shadowColor: Colors.blueAccent,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.blue.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      labelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.blue.shade700),
      hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.blue.shade300),
    ),
    cardTheme: CardTheme(
      elevation: 6,
      shadowColor: Colors.blue.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 6,
    ),
  );

  // 🔹 Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.deepPurple,
    scaffoldBackgroundColor: Colors.black,
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      bodyLarge: GoogleFonts.poppins(color: Colors.white70),
      bodyMedium: GoogleFonts.poppins(color: Colors.white70),
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      elevation: 4,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        shadowColor: Colors.deepPurpleAccent,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.deepPurple.shade900,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
      ),
      labelStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.deepPurple.shade300),
      hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.deepPurple.shade600),
    ),
    cardTheme: CardTheme(
      elevation: 6,
      shadowColor: Colors.deepPurple.shade700,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      elevation: 6,
    ),
  );
}
