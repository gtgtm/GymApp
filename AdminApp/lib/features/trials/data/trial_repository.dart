import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/trials/domain/trial_models.dart';

class TrialRepository {
  TrialRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Trial>> list() {
    return unwrap(
      () => _apiClient.dio.get('/trials'),
      (data) => (data as List<dynamic>).map((json) => Trial.fromJson(json as Map<String, dynamic>)).toList(),
    );
  }

  Future<Trial> create(TrialInput input) {
    return unwrap(
      () => _apiClient.dio.post('/trials', data: input.toJson()),
      (data) => Trial.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Trial> updateStatus(int id, String status) {
    return unwrap(
      () => _apiClient.dio.put('/trials/$id', data: {'status': status}),
      (data) => Trial.fromJson(data as Map<String, dynamic>),
    );
  }
}
