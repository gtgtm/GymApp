import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/plans/domain/plan_models.dart';

class PlanRepository {
  PlanRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<MembershipPlan>> list() {
    return unwrap(
      () => _apiClient.dio.get('/membership-plans'),
      (data) => (data as List<dynamic>)
          .map((json) => MembershipPlan.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<MembershipPlan> create(PlanInput input) {
    return unwrap(
      () => _apiClient.dio.post('/membership-plans', data: input.toJson()),
      (data) => MembershipPlan.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> delete(int id) {
    return unwrap(
      () => _apiClient.dio.delete('/membership-plans/$id'),
      (_) => null,
    );
  }
}
