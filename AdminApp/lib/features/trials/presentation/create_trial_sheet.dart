import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/trials/domain/trial_models.dart';
import 'package:gymapp_admin/features/trials/presentation/trial_providers.dart';

Future<void> showCreateTrialSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _CreateTrialSheet(),
  );
}

class _CreateTrialSheet extends ConsumerStatefulWidget {
  const _CreateTrialSheet();

  @override
  ConsumerState<_CreateTrialSheet> createState() => _CreateTrialSheetState();
}

class _CreateTrialSheetState extends ConsumerState<_CreateTrialSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  DateTime _trialStart = DateTime.now();
  DateTime _trialEnd = DateTime.now().add(const Duration(days: 3));
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _trialStart : _trialEnd,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _trialStart = picked;
      } else {
        _trialEnd = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final format = DateFormat('yyyy-MM-dd');
      await ref
          .read(trialRepositoryProvider)
          .create(
            TrialInput(
              name: _nameController.text.trim(),
              mobile: _mobileController.text.trim(),
              trialStart: format.format(_trialStart),
              trialEnd: format.format(_trialEnd),
            ),
          );
      ref.invalidate(trialListProvider);
      if (mounted) Navigator.of(context).pop();
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();

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
            Text('Add Trial', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _pickDate(isStart: true),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Trial Start'),
                child: Text(dateFormat.format(_trialStart)),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _pickDate(isStart: false),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Trial End'),
                child: Text(dateFormat.format(_trialEnd)),
              ),
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
                  : const Text('Save Trial'),
            ),
          ],
        ),
      ),
    );
  }
}
