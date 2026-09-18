import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/equipment/domain/equipment_models.dart';
import 'package:gymapp_admin/features/equipment/presentation/equipment_providers.dart';

Future<void> showCreateEquipmentSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _CreateEquipmentSheet(),
  );
}

class _CreateEquipmentSheet extends ConsumerStatefulWidget {
  const _CreateEquipmentSheet();

  @override
  ConsumerState<_CreateEquipmentSheet> createState() =>
      _CreateEquipmentSheetState();
}

class _CreateEquipmentSheetState extends ConsumerState<_CreateEquipmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  String _condition = equipmentConditions.first;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(equipmentRepositoryProvider)
          .create(
            EquipmentInput(
              name: _nameController.text.trim(),
              category: _categoryController.text.trim(),
              condition: _condition,
            ),
          );
      ref.invalidate(equipmentListProvider);
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
            Text(
              'Add Equipment',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category (optional)',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _condition,
              decoration: const InputDecoration(labelText: 'Condition'),
              items: [
                for (final condition in equipmentConditions)
                  DropdownMenuItem(
                    value: condition,
                    child: Text(condition.replaceAll('_', ' ')),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _condition = value ?? _condition),
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
                  : const Text('Save Equipment'),
            ),
          ],
        ),
      ),
    );
  }
}
