import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gymapp_admin/core/permissions/nav_permissions.dart';
import 'package:gymapp_admin/core/theme/app_tokens.dart';

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
    final scheme = Theme.of(context).colorScheme;
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: items,
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({required this.tab, required this.selected});

  final _Tab tab;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return _BarButton(
      icon: selected ? tab.selectedIcon : tab.icon,
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
    return _BarButton(
      icon: Icons.menu_rounded,
      label: 'More',
      selected: selected,
      onTap: () => Scaffold.of(context).openEndDrawer(),
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({
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
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 32,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: selected ? 20 : 0,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
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

/// The raised centre action — check-ins are the front desk's most
/// frequent task, so it gets the most prominent target.
class _CheckInButton extends StatelessWidget {
  const _CheckInButton({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(context.tokens.radiusLg);

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: _checkInTab.label,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () => context.go(_checkInTab.path),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Occupies a 44px slot in the bar but paints 58px tall, so
              // the button rises above the bar's top edge.
              SizedBox(
                height: 44,
                child: OverflowBox(
                  maxHeight: 58,
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: radius,
                      border: Border.all(color: scheme.surface, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.45),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      _checkInTab.icon,
                      color: scheme.onPrimary,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _checkInTab.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected ? scheme.primary : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
