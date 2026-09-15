import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickAction {
  const QuickAction(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;
}

const _allActions = [
  QuickAction('/members?new=1', 'Add Member', Icons.person_add_outlined),
  QuickAction('/payments?new=1', 'Collect Payment', Icons.account_balance_wallet_outlined),
  QuickAction('/attendance', 'Mark Attendance', Icons.event_available_outlined),
  QuickAction('/plans?new=1', 'Add Plan', Icons.assignment_add),
  QuickAction('/enquiries?new=1', 'Add Enquiry', Icons.person_search_outlined),
  QuickAction('/expenses?new=1', 'Add Expense', Icons.receipt_long_outlined),
];

class QuickActions extends StatelessWidget {
  const QuickActions({this.exclude = const [], super.key});

  final List<String> exclude;

  @override
  Widget build(BuildContext context) {
    final actions = _allActions.where((action) => !exclude.contains(action.path)).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final action in actions)
          OutlinedButton.icon(
            onPressed: () => context.push(action.path),
            icon: Icon(action.icon, size: 18),
            label: Text(action.label),
          ),
      ],
    );
  }
}
