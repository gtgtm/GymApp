import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_admin/core/permissions/nav_permissions.dart';
import 'package:gymapp_admin/core/router/staff_shell.dart';
import 'package:gymapp_admin/features/attendance/presentation/attendance_screen.dart';
import 'package:gymapp_admin/features/auth/presentation/auth_controller.dart';
import 'package:gymapp_admin/features/auth/presentation/login_screen.dart';
import 'package:gymapp_admin/features/auth/presentation/my_gyms_screen.dart';
import 'package:gymapp_admin/features/dashboard/presentation/dashboard_screen.dart';
import 'package:gymapp_admin/features/enquiries/presentation/enquiries_screen.dart';
import 'package:gymapp_admin/features/equipment/presentation/equipment_screen.dart';
import 'package:gymapp_admin/features/expenses/presentation/expenses_screen.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_home_screen.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_notifications_screen.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_plan_screens.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_profile_screen.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_progress_screen.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_qr_screen.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_shell.dart';
import 'package:gymapp_admin/features/members/presentation/member_detail_screen.dart';
import 'package:gymapp_admin/features/members/presentation/members_screen.dart';
import 'package:gymapp_admin/features/payments/presentation/payments_screen.dart';
import 'package:gymapp_admin/features/plans/presentation/plans_screen.dart';
import 'package:gymapp_admin/features/auth/presentation/acting_gym_controller.dart';
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

/// A top-level tab inside the shell. Switching tabs replaces the page
/// instantly: the default iOS slide would briefly show the previous tab
/// behind the new one, which reads as a broken "push" animation.
GoRoute _tabRoute(String path, Widget Function(GoRouterState state) build) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) =>
        NoTransitionPage(key: state.pageKey, child: build(state)),
  );
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
      final isMyGymsScreen = state.matchedLocation == '/my-gyms';

      if (authState.isLoading) return null;
      if (!isLoggedIn && !isLoggingIn) return '/login';

      if (isLoggedIn && isLoggingIn) {
        return user.requiresGymSelection ? '/my-gyms' : '/dashboard';
      }

      final actingGym = ref.read(actingGymControllerProvider);

      // A regular login with more than one membership must explicitly pick
      // a gym via MyGymsScreen before reaching any gym-scoped route. A
      // sole-membership login is auto-entered by AuthController right when
      // the user object first becomes available (login/currentUser), so by
      // the time redirect() runs, actingGym is already set for that case —
      // this branch only fires for the genuine multi-gym, none-picked-yet
      // state.
      if (isLoggedIn && actingGym == null && !isMyGymsScreen) {
        return '/my-gyms';
      }

      // The role at the acting gym decides which app the person sees: a
      // member gets the member portal, staff get the staff screens. The
      // same login can be a trainer at one gym and a member at another,
      // so this is re-evaluated whenever the acting gym changes.
      if (actingGym != null && !isMyGymsScreen) {
        final isMember = isMemberRole(ref.read(actingRoleNameProvider));
        final onMemberRoute = MemberRoutes.contains(state.matchedLocation);
        if (isMember && !onMemberRoute) return MemberRoutes.home;
        if (!isMember && onMemberRoute) return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/my-gyms',
        builder: (context, state) => const MyGymsScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MemberShellHost(child: child),
        routes: [
          _tabRoute(MemberRoutes.home, (state) => const MemberHomeScreen()),
          _tabRoute(
            MemberRoutes.workout,
            (state) => const MemberWorkoutScreen(),
          ),
          _tabRoute(MemberRoutes.qr, (state) => const MemberQrScreen()),
          _tabRoute(MemberRoutes.diet, (state) => const MemberDietScreen()),
          _tabRoute(
            MemberRoutes.profile,
            (state) => const MemberProfileScreen(),
          ),
          _tabRoute(
            MemberRoutes.progress,
            (state) => const MemberProgressScreen(),
          ),
          _tabRoute(
            MemberRoutes.notifications,
            (state) => const MemberNotificationsScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => StaffShellHost(child: child),
        routes: [
          _tabRoute('/dashboard', (state) => const DashboardScreen()),
          _tabRoute(
            '/members',
            (state) => MembersScreen(
              openCreateOnLoad: state.uri.queryParameters['new'] == '1',
              expiryFilter: state.uri.queryParameters['filter'],
            ),
          ),
          _tabRoute(
            '/enquiries',
            (state) => EnquiriesScreen(
              openCreateOnLoad: state.uri.queryParameters['new'] == '1',
            ),
          ),
          _tabRoute(
            '/trials',
            (state) => TrialsScreen(
              openCreateOnLoad: state.uri.queryParameters['new'] == '1',
            ),
          ),
          _tabRoute(
            '/trainers',
            (state) => TrainersScreen(
              openCreateOnLoad: state.uri.queryParameters['new'] == '1',
            ),
          ),
          _tabRoute(
            '/plans',
            (state) => PlansScreen(
              openCreateOnLoad: state.uri.queryParameters['new'] == '1',
            ),
          ),
          _tabRoute(
            '/payments',
            (state) => PaymentsScreen(
              openCreateOnLoad: state.uri.queryParameters['new'] == '1',
            ),
          ),
          _tabRoute('/attendance', (state) => const AttendanceScreen()),
          _tabRoute(
            '/expenses',
            (state) => ExpensesScreen(
              openCreateOnLoad: state.uri.queryParameters['new'] == '1',
            ),
          ),
          _tabRoute(
            '/equipment',
            (state) => EquipmentScreen(
              openCreateOnLoad: state.uri.queryParameters['new'] == '1',
            ),
          ),
          _tabRoute('/reports', (state) => const ReportsScreen()),
          // Pushed detail screens also live inside the shell so the bottom
          // nav bar stays visible on every screen.
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
      ),
    ],
  );
}
