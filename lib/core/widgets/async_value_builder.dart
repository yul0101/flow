import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_exception.dart';
import '../logging/app_logger.dart';

/// 统一处理 AsyncValue 的加载/成功/失败三态。
///
/// 业务 UI 层直接用这个 widget，避免到处写
/// `if (value.isLoading)` / `if (value.hasError)` 的模板代码。
///
/// 用法示例：
/// ```dart
/// AsyncValueBuilder<List<Post>>(
///   value: ref.watch(feedProvider),
///   data: (posts) => ListView(...),
/// )
/// ```
class AsyncValueBuilder<T> extends StatelessWidget {
  const AsyncValueBuilder({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.skipLoadingOnRefresh = true,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error, StackTrace? stack)? error;
  final bool skipLoadingOnRefresh;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      loading: () => loading?.call() ?? const _AppLoading(),
      error: (e, st) {
        AppLogger.e('AsyncValueBuilder error', e, st);
        if (error != null) return error!(e, st);
        return _AppError(
          message: _extractMessage(e),
          onRetry: null,
        );
      },
      data: data,
    );
  }

  String _extractMessage(Object e) {
    if (e is AppException) return e.message;
    return e.toString();
  }
}

class _AppLoading extends StatelessWidget {
  const _AppLoading();
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _AppError extends StatelessWidget {
  const _AppError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: onRetry, child: const Text('重试')),
          ],
        ],
      ),
    );
  }
}
