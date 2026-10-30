import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../data/auth_repository.dart';
import '../domain/user.dart';

/// 当前认证状态（显式 StreamProvider）。
///
/// 初始：从存储读 token → 拉 me 验证 → 持久输出 User?。
final authProvider = StreamProvider<User?>((ref) async* {
  await AppStorage.ensureInitialized();
  final token = await AppStorage.getToken();
  if (token == null || token.isEmpty) {
    yield null;
    return;
  }
  final me = await ref.watch(authRepositoryProvider.notifier).me();
  yield me;
});

/// 登录动作（显式 FutureProvider）。
final loginProvider = FutureProvider.family<void, ({String email, String password})>((ref, creds) async {
  await ref.watch(authRepositoryProvider.notifier).login(
        email: creds.email,
        password: creds.password,
      );
  ref.invalidate(authProvider);
});

/// 登出。
final logoutProvider = FutureProvider<void>((ref) async {
  await AppStorage.removeToken();
  await AppStorage.removeUserId();
  ref.invalidate(authProvider);
});
