import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_member/core/api/repository_providers.dart';
import 'package:gymapp_member/features/payments/data/payment_models.dart';

part 'payment_providers.g.dart';

@riverpod
Future<List<PaymentRecord>> myPayments(Ref ref) {
  return ref.watch(paymentRepositoryProvider).myPayments();
}
