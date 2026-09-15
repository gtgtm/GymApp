// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dietPlanList)
final dietPlanListProvider = DietPlanListFamily._();

final class DietPlanListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DietPlan>>,
          List<DietPlan>,
          FutureOr<List<DietPlan>>
        >
    with $FutureModifier<List<DietPlan>>, $FutureProvider<List<DietPlan>> {
  DietPlanListProvider._({
    required DietPlanListFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'dietPlanListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dietPlanListHash();

  @override
  String toString() {
    return r'dietPlanListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DietPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DietPlan>> create(Ref ref) {
    final argument = this.argument as int;
    return dietPlanList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DietPlanListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dietPlanListHash() => r'502dfd7344b28378bb0302e6a5fc9103dd838351';

final class DietPlanListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DietPlan>>, int> {
  DietPlanListFamily._()
    : super(
        retry: null,
        name: r'dietPlanListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DietPlanListProvider call(int memberId) =>
      DietPlanListProvider._(argument: memberId, from: this);

  @override
  String toString() => r'dietPlanListProvider';
}
