import 'package:dio/dio.dart';

import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_exception.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/attendance/domain/attendance_models.dart';
import 'package:gymapp_admin/features/attendance/domain/mark_attendance_exception.dart';

class AttendanceRepository {
  AttendanceRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<AttendanceEntry>> today() {
    final today = DateTime.now().toIso8601String().split('T').first;
    return unwrap(
      () => _apiClient.dio.get('/attendance', queryParameters: {'date': today}),
      (data) => (data as List<dynamic>)
          .map((json) => AttendanceEntry.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<MarkAttendanceResult> markByMemberId(int memberId) {
    return _markAttendance(
      () => _apiClient.dio.post('/attendance', data: {'member_id': memberId}),
    );
  }

  Future<MarkAttendanceResult> scanQr(String qrToken) {
    return _markAttendance(
      () => _apiClient.dio.post(
        '/attendance/scan-qr',
        data: {'qr_token': qrToken},
      ),
    );
  }

  Future<MarkAttendanceResult> _markAttendance(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final body = response.data as Map<String, dynamic>;
      return MarkAttendanceResult.fromJson(
        body['data'] as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      final body = error.response?.data;
      if (body is Map<String, dynamic> && error.response?.statusCode == 422) {
        final errorBody = body['error'] as Map<String, dynamic>?;
        final errors = errorBody?['errors'] as Map<String, dynamic>?;
        throw MembershipExpiredException(
          message:
              errorBody?['message'] as String? ?? 'Membership has expired.',
          membershipEndDate: errors?['membership_end_date'] as String?,
          member: errors?['member'] == null
              ? null
              : AttendanceMemberRef.fromJson(
                  errors!['member'] as Map<String, dynamic>,
                ),
        );
      }
      if (body is Map<String, dynamic> && body['error'] != null) {
        final errorBody = body['error'] as Map<String, dynamic>;
        throw ApiException(
          errorBody['message'] as String? ?? 'Failed to mark attendance.',
          statusCode: error.response?.statusCode,
        );
      }
      throw const ApiException('Failed to mark attendance.');
    }
  }
}
