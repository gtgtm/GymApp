import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_admin/core/theme/app_tokens.dart';

/// Date, gym name, and the two header actions (search, profile/menu).
/// Replaces the shell AppBar on the dashboard, so the avatar opens the
/// shell's drawer.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    required this.gymName,
    required this.userName,
    super.key,
  });

  final String gymName;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final initial = userName.isEmpty ? '?' : userName[0].toUpperCase();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEE · d MMMM').format(DateTime.now()),
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                gymName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        _HeaderButton(
          tooltip: 'Search',
          onTap: () => context.push('/search'),
          child: Icon(Icons.search, color: scheme.onSurface, size: 22),
        ),
        SizedBox(width: tokens.spacingSm),
        _HeaderButton(
          tooltip: 'Menu',
          filled: true,
          onTap: () => Scaffold.of(context).openEndDrawer(),
          child: Text(
            initial,
            style: textTheme.titleMedium?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.tooltip,
    required this.onTap,
    required this.child,
    this.filled = false,
  });

  final String tooltip;
  final VoidCallback onTap;
  final Widget child;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(context.tokens.radiusMd);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled ? scheme.primary : scheme.surfaceContainerHighest,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: filled ? null : Border.all(color: scheme.outline),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
