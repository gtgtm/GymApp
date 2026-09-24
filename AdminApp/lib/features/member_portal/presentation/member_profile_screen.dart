import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_admin/core/theme/app_tokens.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/core/widgets/confirm_logout.dart';
import 'package:gymapp_admin/features/auth/presentation/acting_gym_controller.dart';
import 'package:gymapp_admin/features/auth/presentation/auth_controller.dart';
import 'package:gymapp_admin/features/dashboard/presentation/widgets/dashboard_format.dart';
import 'package:gymapp_admin/features/dashboard/presentation/widgets/dashboard_sections.dart';
import 'package:gymapp_admin/features/member_portal/domain/member_portal_models.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_portal_providers.dart';

/// Personal details, payment history, and account actions (switch gym,
/// log out).
class MemberProfileScreen extends ConsumerWidget {
  const MemberProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final payments = ref.watch(myPaymentsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref
          ..invalidate(myProfileProvider)
          ..invalidate(myPaymentsProvider);
        await ref.read(myProfileProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          AsyncValueView(
            value: ref.watch(myProfileProvider),
            onRetry: () => ref.invalidate(myProfileProvider),
            builder: (context, profile) =>
                _ProfileCard(profile: profile, email: user?.email),
          ),
          const SizedBox(height: 22),
          const DashboardSectionHeader(title: 'Payment history'),
          AsyncValueView(
            value: payments,
            onRetry: () => ref.invalidate(myPaymentsProvider),
            builder: (context, records) => records.isEmpty
                ? const DashboardEmptyCard(
                    icon: Icons.receipt_long_outlined,
                    message: 'No payments recorded yet.',
                  )
                : Column(
                    children: [
                      for (final payment in records)
                        _PaymentTile(payment: payment),
                    ],
                  ),
          ),
          const SizedBox(height: 22),
          if (user?.requiresGymSelection ?? false)
            _ActionTile(
              icon: Icons.swap_horiz,
              label: 'Switch gym',
              onTap: () {
                ref.read(actingGymControllerProvider.notifier).exit();
                context.go('/my-gyms');
              },
            ),
          _ActionTile(
            icon: Icons.logout,
            label: 'Log out',
            isDestructive: true,
            onTap: () async {
              if (!await confirmLogout(context)) return;
              await ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.email});

  final MemberProfile profile;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final rows = [
      ('Member code', profile.memberCode),
      ('Mobile', profile.mobile),
      if (email != null) ('Email', email!),
      if (profile.trainerName != null) ('Trainer', profile.trainerName!),
      if (profile.joiningDate != null)
        ('Joined', DateFormat('d MMM yyyy').format(profile.joiningDate!)),
    ];

    return Container(
      padding: EdgeInsets.all(tokens.spacingMd + 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusXl),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(tokens.radiusLg),
                ),
                child: Text(
                  initialsOf(profile.fullName),
                  style: textTheme.titleLarge?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: tokens.spacingMd),
              Expanded(
                child: Text(profile.fullName, style: textTheme.titleLarge),
              ),
            ],
          ),
          SizedBox(height: tokens.spacingMd),
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      label,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(child: Text(value, style: textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment});

  final MemberPaymentRecord payment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.tokens.radiusLg),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.receiptNumber, style: textTheme.titleSmall),
                Text(
                  '${DateFormat('d MMM yyyy').format(payment.paidAt.toLocal())}'
                  ' · ${payment.method.replaceAll('_', ' ')}',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatRupees(payment.amount),
            style: textTheme.titleMedium?.copyWith(color: scheme.secondary),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isDestructive ? scheme.error : scheme.onSurface;
    final radius = BorderRadius.circular(context.tokens.radiusLg);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerHighest,
        borderRadius: radius,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: scheme.outline),
          ),
          leading: Icon(icon, color: color),
          title: Text(label, style: TextStyle(color: color)),
          onTap: onTap,
        ),
      ),
    );
  }
}
