import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/enquiries/domain/enquiry_models.dart';

class EnquiryRepository {
  EnquiryRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Enquiry>> list() {
    return unwrap(
      () => _apiClient.dio.get('/enquiries'),
      (data) => (data as List<dynamic>)
          .map((json) => Enquiry.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Enquiry> create(EnquiryInput input) {
    return unwrap(
      () => _apiClient.dio.post('/enquiries', data: input.toJson()),
      (data) => Enquiry.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Enquiry> updateStatus(int id, String status) {
    return unwrap(
      () => _apiClient.dio.put('/enquiries/$id', data: {'status': status}),
      (data) => Enquiry.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ConversionStats> conversionStats() {
    return unwrap(
      () => _apiClient.dio.get('/enquiries-stats/conversion'),
      (data) => ConversionStats.fromJson(data as Map<String, dynamic>),
    );
  }
}
