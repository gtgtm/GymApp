import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/api_providers.dart';
import 'package:gymapp_admin/features/reports/data/report_repository.dart';
import 'package:gymapp_admin/features/reports/domain/report_models.dart';

part 'report_providers.g.dart';

@riverpod
ReportRepository reportRepository(Ref ref) {
  return ReportRepository(apiClient: ref.watch(apiClientProvider));
}

@riverpod
Future<FinancialSummary> financialSummary(Ref ref, String from, String to) {
  return ref.watch(reportRepositoryProvider).financial(from: from, to: to);
}
