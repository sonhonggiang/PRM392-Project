import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors defined in specification
  static const Color indigo = Color(0xFF1A2F6E);
  static const Color indigoMid = Color(0xFF2D4DB5);
  static const Color indigoLight = Color(0xFF4B6BDC);
  
  static const Color teal = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFF2DD4BF);
  
  static const Color amber = Color(0xFFF59E0B);
  static const Color red = Color(0xFFDC2626);
  static const Color green = Color(0xFF16A34A);
  
  static const Color bg = Color(0xFFF0F4FF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFFE8EDF8);
  
  static const Color text = Color(0xFF0F1C3F);
  static const Color muted = Color(0xFF6B7DB3);
  static const Color border = Color(0xFFC5D0F0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: indigo,
        primary: indigo,
        secondary: teal,
        tertiary: amber,
        background: bg,
        surface: white,
        error: red,
        onPrimary: white,
        onSecondary: white,
        onSurface: text,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: GoogleFonts.beVietnamProTextTheme().copyWith(
        displayLarge: GoogleFonts.beVietnamPro(color: text, fontWeight: FontWeight.w800),
        displayMedium: GoogleFonts.beVietnamPro(color: text, fontWeight: FontWeight.w700),
        displaySmall: GoogleFonts.beVietnamPro(color: text, fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.beVietnamPro(color: text, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.beVietnamPro(color: text, fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.beVietnamPro(color: text, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.beVietnamPro(color: text, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.beVietnamPro(color: text, fontWeight: FontWeight.w400),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: text),
        titleTextStyle: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 20),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: indigo,
          foregroundColor: white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: indigo, width: 2),
        ),
        hintStyle: const TextStyle(color: muted),
      ),
      cardTheme: CardTheme(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border),
        ),
      ),
    );
  }
}
