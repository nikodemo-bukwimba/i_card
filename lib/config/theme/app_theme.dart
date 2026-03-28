import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Material 3 theme — both modes derive every token from [AppColors.seed].
/// Change the seed → entire app re-brands automatically.
abstract class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark  => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final s = AppColors.scheme(brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: s,
      textTheme: _textTheme(s),
      inputDecorationTheme: _inputTheme(s),
      filledButtonTheme: _filledBtn(),
      outlinedButtonTheme: _outlinedBtn(),
      textButtonTheme: _textBtn(),
      cardTheme: _card(s),
      appBarTheme: _appBar(s),
      dividerTheme: DividerThemeData(
        color: s.outlineVariant,
        thickness: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme s) => TextTheme(
    displayLarge:  TextStyle(color: s.onSurface, fontWeight: FontWeight.w700),
    displayMedium: TextStyle(color: s.onSurface, fontWeight: FontWeight.w700),
    headlineLarge: TextStyle(color: s.onSurface, fontWeight: FontWeight.w700),
    headlineMedium:TextStyle(color: s.onSurface, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(color: s.onSurface, fontWeight: FontWeight.w600),
    titleLarge:    TextStyle(color: s.onSurface, fontWeight: FontWeight.w600),
    titleMedium:   TextStyle(color: s.onSurface, fontWeight: FontWeight.w500),
    titleSmall:    TextStyle(color: s.onSurfaceVariant, fontWeight: FontWeight.w500),
    bodyLarge:     TextStyle(color: s.onSurface),
    bodyMedium:    TextStyle(color: s.onSurface),
    bodySmall:     TextStyle(color: s.onSurfaceVariant),
    labelLarge:    TextStyle(color: s.onSurface, fontWeight: FontWeight.w600),
    labelMedium:   TextStyle(color: s.onSurfaceVariant),
    labelSmall:    TextStyle(color: s.onSurfaceVariant, letterSpacing: 1.2),
  );

  static InputDecorationTheme _inputTheme(ColorScheme s) =>
      InputDecorationTheme(
        filled: true,
        fillColor: s.surfaceContainerHighest,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: s.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: s.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: s.error, width: 1.5),
        ),
        labelStyle: TextStyle(color: s.onSurfaceVariant),
        hintStyle: TextStyle(color: s.onSurfaceVariant.withOpacity(0.6)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );

  static FilledButtonThemeData _filledBtn() => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
  );

  static OutlinedButtonThemeData _outlinedBtn() =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );

  static TextButtonThemeData _textBtn() => TextButtonThemeData(
    style: TextButton.styleFrom(
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  );

  static CardThemeData _card(ColorScheme s) => CardThemeData(
    elevation: 0,
    color: s.surfaceContainerLow,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: s.outlineVariant.withOpacity(0.5)),
    ),
    margin: EdgeInsets.zero,
  );

  static AppBarTheme _appBar(ColorScheme s) => AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 1,
    backgroundColor: s.surface,
    foregroundColor: s.onSurface,
    surfaceTintColor: s.surfaceTint,
  );
}

/// Responsive breakpoints helper.
abstract class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= 600 && w < 960;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 960;

  static double formMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 440;
    if (isTablet(context))  return 480;
    return double.infinity;
  }
}