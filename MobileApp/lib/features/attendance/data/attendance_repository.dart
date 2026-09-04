import 'package:gymapp_member/core/api/api_client.dart';
import 'package:gymapp_member/core/api/api_response.dart';
import 'package:gymapp_member/features/attendance/data/attendance_models.dart';

class AttendanceRepository {
  AttendanceRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<AttendanceRecord>> myAttendance() {
    return unwrap(
      () => _apiClient.dio.get('/me/attendance'),
      (data) => (data as List<dynamic>)
          .map((item) => AttendanceRecord.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
