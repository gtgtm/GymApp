import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/enquiries/domain/enquiry_models.dart';

part 'enquiry_providers.g.dart';

@riverpod
Future<List<Enquiry>> enquiryList(Ref ref) {
  return ref.watch(enquiryRepositoryProvider).list();
}

@riverpod
Future<ConversionStats> conversionStats(Ref ref) {
  return ref.watch(enquiryRepositoryProvider).conversionStats();
}
