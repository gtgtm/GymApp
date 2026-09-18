// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gymList)
final gymListProvider = GymListProvider._();

final class GymListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GymSummary>>,
          List<GymSummary>,
          FutureOr<List<GymSummary>>
        >
    with $FutureModifier<List<GymSummary>>, $FutureProvider<List<GymSummary>> {
  GymListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gymListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gymListHash();

  @$internal
  @override
  $FutureProviderElement<List<GymSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GymSummary>> create(Ref ref) {
    return gymList(ref);
  }
}

String _$gymListHash() => r'bdccdf4fe0c194fac41a145cbb4b4d8d0e690397';

@ProviderFor(gymDetail)
final gymDetailProvider = GymDetailFamily._();

final class GymDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<GymDetail>,
          GymDetail,
          FutureOr<GymDetail>
        >
    with $FutureModifier<GymDetail>, $FutureProvider<GymDetail> {
  GymDetailProvider._({
    required GymDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'gymDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gymDetailHash();

  @override
  String toString() {
    return r'gymDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<GymDetail> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<GymDetail> create(Ref ref) {
    final argument = this.argument as int;
    return gymDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GymDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gymDetailHash() => r'7f98d7fecd911bc097b0e86a0c6f825e8c806be5';

final class GymDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<GymDetail>, int> {
  GymDetailFamily._()
    : super(
        retry: null,
        name: r'gymDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GymDetailProvider call(int id) =>
      GymDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'gymDetailProvider';
}
