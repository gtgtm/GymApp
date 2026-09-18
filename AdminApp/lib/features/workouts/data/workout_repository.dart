import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/workouts/domain/workout_models.dart';

class WorkoutRepository {
  WorkoutRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<WorkoutPlan>> list(int memberId) {
    return unwrap(
      () => _apiClient.dio.get(
        '/workout-plans',
        queryParameters: {'member_id': memberId},
      ),
      (data) => (data as List<dynamic>)
          .map((json) => WorkoutPlan.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<WorkoutPlan> create(WorkoutPlanInput input) {
    return unwrap(
      () => _apiClient.dio.post('/workout-plans', data: input.toJson()),
      (data) => WorkoutPlan.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> delete(int id) {
    return unwrap(
      () => _apiClient.dio.delete('/workout-plans/$id'),
      (_) => null,
    );
  }
}
