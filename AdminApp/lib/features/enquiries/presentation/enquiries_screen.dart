import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/core/widgets/async_value_view.dart';
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
      await ref.read(enquiryRepositoryProvider).updateStatus(enquiry.id, status);
      ref.invalidate(enquiryListProvider);
      ref.invalidate(conversionStatsProvider);
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
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
              data: (stats) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        '${stats.conversionRate}%',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('${stats.converted} converted of ${stats.total} total enquiries'),
                      ),
                    ],
                  ),
                ),
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
                    child: Center(child: Text('No enquiries yet.')),
                  );
                }
                return Column(
                  children: [
                    for (final enquiry in enquiries)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(enquiry.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(
                                      enquiry.mobile,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              DropdownButton<String>(
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
                            ],
                          ),
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
