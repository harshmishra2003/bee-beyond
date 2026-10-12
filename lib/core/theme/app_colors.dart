import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette - Light Purple / Royal Indigo Theme
  static const Color primary = Color(0xFF4B489B); // Deep Royal Light Purple / Indigo
  static const Color primaryLight = Color(0xFF6A66C4);
  static const Color primaryDark = Color(0xFF383577);

  static const Color secondary = Color(0xFF5B57AF); // Vibrant Indigo Accent
  static const Color secondaryLight = Color(0xFF8884DE);
  static const Color accent = Color(0xFF0288D1); // Soft Blue Accent

  // Premium Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3F3C88), Color(0xFF5551AC), Color(0xFF413E8D)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient button3DGradient = LinearGradient(
    colors: [Color(0xFF5B57AF), Color(0xFF423F8A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardOverlayGradient = LinearGradient(
    colors: [
      Color(0xD9000000),
      Color(0x66000000),
      Color(0x00000000),
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    stops: [0.0, 0.6, 1.0],
  );

  // Neutral Colors
  static const Color background = Color(0xFFF7F7FD); // Crisp Clean Off-White Lavender
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0EFE9);

  // Text Colors
  static const Color textPrimary = Color(0xFF2C2A54);
  static const Color textSecondary = Color(0xFF5E5C7A);
  static const Color textHint = Color(0xFF9E9CBA);

  // Functional Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Border & Divider
  static const Color border = Color(0xFF4B489B); // Deep Purple Outline as shown in reference screenshots
  static const Color borderSubtle = Color(0xFFE4E2F5);
  static const Color divider = Color(0xFFE8E7F2);

  // Card & Badge Colors
  static const Color cardShadow = Color(0x1F4B489B);
  static const Color badgeBg = Color(0xFFECEBFA);
  static const Color badgeText = Color(0xFF4B489B);
}
