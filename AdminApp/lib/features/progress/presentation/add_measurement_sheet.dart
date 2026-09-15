import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/progress/domain/progress_models.dart';
import 'package:gymapp_admin/features/progress/presentation/progress_providers.dart';

Future<void> showAddMeasurementSheet(BuildContext context, int memberId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _AddMeasurementSheet(memberId: memberId),
  );
}

class _AddMeasurementSheet extends ConsumerStatefulWidget {
  const _AddMeasurementSheet({required this.memberId});

  final int memberId;

  @override
  ConsumerState<_AddMeasurementSheet> createState() => _AddMeasurementSheetState();
}

class _AddMeasurementSheetState extends ConsumerState<_AddMeasurementSheet> {
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  DateTime _recordedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recordedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _recordedDate = picked);
  }

  Future<void> _submit() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(progressRepositoryProvider).addMeasurement(
            BodyMeasurementInput(
              memberId: widget.memberId,
              recordedDate: DateFormat('yyyy-MM-dd').format(_recordedDate),
              weightKg: double.tryParse(_weightController.text),
              bodyFatPercent: double.tryParse(_bodyFatController.text),
            ),
          );
      ref.invalidate(bodyMeasurementListProvider(widget.memberId));
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add Measurement', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Recorded Date'),
              child: Text(DateFormat.yMMMd().format(_recordedDate)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyFatController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Body Fat %'),
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
                : const Text('Save Measurement'),
          ),
        ],
      ),
    );
  }
}
