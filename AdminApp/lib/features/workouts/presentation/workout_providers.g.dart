// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workoutPlanList)
final workoutPlanListProvider = WorkoutPlanListFamily._();

final class WorkoutPlanListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutPlan>>,
          List<WorkoutPlan>,
          FutureOr<List<WorkoutPlan>>
        >
    with
        $FutureModifier<List<WorkoutPlan>>,
        $FutureProvider<List<WorkoutPlan>> {
  WorkoutPlanListProvider._({
    required WorkoutPlanListFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'workoutPlanListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutPlanListHash();

  @override
  String toString() {
    return r'workoutPlanListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WorkoutPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutPlan>> create(Ref ref) {
    final argument = this.argument as int;
    return workoutPlanList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutPlanListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutPlanListHash() => r'cb3d58856040ef24ad875fc82f397e3a991578dd';

final class WorkoutPlanListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<WorkoutPlan>>, int> {
  WorkoutPlanListFamily._()
    : super(
        retry: null,
        name: r'workoutPlanListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkoutPlanListProvider call(int memberId) =>
      WorkoutPlanListProvider._(argument: memberId, from: this);

  @override
  String toString() => r'workoutPlanListProvider';
}
