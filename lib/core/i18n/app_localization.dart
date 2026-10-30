import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// easy_localization 初始化封装。
class AppLocalization {
  AppLocalization._();

  static Future<void> ensureInitialized() async {
    await EasyLocalization.ensureInitialized();
  }

  static const supportedLocales = [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
  ];

  static const path = 'assets/translations';
  static const fallbackLocale = Locale('zh', 'CN');
}
