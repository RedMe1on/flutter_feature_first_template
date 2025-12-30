// lib/screens/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_feature_first_template/src/features/products/data/products_repository.dart';
import 'package:flutter_feature_first_template/src/features/products/domain/product.dart';
import 'package:flutter_feature_first_template/src/shared/utils/device.dart';
import 'package:flutter_feature_first_template/src/shared/utils/responsive.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

final productsProvider = FutureProvider((ref) {
  return ref.read(productsRepositoryProvider).fetchProducts();
});

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveLayout(
      mobileBody: _buildMobileLayout(context, ref),
      tabletBody: _buildTabletLayout(context, ref),
      desktopBody: _buildDesktopLayout(context, ref),
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshProducts(ref),
          ),
        ],
      ),
      body: _buildProductList(context, ref, crossAxisCount: 1),
    );
  }

  Widget _buildTabletLayout(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshProducts(ref),
          ),
          IconButton(icon: const Icon(Icons.grid_view), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildProductList(context, ref, crossAxisCount: 2),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshProducts(ref),
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _buildProductList(context, ref, crossAxisCount: 3),
      ),
    );
  }

  Widget _buildProductList(
    BuildContext context,
    WidgetRef ref, {
    required int crossAxisCount,
  }) {
    final productsAsync = ref.watch(productsProvider);

    return productsAsync.when(
      loading: () => _buildShimmerLoader(context, crossAxisCount),
      error: (error, stack) =>
          _buildErrorWidget(context, error, () => _refreshProducts(ref)),
      data: (products) {
        if (products.isEmpty) {
          return _buildEmptyWidget(context, () => _refreshProducts(ref));
        }

        if (crossAxisCount > 1) {
          return _buildGridView(context, products, crossAxisCount);
        } else {
          return _buildListView(context, products);
        }
      },
    );
  }

  Widget _buildListView(BuildContext context, List<Product> products) {
    return ListView.builder(
      padding: EdgeInsets.all(DeviceUtils.adaptivePadding(context)),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(context, product, isList: true);
      },
    );
  }

  Widget _buildGridView(
    BuildContext context,
    List<Product> products,
    int crossAxisCount,
  ) {
    return GridView.builder(
      padding: EdgeInsets.all(DeviceUtils.adaptivePadding(context)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: DeviceUtils.isDesktop(context) ? 0.8 : 0.9,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(context, product, isList: false);
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product, {
    bool isList = true,
  }) {
    if (isList) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Hero(
            tag: 'product-image-${product.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: product.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(width: 60, height: 60, color: Colors.grey[200]),
                errorWidget: (context, url, error) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          ),
          title: Text(
            product.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: DeviceUtils.adaptiveTextSize(
                context,
                mobile: 14,
                tablet: 15,
                desktop: 16,
              ),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: DeviceUtils.adaptiveTextSize(
                    context,
                    mobile: 14,
                    tablet: 15,
                    desktop: 16,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber[600],
                    size: DeviceUtils.adaptiveTextSize(
                      context,
                      mobile: 14,
                      tablet: 15,
                      desktop: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${product.rating.rate} (${product.rating.count})',
                    style: TextStyle(
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
            ],
          ),
          trailing: Icon(
            Icons.chevron_right,
            size: DeviceUtils.adaptiveTextSize(
              context,
              mobile: 20,
              tablet: 22,
              desktop: 24,
            ),
          ),
          onTap: () => context.go('/products/${product.id}'),
        ),
      );
    } else {
      return Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go('/products/${product.id}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Изображение
                Center(
                  child: Hero(
                    tag: 'product-image-${product.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: product.image,
                        width: double.infinity,
                        height: DeviceUtils.isDesktop(context) ? 200 : 150,
                        fit: BoxFit.contain,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.error)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Название
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: DeviceUtils.adaptiveTextSize(
                      context,
                      mobile: 14,
                      tablet: 15,
                      desktop: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Цена
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: DeviceUtils.adaptiveTextSize(
                      context,
                      mobile: 16,
                      tablet: 17,
                      desktop: 18,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),

                // Рейтинг
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber[600],
                      size: DeviceUtils.adaptiveTextSize(
                        context,
                        mobile: 16,
                        tablet: 17,
                        desktop: 18,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.rating.rate.toString(),
                      style: TextStyle(
                        fontSize: DeviceUtils.adaptiveTextSize(
                          context,
                          mobile: 14,
                          tablet: 15,
                          desktop: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${product.rating.count})',
                      style: TextStyle(
                        fontSize: DeviceUtils.adaptiveTextSize(
                          context,
                          mobile: 12,
                          tablet: 13,
                          desktop: 14,
                        ),
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.category,
                        style: TextStyle(
                          fontSize: DeviceUtils.adaptiveTextSize(
                            context,
                            mobile: 10,
                            tablet: 11,
                            desktop: 12,
                          ),
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
            const SizedBox(height: 16),
            Text(
              'Error loading products',
              style: TextStyle(
                fontSize: DeviceUtils.adaptiveTextSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context, VoidCallback onRefresh) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(DeviceUtils.adaptivePadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: DeviceUtils.isMobile(context) ? 48 : 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: DeviceUtils.adaptiveTextSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRefresh, child: const Text('Refresh')),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoader(BuildContext context, int crossAxisCount) {
    if (crossAxisCount > 1) {
      return GridView.builder(
        padding: EdgeInsets.all(DeviceUtils.adaptivePadding(context)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: DeviceUtils.isDesktop(context) ? 0.8 : 0.9,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: DeviceUtils.isDesktop(context) ? 200 : 150,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Container(height: 16, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 14, width: 80, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 14, width: 60, color: Colors.white),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      return ListView.builder(
        padding: EdgeInsets.all(DeviceUtils.adaptivePadding(context)),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(width: 60, height: 60, color: Colors.white),
                title: Container(height: 16, color: Colors.white),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Container(height: 14, width: 80, color: Colors.white),
                    const SizedBox(height: 4),
                    Container(height: 12, width: 100, color: Colors.white),
                  ],
                ),
                trailing: Container(width: 24, height: 24, color: Colors.white),
              ),
            ),
          );
        },
      );
    }
  }

  void _refreshProducts(WidgetRef ref) {
    ref.invalidate(productsProvider);
  }
}
