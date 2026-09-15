import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/expenses/domain/expense_models.dart';

part 'expense_providers.g.dart';

@riverpod
Future<List<Expense>> expenseList(Ref ref) {
  return ref.watch(expenseRepositoryProvider).list();
}
