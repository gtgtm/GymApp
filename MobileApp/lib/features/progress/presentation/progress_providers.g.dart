// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myProgress)
final myProgressProvider = MyProgressProvider._();

final class MyProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProgressData>,
          ProgressData,
          FutureOr<ProgressData>
        >
    with $FutureModifier<ProgressData>, $FutureProvider<ProgressData> {
  MyProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myProgressHash();

  @$internal
  @override
  $FutureProviderElement<ProgressData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProgressData> create(Ref ref) {
    return myProgress(ref);
  }
}

String _$myProgressHash() => r'29464f3b713f3d2e76d9a5ff43d508efca19b717';
