import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/payments/domain/payment_models.dart';

part 'payment_providers.g.dart';

@riverpod
Future<List<Payment>> paymentList(Ref ref) {
  return ref.watch(paymentRepositoryProvider).list();
}
