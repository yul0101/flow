import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

/// 将 dio 的异常统一转换为 [AppException]。
class ErrorInterceptor extends Interceptor {
  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final exception = _convert(err);
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: exception,
    ));
  }

  AppException _convert(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const NetworkException();
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        final message = _extractMessage(err.response);
        if (statusCode == 401) return const UnauthorizedException();
        if (statusCode >= 500) {
          return ServerException(message.isEmpty ? '服务器繁忙，请稍后再试' : message, statusCode: statusCode);
        }
        return ServerException(
          message.isEmpty ? '请求失败 ($statusCode)' : message,
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return const UnknownException('请求已取消');
      case DioExceptionType.badCertificate:
        return const UnknownException('证书验证失败');
    }
  }

  String _extractMessage(Response? response) {
    if (response == null) return '';
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['msg'] ?? '').toString();
    }
    return '';
  }
}
