// 这些是**集成测试**——需要后端先启动：
//   cd server && npm install && npm run dev
//   npm run init-db   # 首次 seed
// 然后：flutter test

import 'package:flow/features/auth/domain/user.dart';
import 'package:flow/features/feed/data/feed_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _kIntegrationSkip = '需要后端先启动：cd server && npm run dev';

void main() {
  late ProviderContainer container;
  late FeedRepository repository;

  final testUser = User(
    id: 'u_test',
    username: 'tester',
    avatar: 'https://example.com/a.png',
    createdAt: DateTime.now(),
  );

  setUp(() {
    container = ProviderContainer();
    repository = container.read(feedRepositoryProvider.notifier);
  });

  tearDown(() => container.dispose());

  test('分页：第一页有数据，超出范围返回空列表', () async {
    final firstPage = await repository.fetchFeed(page: 1);
    expect(firstPage, isNotEmpty);

    final beyond = await repository.fetchFeed(page: 100);
    expect(beyond, isEmpty);
  }, skip: _kIntegrationSkip);

  test('发帖后出现在 Feed 首位', () async {
    final created = await repository.createPost(
      content: '集成测试帖',
      author: testUser,
    );
    expect(created.id, isNotEmpty);
    expect(created.content, '集成测试帖');
  }, skip: _kIntegrationSkip);

  test('点赞翻转状态并同步计数', () async {
    final post = (await repository.fetchFeed(page: 1)).first;
    final originalLikes = post.likes;

    final liked = await repository.toggleLike(post.id);
    expect(liked.liked, isTrue);
    expect(liked.likes, originalLikes + 1);

    final unliked = await repository.toggleLike(post.id);
    expect(unliked.liked, isFalse);
    expect(unliked.likes, originalLikes);
  }, skip: _kIntegrationSkip);

  test('评论写入后出现在列表并增加帖子评论数', () async {
    final post = (await repository.fetchFeed(page: 1)).first;
    final originalComments = post.comments;

    final updated = await repository.addComment(
      postId: post.id,
      content: '集成测试评论',
      author: testUser,
    );
    expect(updated.comments, originalComments + 1);
  }, skip: _kIntegrationSkip);
}
