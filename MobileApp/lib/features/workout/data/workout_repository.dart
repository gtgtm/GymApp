import 'package:gymapp_member/core/api/api_client.dart';
import 'package:gymapp_member/core/api/api_response.dart';
import 'package:gymapp_member/features/workout/domain/workout_models.dart';

class WorkoutRepository {
  WorkoutRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<WorkoutPlan>> myWorkoutPlans() {
    return unwrap(
      () => _apiClient.dio.get('/me/workout-plans'),
      (data) => (data as List<dynamic>)
          .map((item) => WorkoutPlan.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
