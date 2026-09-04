import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_member/core/widgets/async_value_view.dart';
import 'package:gymapp_member/features/auth/presentation/auth_controller.dart';
import 'package:gymapp_member/features/membership/presentation/membership_providers.dart';
import 'package:gymapp_member/features/payments/presentation/payment_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(memberProfileProvider);
    final paymentsAsync = ref.watch(myPaymentsProvider);
    final user = ref.watch(authControllerProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AsyncValueView(
            value: profileAsync,
            onRetry: () => ref.invalidate(memberProfileProvider),
            builder: (context, profile) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(label: 'Name', value: profile.fullName),
                    _InfoRow(label: 'Member Code', value: profile.memberCode),
                    _InfoRow(label: 'Mobile', value: profile.mobile),
                    if (user != null) _InfoRow(label: 'Email', value: user.email),
                    if (profile.trainerName != null) _InfoRow(label: 'Trainer', value: profile.trainerName!),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Payment History', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          AsyncValueView(
            value: paymentsAsync,
            onRetry: () => ref.invalidate(myPaymentsProvider),
            builder: (context, payments) {
              if (payments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No payments recorded yet.'),
                );
              }

              return Column(
                children: [
                  for (final payment in payments)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('₹${payment.amount.toStringAsFixed(2)}'),
                        subtitle: Text('${payment.receiptNumber} · ${payment.method}'),
                        trailing: Text(DateFormat.yMMMd().format(payment.paidAt)),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
