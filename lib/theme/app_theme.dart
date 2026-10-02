import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF272262);
  static const Color primaryLight = Color(0xFF46408E);
  static const Color primaryDark = Color(0xFF151234);
  static const Color accentColor = Color(0xFF5CC7CF);
  static const Color accentDark = Color(0xFF126B74);
  static const Color accentSoft = Color(0xFFE5F7F8);

  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundCool = Color(0xFFEDF3F6);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF0F2F6);
  static const Color surfaceStrong = Color(0xFFE2E6ED);
  static const Color textPrimary = Color(0xFF171827);
  static const Color textSecondary = Color(0xFF69717C);
  static const Color dividerColor = Color(0xFFE5E8ED);
  static const Color errorColor = Color(0xFFC83246);
  static const Color successColor = Color(0xFF12805B);
  static const Color warningColor = Color(0xFFC96B12);

  static const double radiusSmall = 6;
  static const double radius = 8;
  static const double navigationRadius = 20;

  static const Duration motionFast = Duration(milliseconds: 160);
  static const Duration motion = Duration(milliseconds: 320);
  static const Duration motionSlow = Duration(milliseconds: 480);
  static const Curve motionCurve = Curves.easeOutCubic;

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryColor, primaryLight],
    stops: [0, 0.62, 1],
  );

  static const LinearGradient premiumGradient = primaryGradient;

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentColor, Color(0xFF2EA9B5)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryColor, Color(0xFF343071)],
    stops: [0, 0.68, 1],
  );

  static const LinearGradient canvasGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAFBFC), backgroundLight, Color(0xFFF0F4F5)],
    stops: [0, 0.58, 1],
  );

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: primaryDark.withAlpha(30),
      blurRadius: 34,
      offset: const Offset(0, 16),
      spreadRadius: -12,
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryDark.withAlpha(12),
      blurRadius: 16,
      offset: const Offset(0, 8),
      spreadRadius: -8,
    ),
    BoxShadow(
      color: Colors.white.withAlpha(176),
      blurRadius: 1,
      offset: const Offset(0, -1),
    ),
  ];

  static List<BoxShadow> get navShadow => [
    BoxShadow(
      color: primaryDark.withAlpha(28),
      blurRadius: 34,
      offset: const Offset(0, 14),
      spreadRadius: -8,
    ),
  ];

  static List<BoxShadow> get glassShadow => [
    BoxShadow(
      color: primaryDark.withAlpha(28),
      blurRadius: 30,
      offset: const Offset(0, 14),
      spreadRadius: -10,
    ),
  ];

  static ThemeData get lightTheme {
    final base = ThemeData.light().textTheme.apply(fontFamily: 'Manrope');
    const colorScheme = ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: accentSoft,
      onPrimaryContainer: primaryColor,
      secondary: accentDark,
      onSecondary: Colors.white,
      secondaryContainer: accentSoft,
      onSecondaryContainer: primaryDark,
      surface: surfaceColor,
      onSurface: textPrimary,
      error: errorColor,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      fontFamily: 'Manrope',
      scaffoldBackgroundColor: surfaceColor,
      canvasColor: surfaceColor,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      textTheme: base.copyWith(
        displayLarge: base.displayLarge?.copyWith(
          fontSize: 36,
          height: 1.1,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: 0,
        ),
        displayMedium: base.displayMedium?.copyWith(
          fontSize: 30,
          height: 1.16,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0,
        ),
        headlineLarge: base.headlineLarge?.copyWith(
          fontSize: 28,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0,
        ),
        headlineMedium: base.headlineMedium?.copyWith(
          fontSize: 20,
          height: 1.28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0,
        ),
        headlineSmall: base.headlineSmall?.copyWith(
          fontSize: 17,
          height: 1.34,
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
          height: 1.58,
          color: textPrimary,
          letterSpacing: 0,
        ),
        bodyMedium: base.bodyMedium?.copyWith(
          fontSize: 14,
          height: 1.52,
          color: textPrimary,
          letterSpacing: 0,
        ),
        bodySmall: base.bodySmall?.copyWith(
          fontSize: 12,
          height: 1.46,
          color: textSecondary,
          letterSpacing: 0,
        ),
        labelLarge: base.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        labelMedium: base.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CecPageTransitionsBuilder(),
          TargetPlatform.iOS: CecPageTransitionsBuilder(),
          TargetPlatform.linux: CecPageTransitionsBuilder(),
          TargetPlatform.macOS: CecPageTransitionsBuilder(),
          TargetPlatform.windows: CecPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor.withAlpha(240),
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: 64,
        titleSpacing: 8,
        titleTextStyle: TextStyle(
          fontFamily: 'Manrope',
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        iconTheme: const IconThemeData(color: primaryColor, size: 22),
        actionsIconTheme: const IconThemeData(color: primaryColor, size: 22),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: accentSoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontFamily: 'Manrope',
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
        color: surfaceColor.withAlpha(238),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: Colors.white.withAlpha(210)),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 52),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryColor.withAlpha(90),
          disabledForegroundColor: Colors.white.withAlpha(190),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          foregroundColor: primaryColor,
          backgroundColor: Colors.white.withAlpha(146),
          side: BorderSide(color: primaryColor.withAlpha(34)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size.square(44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: primaryColor.withAlpha(26)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: primaryColor.withAlpha(26)),
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
          vertical: 16,
        ),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        labelStyle: const TextStyle(color: textSecondary, letterSpacing: 0),
        hintStyle: const TextStyle(color: textSecondary, letterSpacing: 0),
      ),
      dividerTheme: DividerThemeData(
        color: primaryColor.withAlpha(20),
        thickness: 1,
        space: 1,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.white
                : backgroundLight,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? primaryColor
                : textSecondary,
          ),
          side: const WidgetStatePropertyAll(BorderSide(color: dividerColor)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accentSoft,
        selectedColor: primaryColor,
        side: BorderSide(color: primaryColor.withAlpha(18)),
        labelStyle: TextStyle(
          fontFamily: 'Manrope',
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
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor.withAlpha(248),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: primaryColor.withAlpha(20)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
        modalBackgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: surfaceStrong,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: primaryDark.withAlpha(244),
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        contentTextStyle: TextStyle(
          fontFamily: 'Manrope',
          color: Colors.white,
          fontSize: 13,
          letterSpacing: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: Colors.white.withAlpha(25)),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicator: BoxDecoration(
          color: accentSoft,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: accentColor.withAlpha(64)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: primaryColor,
        unselectedLabelColor: textSecondary,
        dividerColor: Colors.transparent,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        labelStyle: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w500,
          fontSize: 12,
          letterSpacing: 0,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: primaryColor.withAlpha(90), width: 1.4),
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? primaryColor
              : Colors.transparent;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accentDark,
        linearTrackColor: surfaceStrong,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primaryColor,
        selectionColor: Color(0x555CC7CF),
        selectionHandleColor: accentDark,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: primaryDark.withAlpha(242),
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        textStyle: TextStyle(
          fontFamily: 'Manrope',
          color: Colors.white,
          fontSize: 11,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class CecPageTransitionsBuilder extends PageTransitionsBuilder {
  const CecPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.isFirst) return child;

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) return child;

    final curved = CurvedAnimation(
      parent: animation,
      curve: AppTheme.motionCurve,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.72, end: 1).animate(curved),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.035, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
