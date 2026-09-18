import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/core/widgets/app_list_card.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
import 'package:gymapp_admin/core/widgets/empty_state.dart';
import 'package:gymapp_admin/core/widgets/stat_card.dart';
import 'package:gymapp_admin/features/enquiries/domain/enquiry_models.dart';
import 'package:gymapp_admin/features/enquiries/presentation/create_enquiry_sheet.dart';
import 'package:gymapp_admin/features/enquiries/presentation/enquiry_providers.dart';

class EnquiriesScreen extends ConsumerStatefulWidget {
  const EnquiriesScreen({this.openCreateOnLoad = false, super.key});

  final bool openCreateOnLoad;

  @override
  ConsumerState<EnquiriesScreen> createState() => _EnquiriesScreenState();
}

class _EnquiriesScreenState extends ConsumerState<EnquiriesScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.openCreateOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showCreateEnquirySheet(context);
      });
    }
  }

  Future<void> _updateStatus(Enquiry enquiry, String status) async {
    try {
      await ref
          .read(enquiryRepositoryProvider)
          .updateStatus(enquiry.id, status);
      ref.invalidate(enquiryListProvider);
      ref.invalidate(conversionStatsProvider);
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final enquiriesAsync = ref.watch(enquiryListProvider);
    final statsAsync = ref.watch(conversionStatsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateEnquirySheet(context),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(enquiryListProvider);
          ref.invalidate(conversionStatsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            statsAsync.when(
              data: (stats) => StatCard(
                label:
                    '${stats.converted} converted of ${stats.total} total enquiries',
                value: '${stats.conversionRate}%',
                icon: Icons.trending_up,
                tone: StatTone.success,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            AsyncValueView(
              value: enquiriesAsync,
              onRetry: () => ref.invalidate(enquiryListProvider),
              builder: (context, enquiries) {
                if (enquiries.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: EmptyState(
                      icon: Icons.person_search_outlined,
                      message: 'No enquiries yet.',
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final enquiry in enquiries)
                      AppListCard(
                        title: Text(enquiry.name),
                        subtitle: Text(enquiry.mobile),
                        trailing: DropdownButton<String>(
                          value: enquiry.status,
                          underline: const SizedBox.shrink(),
                          items: [
                            for (final status in enquiryStatuses)
                              DropdownMenuItem(
                                value: status,
                                child: Text(status.replaceAll('_', ' ')),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) _updateStatus(enquiry, value);
                          },
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
