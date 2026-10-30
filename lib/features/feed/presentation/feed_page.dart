import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/widgets/async_value_builder.dart';
import '../providers/feed_provider.dart';
import 'widgets/post_card.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});
  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final notifier = ref.read(feedPaginationProvider.notifier);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        notifier.hasMore &&
        !notifier.loadingMore &&
        !ref.read(feedPaginationProvider).isLoading) {
      notifier.loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(feedPaginationProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedPaginationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.compose),
        tooltip: '发帖',
        child: const Icon(Icons.edit_outlined),
      ),
      body: AsyncValueBuilder(
        value: feedState,
        data: (posts) => RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: posts.length + 1,
            separatorBuilder: (_, __) => const SizedBox.shrink(),
            itemBuilder: (context, index) {
              if (index == posts.length) {
                final notifier = ref.read(feedPaginationProvider.notifier);
                if (ref.read(feedPaginationProvider).isLoading && posts.isNotEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!notifier.hasMore && posts.isNotEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('—— 没有更多了 ——')),
                  );
                }
                return const SizedBox.shrink();
              }
              final post = posts[index];
              return PostCard(
                post: post,
                onTap: () => context.push('/post/${post.id}'),
              );
            },
          ),
        ),
      ),
    );
  }
}
