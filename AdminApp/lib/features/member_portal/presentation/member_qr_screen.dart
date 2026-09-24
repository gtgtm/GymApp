import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:gymapp_admin/core/theme/app_tokens.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/core/widgets/status_badge.dart';
import 'package:gymapp_admin/features/dashboard/presentation/widgets/dashboard_sections.dart';
import 'package:gymapp_admin/features/member_portal/domain/member_portal_models.dart';
import 'package:gymapp_admin/features/member_portal/presentation/member_portal_providers.dart';

const _qrSize = 220.0;

/// The member's check-in QR (staff scan it from the Check-in tab) and
/// their attendance history.
class MemberQrScreen extends ConsumerWidget {
  const MemberQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrAsync = ref.watch(myQrCodeProvider);
    final attendance = ref.watch(myAttendanceProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref
          ..invalidate(myQrCodeProvider)
          ..invalidate(myAttendanceProvider);
        await ref.read(myAttendanceProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          AsyncValueView(
            value: qrAsync,
            onRetry: () => ref.invalidate(myQrCodeProvider),
            builder: (context, qr) => _QrCard(qr: qr),
          ),
          const SizedBox(height: 24),
          const DashboardSectionHeader(title: 'Attendance history'),
          AsyncValueView(
            value: attendance,
            onRetry: () => ref.invalidate(myAttendanceProvider),
            builder: (context, records) => records.isEmpty
                ? const DashboardEmptyCard(
                    icon: Icons.how_to_reg_outlined,
                    message: 'No check-ins yet.',
                  )
                : Column(
                    children: [
                      for (final record in records)
                        _AttendanceTile(record: record),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.qr});

  final MemberQrCode qr;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.spacingLg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusXl),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        children: [
          // Scanners need dark modules on a light field — keep the code on
          // white even in the dark theme.
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(tokens.radiusLg),
            ),
            child: QrImageView(
              data: qr.qrToken,
              size: _qrSize,
              backgroundColor: Colors.white,
              semanticsLabel: 'Check-in QR code for ${qr.memberCode}',
            ),
          ),
          SizedBox(height: tokens.spacingMd),
          Text(
            qr.memberCode,
            style: textTheme.titleLarge?.copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            'Show this at the front desk to check in.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({required this.record});

  final MemberAttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final time = record.checkInTime == null || record.checkInTime!.length < 5
        ? null
        : record.checkInTime!.substring(0, 5);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, d MMM yyyy').format(record.date),
                  style: textTheme.titleSmall,
                ),
                if (time != null)
                  Text(
                    'Checked in at $time',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          StatusBadge(
            label: record.status,
            tone: record.status == 'present'
                ? StatusTone.success
                : StatusTone.neutral,
          ),
        ],
      ),
    );
  }
}
