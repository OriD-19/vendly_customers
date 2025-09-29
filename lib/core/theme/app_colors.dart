import 'package:flutter/material.dart';

/// App color palette based on Vendly brand colors
class AppColors {
  // Brand Colors - Light Theme
  static const Color persianIndigo = Color(0xFF2E095F);
  static const Color mauve = Color(0xFF9B5FC0);
  static const Color aliceBlue = Color(0xFFF8F9FA);
  static const Color russianViolet = Color(0xFF1D0245);
  static const Color indigo = Color(0xFF461282);

  // Brand Colors - Dark Theme
  static const Color persianIndigoDark = Color(0xFF4A2E8F);
  static const Color mauveDark = Color(0xFFE4B8FF);
  static const Color aliceBlueDark = Color(0xFF1A1A1A);
  static const Color russianVioletDark = Color(0xFF6B4C93);
  static const Color indigoDark = Color(0xFF7B4CB8);

  // Light Theme Colors
  static const Color surfacePrimary = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF1F3F4);
  static const Color surfaceTertiary = Color(0xFFE9ECEF);
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF495057);
  static const Color textTertiary = Color(0xFF6C757D);
  static const Color borderColor = Color(0xFFDEE2E6);
  static const Color borderStrong = Color(0xFFADB5BD);

  // Dark Theme Colors
  static const Color surfacePrimaryDark = Color(0xFF242424);
  static const Color surfaceSecondaryDark = Color(0xFF2D2D2D);
  static const Color surfaceTertiaryDark = Color(0xFF363636);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textTertiaryDark = Color(0xFF808080);
  static const Color borderColorDark = Color(0xFF404040);
  static const Color borderStrongDark = Color(0xFF606060);

  // Interactive States
  static const Color hoverOverlay = Color(0x0D2E095F);
  static const Color hoverSurface = Color(0xFFF8F9FA);
  static const Color focusRing = Color(0xFFCF9AF7);
  static const Color activeState = Color(0x1A2E095F);

  // Status Colors
  static const Color error = Color(0xFFDC3545);
  static const Color errorLight = Color(0xFFF8D7DA);
  static const Color success = Color(0xFF28A745);
  static const Color successLight = Color(0xFFD4EDDA);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF3CD);
  static const Color info = Color(0xFF17A2B8);
  static const Color infoLight = Color(0xFFD1ECF1);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mauve, persianIndigo],
  );

  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
    colors: [Color(0xFFCF9AF7), Color(0xFF9B5FC0)],
  );
}
