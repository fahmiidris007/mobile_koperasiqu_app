import 'dart:developer';

import 'package:dio/dio.dart';
import 'auth_interceptor.dart';

/// Singleton Dio client configured for KoperasiQu API
class ApiClient {
  ApiClient._();

  static const String baseUrl = 'http://34.87.41.221:8000/api';

  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => log('[API] $obj'),
      ),
    );

    return dio;
  }

  /// Reset instance (useful for logout / testing)
  static void reset() {
    _instance = null;
  }
}
