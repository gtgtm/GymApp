// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myWorkoutPlans)
final myWorkoutPlansProvider = MyWorkoutPlansProvider._();

final class MyWorkoutPlansProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutPlan>>,
          List<WorkoutPlan>,
          FutureOr<List<WorkoutPlan>>
        >
    with
        $FutureModifier<List<WorkoutPlan>>,
        $FutureProvider<List<WorkoutPlan>> {
  MyWorkoutPlansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myWorkoutPlansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myWorkoutPlansHash();

  @$internal
  @override
  $FutureProviderElement<List<WorkoutPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WorkoutPlan>> create(Ref ref) {
    return myWorkoutPlans(ref);
  }
}

String _$myWorkoutPlansHash() => r'acbe7b3ece6be0ee922abbc0332d9bdd2103bd99';
