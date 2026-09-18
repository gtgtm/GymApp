import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_admin/core/widgets/app_list_card.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/core/widgets/empty_state.dart';
import 'package:gymapp_admin/features/expenses/presentation/create_expense_sheet.dart';
import 'package:gymapp_admin/features/expenses/presentation/expense_providers.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({this.openCreateOnLoad = false, super.key});

  final bool openCreateOnLoad;

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.openCreateOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showCreateExpenseSheet(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expenseListProvider);
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateExpenseSheet(context),
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView(
        value: expensesAsync,
        onRetry: () => ref.invalidate(expenseListProvider),
        builder: (context, expenses) {
          if (expenses.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'No expenses recorded yet.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(expenseListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return AppListCard(
                  title: Text(expense.category.replaceAll('_', ' ')),
                  subtitle: Text(
                    expense.description ??
                        dateFormat.format(DateTime.parse(expense.expenseDate)),
                  ),
                  trailing: Text(
                    '₹${expense.amount}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
