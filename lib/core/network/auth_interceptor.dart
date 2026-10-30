import 'package:dio/dio.dart';

import '../storage/app_storage.dart';

/// 自动在请求头挂 Token。
///
/// 每次请求前从 [AppStorage] 读取最新 token，避免持有的是过时引用。
class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await AppStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
