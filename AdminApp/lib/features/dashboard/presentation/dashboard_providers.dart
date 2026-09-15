import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/dashboard/domain/dashboard_models.dart';

part 'dashboard_providers.g.dart';

@riverpod
Future<DashboardData> dashboardData(Ref ref) {
  return ref.watch(dashboardRepositoryProvider).fetch();
}
