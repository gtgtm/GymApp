import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/progress/domain/progress_models.dart';

part 'progress_providers.g.dart';

@riverpod
Future<List<BodyMeasurement>> bodyMeasurementList(Ref ref, int memberId) {
  return ref.watch(progressRepositoryProvider).measurements(memberId);
}

@riverpod
Future<List<ProgressPhoto>> progressPhotoList(Ref ref, int memberId) {
  return ref.watch(progressRepositoryProvider).photos(memberId);
}
