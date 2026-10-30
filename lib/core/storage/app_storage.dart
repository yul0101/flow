import 'package:shared_preferences/shared_preferences.dart';

import '../errors/app_exception.dart';
import '../logging/app_logger.dart';

/// 本地存储封装。
///
/// 封装 [SharedPreferences] 为简单的 key-value 接口，
/// 避免业务层到处散落 `await SharedPreferences.getInstance()`。
class AppStorage {
  AppStorage._();

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// 应用启动时调用，确保 prefs 已初始化。
  static Future<void> ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ========== Token ==========
  static const String _keyToken = 'auth_token';
  static Future<void> saveToken(String token) async {
    final p = await _instance;
    await p.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final p = await _instance;
    return p.getString(_keyToken);
  }

  static Future<void> removeToken() async {
    final p = await _instance;
    await p.remove(_keyToken);
  }

  // ========== 用户 ID ==========
  static const String _keyUserId = 'auth_user_id';
  static Future<void> saveUserId(String userId) async {
    final p = await _instance;
    await p.setString(_keyUserId, userId);
  }

  static Future<String?> getUserId() async {
    final p = await _instance;
    return p.getString(_keyUserId);
  }

  static Future<void> removeUserId() async {
    final p = await _instance;
    await p.remove(_keyUserId);
  }

  // ========== 主题偏好 ==========
  static const String _keyTheme = 'theme_mode';
  static Future<void> saveThemeMode(String mode) async {
    final p = await _instance;
    await p.setString(_keyTheme, mode);
  }

  /// 同步读取（Notifier.build 可用，值为 null 时已异步初始化过）。
  static String? getThemeModeSync() {
    return _prefs?.getString(_keyTheme);
  }

  // ========== 通用接口 ==========
  static Future<void> clearAll() async {
    try {
      final p = await _instance;
      await p.clear();
      AppLogger.d('AppStorage: 全部清除');
    } catch (e) {
      throw const StorageException();
    }
  }
}
