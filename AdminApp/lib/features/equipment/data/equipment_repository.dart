import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/equipment/domain/equipment_models.dart';

class EquipmentRepository {
  EquipmentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Equipment>> list() {
    return unwrap(
      () => _apiClient.dio.get('/equipment'),
      (data) =>
          (data as List<dynamic>).map((json) => Equipment.fromJson(json as Map<String, dynamic>)).toList(),
    );
  }

  Future<Equipment> create(EquipmentInput input) {
    return unwrap(
      () => _apiClient.dio.post('/equipment', data: input.toJson()),
      (data) => Equipment.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<Equipment>> maintenanceDue() {
    return unwrap(
      () => _apiClient.dio.get('/equipment-maintenance-due'),
      (data) =>
          (data as List<dynamic>).map((json) => Equipment.fromJson(json as Map<String, dynamic>)).toList(),
    );
  }
}
