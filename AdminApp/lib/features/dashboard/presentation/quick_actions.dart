import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gymapp_admin/core/permissions/nav_permissions.dart';
import 'package:gymapp_admin/core/theme/app_tokens.dart';

class QuickAction {
  const QuickAction(
    this.path,
    this.label,
    this.icon,
    this.requires, {
    this.action,
  });

  final String path;
  final String label;
  final IconData icon;

  /// The nav permission the acting role needs for this shortcut to show.
  final NavKey requires;

  /// An extra write permission, for shortcuts that create something on a
  /// screen the role can otherwise only view (e.g. trainers and members).
  final StaffAction? action;

  bool isAllowedFor(String? roleName) =>
      canAccessNav(roleName, requires) &&
      (action == null || canPerform(roleName, action!));
}

const _allActions = [
  QuickAction(
    '/members?new=1',
    'Add member',
    Icons.person_add_alt_1_outlined,
    NavKey.members,
    action: StaffAction.createMember,
  ),
  QuickAction(
    '/payments?new=1',
    'Collect',
    Icons.payments_outlined,
    NavKey.payments,
  ),
  QuickAction(
    '/enquiries?new=1',
    'Enquiry',
    Icons.person_search_outlined,
    NavKey.enquiries,
  ),
  QuickAction(
    '/attendance',
    'Scan QR',
    Icons.qr_code_scanner,
    NavKey.attendance,
  ),
];

/// One card of up to four icon shortcuts. The first visible action is the
/// primary one (filled); the rest are tonal.
class QuickActions extends StatelessWidget {
  const QuickActions({required this.roleName, super.key});

  final String? roleName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;
    final actions = _allActions
        .where((action) => action.isAllowedFor(roleName))
        .toList();

    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(vertical: tokens.spacingMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < actions.length; i++)
            _QuickActionButton(action: actions[i], isPrimary: i == 0),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.action, required this.isPrimary});

  final QuickAction action;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;
    final radius = BorderRadius.circular(tokens.radiusMd);

    return Semantics(
      button: true,
      label: action.label,
      child: InkWell(
        borderRadius: radius,
        // Every shortcut targets a tab inside the shell, so switch to it
        // (go) rather than stacking it over the dashboard (push).
        onTap: () => context.go(action.path),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isPrimary ? scheme.primary : scheme.surface,
                  borderRadius: radius,
                  border: isPrimary ? null : Border.all(color: scheme.outline),
                  boxShadow: isPrimary
                      ? [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  action.icon,
                  color: isPrimary ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
