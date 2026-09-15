// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trial_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trialList)
final trialListProvider = TrialListProvider._();

final class TrialListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Trial>>,
          List<Trial>,
          FutureOr<List<Trial>>
        >
    with $FutureModifier<List<Trial>>, $FutureProvider<List<Trial>> {
  TrialListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trialListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trialListHash();

  @$internal
  @override
  $FutureProviderElement<List<Trial>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Trial>> create(Ref ref) {
    return trialList(ref);
  }
}

String _$trialListHash() => r'35ea60108cca6a93d703403bad83b0ca53bea112';
