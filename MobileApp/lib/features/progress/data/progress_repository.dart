import 'package:gymapp_member/core/api/api_client.dart';
import 'package:gymapp_member/core/api/api_response.dart';
import 'package:gymapp_member/features/progress/domain/progress_models.dart';

class ProgressRepository {
  ProgressRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ProgressData> myProgress() {
    return unwrap(
      () => _apiClient.dio.get('/me/progress'),
      (data) => ProgressData.fromJson(data as Map<String, dynamic>),
    );
  }
}
