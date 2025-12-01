import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// MediRemind Theme Configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.pureWhite,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlack,
        onPrimary: AppColors.pureWhite,
        surface: AppColors.pureWhite,
        onSurface: AppColors.primaryBlack,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        // Heading 1: 32px, weight 800
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          height: 1.2,
          color: AppColors.primaryBlack,
        ),
        // Heading 2: 24px, weight 700
        displayMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.3,
          color: AppColors.primaryBlack,
        ),
        // Heading 3: 20px, weight 700
        displaySmall: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.4,
          color: AppColors.primaryBlack,
        ),
        // Body Large: 16px, weight 400
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.primaryBlack,
        ),
        // Body: 14px, weight 400
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.primaryBlack,
        ),
        // Small: 12px, weight 400
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.primaryBlack,
        ),
        // Label: 12px, weight 600
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: AppColors.primaryBlack,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.primaryBlack,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryBlack,
        ),
      ),
    );
  }

  // Prevent instantiation
  AppTheme._();
}
