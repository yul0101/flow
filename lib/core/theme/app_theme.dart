import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/app_storage.dart';

/// 主题模式枚举。
enum AppThemeMode { system, light, dark }

extension AppThemeModeX on AppThemeMode {
  ThemeMode toThemeMode() => switch (this) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };

  static AppThemeMode fromString(String? value) => switch (value) {
        'light' => AppThemeMode.light,
        'dark' => AppThemeMode.dark,
        _ => AppThemeMode.system,
      };
}

/// 主题模式 controller provider。
final themeModeProvider = NotifierProvider<ThemeModeNotifier, AppThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    final saved = AppStorage.getThemeModeSync();
    return AppThemeModeX.fromString(saved);
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    await AppStorage.saveThemeMode(mode.name);
  }
}

/// Light 主题。
final lightTheme = FlexThemeData.light(
  scheme: FlexScheme.gold,
  useMaterial3: true,
);

/// Dark 主题。
final darkTheme = FlexThemeData.dark(
  scheme: FlexScheme.gold,
  useMaterial3: true,
);
