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
    r'1e48785ae25782f260a6f5c409ebbfde79510a61';

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

/// The role that applies to the gym currently being acted as — the answer
/// to "what can this login do right now", which nav gating and dashboard
/// variants both need. It comes from whichever membership matches the
/// acting gym, or the sole membership if none has been explicitly entered
/// yet.

@ProviderFor(actingRoleName)
final actingRoleNameProvider = ActingRoleNameProvider._();

/// The role that applies to the gym currently being acted as — the answer
/// to "what can this login do right now", which nav gating and dashboard
/// variants both need. It comes from whichever membership matches the
/// acting gym, or the sole membership if none has been explicitly entered
/// yet.

final class ActingRoleNameProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The role that applies to the gym currently being acted as — the answer
  /// to "what can this login do right now", which nav gating and dashboard
  /// variants both need. It comes from whichever membership matches the
  /// acting gym, or the sole membership if none has been explicitly entered
  /// yet.
  ActingRoleNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'actingRoleNameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$actingRoleNameHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return actingRoleName(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$actingRoleNameHash() => r'7a8430fd5baba33c3b278bf9733b8b345024c379';
