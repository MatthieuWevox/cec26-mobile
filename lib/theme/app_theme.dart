import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF272262);
  static const Color primaryLight = Color(0xFF403A86);
  static const Color primaryDark = Color(0xFF17143E);
  static const Color accentColor = Color(0xFF5CC7CF);
  static const Color accentDark = Color(0xFF168D99);
  static const Color accentSoft = Color(0xFFE8F8FA);

  static const Color backgroundLight = Color(0xFFF6F7FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF0F2F6);
  static const Color surfaceStrong = Color(0xFFE4E7EE);
  static const Color textPrimary = Color(0xFF171827);
  static const Color textSecondary = Color(0xFF646B7F);
  static const Color dividerColor = Color(0xFFE2E5EC);
  static const Color errorColor = Color(0xFFD92D3A);
  static const Color successColor = Color(0xFF138A61);
  static const Color warningColor = Color(0xFFD97706);

  static const double radiusSmall = 6;
  static const double radius = 8;

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryColor],
  );

  static const LinearGradient premiumGradient = primaryGradient;

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentColor, Color(0xFF33AAB5)],
  );

  static const LinearGradient headerGradient = primaryGradient;

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: primaryDark.withAlpha(16),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryDark.withAlpha(13),
      blurRadius: 18,
      offset: const Offset(0, 8),
      spreadRadius: -6,
    ),
  ];

  static List<BoxShadow> get navShadow => [
    BoxShadow(
      color: primaryDark.withAlpha(20),
      blurRadius: 22,
      offset: const Offset(0, -5),
      spreadRadius: -8,
    ),
  ];

  static ThemeData get lightTheme {
    final base = GoogleFonts.poppinsTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: accentSoft,
        onPrimaryContainer: primaryColor,
        secondary: accentDark,
        onSecondary: Colors.white,
        surface: surfaceColor,
        onSurface: textPrimary,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: base.copyWith(
        displayLarge: base.displayLarge?.copyWith(
          fontSize: 34,
          height: 1.12,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: 0,
        ),
        displayMedium: base.displayMedium?.copyWith(
          fontSize: 28,
          height: 1.18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0,
        ),
        headlineLarge: base.headlineLarge?.copyWith(
          fontSize: 23,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0,
        ),
        headlineMedium: base.headlineMedium?.copyWith(
          fontSize: 19,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0,
        ),
        headlineSmall: base.headlineSmall?.copyWith(
          fontSize: 16,
          height: 1.35,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0,
        ),
        titleLarge: base.titleLarge?.copyWith(
          fontSize: 16,
          height: 1.35,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0,
        ),
        titleMedium: base.titleMedium?.copyWith(
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0,
        ),
        bodyLarge: base.bodyLarge?.copyWith(
          fontSize: 15,
          height: 1.6,
          color: textPrimary,
          letterSpacing: 0,
        ),
        bodyMedium: base.bodyMedium?.copyWith(
          fontSize: 14,
          height: 1.55,
          color: textPrimary,
          letterSpacing: 0,
        ),
        bodySmall: base.bodySmall?.copyWith(
          fontSize: 12,
          height: 1.45,
          color: textSecondary,
          letterSpacing: 0,
        ),
        labelLarge: base.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        iconTheme: const IconThemeData(color: primaryColor),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        indicatorColor: accentSoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? primaryColor
                : textSecondary,
            letterSpacing: 0,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? primaryColor
                : textSecondary,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: dividerColor),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 50),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 50),
          foregroundColor: primaryColor,
          side: const BorderSide(color: dividerColor),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: accentDark, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accentSoft,
        selectedColor: primaryColor,
        side: BorderSide.none,
        labelStyle: GoogleFonts.poppins(
          color: primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: primaryDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: primaryDark,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: accentColor,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: primaryColor,
        unselectedLabelColor: textSecondary,
        dividerColor: dividerColor,
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: 0,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
