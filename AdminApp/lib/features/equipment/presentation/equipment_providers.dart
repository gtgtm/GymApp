import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/equipment/domain/equipment_models.dart';

part 'equipment_providers.g.dart';

@riverpod
Future<List<Equipment>> equipmentList(Ref ref) {
  return ref.watch(equipmentRepositoryProvider).list();
}

@riverpod
Future<List<Equipment>> maintenanceDueList(Ref ref) {
  return ref.watch(equipmentRepositoryProvider).maintenanceDue();
}
