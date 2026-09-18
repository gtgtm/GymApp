import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/trainers/domain/trainer_models.dart';

class TrainerRepository {
  TrainerRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Trainer>> list() {
    return unwrap(
      () => _apiClient.dio.get('/trainers'),
      (data) => (data as List<dynamic>)
          .map((json) => Trainer.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Trainer> create(TrainerInput input) {
    return unwrap(
      () => _apiClient.dio.post('/trainers', data: input.toJson()),
      (data) => Trainer.fromJson(data as Map<String, dynamic>),
    );
  }
}
