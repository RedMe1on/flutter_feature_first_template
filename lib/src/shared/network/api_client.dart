import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_feature_first_template/src/shared/network/api_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'api_client.g.dart';

@riverpod
Dio dio(Ref ref) {
  final options = BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
    receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  final dio = Dio(options);

  // Добавляем логирование или интерцепторы (например, для токенов)
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
}

@riverpod
Dio dioFake(Ref ref) {
  final options = BaseOptions(
    baseUrl: 'https://fakestoreapi.com',
    connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
    receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  final dio = Dio(options);

  // Добавляем логирование или интерцепторы (например, для токенов)
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
}