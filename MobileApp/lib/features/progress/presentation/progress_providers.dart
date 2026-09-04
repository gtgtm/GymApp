import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_member/core/api/repository_providers.dart';
import 'package:gymapp_member/features/progress/domain/progress_models.dart';

part 'progress_providers.g.dart';

@riverpod
Future<ProgressData> myProgress(Ref ref) {
  return ref.watch(progressRepositoryProvider).myProgress();
}
