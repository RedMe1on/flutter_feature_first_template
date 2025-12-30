// lib/src/features/posts/data/posts_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/post.dart';

part 'posts_repository.g.dart';

class PostsRepository {
  final Dio _dio;
  PostsRepository(this._dio);

  Future<List<Post>> fetchPosts() async {
    final response = await _dio.get('https://jsonplaceholder.typicode.com/posts');
    final data = response.data as List;
    return data.map((json) => Post.fromJson(json)).toList();
  }
}

@riverpod
PostsRepository postsRepository(Ref ref) {
  return PostsRepository(Dio());
}
