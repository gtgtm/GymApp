import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gymapp_member/features/attendance/presentation/attendance_screen.dart';
import 'package:gymapp_member/features/auth/presentation/auth_controller.dart';
import 'package:gymapp_member/features/auth/presentation/login_screen.dart';
import 'package:gymapp_member/features/dashboard/presentation/dashboard_screen.dart';
import 'package:gymapp_member/features/diet/presentation/diet_screen.dart';
import 'package:gymapp_member/features/notifications/presentation/notifications_screen.dart';
import 'package:gymapp_member/features/profile/presentation/profile_screen.dart';
import 'package:gymapp_member/features/progress/presentation/progress_screen.dart';
import 'package:gymapp_member/features/workout/presentation/workout_screen.dart';

part 'app_router.g.dart';

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
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
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (authState.isLoading) return null;
      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => _MemberShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/workout', builder: (context, state) => const WorkoutScreen()),
          GoRoute(path: '/diet', builder: (context, state) => const DietScreen()),
          GoRoute(path: '/progress', builder: (context, state) => const ProgressScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          GoRoute(path: '/attendance', builder: (context, state) => const AttendanceScreen()),
          GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
        ],
      ),
    ],
  );
}

class _MemberShell extends StatelessWidget {
  const _MemberShell({required this.child});

  final Widget child;

  static const _tabs = [
    ('/dashboard', Icons.home_outlined, Icons.home, 'Home'),
    ('/workout', Icons.fitness_center_outlined, Icons.fitness_center, 'Workout'),
    ('/diet', Icons.restaurant_outlined, Icons.restaurant, 'Diet'),
    ('/progress', Icons.show_chart_outlined, Icons.show_chart, 'Progress'),
    ('/profile', Icons.person_outline, Icons.person, 'Profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((tab) => tab.$1 == location);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final isTabRoute = _tabs.any((tab) => tab.$1 == GoRouterState.of(context).matchedLocation);

    return Scaffold(
      body: child,
      bottomNavigationBar: isTabRoute
          ? NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) => context.go(_tabs[index].$1),
              destinations: [
                for (final tab in _tabs)
                  NavigationDestination(
                    icon: Icon(tab.$2),
                    selectedIcon: Icon(tab.$3),
                    label: tab.$4,
                  ),
              ],
            )
          : null,
    );
  }
}
