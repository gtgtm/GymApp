import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/trials/domain/trial_models.dart';

part 'trial_providers.g.dart';

@riverpod
Future<List<Trial>> trialList(Ref ref) {
  return ref.watch(trialRepositoryProvider).list();
}
