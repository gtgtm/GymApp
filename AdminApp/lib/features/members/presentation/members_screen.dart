import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/features/members/presentation/create_member_sheet.dart';
import 'package:gymapp_admin/features/members/presentation/expiry_badge.dart';
import 'package:gymapp_admin/features/members/presentation/member_providers.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({this.openCreateOnLoad = false, super.key});

  final bool openCreateOnLoad;

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    if (widget.openCreateOnLoad) {
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

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(memberListProvider(_search));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateMemberSheet(context),
        child: const Icon(Icons.add),
      ),
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
            const SizedBox(height: 12),
            Expanded(
              child: AsyncValueView(
                value: membersAsync,
                onRetry: () => ref.invalidate(memberListProvider(_search)),
                builder: (context, page) {
                  if (page.members.isEmpty) {
                    return const Center(child: Text('No members found.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(memberListProvider(_search)),
                    child: ListView.separated(
                      itemCount: page.members.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final member = page.members[index];
                        return ListTile(
                          title: Text(member.fullName),
                          subtitle: Text('${member.mobile} · ${member.memberCode}'),
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
