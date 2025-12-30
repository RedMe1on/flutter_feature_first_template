// lib/src/routing/app_router.dart
import 'package:go_router/go_router.dart';
import '../features/posts/presentation/pages/posts.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PostsScreen(),
    ),
  ],
);
