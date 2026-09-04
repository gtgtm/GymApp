import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:gymapp_member/core/widgets/async_value_view.dart';
import 'package:gymapp_member/features/attendance/presentation/attendance_providers.dart';
import 'package:gymapp_member/features/membership/presentation/membership_providers.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrAsync = ref.watch(memberQrCodeProvider);
    final historyAsync = ref.watch(myAttendanceHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(memberQrCodeProvider);
          ref.invalidate(myAttendanceHistoryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Show this code at the front desk to check in',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    AsyncValueView(
                      value: qrAsync,
                      onRetry: () => ref.invalidate(memberQrCodeProvider),
                      builder: (context, qr) => Column(
                        children: [
                          QrImageView(data: qr.qrToken, size: 200),
                          const SizedBox(height: 12),
                          Text(qr.memberCode, style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Recent Attendance', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            AsyncValueView(
              value: historyAsync,
              onRetry: () => ref.invalidate(myAttendanceHistoryProvider),
              builder: (context, records) {
                if (records.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No attendance recorded yet.')),
                  );
                }

                return Column(
                  children: [
                    for (final record in records)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.check_circle_outline),
                          title: Text(DateFormat.yMMMd().format(record.date)),
                          subtitle: record.checkInTime != null ? Text(record.checkInTime!) : null,
                          trailing: Chip(label: Text(record.status)),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
