import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/storage/app_storage.dart';
import '../domain/user.dart';

final authRepositoryProvider = NotifierProvider<AuthRepository, void>(
  AuthRepository.new,
);

class AuthRepository extends Notifier<void> {
  @override
  void build() {}

  Dio get _dio => ref.watch(dioProvider);

  /// 登录。成功后自动持久化 token，返回当前用户。
  Future<User> login({required String email, required String password}) async {
    final response = await _dio.post(ApiConfig.login, data: {
      'email': email,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    await AppStorage.saveToken(token);
    await AppStorage.saveUserId(user.id);
    AppLogger.d('AuthRepository login OK user=${user.username}');
    return user;
  }

  /// 注册。成功后自动持久化 token。
  Future<User> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(ApiConfig.register, data: {
      'username': username,
      'email': email,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    await AppStorage.saveToken(token);
    await AppStorage.saveUserId(user.id);
    AppLogger.d('AuthRepository register OK user=${user.username}');
    return user;
  }

  /// 获取当前登录用户（带 token 请求）。未登录或失败时返回 null。
  Future<User?> me() async {
    try {
      final response = await _dio.get(ApiConfig.me);
      final data = response.data as Map<String, dynamic>;
      return User.fromJson(data);
    } on UnauthorizedException {
      // 401 → token 无效，清理存储
      await AppStorage.removeToken();
      await AppStorage.removeUserId();
      return null;
    } on AppException {
      return null;
    }
  }
}
