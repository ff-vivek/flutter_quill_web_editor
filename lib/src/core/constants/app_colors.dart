import 'package:flutter/material.dart';

/// Color palette for the Quill Web Editor package.
///
/// All colors used throughout the editor are defined here for consistency
/// and easy customization.
abstract class AppColors {
  // Primary accent color
  static const Color accent = Color(0xFFC45D35);
  static const Color accentHover = Color(0xFFA84D2B);
  static const Color accentLight = Color(0x1AC45D35); // 10% opacity

  // Text colors
  static const Color textPrimary = Color(0xFF2C2825);
  static const Color textSecondary = Color(0xFF6B6560);
  static const Color textMuted = Color(0xFF9A948E);

  // Background colors
  static const Color background = Color(0xFFF8F6F3);
  static const Color backgroundAlt = Color(0xFFEFEAE4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceHover = Color(0xFFFAF9F8);

  // Border colors
  static const Color border = Color(0xFFE5E0DA);
  static const Color borderLight = Color(0xFFF0EBE5);

  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFE57C23);
  static const Color error = Color(0xFFEF4444);

  // Editor specific
  static const Color blockquoteBorder = accent;
  static const Color linkColor = accent;
  static const Color codeBackground = Color(0xFFF0F0F0);
  static const Color preBackground = background;

  /// Creates a color with the specified opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}

