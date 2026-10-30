/// 应用统一异常类型。
///
/// 所有 Repository/Service 层捕获的异常都应转换为 [AppException]
/// 再向上抛出，UI 层通过 [AppException.message] 展示给用户。
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// 网络请求失败（无网络、超时、DNS 失败）。
class NetworkException extends AppException {
  const NetworkException([super.message = '网络连接失败，请检查网络设置']);
}

/// 服务端返回非 2xx 状态码。
class ServerException extends AppException {
  const ServerException(super.message, {required this.statusCode});
  final int statusCode;
}

/// 401 未认证 / Token 过期。
class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = '登录已过期，请重新登录']);
}

/// 业务逻辑异常（如"用户名已存在"、"余额不足"）。
class BusinessException extends AppException {
  const BusinessException(super.message);
}

/// 本地存储读写失败。
class StorageException extends AppException {
  const StorageException([super.message = '本地数据读写失败']);
}

/// 未知异常。
class UnknownException extends AppException {
  const UnknownException([super.message = '未知错误，请稍后重试']);
}
