import 'package:flutter/material.dart';

const loafOrange = Color(0xFFFF6B35);
const loafSoftOrange = Color(0xFFFF8C5A);
const loafDeepOrange = Color(0xFFD2691E);
const loafPeach = Color(0xFFF4A460);
const loafCream = Color(0xFFFFF4E6);
const loafLightCream = Color(0xFFFFF8DC);
const loafBrown = Color(0xFF5F2B15);
const loafMuted = Color(0xFF8A6B5B);
const loafBorder = Color(0xFFF1D7C5);
const loafSuccess = Color(0xFF2E7D4F);

ThemeData buildLoafTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: loafOrange,
    brightness: Brightness.light,
  ).copyWith(
    primary: loafOrange,
    onPrimary: Colors.white,
    secondary: loafSoftOrange,
    onSecondary: Colors.white,
    tertiary: loafPeach,
    surface: Colors.white,
    onSurface: loafBrown,
    error: const Color(0xFFC2412D),
  );

  final base = ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: loafCream,
    useMaterial3: true,
  );

  final textTheme = base.textTheme.apply(
    bodyColor: loafBrown,
    displayColor: loafBrown,
  );

  return base.copyWith(
    textTheme: textTheme.copyWith(
      headlineMedium:
          textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      headlineSmall:
          textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      labelLarge: textTheme.labelLarge?.copyWith(
        color: loafDeepOrange,
        fontWeight: FontWeight.w800,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: loafCream,
      foregroundColor: loafBrown,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: loafBrown,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(color: loafOrange),
      actionsIconTheme: IconThemeData(color: loafOrange),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: loafBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIconColor: loafSoftOrange,
      hintStyle: const TextStyle(color: loafMuted),
      labelStyle:
          const TextStyle(color: loafMuted, fontWeight: FontWeight.w600),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: loafBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: loafOrange, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.error, width: 1.6),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: loafOrange,
        foregroundColor: Colors.white,
        disabledBackgroundColor: loafBorder,
        disabledForegroundColor: loafMuted,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: loafOrange,
        side: const BorderSide(color: loafOrange),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: loafOrange,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: loafOrange),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colors.white,
      selectedColor: loafOrange,
      disabledColor: loafBorder,
      labelStyle:
          const TextStyle(color: loafBrown, fontWeight: FontWeight.w700),
      secondaryLabelStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      side: const BorderSide(color: loafBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: loafLightCream,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected) ? loafOrange : loafMuted,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w600,
          fontSize: 11,
          height: 1.05,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? loafOrange : loafMuted,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: loafBrown,
      contentTextStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    dividerTheme: const DividerThemeData(color: loafBorder),
  );
}
