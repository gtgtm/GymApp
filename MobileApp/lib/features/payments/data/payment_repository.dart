import 'package:gymapp_member/core/api/api_client.dart';
import 'package:gymapp_member/core/api/api_response.dart';
import 'package:gymapp_member/features/payments/data/payment_models.dart';

class PaymentRepository {
  PaymentRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<PaymentRecord>> myPayments() {
    return unwrap(
      () => _apiClient.dio.get('/me/payments'),
      (data) => (data as List<dynamic>)
          .map((item) => PaymentRecord.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
