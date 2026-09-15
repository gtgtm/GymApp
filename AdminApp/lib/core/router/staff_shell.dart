import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gymapp_admin/core/permissions/nav_permissions.dart';
import 'package:gymapp_admin/features/auth/presentation/auth_controller.dart';

class _NavItem {
  const _NavItem(this.path, this.key, this.icon, this.label);

  final String path;
  final NavKey key;
  final IconData icon;
  final String label;
}

const _navItems = [
  _NavItem('/dashboard', NavKey.dashboard, Icons.dashboard_outlined, 'Dashboard'),
  _NavItem('/members', NavKey.members, Icons.people_outline, 'Members'),
  _NavItem('/enquiries', NavKey.enquiries, Icons.person_search_outlined, 'Enquiries'),
  _NavItem('/trials', NavKey.trials, Icons.hourglass_empty, 'Trials'),
  _NavItem('/trainers', NavKey.trainers, Icons.fitness_center_outlined, 'Trainers'),
  _NavItem('/plans', NavKey.plans, Icons.assignment_outlined, 'Membership Plans'),
  _NavItem('/payments', NavKey.payments, Icons.payments_outlined, 'Payments'),
  _NavItem('/attendance', NavKey.attendance, Icons.qr_code_scanner_outlined, 'Attendance'),
  _NavItem('/expenses', NavKey.expenses, Icons.receipt_long_outlined, 'Expenses'),
  _NavItem('/equipment', NavKey.equipment, Icons.build_outlined, 'Equipment'),
  _NavItem('/reports', NavKey.reports, Icons.bar_chart_outlined, 'Reports'),
];

class StaffShell extends ConsumerWidget {
  const StaffShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final location = GoRouterState.of(context).matchedLocation;
    final visibleItems = _navItems.where((item) => canAccessNav(user?.roleName, item.key)).toList();
    final currentLabel = visibleItems
        .firstWhere(
          (item) => item.path == location,
          orElse: () => visibleItems.isNotEmpty ? visibleItems.first : _navItems.first,
        )
        .label;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentLabel),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('GymBrain', style: Theme.of(context).textTheme.headlineSmall),
                    Text(user?.gymName ?? '', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final item in visibleItems)
                      ListTile(
                        leading: Icon(item.icon),
                        title: Text(item.label),
                        selected: item.path == location,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go(item.path);
                        },
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log out'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(authControllerProvider.notifier).logout();
                },
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
