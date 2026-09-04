import 'package:dio/dio.dart';

import 'package:gymapp_member/core/auth/token_storage.dart';

/// Compile-time configurable API base URL.
/// Override at build/run time with:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
const _defaultBaseUrl = 'http://127.0.0.1:8000/api/v1';
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: _defaultBaseUrl,
);

typedef UnauthorizedCallback = void Function();

class ApiClient {
  ApiClient({required TokenStorage tokenStorage, UnauthorizedCallback? onUnauthorized})
      : _tokenStorage = tokenStorage,
        _dio = Dio(
          BaseOptions(
            baseUrl: apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 20),
            headers: {'Accept': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.read();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Dio get dio => _dio;
}
