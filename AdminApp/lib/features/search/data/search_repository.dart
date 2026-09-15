import 'package:gymapp_admin/core/api/api_client.dart';
import 'package:gymapp_admin/core/api/api_response.dart';
import 'package:gymapp_admin/features/search/domain/search_models.dart';

class SearchRepository {
  SearchRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<GlobalSearchResults> search(String query) {
    return unwrap(
      () => _apiClient.dio.get('/search', queryParameters: {'q': query}),
      (data) => GlobalSearchResults.fromJson(data as Map<String, dynamic>),
    );
  }
}
