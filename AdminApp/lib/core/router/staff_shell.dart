import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gymapp_admin/core/permissions/nav_permissions.dart';
import 'package:gymapp_admin/core/theme/app_tokens.dart';
import 'package:gymapp_admin/features/auth/presentation/auth_controller.dart';
import 'package:gymapp_admin/features/platform/presentation/acting_gym_controller.dart';

class _NavItem {
  const _NavItem(this.path, this.key, this.icon, this.label);

  final String path;
  final NavKey key;
  final IconData icon;
  final String label;
}

const _navItems = [
  _NavItem(
    '/dashboard',
    NavKey.dashboard,
    Icons.dashboard_outlined,
    'Dashboard',
  ),
  _NavItem('/members', NavKey.members, Icons.people_outline, 'Members'),
  _NavItem(
    '/enquiries',
    NavKey.enquiries,
    Icons.person_search_outlined,
    'Enquiries',
  ),
  _NavItem('/trials', NavKey.trials, Icons.hourglass_empty, 'Trials'),
  _NavItem(
    '/trainers',
    NavKey.trainers,
    Icons.fitness_center_outlined,
    'Trainers',
  ),
  _NavItem(
    '/plans',
    NavKey.plans,
    Icons.assignment_outlined,
    'Membership Plans',
  ),
  _NavItem('/payments', NavKey.payments, Icons.payments_outlined, 'Payments'),
  _NavItem(
    '/attendance',
    NavKey.attendance,
    Icons.qr_code_scanner_outlined,
    'Attendance',
  ),
  _NavItem(
    '/expenses',
    NavKey.expenses,
    Icons.receipt_long_outlined,
    'Expenses',
  ),
  _NavItem('/equipment', NavKey.equipment, Icons.build_outlined, 'Equipment'),
  _NavItem('/reports', NavKey.reports, Icons.bar_chart_outlined, 'Reports'),
];

class StaffShell extends ConsumerWidget {
  const StaffShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final actingGym = ref.watch(actingGymControllerProvider);
    final actingRoleName = ref.watch(actingRoleNameProvider);
    final location = GoRouterState.of(context).matchedLocation;
    final visibleItems = _navItems
        .where((item) => canAccessNav(actingRoleName, item.key))
        .toList();
    final currentLabel = visibleItems
        .firstWhere(
          (item) => item.path == location,
          orElse: () =>
              visibleItems.isNotEmpty ? visibleItems.first : _navItems.first,
        )
        .label;
    final displayGymName =
        actingGym?.name ?? user?.soleMembership?.gymName ?? '';
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentLabel.toUpperCase(),
          style: const TextStyle(letterSpacing: 1.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: scheme.primary,
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      bottomNavigationBar: actingGym == null
          ? null
          : Material(
              color: scheme.tertiaryContainer,
              child: SafeArea(
                top: false,
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.visibility_outlined,
                    color: scheme.tertiary,
                  ),
                  title: Text('Viewing: ${actingGym.name}'),
                  trailing: TextButton(
                    onPressed: () {
                      ref.read(actingGymControllerProvider.notifier).exit();
                      context.go('/gyms');
                    },
                    child: const Text('Exit'),
                  ),
                ),
              ),
            ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: scheme.surface),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'GYMBRAIN',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: scheme.primary,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayGymName,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    for (final item in visibleItems)
                      _DrawerNavTile(
                        icon: item.icon,
                        label: item.label,
                        selected: item.path == location,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go(item.path);
                        },
                      ),
                  ],
                ),
              ),
              Divider(height: 1, color: scheme.outline),
              Padding(
                padding: EdgeInsets.symmetric(vertical: tokens.spacingXs),
                child: ListTile(
                  leading: Icon(Icons.logout, color: scheme.error),
                  title: Text('Log out', style: TextStyle(color: scheme.error)),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await ref.read(authControllerProvider.notifier).logout();
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}

class _DrawerNavTile extends StatelessWidget {
  const _DrawerNavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spacingSm, vertical: 2),
      child: Material(
        color: selected
            ? scheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                if (selected)
                  Container(
                    width: 3,
                    height: 20,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                else
                  const SizedBox(width: 15),
                Icon(
                  icon,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? scheme.primary : scheme.onSurface,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
