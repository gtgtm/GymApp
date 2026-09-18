import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymapp_admin/core/api/repository_providers.dart';
import 'package:gymapp_admin/features/workouts/domain/workout_models.dart';
import 'package:gymapp_admin/features/workouts/presentation/workout_providers.dart';

Future<void> showCreateWorkoutPlanSheet(BuildContext context, int memberId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _CreateWorkoutPlanSheet(memberId: memberId),
  );
}

class _ExerciseDraft {
  _ExerciseDraft({this.dayNumber = 1});

  int dayNumber;
  final nameController = TextEditingController();
  final setsController = TextEditingController();
  final repsController = TextEditingController();

  void dispose() {
    nameController.dispose();
    setsController.dispose();
    repsController.dispose();
  }

  WorkoutExercise? toExercise() {
    if (nameController.text.trim().isEmpty) return null;
    return WorkoutExercise(
      dayNumber: dayNumber,
      exerciseName: nameController.text.trim(),
      sets: int.tryParse(setsController.text),
      reps: repsController.text.trim().isEmpty
          ? null
          : repsController.text.trim(),
    );
  }
}

class _CreateWorkoutPlanSheet extends ConsumerStatefulWidget {
  const _CreateWorkoutPlanSheet({required this.memberId});

  final int memberId;

  @override
  ConsumerState<_CreateWorkoutPlanSheet> createState() =>
      _CreateWorkoutPlanSheetState();
}

class _CreateWorkoutPlanSheetState
    extends ConsumerState<_CreateWorkoutPlanSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _exercises = <_ExerciseDraft>[_ExerciseDraft()];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    for (final exercise in _exercises) {
      exercise.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final exercises = _exercises
        .map((e) => e.toExercise())
        .whereType<WorkoutExercise>()
        .toList();
    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(workoutRepositoryProvider)
          .create(
            WorkoutPlanInput(
              memberId: widget.memberId,
              name: _nameController.text.trim(),
              exercises: exercises,
            ),
          );
      ref.invalidate(workoutPlanListProvider(widget.memberId));
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
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomSheetTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).bottomSheetTheme.dragHandleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Create Workout Plan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Plan Name'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Text('Exercises', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (var i = 0; i < _exercises.length; i++)
                _ExerciseRow(
                  draft: _exercises[i],
                  onRemove: _exercises.length > 1
                      ? () => setState(() => _exercises.removeAt(i))
                      : null,
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () =>
                    setState(() => _exercises.add(_ExerciseDraft())),
                icon: const Icon(Icons.add),
                label: const Text('Add Exercise'),
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
      ),
    );
  }
}

class _ExerciseRow extends StatefulWidget {
  const _ExerciseRow({required this.draft, this.onRemove});

  final _ExerciseDraft draft;
  final VoidCallback? onRemove;

  @override
  State<_ExerciseRow> createState() => _ExerciseRowState();
}

class _ExerciseRowState extends State<_ExerciseRow> {
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
                  child: TextField(
                    controller: widget.draft.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Exercise Name',
                    ),
                  ),
                ),
                if (widget.onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: widget.draft.dayNumber,
                    decoration: const InputDecoration(labelText: 'Day'),
                    items: [
                      for (var day = 1; day <= 7; day++)
                        DropdownMenuItem(value: day, child: Text('Day $day')),
                    ],
                    onChanged: (value) =>
                        setState(() => widget.draft.dayNumber = value ?? 1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.draft.setsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Sets'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.draft.repsController,
                    decoration: const InputDecoration(labelText: 'Reps'),
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
