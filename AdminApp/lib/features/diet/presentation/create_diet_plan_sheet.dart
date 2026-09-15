import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/diet/domain/diet_models.dart';
import 'package:gymapp_admin/features/diet/presentation/diet_providers.dart';

Future<void> showCreateDietPlanSheet(BuildContext context, int memberId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _CreateDietPlanSheet(memberId: memberId),
  );
}

class _MealDraft {
  _MealDraft({this.mealSlot = 'breakfast'});

  String mealSlot;
  final foodController = TextEditingController();
  final quantityController = TextEditingController();

  void dispose() {
    foodController.dispose();
    quantityController.dispose();
  }

  DietMeal? toMeal() {
    if (foodController.text.trim().isEmpty) return null;
    return DietMeal(
      mealSlot: mealSlot,
      foodItem: foodController.text.trim(),
      quantity: quantityController.text.trim().isEmpty ? null : quantityController.text.trim(),
    );
  }
}

class _CreateDietPlanSheet extends ConsumerStatefulWidget {
  const _CreateDietPlanSheet({required this.memberId});

  final int memberId;

  @override
  ConsumerState<_CreateDietPlanSheet> createState() => _CreateDietPlanSheetState();
}

class _CreateDietPlanSheetState extends ConsumerState<_CreateDietPlanSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _meals = <_MealDraft>[_MealDraft()];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    for (final meal in _meals) {
      meal.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final meals = _meals.map((m) => m.toMeal()).whereType<DietMeal>().toList();
    if (meals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one meal.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(dietRepositoryProvider).create(
            DietPlanInput(memberId: widget.memberId, name: _nameController.text.trim(), meals: meals),
          );
      ref.invalidate(dietPlanListProvider(widget.memberId));
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
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Form(
        key: _formKey,
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Text('Create Diet Plan', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Plan Name'),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Text('Meals', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (var i = 0; i < _meals.length; i++)
              _MealRow(draft: _meals[i], onRemove: _meals.length > 1 ? () => setState(() => _meals.removeAt(i)) : null),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => setState(() => _meals.add(_MealDraft())),
              icon: const Icon(Icons.add),
              label: const Text('Add Meal'),
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
                  : const Text('Save Plan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealRow extends StatefulWidget {
  const _MealRow({required this.draft, this.onRemove});

  final _MealDraft draft;
  final VoidCallback? onRemove;

  @override
  State<_MealRow> createState() => _MealRowState();
}

class _MealRowState extends State<_MealRow> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: widget.draft.mealSlot,
                    decoration: const InputDecoration(labelText: 'Meal'),
                    items: [
                      for (final slot in mealSlots)
                        DropdownMenuItem(value: slot, child: Text(mealSlotLabel(slot))),
                    ],
                    onChanged: (value) => setState(() => widget.draft.mealSlot = value ?? 'breakfast'),
                  ),
                ),
                if (widget.onRemove != null)
                  IconButton(icon: const Icon(Icons.close), onPressed: widget.onRemove),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: widget.draft.foodController,
                    decoration: const InputDecoration(labelText: 'Food Item'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.draft.quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
