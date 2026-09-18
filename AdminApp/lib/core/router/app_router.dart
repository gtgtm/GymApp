import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/router/staff_shell.dart';
import 'package:gymapp_admin/features/attendance/presentation/attendance_screen.dart';
import 'package:gymapp_admin/features/auth/presentation/auth_controller.dart';
import 'package:gymapp_admin/features/auth/presentation/login_screen.dart';
import 'package:gymapp_admin/features/dashboard/presentation/dashboard_screen.dart';
import 'package:gymapp_admin/features/enquiries/presentation/enquiries_screen.dart';
import 'package:gymapp_admin/features/equipment/presentation/equipment_screen.dart';
import 'package:gymapp_admin/features/expenses/presentation/expenses_screen.dart';
import 'package:gymapp_admin/features/members/presentation/member_detail_screen.dart';
import 'package:gymapp_admin/features/members/presentation/members_screen.dart';
import 'package:gymapp_admin/features/payments/presentation/payments_screen.dart';
import 'package:gymapp_admin/features/plans/presentation/plans_screen.dart';
import 'package:gymapp_admin/features/platform/presentation/acting_gym_controller.dart';
import 'package:gymapp_admin/features/platform/presentation/gyms_screen.dart';
import 'package:gymapp_admin/features/reports/presentation/reports_screen.dart';
import 'package:gymapp_admin/features/search/presentation/search_screen.dart';
import 'package:gymapp_admin/features/trainers/presentation/trainers_screen.dart';
import 'package:gymapp_admin/features/trials/presentation/trials_screen.dart';

part 'app_router.g.dart';

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
    ref.listen(actingGymControllerProvider, (_, _) => notifyListeners());
  }
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refreshListenable = _AuthRefreshListenable(ref);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final user = authState.value;
      final isLoggedIn = user != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isGymsScreen = state.matchedLocation == '/gyms';

      if (authState.isLoading) return null;
      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) {
        return user.isSuperAdmin ? '/gyms' : '/dashboard';
      }

      // super_admin has no gym of its own — every gym-scoped screen requires
      // having entered one first via the gym directory (see GymsScreen).
      final hasEnteredGym = ref.read(actingGymControllerProvider) != null;
      if (isLoggedIn && user.isSuperAdmin && !hasEnteredGym && !isGymsScreen) {
        return '/gyms';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/gyms', builder: (context, state) => const GymsScreen()),
      ShellRoute(
        builder: (context, state, child) => StaffShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/members',
            builder: (context, state) => MembersScreen(
              openCreateOnLoad: state.uri.queryParameters['new'] == '1',
              expiryFilter: state.uri.queryParameters['filter'],
            ),
          ),
          GoRoute(
            path: '/enquiries',
            builder: (context, state) => EnquiriesScreen(
              openCreateOnLoad: state.uri.queryParameters['new'] == '1',
            ),
          ),
          GoRoute(
            path: '/trials',
            builder: (context, state) => TrialsScreen(
              openCreateOnLoad: state.uri.queryParameters['new'] == '1',
            ),
          ),
          GoRoute(
            path: '/trainers',
            builder: (context, state) => TrainersScreen(
              openCreateOnLoad: state.uri.queryParameters['new'] == '1',
            ),
          ),
          GoRoute(
            path: '/plans',
            builder: (context, state) => PlansScreen(
              openCreateOnLoad: state.uri.queryParameters['new'] == '1',
            ),
          ),
          GoRoute(
            path: '/payments',
            builder: (context, state) => PaymentsScreen(
              openCreateOnLoad: state.uri.queryParameters['new'] == '1',
            ),
          ),
          GoRoute(
            path: '/attendance',
            builder: (context, state) => const AttendanceScreen(),
          ),
          GoRoute(
            path: '/expenses',
            builder: (context, state) => ExpensesScreen(
              openCreateOnLoad: state.uri.queryParameters['new'] == '1',
            ),
          ),
          GoRoute(
            path: '/equipment',
            builder: (context, state) => EquipmentScreen(
              openCreateOnLoad: state.uri.queryParameters['new'] == '1',
            ),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/members/:id',
        builder: (context, state) => MemberDetailScreen(
          memberId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
    ],
  );
}
