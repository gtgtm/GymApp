import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gymapp_admin/core/theme/app_tokens.dart';

class QuickAction {
  const QuickAction(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;
}

const _allActions = [
  QuickAction('/members?new=1', 'Add Member', Icons.person_add_outlined),
  QuickAction(
    '/payments?new=1',
    'Collect Payment',
    Icons.account_balance_wallet_outlined,
  ),
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
    final actions = _allActions
        .where((action) => !exclude.contains(action.path))
        .toList();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final action in actions) _QuickActionTile(action: action),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(tokens.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        onTap: () => context.push(action.path),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outline),
            borderRadius: BorderRadius.circular(tokens.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                action.label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
