import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/api_providers.dart';
import 'package:gymapp_admin/features/search/data/search_repository.dart';
import 'package:gymapp_admin/features/search/domain/search_models.dart';

part 'search_providers.g.dart';

@riverpod
SearchRepository searchRepository(Ref ref) {
  return SearchRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
Future<GlobalSearchResults> globalSearch(Ref ref, String query) {
  if (query.trim().length < 2) {
    return Future.value(
      const GlobalSearchResults(
        members: [],
        trainers: [],
        payments: [],
        enquiries: [],
      ),
    );
  }
  return ref.watch(searchRepositoryProvider).search(query);
}
