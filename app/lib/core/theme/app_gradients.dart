import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppGradients {
  const AppGradients._();

  static LinearGradient pageBackground({required bool isDark}) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0xFF080C10), Color(0xFF0C1118), Color(0xFF0A0F15)]
            : const [Color(0xFFEEF2FF), Color(0xFFF0F7FF), Color(0xFFE8F4F0)],
      );

  static LinearGradient heroCard({required bool isDark}) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0xFF1E1E1E), Color(0xFF121212)]
            : const [Color(0xFF111111), Color(0xFF2A2A2A)],
      );

  static LinearGradient glassFrost({required bool isDark}) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0x18FFFFFF), Color(0x08FFFFFF)]
            : const [Color(0x52FFFFFF), Color(0x2BFFFFFF)],
      );

  static LinearGradient progressRing({required bool isDark}) => LinearGradient(
        colors: isDark
            ? const [AppColors.disciplineEmber, AppColors.disciplineEmberLight]
            : const [AppColors.calmGold, AppColors.calmGoldLight],
      );

  static LinearGradient streakGlow({required bool isDark}) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? const [Color(0x4019C37D), Color(0x0019C37D)]
            : const [Color(0x400F9D6E), Color(0x000F9D6E)],
      );
}
