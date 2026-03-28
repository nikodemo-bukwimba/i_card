import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AppColors
///
/// ╔══════════════════════════════════════════════════════════╗
/// ║  🎨  CHANGE ONLY THIS ONE LINE TO RE-BRAND THE APP     ║
/// ╚══════════════════════════════════════════════════════════╝
/// Everything else — light scheme, dark scheme, component tokens — derives
/// automatically from [seed] via Material 3 colour generation.
/// ─────────────────────────────────────────────────────────────────────────────
abstract class AppColors {
  // ═══════════════════════════════════════════════════════════
  static const Color seed = Color(0xFF3C3489); // ← change me
  // ═══════════════════════════════════════════════════════════

  // Complementary accents (can also be swapped independently)
  static const Color seedAccent = Color(0xFF1D9E75);
  static const Color seedGold = Color(0xFFC9A84C);

  // Fixed dark-surface palette (used in always-dark custom widgets)
  static const Color darkSurface = Color(0xFF0E0D1A);
  static const Color darkSurface2 = Color(0xFF1A1828);
  static const Color purpleMid = Color(0xFF7F77DD);
  static const Color textLight = Color(0xFFF0EEFF);
  static const Color textMuted = Color(0xFF9B97C4);

  // WhatsApp / LinkedIn brand colours (never theme-dependent)
  static const Color whatsApp = Color(0xFF25D366);
  static const Color linkedIn = Color(0xFF0A66C2);

  /// Build a full [ColorScheme] for [brightness] seeded from [seed].
  static ColorScheme scheme(Brightness brightness) => ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
      ).copyWith(
        secondary: seedAccent,
        secondaryContainer: seedAccent.withOpacity(0.15),
        onSecondaryContainer: seedAccent,
        tertiary: seedGold,
        tertiaryContainer: seedGold.withOpacity(0.15),
        onTertiaryContainer: seedGold,
      );

  // ── Hex helpers ───────────────────────────────────────────────────────────
  static Color fromHex(String hex) {
    // Strip # and any non-hex characters
    hex = hex.replaceAll('#', '').replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    if (hex.length == 6) hex = 'FF$hex';
    // Ensure exactly 8 chars, pad or truncate
    if (hex.length > 8) hex = hex.substring(hex.length - 8);
    if (hex.length < 8) hex = hex.padLeft(8, 'F');
    return Color(int.parse(hex, radix: 16));
  }

  static String toHex(Color color) =>
      '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
}
