import 'package:flutter/material.dart';

// DroneAtlas design system. Existing names are intentionally preserved so
// older screens and downloadable lessons remain compatible.
const navy = Color(0xFF040A12);
const deepNavy = Color(0xFF071523);
const panel = Color(0xFF0D1D2C);
const surfaceDark = Color(0xFF102638);
const cyan = Color(0xFF21E6C1);
const electricBlue = Color(0xFF4BA3FF);
const orange = Color(0xFFFFB15C);
const violet = Color(0xFFA78BFA);
const lime = Color(0xFFC7F464);
const success = Color(0xFF60E5A8);
const danger = Color(0xFFFF7185);
const ink = Color(0xFF0B1722);
const paper = Color(0xFFF4F7FA);

ThemeData buildDroneTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: cyan,
    brightness: brightness,
    surface: dark ? panel : Colors.white,
  ).copyWith(
    primary: cyan,
    onPrimary: navy,
    secondary: electricBlue,
    onSecondary: Colors.white,
    tertiary: violet,
    error: danger,
    surface: dark ? panel : Colors.white,
    onSurface: dark ? const Color(0xFFF5FAFC) : ink,
    surfaceContainerHighest:
        dark ? const Color(0xFF142B3D) : const Color(0xFFE9F0F4),
    outline: dark ? Colors.white24 : const Color(0xFFCAD7DE),
  );

  final baseText = Typography.material2021(
    platform: TargetPlatform.android,
  ).black;
  final textTheme = baseText.copyWith(
    displayLarge: baseText.displayLarge?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -2.6,
      height: .96,
    ),
    displayMedium: baseText.displayMedium?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -2,
      height: 1,
    ),
    headlineLarge: baseText.headlineLarge?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -1.2,
    ),
    headlineMedium: baseText.headlineMedium?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -.9,
    ),
    titleLarge: baseText.titleLarge?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -.55,
    ),
    titleMedium: baseText.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -.2,
    ),
    bodyLarge: baseText.bodyLarge?.copyWith(height: 1.45),
    bodyMedium: baseText.bodyMedium?.copyWith(height: 1.42),
    labelLarge: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w900),
  ).apply(
    bodyColor: dark ? const Color(0xFFDDEAF0) : const Color(0xFF263C49),
    displayColor: dark ? Colors.white : ink,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? navy : paper,
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarThemeData(
      backgroundColor: Colors.transparent,
      foregroundColor: dark ? Colors.white : ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: dark ? Colors.white : ink,
        fontWeight: FontWeight.w900,
        fontSize: 21,
        letterSpacing: -.55,
      ),
    ),
    cardTheme: CardThemeData(
      color: dark ? panel.withOpacity(.93) : Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: dark ? Colors.black54 : const Color(0x1A18384B),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(
          color: dark ? Colors.white.withOpacity(.075) : const Color(0xFFE0E9EE),
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: dark ? Colors.white.withOpacity(.08) : const Color(0xFFE1E9ED),
      thickness: 1,
      space: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: dark ? const Color(0xF2081520) : const Color(0xF9FFFFFF),
      surfaceTintColor: Colors.transparent,
      indicatorColor: cyan.withOpacity(dark ? .18 : .14),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: states.contains(WidgetState.selected) ? 25 : 23,
          color: states.contains(WidgetState.selected)
              ? cyan
              : scheme.onSurfaceVariant,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 11,
          color: states.contains(WidgetState.selected)
              ? (dark ? Colors.white : ink)
              : scheme.onSurfaceVariant,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w900
              : FontWeight.w700,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: cyan.withOpacity(.16),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      selectedIconTheme: const IconThemeData(color: cyan, size: 25),
      unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      selectedLabelTextStyle: TextStyle(
        color: dark ? Colors.white : ink,
        fontWeight: FontWeight.w900,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: scheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? Colors.white.withOpacity(.055) : Colors.white,
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(19),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(19),
        borderSide: BorderSide(
          color: dark ? Colors.white.withOpacity(.08) : const Color(0xFFDCE6EB),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(19),
        borderSide: const BorderSide(color: cyan, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(19),
        borderSide: const BorderSide(color: danger),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(19),
        borderSide: BorderSide(
          color: dark ? Colors.white.withOpacity(.05) : const Color(0xFFE3EAEE),
        ),
      ),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      floatingLabelStyle: TextStyle(
        color: dark ? cyan : const Color(0xFF006B61),
        fontWeight: FontWeight.w800,
      ),
      prefixIconColor: dark ? scheme.onSurfaceVariant : const Color(0xFF35515E),
      suffixIconColor: dark ? scheme.onSurfaceVariant : const Color(0xFF35515E),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: cyan,
        foregroundColor: navy,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        side: BorderSide(color: dark ? Colors.white24 : Colors.black12),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: dark ? cyan : const Color(0xFF007C74),
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: dark ? const Color(0xFF122638) : const Color(0xFFEAF4F8),
      disabledColor: dark ? const Color(0xFF172431) : const Color(0xFFF0F3F5),
      selectedColor: dark ? cyan.withOpacity(.24) : const Color(0xFFBFEFE6),
      secondarySelectedColor:
          dark ? electricBlue.withOpacity(.22) : const Color(0xFFDCEBFF),
      checkmarkColor: dark ? cyan : const Color(0xFF00695F),
      deleteIconColor: dark ? scheme.onSurfaceVariant : const Color(0xFF294552),
      iconTheme: IconThemeData(
        color: dark ? scheme.onSurfaceVariant : const Color(0xFF294552),
        size: 18,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide(
        color: dark ? Colors.white.withOpacity(.13) : const Color(0xFFBFD0D8),
      ),
      labelStyle: TextStyle(
        color: dark ? scheme.onSurface : const Color(0xFF102A43),
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
      secondaryLabelStyle: TextStyle(
        color: dark ? Colors.white : const Color(0xFF082032),
        fontWeight: FontWeight.w900,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
    ),
    listTileTheme: ListTileThemeData(
      textColor: scheme.onSurface,
      iconColor: scheme.onSurfaceVariant,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w800,
        fontSize: 15,
      ),
      subtitleTextStyle: TextStyle(
        color: scheme.onSurfaceVariant,
        height: 1.35,
        fontSize: 13,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: dark ? panel : Colors.white,
      surfaceTintColor: Colors.transparent,
      textStyle: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) return cyan;
        return dark ? const Color(0xFF172A3A) : Colors.white;
      }),
      checkColor: const WidgetStatePropertyAll<Color>(navy),
      side: BorderSide(
        color: dark ? Colors.white38 : const Color(0xFF607D8B),
        width: 1.4,
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return dark ? cyan : const Color(0xFF007C70);
        }
        return dark ? scheme.onSurfaceVariant : const Color(0xFF526D79);
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) return navy;
        return dark ? const Color(0xFFDDEAF0) : const Color(0xFF526D79);
      }),
      trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) return cyan;
        return dark ? Colors.white24 : const Color(0xFFCEDAE0);
      }),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: dark ? cyan : const Color(0xFF007C70),
      selectionColor: cyan.withOpacity(.26),
      selectionHandleColor: dark ? cyan : const Color(0xFF007C70),
    ),
        sliderTheme: SliderThemeData(
      activeTrackColor: cyan,
      thumbColor: cyan,
      inactiveTrackColor: cyan.withOpacity(.16),
      overlayColor: cyan.withOpacity(.12),
      trackHeight: 5,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: cyan),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: dark ? const Color(0xFF163247) : ink,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: dark ? panel : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: dark ? navy : paper,
      modalBackgroundColor: dark ? navy : paper,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
    ),
  );
}
