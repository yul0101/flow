import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_views.dart';
import '../../../core/widgets/async_value_builder.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/comment.dart';
import '../domain/post.dart';
import '../providers/feed_provider.dart';
import 'widgets/post_card.dart';

/// 帖子详情：正文 + 评论列表 + 评论输入。
class PostDetailPage extends ConsumerStatefulWidget {
  const PostDetailPage({super.key, required this.postId});
  final String postId;

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final _commentController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Post? _findPost(List<Post>? posts) {
    if (posts == null) return null;
    for (final post in posts) {
      if (post.id == widget.postId) return post;
    }
    return null;
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty || _sending) return;
    final user = ref.read(authProvider).value;
    if (user == null) return;

    setState(() => _sending = true);
    try {
      await ref.read(addCommentProvider((
        postId: widget.postId,
        content: content,
        author: user,
      )).future);
      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('评论失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = _findPost(ref.watch(feedPaginationProvider).value);
    final commentsState = ref.watch(commentsProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(title: const Text('帖子')),
      body: post == null
          ? const AppEmptyView(message: '帖子不存在或已删除')
          : Column(
              children: [
                PostCard(post: post),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('评论', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                Expanded(
                  child: AsyncValueBuilder(
                    value: commentsState,
                    data: (comments) => comments.isEmpty
                        ? const AppEmptyView(message: '还没有评论，来说第一句')
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: comments.length,
                            separatorBuilder: (_, __) => const Divider(height: 16),
                            itemBuilder: (_, index) =>
                                _CommentTile(comment: comments[index]),
                          ),
                  ),
                ),
                const Divider(height: 1),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendComment(),
                            decoration: const InputDecoration(
                              hintText: '写评论…',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _sending ? null : _sendComment,
                          icon: _sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});
  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(comment.author.avatar),
          radius: 14,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment.author.username,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 2),
              Text(comment.content),
            ],
          ),
        ),
      ],
    );
  }
}
