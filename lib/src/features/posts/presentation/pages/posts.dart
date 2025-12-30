// lib/src/features/posts/presentation/posts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/posts_repository.dart';

// Провайдер данных
final postsProvider = FutureProvider((ref) {
  return ref.watch(postsRepositoryProvider).fetchPosts();
});

class PostsScreen extends ConsumerWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Feature-First Posts')),
      body: SelectionArea(
        child: postsAsync.when(
          data: (posts) => ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) =>
                ListTile(title: Text(posts[index].title)),
          ),
          error: (err, stack) => Center(child: Text('Error: $err')),
          loading: () => _LoadingShimmer(),
        ),
      ),
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (_, __) =>
            ListTile(title: Container(height: 20, color: Colors.white)),
      ),
    );
  }
}
