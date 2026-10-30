import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../providers/feed_provider.dart';

/// 发帖页：文本 + 可选图片 URL。
///
/// 骨架阶段用图片 URL 代替真实上传；接入后端时替换为上传组件，
/// 拿到 CDN 地址后传给 `postComposerProvider.submit(imageUrl: ...)`。
class ComposePage extends ConsumerStatefulWidget {
  const ComposePage({super.key});
  @override
  ConsumerState<ComposePage> createState() => _ComposePageState();
}

class _ComposePageState extends ConsumerState<ComposePage> {
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = ref.read(authProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登录态失效，请重新登录')),
      );
      return;
    }
    final imageUrl = _imageUrlController.text.trim();
    try {
      await ref.read(postComposerProvider.notifier).submit(
            content: _contentController.text.trim(),
            imageUrl: imageUrl.isEmpty ? null : imageUrl,
            author: user,
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发布失败：$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(postComposerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('发布'),
        actions: [
          TextButton(
            onPressed: submitting ? null : _submit,
            child: submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('发布'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _contentController,
              maxLines: 6,
              maxLength: 500,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '说点什么…',
                border: InputBorder.none,
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return '内容不能为空';
                if (value.trim().length > 500) return '最多 500 字';
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: '图片 URL（可选）',
                hintText: 'https://…',
                helperText: '骨架阶段直接贴图片地址，真实项目替换为上传组件',
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return null;
                if (!text.startsWith('http')) return '请输入以 http 开头的地址';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
