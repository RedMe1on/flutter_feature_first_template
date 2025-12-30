// lib/src/features/posts/data/posts_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_feature_first_template/src/shared/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/product.dart';

part 'products_repository.g.dart';

class ProductsRepository {
  final Dio _dio;
  ProductsRepository(this._dio);

  Future<List<Product>> fetchProducts() async {
    final response = await _dio.get('/products');
    final data = response.data as List;
    return data.map((json) => Product.fromJson(json)).toList();
  }

  Future<Product> fetchProduct(int id) async {
    try {
      final response = await _dio.get('/products/$id');

      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      }
      throw Exception('Failed to load product');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

@riverpod
ProductsRepository productsRepository(Ref ref) {
  // Watch за общим провайдером Dio
  final dio = ref.watch(dioFakeProvider);
  return ProductsRepository(dio);
}
