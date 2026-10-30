/// API 配置。
///
/// 默认指向本地后端（server/）。生产构建时可通过
/// `--dart-define=API_BASE_URL=https://api.flow.app` 覆盖。
class ApiConfig {
  const ApiConfig._();

  /// 默认值 = 本地后端。真实部署时通过 --dart-define 或修改此处切换。
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // ========== 路由常量（与 server/README.md 保持一致）==========
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String me = '/api/auth/me';
  static const String feed = '/api/feed';

  // 动态路由：在 Repository 里用 '$feed/xxx' 拼接
  // POST /api/posts
  // POST /api/posts/:id/like
  // GET  /api/posts/:id/comments
  // POST /api/posts/:id/comments
}
