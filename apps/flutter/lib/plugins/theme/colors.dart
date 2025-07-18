import 'package:flutter/material.dart';

class AppColors {
  final Color primary;
  final Color background;
  final Color scaffoldBackground;
  final Color card;
  final Color text;
  final Color secondaryText;
  final Color border;
  final Color icon;
  final Color error;
  final Color inputFieldBg;
  final Color inputFieldBorder;
  final Color bottomNavBarBarrier;

  const AppColors({
    required this.primary,
    required this.background,
    required this.scaffoldBackground,
    required this.card,
    required this.text,
    required this.secondaryText,
    required this.border,
    required this.icon,
    required this.error,
    required this.inputFieldBg,
    required this.inputFieldBorder,
    required this.bottomNavBarBarrier,
  });


  // Light theme
  static const light = AppColors(
    primary: Color(0xFFE91E63),
    background: Color.fromARGB(255, 255, 255, 255),
    scaffoldBackground: Color.fromARGB(255, 255, 255, 255),
    card: Color(0xFFFFFFFF),
    text: Color.fromARGB(255, 18, 20, 18),
    secondaryText: Color(0xFF666666),
    border: Color(0xFFFCE4EC),
    icon: Color.fromARGB(255, 22, 26, 22),
    error: Color(0xFFD32F2F),
    inputFieldBg: Color.fromARGB(10, 242, 242, 242),
    inputFieldBorder: Color(0x14000000),
    bottomNavBarBarrier: Color.fromARGB(80, 0, 0, 0),
  );

  // Dark theme
  static const dark = AppColors(
    primary: Color(0xFFE91E63),
    background: Color.fromARGB(255, 0, 0, 0),
    scaffoldBackground: Color.fromARGB(255, 0, 0, 0),
    card: Color.fromARGB(255, 13, 13, 16),
    text: Color(0xFFF1F8E9),
    secondaryText: Color(0xFFB0B0B0),
    border: Color(0xFF4A1C29),
    icon: Color.fromARGB(255, 190, 204, 191),
    error: Color(0xFFD32F2F),
    inputFieldBg: Color.fromARGB(10, 255, 255, 255),
    inputFieldBorder: Color(0x14FFFFFF),
    bottomNavBarBarrier: Color.fromARGB(137, 2, 27, 1),
  );

}
