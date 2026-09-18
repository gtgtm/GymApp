import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/reports/domain/report_models.dart';

class ReportRepository {
  ReportRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<FinancialSummary> financial({
    required String from,
    required String to,
  }) {
    return unwrap(
      () => _apiClient.dio.get(
        '/reports/financial',
        queryParameters: {'from': from, 'to': to},
      ),
      (data) => FinancialSummary.fromJson(
        (data as Map<String, dynamic>)['summary'] as Map<String, dynamic>,
      ),
    );
  }
}
