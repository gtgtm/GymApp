import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gymapp_admin/core/permissions/nav_permissions.dart';
import 'package:gymapp_admin/core/widgets/app_bottom_bar.dart';

class _Tab {
  const _Tab(this.path, this.key, this.icon, this.selectedIcon, this.label);

  final String path;
  final NavKey key;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Regular tabs in display order. The raised Check-in action is inserted
/// in the middle of whichever of these (plus "More") are visible.
const _tabs = [
  _Tab(
    '/dashboard',
    NavKey.dashboard,
    Icons.home_outlined,
    Icons.home_rounded,
    'Home',
  ),
  _Tab(
    '/members',
    NavKey.members,
    Icons.people_outline,
    Icons.people_rounded,
    'Members',
  ),
  _Tab(
    '/payments',
    NavKey.payments,
    Icons.credit_card_outlined,
    Icons.credit_card,
    'Billing',
  ),
];

const _checkInTab = _Tab(
  '/attendance',
  NavKey.attendance,
  Icons.qr_code_scanner,
  Icons.qr_code_scanner,
  'Check-in',
);

/// Primary navigation: the most-used screens as tabs, a raised Check-in
/// action in the middle, and "More" opening the shell drawer for
/// everything else. Tabs the acting role can't access are hidden.
class StaffBottomBar extends StatelessWidget {
  const StaffBottomBar({
    required this.location,
    required this.roleName,
    super.key,
  });

  final String location;
  final String? roleName;

  bool _isSelected(_Tab tab) =>
      location == tab.path || location.startsWith('${tab.path}/');

  @override
  Widget build(BuildContext context) {
    bool allowed(_Tab tab) => canAccessNav(roleName, tab.key);

    final visibleTabs = _tabs.where(allowed).toList();
    final showCheckIn = allowed(_checkInTab);
    final tabKeys = {..._tabs.map((tab) => tab.key), _checkInTab.key};
    // "More" opens the drawer; only worth a slot when the role can reach
    // screens the tabs don't already cover (a trainer can't, for example).
    final showMore = NavKey.values.any(
      (key) => !tabKeys.contains(key) && canAccessNav(roleName, key),
    );
    final isOnTab = [
      ...visibleTabs,
      if (showCheckIn) _checkInTab,
    ].any(_isSelected);

    final items = <Widget>[
      for (final tab in visibleTabs)
        _BarItem(tab: tab, selected: _isSelected(tab)),
      if (showMore) _MoreItem(selected: !isOnTab),
    ];
    if (showCheckIn) {
      // Centre the raised action: Home | Check-in | Members for a trainer,
      // Home, Members | Check-in | Billing, More for admin/reception.
      items.insert(
        (items.length / 2).ceil(),
        _CheckInButton(selected: _isSelected(_checkInTab)),
      );
    }

    return AppBottomBar(children: items);
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({required this.tab, required this.selected});

  final _Tab tab;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return BottomBarItem(
      icon: tab.icon,
      selectedIcon: tab.selectedIcon,
      label: tab.label,
      selected: selected,
      onTap: () => context.go(tab.path),
    );
  }
}

class _MoreItem extends StatelessWidget {
  const _MoreItem({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return BottomBarItem(
      icon: Icons.menu_rounded,
      label: 'More',
      selected: selected,
      onTap: () => Scaffold.of(context).openEndDrawer(),
    );
  }
}

class _CheckInButton extends StatelessWidget {
  const _CheckInButton({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return BottomBarCenterAction(
      icon: _checkInTab.icon,
      label: _checkInTab.label,
      selected: selected,
      onTap: () => context.go(_checkInTab.path),
    );
  }
}
