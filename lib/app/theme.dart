import 'package:flutter/material.dart';

class AppColors {
  // 品牌色
  static const primary    = Color(0xFF5B5FEF);
  static const accent     = Color(0xFF8B5CF6);
  static const gradient1  = Color(0xFF5B5FEF);
  static const gradient2  = Color(0xFF8B5CF6);

  // 语义色
  static const success    = Color(0xFF10B981);
  static const warning    = Color(0xFFF59E0B);
  static const error      = Color(0xFFEF4444);
  static const info       = Color(0xFF3B82F6);

  // 内容类型
  static const whiteboard = Color(0xFF3B82F6);  // 蓝
  static const card       = Color(0xFFF59E0B);  // 橙
  static const document   = Color(0xFF10B981);  // 绿
  static const receipt    = Color(0xFF8B5CF6);  // 紫
  static const menu       = Color(0xFFEF4444);  // 红

  // 中性色（Light）
  static const background = Color(0xFFF8F8FF);
  static const surface    = Color(0xFFFFFFFF);
  static const border     = Color(0xFFE5E7EB);
  static const textPrimary   = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary  = Color(0xFF9CA3AF);

  // 中性色（Dark）
  static const darkBg      = Color(0xFF0C0C18);
  static const darkSurface = Color(0xFF12121F);
  static const darkBorder  = Color(0xFF1E1E30);
  static const darkText    = Color(0xFFE5E7EB);
}

class AppGradients {
  static const primary = LinearGradient(
    colors: [AppColors.gradient1, AppColors.gradient2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const hero = LinearGradient(
    colors: [Color(0xFF0C0C18), Color(0xFF1A0F2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.surface,
      background: AppColors.background,
    ),
    fontFamily: 'SF Pro Display',
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
      background: AppColors.darkBg,
    ),
    fontFamily: 'SF Pro Display',
    scaffoldBackgroundColor: AppColors.darkBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.darkText),
      titleTextStyle: TextStyle(
        color: AppColors.darkText,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
    ),
  );
}
