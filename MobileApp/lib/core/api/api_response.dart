import 'package:dio/dio.dart';

import 'package:gymapp_member/core/api/api_exception.dart';

/// Unwraps the backend's `{ success, data, error, meta }` envelope.
///
/// [parse] converts the raw `data` payload into a typed model. Throws
/// [ApiException] when the backend reports failure or the request itself
/// fails at the transport level.
Future<T> unwrap<T>(
  Future<Response<dynamic>> Function() request,
  T Function(dynamic data) parse,
) async {
  try {
    final response = await request();
    final body = response.data as Map<String, dynamic>;

    if (body['success'] == true) {
      return parse(body['data']);
    }

    final error = body['error'] as Map<String, dynamic>?;
    throw ApiException(
      error?['message'] as String? ?? 'Something went wrong.',
      statusCode: response.statusCode,
      fieldErrors: (error?['errors'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, List<String>.from(value as List)),
      ),
    );
  } on DioException catch (error) {
    final body = error.response?.data;
    if (body is Map<String, dynamic> && body['error'] != null) {
      final errorBody = body['error'] as Map<String, dynamic>;
      throw ApiException(
        errorBody['message'] as String? ?? 'Something went wrong.',
        statusCode: error.response?.statusCode,
      );
    }

    throw ApiException(
      switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          'The connection timed out. Please try again.',
        DioExceptionType.connectionError => 'Could not reach the server. Check your connection.',
        _ => 'Something went wrong. Please try again.',
      },
      statusCode: error.response?.statusCode,
    );
  }
}
