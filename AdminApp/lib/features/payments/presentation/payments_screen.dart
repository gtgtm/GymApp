import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/features/payments/presentation/payment_providers.dart';
import 'package:gymapp_admin/features/payments/presentation/record_payment_sheet.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({this.openCreateOnLoad = false, super.key});

  final bool openCreateOnLoad;

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.openCreateOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showRecordPaymentSheet(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentListProvider);
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showRecordPaymentSheet(context),
        child: const Icon(Icons.add),
      ),
      body: AsyncValueView(
        value: paymentsAsync,
        onRetry: () => ref.invalidate(paymentListProvider),
        builder: (context, payments) {
          if (payments.isEmpty) {
            return const Center(child: Text('No payments recorded yet.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(paymentListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final payment = payments[index];
                return ListTile(
                  title: Text(payment.member?.fullName ?? 'Unknown member'),
                  subtitle: Text('${payment.receiptNumber} · ${payment.method}'),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('₹${payment.amount}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        dateFormat.format(DateTime.parse(payment.paidAt)),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
