import 'package:gymapp_member/core/api/api_client.dart';
import 'package:gymapp_member/core/api/api_response.dart';
import 'package:gymapp_member/features/diet/domain/diet_models.dart';

class DietRepository {
  DietRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<DietPlan>> myDietPlans() {
    return unwrap(
      () => _apiClient.dio.get('/me/diet-plans'),
      (data) => (data as List<dynamic>)
          .map((item) => DietPlan.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
