import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/features/attendance/domain/mark_attendance_exception.dart';
import 'package:gymapp_admin/features/attendance/presentation/attendance_providers.dart';
import 'package:gymapp_admin/features/attendance/presentation/qr_scanner_view.dart';
import 'package:gymapp_admin/features/members/domain/member_models.dart';
import 'package:gymapp_admin/features/members/presentation/member_providers.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showResult(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Future<void> _markByMember(Member member) async {
    try {
      final result = await ref.read(attendanceRepositoryProvider).markByMemberId(member.id);
      _showResult(
        '${member.fullName} marked present. Valid until ${result.membershipEndDate ?? '-'}.',
      );
      ref.invalidate(todaysAttendanceProvider);
    } on MembershipExpiredException catch (error) {
      _showResult(error.message, isError: true);
    } on Exception catch (error) {
      _showResult(error.toString(), isError: true);
    }
  }

  Future<void> _handleQrDetected(String qrToken) async {
    try {
      final result = await ref.read(attendanceRepositoryProvider).scanQr(qrToken);
      _showResult(
        '${result.member?.fullName ?? 'Member'} checked in. Valid until ${result.membershipEndDate ?? '-'}.',
      );
      ref.invalidate(todaysAttendanceProvider);
    } on MembershipExpiredException catch (error) {
      _showResult(error.message, isError: true);
    } on Exception catch (error) {
      _showResult(error.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(todaysAttendanceProvider);

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Search Member'),
            Tab(text: 'Scan QR Code'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _SearchMarkTab(onMark: _markByMember),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    QrScannerView(onDetected: (value) => unawaited(_handleQrDetected(value))),
                    const SizedBox(height: 12),
                    Text(
                      'Point the camera at a member\'s QR code.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("Today's Attendance", style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
        Expanded(
          child: AsyncValueView(
            value: attendanceAsync,
            onRetry: () => ref.invalidate(todaysAttendanceProvider),
            builder: (context, entries) {
              if (entries.isEmpty) {
                return const Center(child: Text('No attendance marked yet today.'));
              }
              return ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    title: Text(entry.member?.fullName ?? 'Unknown member'),
                    subtitle: Text(entry.checkInTime ?? ''),
                    trailing: Chip(label: Text(entry.status)),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchMarkTab extends ConsumerStatefulWidget {
  const _SearchMarkTab({required this.onMark});

  final ValueChanged<Member> onMark;

  @override
  ConsumerState<_SearchMarkTab> createState() => _SearchMarkTabState();
}

class _SearchMarkTabState extends ConsumerState<_SearchMarkTab> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(memberListProvider(_search));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search by name, mobile, or member ID',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => _search = value),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AsyncValueView(
              value: membersAsync,
              builder: (context, page) {
                if (_search.trim().length < 2) {
                  return const Center(child: Text('Type at least 2 characters to search.'));
                }
                if (page.members.isEmpty) {
                  return const Center(child: Text('No members found.'));
                }
                return ListView.builder(
                  itemCount: page.members.length,
                  itemBuilder: (context, index) {
                    final member = page.members[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(member.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text(
                                  '${member.mobile} · ${member.memberCode}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            style: FilledButton.styleFrom(minimumSize: Size.zero),
                            onPressed: () => widget.onMark(member),
                            child: const Text('Mark'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
