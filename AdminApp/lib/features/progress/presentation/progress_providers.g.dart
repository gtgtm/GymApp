// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bodyMeasurementList)
final bodyMeasurementListProvider = BodyMeasurementListFamily._();

final class BodyMeasurementListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BodyMeasurement>>,
          List<BodyMeasurement>,
          FutureOr<List<BodyMeasurement>>
        >
    with
        $FutureModifier<List<BodyMeasurement>>,
        $FutureProvider<List<BodyMeasurement>> {
  BodyMeasurementListProvider._({
    required BodyMeasurementListFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'bodyMeasurementListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bodyMeasurementListHash();

  @override
  String toString() {
    return r'bodyMeasurementListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BodyMeasurement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BodyMeasurement>> create(Ref ref) {
    final argument = this.argument as int;
    return bodyMeasurementList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BodyMeasurementListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bodyMeasurementListHash() =>
    r'b0ad4b14214dc6d450ca49957d095498c2ab2515';

final class BodyMeasurementListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<BodyMeasurement>>, int> {
  BodyMeasurementListFamily._()
    : super(
        retry: null,
        name: r'bodyMeasurementListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BodyMeasurementListProvider call(int memberId) =>
      BodyMeasurementListProvider._(argument: memberId, from: this);

  @override
  String toString() => r'bodyMeasurementListProvider';
}

@ProviderFor(progressPhotoList)
final progressPhotoListProvider = ProgressPhotoListFamily._();

final class ProgressPhotoListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProgressPhoto>>,
          List<ProgressPhoto>,
          FutureOr<List<ProgressPhoto>>
        >
    with
        $FutureModifier<List<ProgressPhoto>>,
        $FutureProvider<List<ProgressPhoto>> {
  ProgressPhotoListProvider._({
    required ProgressPhotoListFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'progressPhotoListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$progressPhotoListHash();

  @override
  String toString() {
    return r'progressPhotoListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ProgressPhoto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProgressPhoto>> create(Ref ref) {
    final argument = this.argument as int;
    return progressPhotoList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgressPhotoListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$progressPhotoListHash() => r'd7d390205f5a0438950030039e412db27001dece';

final class ProgressPhotoListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ProgressPhoto>>, int> {
  ProgressPhotoListFamily._()
    : super(
        retry: null,
        name: r'progressPhotoListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProgressPhotoListProvider call(int memberId) =>
      ProgressPhotoListProvider._(argument: memberId, from: this);

  @override
  String toString() => r'progressPhotoListProvider';
}
