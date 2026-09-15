import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gymapp_admin/features/search/presentation/search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(globalSearchProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search members, payments, trainers...',
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
      ),
      body: resultsAsync.when(
        data: (results) {
          if (_query.trim().length < 2) {
            return const Center(child: Text('Type at least 2 characters to search.'));
          }
          if (results.isEmpty) {
            return const Center(child: Text('No results found.'));
          }
          return ListView(
            children: [
              if (results.members.isNotEmpty)
                _ResultGroup(
                  label: 'Members',
                  children: [
                    for (final member in results.members)
                      ListTile(
                        title: Text(member.fullName),
                        subtitle: Text('${member.mobile} · ${member.memberCode}'),
                        onTap: () => context.push('/members/${member.id}'),
                      ),
                  ],
                ),
              if (results.trainers.isNotEmpty)
                _ResultGroup(
                  label: 'Trainers',
                  children: [
                    for (final trainer in results.trainers)
                      ListTile(title: Text(trainer.name), subtitle: Text(trainer.phone ?? '')),
                  ],
                ),
              if (results.payments.isNotEmpty)
                _ResultGroup(
                  label: 'Payments',
                  children: [
                    for (final payment in results.payments)
                      ListTile(
                        title: Text(payment.receiptNumber),
                        trailing: Text('₹${payment.amount}'),
                      ),
                  ],
                ),
              if (results.enquiries.isNotEmpty)
                _ResultGroup(
                  label: 'Enquiries',
                  children: [
                    for (final enquiry in results.enquiries)
                      ListTile(
                        title: Text(enquiry.name),
                        trailing: Chip(label: Text(enquiry.status), visualDensity: VisualDensity.compact),
                      ),
                  ],
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
    );
  }
}

class _ResultGroup extends StatelessWidget {
  const _ResultGroup({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
          ),
        ),
        ...children,
      ],
    );
  }
}
