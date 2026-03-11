import 'package:flutter/material.dart';

class AppColors {
  static const Color secondary = Color(0xFF5B86E5); // Blue
  static const Color primary = Color(0xFF36D1DC);   // Cyan
  static const Color text = Color(0xFF1A1A2E);
  static const Color success = Color(0xFF26A69A);
  static const Color instructions = Color(0xFFE53935);
  static const Color btn2 = Color(0xFF2E516C);

  static const List<Color> brandGradient = [secondary, primary];
}

class AppTheme {
  // ── Light backgrounds ──
  static const Color bg      = Color(0xFFF4F6FB); // page bg — light grey-blue
  static const Color surface = Color(0xFFFFFFFF); // sidebar / topbar — pure white
  static const Color card    = Color(0xFFFFFFFF); // card bg — white
  static const Color border  = Color(0xFFE4E9F2); // subtle border

  // ── Brand ──
  static const Color primary   = AppColors.primary;
  static const Color secondary = AppColors.secondary;
  static const Color green     = Color(0xFF26A69A);
  static const Color red       = Color(0xFFE53935);
  static const Color orange    = Color(0xFFFB8C00);
  static const Color purple    = Color(0xFF7C6FCD);

  // ── Text ──
  static const Color textPrimary   = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textMuted     = Color(0xFF94A3B8);
  static const Color textDim       = Color(0xFFCBD5E1);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      onSurface: textPrimary,
    ),
    dividerColor: border,
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [AppColors.secondary, AppColors.primary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient brandGradientVertical = LinearGradient(
    colors: [AppColors.secondary, AppColors.primary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static Color typeColor(String type) {
    switch (type) {
      case 'Sale':        return primary;
      case 'Purchase':    return orange;
      case 'Payment In':  return secondary;
      case 'Payment Out': return red;
      case 'Recovery':    return green;
      default:            return textSecondary;
    }
  }

  static String typeIcon(String type) {
    switch (type) {
      case 'Sale':        return '↑';
      case 'Purchase':    return '↓';
      case 'Payment In':  return '↙';
      case 'Payment Out': return '↗';
      case 'Recovery':    return '⟳';
      default:            return '•';
    }
  }
}