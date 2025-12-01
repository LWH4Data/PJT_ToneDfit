import 'package:flutter/material.dart';
import '../../shared/styles/tokens.dart';

// Material Theme 정의
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.primaryDark,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppTypography.fontSizeXxxl,
          fontWeight: AppTypography.fontWeightBold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: AppTypography.fontSizeXxl,
          fontWeight: AppTypography.fontWeightBold,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: AppTypography.fontSizeXl,
          fontWeight: AppTypography.fontWeightSemiBold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: AppTypography.fontSizeLg,
          fontWeight: AppTypography.fontWeightSemiBold,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: AppTypography.fontSizeMd,
          fontWeight: AppTypography.fontWeightRegular,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: AppTypography.fontSizeSm,
          fontWeight: AppTypography.fontWeightRegular,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: AppTypography.fontSizeXs,
          fontWeight: AppTypography.fontWeightRegular,
          color: AppColors.textHint,
        ),
      ),
      
      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryDark,
          minimumSize: const Size(AppSizes.buttonWidth, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
          ),
          textStyle: const TextStyle(
            fontSize: AppTypography.fontSizeXl,
            fontWeight: AppTypography.fontWeightSemiBold,
          ),
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.primaryDark,
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
        error: AppColors.error,
      ),
      // Dark theme specific overrides...
    );
  }
}
