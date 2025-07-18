import 'package:flutter/material.dart';
import 'constants.dart';
import 'colors.dart';

ThemeData appThemeData(AppColors colors, Brightness brightness) {
  return ThemeData(
    brightness: brightness,
    primaryColor: colors.primary,
    scaffoldBackgroundColor: colors.scaffoldBackground,
    cardColor: colors.card,
    shadowColor: colors.border,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: colors.text, fontSize: 16),
      bodyMedium: TextStyle(color: colors.text, fontSize: 14),
      titleLarge: TextStyle(
        color: colors.text,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      titleMedium: TextStyle(
        color: colors.text,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      labelLarge: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
      titleSmall: TextStyle(
        color: colors.text,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      labelMedium: TextStyle(color: colors.text, fontSize: 12),
      labelSmall: TextStyle(color: colors.text, fontSize: 10),
      bodySmall: TextStyle(color: colors.text, fontSize: 12),
      headlineLarge: TextStyle(
        color: colors.text,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      headlineMedium: TextStyle(
        color: colors.text,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      headlineSmall: TextStyle(
        color: colors.text,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      displayLarge: TextStyle(
        color: colors.text,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      displayMedium: TextStyle(
        color: colors.text,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      displaySmall: TextStyle(
        color: colors.text,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.scaffoldBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: colors.text),
      titleTextStyle: TextStyle(
        color: colors.text,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      centerTitle: true,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.scaffoldBackground,
      titleTextStyle: TextStyle(
        color: colors.text,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      contentTextStyle: TextStyle(color: colors.secondaryText, fontSize: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appRadius),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.inputFieldBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(appRadius * 0.3),
        borderSide: BorderSide(color: colors.inputFieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(appRadius * 0.3),
        borderSide: BorderSide(color: colors.inputFieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(appRadius * 0.3),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      labelStyle: TextStyle(color: colors.text),
      hintStyle: TextStyle(color: colors.text),
      prefixIconColor: colors.text.withOpacity(0.6),
      suffixIconColor: colors.text,
      prefixStyle: TextStyle(fontSize: 9),
      suffixStyle: TextStyle(fontSize: 9),
    ),

    iconTheme: IconThemeData(color: colors.icon),
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      error: colors.error,
      onPrimary: Colors.white,
      onError: Colors.white,
      secondary: colors.icon,
      onSecondary: colors.text,
      surface: colors.card,
      onSurface: colors.text,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(appRadius),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        padding: EdgeInsets.symmetric(vertical: appRadius / 2),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(appRadius),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        padding: EdgeInsets.symmetric(
          vertical: appPadding,
          horizontal: appPadding,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.text,
        backgroundColor: colors.text.withOpacity(0.04),
        side: BorderSide(color: colors.text.withOpacity(0.045), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(appBorderRadius),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        padding: EdgeInsets.symmetric(
          vertical: appPadding * 1.5,
          horizontal: appPadding,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appRadius),
      ),
      elevation: 4,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colors.background,
      disabledColor: colors.background.withOpacity(0.5),
      selectedColor: colors.primary.withOpacity(0.15),
      secondarySelectedColor: colors.primary.withOpacity(0.25),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: TextStyle(color: colors.text),
      secondaryLabelStyle: TextStyle(color: colors.primary),
      brightness: brightness,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appBorderRadius),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected)
                ? colors.primary
                : colors.border,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected)
                ? colors.primary.withOpacity(0.5)
                : colors.border.withOpacity(0.3),
      ),
      trackOutlineColor: WidgetStateProperty.all(colors.border),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appRadius / 2),
      ),
      fillColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected)
                ? colors.primary
                : colors.border,
      ),
      checkColor: WidgetStateProperty.all(Colors.white),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected)
                ? colors.primary
                : colors.border,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: colors.primary,
      inactiveTrackColor: colors.border,
      thumbColor: colors.primary,
      overlayColor: colors.primary.withOpacity(0.2),
      valueIndicatorColor: colors.primary,
      trackHeight: 4,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: appRadius / 2.5),
      trackShape: const RoundedRectSliderTrackShape(),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: colors.primary,
      unselectedLabelColor: colors.secondaryText,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: colors.primary, width: 3),
        borderRadius: BorderRadius.circular(appRadius),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: colors.border.withOpacity(0.3),
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colors.inputFieldBorder,
      thickness: 0.5,
      space: 0.5,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appRadius),
      ),
      textStyle: TextStyle(color: colors.text),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appRadius),
      ),
      tileColor: colors.card,
      selectedTileColor: colors.primary.withOpacity(0.08),
      iconColor: colors.icon,
      textColor: colors.text,
      selectedColor: colors.primary,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.background,
      shadowColor: colors.border,
      elevation: 10,
      modalBarrierColor: colors.bottomNavBarBarrier,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(appRadius * 0.7),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: colors.card,
      shadowColor: colors.border.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appRadius * 0.5),
        side: BorderSide(color: colors.border.withOpacity(0.3), width: 0.5),
      ),
      elevation: 0.5,
    ),
    useMaterial3: true,
  );
}
