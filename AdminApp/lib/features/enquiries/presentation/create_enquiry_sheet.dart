import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/enquiries/domain/enquiry_models.dart';
import 'package:gymapp_admin/features/enquiries/presentation/enquiry_providers.dart';

Future<void> showCreateEnquirySheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _CreateEnquirySheet(),
  );
}

class _CreateEnquirySheet extends ConsumerStatefulWidget {
  const _CreateEnquirySheet();

  @override
  ConsumerState<_CreateEnquirySheet> createState() => _CreateEnquirySheetState();
}

class _CreateEnquirySheetState extends ConsumerState<_CreateEnquirySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _sourceController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(enquiryRepositoryProvider).create(
            EnquiryInput(
              name: _nameController.text.trim(),
              mobile: _mobileController.text.trim(),
              source: _sourceController.text.trim(),
            ),
          );
      ref.invalidate(enquiryListProvider);
      ref.invalidate(conversionStatsProvider);
      if (mounted) Navigator.of(context).pop();
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add Enquiry', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sourceController,
              decoration: const InputDecoration(labelText: 'Source (optional)'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Enquiry'),
            ),
          ],
        ),
      ),
    );
  }
}
