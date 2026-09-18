import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/platform/domain/platform_models.dart';

part 'platform_providers.g.dart';

@riverpod
Future<List<GymSummary>> gymList(Ref ref) {
  return ref.watch(platformRepositoryProvider).gyms();
}

@riverpod
Future<GymDetail> gymDetail(Ref ref, int id) {
  return ref.watch(platformRepositoryProvider).gym(id);
}
