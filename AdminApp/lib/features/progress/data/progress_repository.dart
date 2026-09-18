import 'package:dio/dio.dart';

import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/progress/domain/progress_models.dart';

class ProgressRepository {
  ProgressRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<BodyMeasurement>> measurements(int memberId) {
    return unwrap(
      () => _apiClient.dio.get(
        '/body-measurements',
        queryParameters: {'member_id': memberId},
      ),
      (data) => (data as List<dynamic>)
          .map((json) => BodyMeasurement.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<BodyMeasurement> addMeasurement(BodyMeasurementInput input) {
    return unwrap(
      () => _apiClient.dio.post('/body-measurements', data: input.toJson()),
      (data) => BodyMeasurement.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<ProgressPhoto>> photos(int memberId) {
    return unwrap(
      () => _apiClient.dio.get(
        '/progress-photos',
        queryParameters: {'member_id': memberId},
      ),
      (data) => (data as List<dynamic>)
          .map((json) => ProgressPhoto.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ProgressPhoto> uploadPhoto({
    required int memberId,
    required String filePath,
    required String takenOn,
    String? type,
  }) {
    final formData = FormData.fromMap({
      'member_id': memberId,
      'taken_on': takenOn,
      if (type != null) 'type': type,
      'photo': MultipartFile.fromFileSync(filePath),
    });

    return unwrap(
      () => _apiClient.dio.post('/progress-photos', data: formData),
      (data) => ProgressPhoto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deletePhoto(int id) {
    return unwrap(
      () => _apiClient.dio.delete('/progress-photos/$id'),
      (_) => null,
    );
  }
}
