import 'package:flutter/material.dart';

class AppColors {
  static const seed = Color(0xFF3B82F6);

  static ColorScheme lightScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  );

  static ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.dark,
  );
}
