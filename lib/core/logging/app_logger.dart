import 'package:logger/logger.dart';

/// 全局日志实例。
///
/// 生产环境会自动过滤 debug/info 级别的日志。
final class AppLogger {
  AppLogger._();

  static final Logger _instance = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 100,
      colors: true,
    ),
    level: Level.verbose,
    output: null,
    filter: null,
  );

  static void v(dynamic msg, [dynamic error, StackTrace? stackTrace]) {
    _instance.t(msg, error: error, stackTrace: stackTrace);
  }

  static void d(dynamic msg, [dynamic error, StackTrace? stackTrace]) {
    _instance.d(msg, error: error, stackTrace: stackTrace);
  }

  static void i(dynamic msg, [dynamic error, StackTrace? stackTrace]) {
    _instance.i(msg, error: error, stackTrace: stackTrace);
  }

  static void w(dynamic msg, [dynamic error, StackTrace? stackTrace]) {
    _instance.w(msg, error: error, stackTrace: stackTrace);
  }

  static void e(dynamic msg, [dynamic error, StackTrace? stackTrace]) {
    _instance.e(msg, error: error, stackTrace: stackTrace);
  }
}
