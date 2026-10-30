import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_config.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import '../logging/app_logger.dart';

/// 全局 Dio 单例 provider。
///
/// Repository 层通过 `ref.watch(dioProvider)` 获取，
/// 统一复用一个实例和拦截器链。
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.addAll([
    AuthInterceptor(),
    _LoggingInterceptor(),
    ErrorInterceptor(),
  ]);

  AppLogger.d('Dio 实例初始化完成，baseUrl=${ApiConfig.baseUrl}');
  return dio;
});

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.d('→ ${options.method} ${options.baseUrl}${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.d('← ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.e('✗ ${err.requestOptions.method} ${err.requestOptions.path}', err);
    handler.next(err);
  }
}
