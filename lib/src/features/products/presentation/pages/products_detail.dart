import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_feature_first_template/src/features/products/data/products_repository.dart';
import 'package:flutter_feature_first_template/src/features/products/domain/product.dart';
import 'package:flutter_feature_first_template/src/shared/utils/device.dart';
import 'package:shimmer/shimmer.dart';

final productDetailProvider = FutureProvider.family<Product, int>((
  ref,
  productId,
) async {
  final repository = ref.read(productsRepositoryProvider);
  return await repository.fetchProduct(productId);
});

class ProductDetailScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshProduct(ref),
          ),
        ],
      ),
      body: _buildProductDetail(context, ref),
    );
  }

  Widget _buildProductDetail(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return productAsync.when(
      loading: () => _buildShimmerLoader(context),
      error: (error, stack) =>
          _buildErrorWidget(context, error, () => _refreshProduct(ref)),
      data: (product) => _buildProductContent(context, product),
    );
  }

  Widget _buildProductContent(BuildContext context, Product product) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(DeviceUtils.adaptivePadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение продукта
          Hero(
            tag: 'product-image-${product.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: product.image,
                width: double.infinity,
                height: DeviceUtils.isDesktop(context) ? 400 : 300,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  height: DeviceUtils.isDesktop(context) ? 400 : 300,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: DeviceUtils.isDesktop(context) ? 400 : 300,
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error,
                        size: DeviceUtils.isMobile(context) ? 48 : 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load image',
                        style: TextStyle(
                          fontSize: DeviceUtils.adaptiveTextSize(
                            context,
                            mobile: 14,
                            tablet: 16,
                            desktop: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: DeviceUtils.adaptivePadding(context) * 1.5),

          // Название и цена
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: DeviceUtils.adaptiveTextSize(
                      context,
                      mobile: 18,
                      tablet: 22,
                      desktop: 26,
                    ),
                  ),
                ),
              ),
              Chip(
                backgroundColor: Colors.green[50],
                label: Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: DeviceUtils.adaptiveTextSize(
                      context,
                      mobile: 16,
                      tablet: 18,
                      desktop: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: DeviceUtils.adaptivePadding(context)),

          // Рейтинг
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DeviceUtils.adaptivePadding(context),
                  vertical: DeviceUtils.adaptivePadding(context) / 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber[700],
                      size: DeviceUtils.adaptiveTextSize(
                        context,
                        mobile: 18,
                        tablet: 20,
                        desktop: 22,
                      ),
                    ),
                    SizedBox(width: DeviceUtils.adaptivePadding(context) / 2),
                    Text(
                      product.rating.rate.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: DeviceUtils.adaptiveTextSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                    ),
                    SizedBox(width: DeviceUtils.adaptivePadding(context) / 4),
                    Text(
                      '(${product.rating.count} reviews)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: DeviceUtils.adaptiveTextSize(
                          context,
                          mobile: 12,
                          tablet: 13,
                          desktop: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: DeviceUtils.adaptivePadding(context)),

          // Категория
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: DeviceUtils.adaptivePadding(context),
              vertical: DeviceUtils.adaptivePadding(context) / 2,
            ),
            decoration: BoxDecoration(
              color: Colors.deepPurple[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              product.category.toUpperCase(),
              style: TextStyle(
                color: Colors.deepPurple[700],
                fontWeight: FontWeight.w500,
                fontSize: DeviceUtils.adaptiveTextSize(
                  context,
                  mobile: 11,
                  tablet: 12,
                  desktop: 13,
                ),
                letterSpacing: 0.5,
              ),
            ),
          ),

          SizedBox(height: DeviceUtils.adaptivePadding(context) * 1.5),

          // Описание
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: DeviceUtils.adaptiveTextSize(
                context,
                mobile: 18,
                tablet: 20,
                desktop: 22,
              ),
            ),
          ),
          SizedBox(height: DeviceUtils.adaptivePadding(context) / 2),
          Text(
            product.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[700],
              height: 1.5,
              fontSize: DeviceUtils.adaptiveTextSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
            ),
          ),

          SizedBox(height: DeviceUtils.adaptivePadding(context) * 2.5),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(
    BuildContext context,
    Object error,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DeviceUtils.adaptivePadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: DeviceUtils.isMobile(context) ? 48 : 64,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: DeviceUtils.adaptivePadding(context)),
            Text(
              'Error loading product',
              style: TextStyle(
                fontSize: DeviceUtils.adaptiveTextSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
              ),
            ),
            SizedBox(height: DeviceUtils.adaptivePadding(context) / 2),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: DeviceUtils.adaptiveTextSize(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 14,
                ),
                color: Colors.grey,
              ),
            ),
            SizedBox(height: DeviceUtils.adaptivePadding(context)),
            ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoader(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(DeviceUtils.adaptivePadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: DeviceUtils.isDesktop(context) ? 400 : 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: DeviceUtils.adaptivePadding(context) * 1.5),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: DeviceUtils.adaptiveTextSize(
                context,
                mobile: 32,
                tablet: 36,
                desktop: 40,
              ),
              color: Colors.white,
            ),
          ),
          SizedBox(height: DeviceUtils.adaptivePadding(context)),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: DeviceUtils.adaptiveTextSize(
                context,
                mobile: 120,
                tablet: 140,
                desktop: 160,
              ),
              height: DeviceUtils.adaptiveTextSize(
                context,
                mobile: 24,
                tablet: 28,
                desktop: 32,
              ),
              color: Colors.white,
            ),
          ),
          SizedBox(height: DeviceUtils.adaptivePadding(context)),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: DeviceUtils.adaptiveTextSize(
                context,
                mobile: 80,
                tablet: 100,
                desktop: 120,
              ),
              height: DeviceUtils.adaptiveTextSize(
                context,
                mobile: 24,
                tablet: 28,
                desktop: 32,
              ),
              color: Colors.white,
            ),
          ),
          SizedBox(height: DeviceUtils.adaptivePadding(context) * 1.5),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: DeviceUtils.adaptiveTextSize(
                context,
                mobile: 100,
                tablet: 120,
                desktop: 140,
              ),
              height: DeviceUtils.adaptiveTextSize(
                context,
                mobile: 28,
                tablet: 32,
                desktop: 36,
              ),
              color: Colors.white,
            ),
          ),
          SizedBox(height: DeviceUtils.adaptivePadding(context) / 2),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: DeviceUtils.adaptiveTextSize(
                context,
                mobile: 120,
                tablet: 140,
                desktop: 160,
              ),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _refreshProduct(WidgetRef ref) {
    ref.invalidate(productDetailProvider(productId));
  }
}
