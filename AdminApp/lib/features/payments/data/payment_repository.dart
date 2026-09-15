import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/payments/domain/payment_models.dart';

class PaymentRepository {
  PaymentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Payment>> list() {
    return unwrap(
      () => _apiClient.dio.get('/payments'),
      (data) =>
          (data as List<dynamic>).map((json) => Payment.fromJson(json as Map<String, dynamic>)).toList(),
    );
  }

  Future<Payment> create(PaymentInput input) {
    return unwrap(
      () => _apiClient.dio.post('/payments', data: input.toJson()),
      (data) => Payment.fromJson(data as Map<String, dynamic>),
    );
  }
}
