import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/user.dart';
import '../data/feed_repository.dart';
import '../domain/comment.dart';
import '../domain/post.dart';

/// Feed 分页 controller（显式 AsyncNotifierProvider）。
final feedPaginationProvider =
    AsyncNotifierProvider<FeedPaginationNotifier, List<Post>>(
  FeedPaginationNotifier.new,
);

class FeedPaginationNotifier extends AsyncNotifier<List<Post>> {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _loadingMore = false;

  bool get hasMore => _hasMore;
  bool get loadingMore => _loadingMore;

  @override
  Future<List<Post>> build() async {
    final firstPage = await ref.watch(feedRepositoryProvider.notifier).fetchFeed(page: 1);
    _currentPage = 1;
    _hasMore = firstPage.isNotEmpty;
    return firstPage;
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore || state.isLoading) return;
    _loadingMore = true;
    try {
      final nextPage = _currentPage + 1;
      final more = await ref.watch(feedRepositoryProvider.notifier).fetchFeed(page: nextPage);
      _currentPage = nextPage;
      _hasMore = more.isNotEmpty;
      state = AsyncData([...(state.value ?? []), ...more]);
    } catch (e, st) {
      state = AsyncError<List<Post>>(e, st);
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncLoading();
    try {
      final firstPage = await ref.watch(feedRepositoryProvider.notifier).fetchFeed(page: 1);
      state = AsyncData(firstPage);
    } catch (e, st) {
      state = AsyncError<List<Post>>(e, st);
    }
  }

  /// 用新数据替换列表中的同 id 帖子（点赞 / 评论后调用）。
  void replacePost(Post post) {
    final posts = state.value;
    if (posts == null) return;
    state = AsyncData([
      for (final item in posts) item.id == post.id ? post : item,
    ]);
  }

  /// 点赞：先本地乐观更新，再以仓库返回结果为准，失败则回滚。
  Future<void> toggleLike(Post post) async {
    final optimistic = post.copyWith(
      liked: !post.liked,
      likes: post.liked ? post.likes - 1 : post.likes + 1,
    );
    replacePost(optimistic);
    try {
      final updated = await ref.read(feedRepositoryProvider.notifier).toggleLike(post.id);
      replacePost(updated);
    } catch (_) {
      replacePost(post);
      rethrow;
    }
  }
}

/// 发帖动作。
final postComposerProvider = AsyncNotifierProvider<PostComposer, void>(
  PostComposer.new,
);

class PostComposer extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit({
    required String content,
    String? imageUrl,
    required User author,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(feedRepositoryProvider.notifier).createPost(
            content: content,
            imageUrl: imageUrl,
            author: author,
          );
      state = const AsyncData(null);
      ref.invalidate(feedPaginationProvider);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

/// 某个帖子的评论列表。
final commentsProvider = FutureProvider.family<List<Comment>, String>(
  (ref, postId) => ref.read(feedRepositoryProvider.notifier).fetchComments(postId),
);

/// 新增评论动作。
final addCommentProvider = FutureProvider.family<void,
    ({String postId, String content, User author})>((ref, args) async {
  final updated = await ref.read(feedRepositoryProvider.notifier).addComment(
        postId: args.postId,
        content: args.content,
        author: args.author,
      );
  ref.read(feedPaginationProvider.notifier).replacePost(updated);
  ref.invalidate(commentsProvider(args.postId));
});
