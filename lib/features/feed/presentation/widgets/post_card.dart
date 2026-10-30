import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/post.dart';
import '../../providers/feed_provider.dart';

class PostCard extends ConsumerWidget {
  const PostCard({super.key, required this.post, this.onTap});
  final Post post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 作者
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(post.author.avatar),
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(post.author.username,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(_timeAgo(post.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Text(post.content, style: Theme.of(context).textTheme.bodyMedium),
              if (post.imageUrl != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // 操作区
              Row(
                children: [
                  InkWell(
                    onTap: () => ref
                        .read(feedPaginationProvider.notifier)
                        .toggleLike(post),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            post.liked ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: post.liked ? Colors.red : null,
                          ),
                          const SizedBox(width: 4),
                          Text('${post.likes}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 18),
                          const SizedBox(width: 4),
                          Text('${post.comments}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }
}
