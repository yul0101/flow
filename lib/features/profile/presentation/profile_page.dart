import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_value_builder.dart';
import '../../auth/providers/auth_provider.dart';
import 'widgets/logout_button.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('我的'), actions: const [LogoutButton()]),
      body: AsyncValueBuilder(
        value: authState,
        data: (user) {
          if (user == null) {
            return const Center(child: Text('未登录'));
          }
          return ListView(
            children: [
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage(user.avatar),
              ),
              const SizedBox(height: 12),
              Text(user.username,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge),
              if (user.bio != null) ...[
                const SizedBox(height: 4),
                Text(user.bio!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
              ],
              const SizedBox(height: 24),
              // 简单设置占位
              ListTile(leading: const Icon(Icons.settings), title: const Text('设置'), onTap: () {}),
              ListTile(leading: const Icon(Icons.notifications), title: const Text('通知'), onTap: () {}),
              ListTile(leading: const Icon(Icons.help), title: const Text('帮助'), onTap: () {}),
            ],
          );
        },
      ),
    );
  }
}
