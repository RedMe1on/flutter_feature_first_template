// lib/src/routing/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter_feature_first_template/src/features/products/presentation/pages/products.dart';
import 'package:flutter_feature_first_template/src/features/products/presentation/pages/products_detail.dart';
import '../features/posts/presentation/pages/posts.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PostsScreen(),
      routes: [
        GoRoute(
          path: 'products',
          builder: (context, state) => const ProductListScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return ProductDetailScreen(productId: id);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
