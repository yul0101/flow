import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/feed/presentation/compose_page.dart';
import '../../features/feed/presentation/feed_page.dart';
import '../../features/feed/presentation/post_detail_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../logging/app_logger.dart';

/// 路由路径常量（集中管理，避免散落字符串）。
class AppRoutes {
  AppRoutes._();

  static const String login = '/auth/login';
  static const String register = '/auth/register';

  static const String feed = '/';
  static const String compose = '/compose';
  static const String postDetail = '/post/:id';
  static const String profile = '/profile';
}

/// go_router 配置。
///
/// redirect 守卫通过 [authProvider] 判断登录态：
/// - 未登录访问 /app/* → /auth/login
/// - 已登录访问 /auth/* → /
GoRouter createAppRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.feed,
    redirect: (context, state) {
      final loggedIn = ref.read(authProvider).value;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      if (loggedIn == null && !isAuthRoute) {
        AppLogger.d('Redirect → 未登录，跳转到 /auth/login');
        return AppRoutes.login;
      }
      if (loggedIn != null && isAuthRoute) {
        AppLogger.d('Redirect → 已登录，跳转到 /');
        return AppRoutes.feed;
      }
      return null;
    },
    refreshListenable: _AuthRefreshListenable(ref),
    routes: [
      // ========== Auth ==========
      GoRoute(
        path: AppRoutes.login,
        builder: (_, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, state) => const Scaffold(
          body: Center(child: Text('注册页面 · 待实现')),
        ),
      ),

      // ========== Main App ==========
      StatefulShellRoute.indexedStack(
        builder: (_, state, shell) => _MainScaffold(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.feed,
                builder: (_, state) => const FeedPage(),
                routes: [
                  GoRoute(
                    path: 'compose',
                    builder: (_, state) => const ComposePage(),
                  ),
                  GoRoute(
                    path: 'post/:id',
                    builder: (_, state) =>
                        PostDetailPage(postId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// 让 go_router 在 authProvider 变化时自动触发 redirect。
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._ref) {
    _ref.listen(authProvider, (_, _) {
      notifyListeners();
    });
  }
  final WidgetRef _ref;
}

/// 主应用壳：底部导航栏。
class _MainScaffold extends StatelessWidget {
  const _MainScaffold({required this.shell});
  final StatefulNavigationShell shell;

  void _goBranch(int index) {
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
