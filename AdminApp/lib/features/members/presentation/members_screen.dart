import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gymapp_admin/core/permissions/nav_permissions.dart';
import 'package:gymapp_admin/core/widgets/app_list_card.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/core/widgets/empty_state.dart';
import 'package:gymapp_admin/features/auth/presentation/acting_gym_controller.dart';
import 'package:gymapp_admin/features/members/domain/member_models.dart';
import 'package:gymapp_admin/features/members/presentation/create_member_sheet.dart';
import 'package:gymapp_admin/features/members/presentation/expiry_badge.dart';
import 'package:gymapp_admin/features/members/presentation/member_providers.dart';

/// Recognized values for the `filter` query parameter on `/members`.
const _expiredFilter = 'expired';
const _expiringSoonFilter = 'expiring_soon';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({
    this.openCreateOnLoad = false,
    this.expiryFilter,
    super.key,
  });

  final bool openCreateOnLoad;

  /// Optional expiry-bucket filter, e.g. from a dashboard stat card link.
  /// One of [_expiredFilter] or [_expiringSoonFilter]; unrecognized values
  /// are ignored.
  final String? expiryFilter;

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  final _searchController = TextEditingController();
  String _search = '';
  late String? _expiryFilter = widget.expiryFilter;

  @override
  void initState() {
    super.initState();
    final canCreate = canPerform(
      ref.read(actingRoleNameProvider),
      StaffAction.createMember,
    );
    if (widget.openCreateOnLoad && canCreate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showCreateMemberSheet(context);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesExpiryFilter(Member member) {
    return switch (_expiryFilter) {
      _expiredFilter => member.expiryBucket == ExpiryBucket.red,
      _expiringSoonFilter =>
        member.expiryBucket == ExpiryBucket.yellow ||
            member.expiryBucket == ExpiryBucket.orange,
      _ => true,
    };
  }

  String _filterLabel(String filter) => switch (filter) {
    _expiredFilter => 'Expired',
    _expiringSoonFilter => 'Expiring soon',
    _ => filter,
  };

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(memberListProvider(_search));
    final canCreate = canPerform(
      ref.watch(actingRoleNameProvider),
      StaffAction.createMember,
    );

    return Scaffold(
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () => showCreateMemberSheet(context),
              child: const Icon(Icons.add),
            )
          : null,
      body: Padding(
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
            if (_expiryFilter != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  label: Text(_filterLabel(_expiryFilter!)),
                  onDeleted: () => setState(() => _expiryFilter = null),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: AsyncValueView(
                value: membersAsync,
                onRetry: () => ref.invalidate(memberListProvider(_search)),
                builder: (context, page) {
                  final members = page.members
                      .where(_matchesExpiryFilter)
                      .toList();
                  if (members.isEmpty) {
                    return const EmptyState(
                      icon: Icons.people_outline,
                      message: 'No members found.',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(memberListProvider(_search)),
                    child: ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return AppListCard(
                          title: Text(member.fullName),
                          subtitle: Text(
                            '${member.mobile} · ${member.memberCode}',
                          ),
                          trailing: ExpiryBadge(bucket: member.expiryBucket),
                          onTap: () => context.push('/members/${member.id}'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
