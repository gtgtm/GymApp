import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gymapp_admin/core/widgets/app_bottom_bar.dart';

/// Member portal routes. Kept under their own prefix so the router can
/// tell member screens from staff screens when enforcing the acting role.
abstract final class MemberRoutes {
  static const prefix = '/member';
  static const home = '/member';
  static const workout = '/member/workout';
  static const qr = '/member/qr';
  static const diet = '/member/diet';
  static const profile = '/member/profile';
  static const progress = '/member/progress';
  static const notifications = '/member/notifications';

  static bool contains(String location) =>
      location == prefix || location.startsWith('$prefix/');
}

const _titles = {
  MemberRoutes.workout: 'Workout',
  MemberRoutes.qr: 'My QR code',
  MemberRoutes.diet: 'Diet',
  MemberRoutes.profile: 'Profile',
  MemberRoutes.progress: 'Progress',
  MemberRoutes.notifications: 'Notifications',
};

/// Rebuilds [MemberShell] on every navigation (see StaffShellHost for why).
class MemberShellHost extends StatelessWidget {
  const MemberShellHost({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GoRouter.of(context).routerDelegate,
      builder: (context, _) => MemberShell(child: child),
    );
  }
}

class MemberShell extends StatelessWidget {
  const MemberShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(context).state.matchedLocation;
    final scheme = Theme.of(context).colorScheme;
    // Home draws its own pinned header.
    final title = _titles[location];

    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                title.toUpperCase(),
                style: const TextStyle(letterSpacing: 1.0),
              ),
              actions: [
                if (location != MemberRoutes.notifications)
                  IconButton(
                    tooltip: 'Notifications',
                    icon: const Icon(Icons.notifications_none_rounded),
                    color: scheme.primary,
                    onPressed: () => context.go(MemberRoutes.notifications),
                  ),
              ],
            ),
      bottomNavigationBar: _MemberBottomBar(location: location),
      body: child,
    );
  }
}

class _MemberBottomBar extends StatelessWidget {
  const _MemberBottomBar({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    BottomBarItem tab(String path, IconData icon, IconData on, String label) {
      return BottomBarItem(
        icon: icon,
        selectedIcon: on,
        label: label,
        selected: location == path,
        onTap: () => context.go(path),
      );
    }

    return AppBottomBar(
      children: [
        tab(MemberRoutes.home, Icons.home_outlined, Icons.home_rounded, 'Home'),
        tab(
          MemberRoutes.workout,
          Icons.fitness_center_outlined,
          Icons.fitness_center,
          'Workout',
        ),
        BottomBarCenterAction(
          icon: Icons.qr_code_2_rounded,
          label: 'My QR',
          selected: location == MemberRoutes.qr,
          onTap: () => context.go(MemberRoutes.qr),
        ),
        tab(
          MemberRoutes.diet,
          Icons.restaurant_outlined,
          Icons.restaurant,
          'Diet',
        ),
        tab(
          MemberRoutes.profile,
          Icons.person_outline_rounded,
          Icons.person_rounded,
          'Profile',
        ),
      ],
    );
  }
}
