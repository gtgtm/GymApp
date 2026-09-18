import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/expenses/domain/expense_models.dart';

class ExpenseRepository {
  ExpenseRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Expense>> list() {
    return unwrap(
      () => _apiClient.dio.get('/expenses'),
      (data) => (data as List<dynamic>)
          .map((json) => Expense.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Expense> create(ExpenseInput input) {
    return unwrap(
      () => _apiClient.dio.post('/expenses', data: input.toJson()),
      (data) => Expense.fromJson(data as Map<String, dynamic>),
    );
  }
}
