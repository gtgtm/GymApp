import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/trainers/domain/trainer_models.dart';

part 'trainer_providers.g.dart';

@riverpod
Future<List<Trainer>> trainerList(Ref ref) {
  return ref.watch(trainerRepositoryProvider).list();
}
