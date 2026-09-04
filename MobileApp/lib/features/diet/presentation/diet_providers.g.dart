// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myDietPlans)
final myDietPlansProvider = MyDietPlansProvider._();

final class MyDietPlansProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DietPlan>>,
          List<DietPlan>,
          FutureOr<List<DietPlan>>
        >
    with $FutureModifier<List<DietPlan>>, $FutureProvider<List<DietPlan>> {
  MyDietPlansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myDietPlansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myDietPlansHash();

  @$internal
  @override
  $FutureProviderElement<List<DietPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DietPlan>> create(Ref ref) {
    return myDietPlans(ref);
  }
}

String _$myDietPlansHash() => r'0259142b548ce21170ded98304c718173f0a0444';
