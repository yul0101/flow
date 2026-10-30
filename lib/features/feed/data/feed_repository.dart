import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_config.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/utils/constants.dart';
import '../../auth/domain/user.dart';
import '../domain/comment.dart';
import '../domain/post.dart';

/// Feed 数据仓库（显式 NotifierProvider）。
///
/// 骨架阶段对接真实后端（server/）。Repository 内部
/// 用 [ref.watch(dioProvider)] 取带拦截器链的 Dio 实例，
/// 方法签名锁死——换后端只需改内部实现，上层 Provider / UI 零改动。
final feedRepositoryProvider = NotifierProvider<FeedRepository, void>(
  FeedRepository.new,
);

class FeedRepository extends Notifier<void> {
  @override
  void build() {}

  Dio get _dio => ref.watch(dioProvider);

  Future<List<Post>> fetchFeed({required int page}) async {
    final response = await _dio.get(ApiConfig.feed, queryParameters: {
      'page': page,
      'size': AppConstants.pageSize,
    });
    final list = response.data as List<dynamic>;
    return list.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Post> createPost({
    required String content,
    String? imageUrl,
    required User author, // author 由 Repository 内部不使用，后端从 token 解析
  }) async {
    final response = await _dio.post('${ApiConfig.feed}/posts', data: {
      'content': content,
      'imageUrl': imageUrl,
    });
    return Post.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Post> toggleLike(String postId) async {
    final response = await _dio.post('${ApiConfig.feed}/posts/$postId/like');
    return Post.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Comment>> fetchComments(String postId) async {
    final response = await _dio.get('${ApiConfig.feed}/posts/$postId/comments');
    final list = response.data as List<dynamic>;
    return list.map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Post> addComment({
    required String postId,
    required String content,
    required User author, // 同上，author 由 token 解析
  }) async {
    await _dio.post('${ApiConfig.feed}/posts/$postId/comments', data: {
      'content': content,
    });
    // 评论计数在后端事务里已经 +1，拉一下最新的 post
    final response = await _dio.get(ApiConfig.feed, queryParameters: {
      'page': 1,
      'size': 100,
    });
    final list = response.data as List<dynamic>;
    final posts = list
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
    return posts.firstWhere(
      (p) => p.id == postId,
      orElse: () => throw StateError('Post $postId not found after comment'),
    );
  }
}
