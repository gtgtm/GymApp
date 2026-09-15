// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(planList)
final planListProvider = PlanListProvider._();

final class PlanListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MembershipPlan>>,
          List<MembershipPlan>,
          FutureOr<List<MembershipPlan>>
        >
    with
        $FutureModifier<List<MembershipPlan>>,
        $FutureProvider<List<MembershipPlan>> {
  PlanListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planListHash();

  @$internal
  @override
  $FutureProviderElement<List<MembershipPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MembershipPlan>> create(Ref ref) {
    return planList(ref);
  }
}

String _$planListHash() => r'c68ddd1295c7862f2b11daf6899d66b4e8b22c88';
