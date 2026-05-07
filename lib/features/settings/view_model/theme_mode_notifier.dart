import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/hive/hive_boxes.dart';
import '../model/theme_mode_model.dart';

class ThemeModeNotifier extends Notifier<AppThemeMode> {
  static const _key = 'theme_mode';

  @override
  AppThemeMode build() {
    _loadFromHive();
    return AppThemeMode.system;
  }

  Future<void> _loadFromHive() async {
    final box = Hive.box(HiveBoxes.settings);
    final saved = box.get(_key) as String?;
    state = AppThemeModeX.fromKey(saved);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    final box = Hive.box(HiveBoxes.settings);
    await box.put(_key, mode.key);
  }

  ThemeMode get flutterThemeMode {
    switch (state) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, AppThemeMode>(
  ThemeModeNotifier.new,
);
