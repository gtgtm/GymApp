// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'6acb45f4c02e8f7217779043f411605c3b6db609';

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, StaffUser?> {
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'ddb78b90797f8ffebe92b68f80baf8c440daa1c6';

abstract class _$AuthController extends $AsyncNotifier<StaffUser?> {
  FutureOr<StaffUser?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<StaffUser?>, StaffUser?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<StaffUser?>, StaffUser?>,
              AsyncValue<StaffUser?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
