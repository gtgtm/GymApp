// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acting_gym_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod-visible mirror of ActingGymHub so widgets can watch/rebuild on
/// enter/exit. ApiClient reads the hub directly (it can't depend on
/// Riverpod), so every mutation here must also update the hub.

@ProviderFor(ActingGymController)
final actingGymControllerProvider = ActingGymControllerProvider._();

/// Riverpod-visible mirror of ActingGymHub so widgets can watch/rebuild on
/// enter/exit. ApiClient reads the hub directly (it can't depend on
/// Riverpod), so every mutation here must also update the hub.
final class ActingGymControllerProvider
    extends $NotifierProvider<ActingGymController, ActingGym?> {
  /// Riverpod-visible mirror of ActingGymHub so widgets can watch/rebuild on
  /// enter/exit. ApiClient reads the hub directly (it can't depend on
  /// Riverpod), so every mutation here must also update the hub.
  ActingGymControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'actingGymControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$actingGymControllerHash();

  @$internal
  @override
  ActingGymController create() => ActingGymController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActingGym? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActingGym?>(value),
    );
  }
}

String _$actingGymControllerHash() =>
    r'abcf5e1d1878665f389ef77096f514c2807e5be1';

/// Riverpod-visible mirror of ActingGymHub so widgets can watch/rebuild on
/// enter/exit. ApiClient reads the hub directly (it can't depend on
/// Riverpod), so every mutation here must also update the hub.

abstract class _$ActingGymController extends $Notifier<ActingGym?> {
  ActingGym? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ActingGym?, ActingGym?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ActingGym?, ActingGym?>,
              ActingGym?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
