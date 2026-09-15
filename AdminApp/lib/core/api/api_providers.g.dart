// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tokenStorage)
final tokenStorageProvider = TokenStorageProvider._();

final class TokenStorageProvider
    extends $FunctionalProvider<TokenStorage, TokenStorage, TokenStorage>
    with $Provider<TokenStorage> {
  TokenStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenStorageHash();

  @$internal
  @override
  $ProviderElement<TokenStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TokenStorage create(Ref ref) {
    return tokenStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenStorage>(value),
    );
  }
}

String _$tokenStorageHash() => r'a42816fb1cf5af728e44ff5c48bfcaf5dc6b12aa';

@ProviderFor(unauthorizedHub)
final unauthorizedHubProvider = UnauthorizedHubProvider._();

final class UnauthorizedHubProvider
    extends
        $FunctionalProvider<
          UnauthorizedNotifier,
          UnauthorizedNotifier,
          UnauthorizedNotifier
        >
    with $Provider<UnauthorizedNotifier> {
  UnauthorizedHubProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unauthorizedHubProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unauthorizedHubHash();

  @$internal
  @override
  $ProviderElement<UnauthorizedNotifier> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UnauthorizedNotifier create(Ref ref) {
    return unauthorizedHub(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnauthorizedNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnauthorizedNotifier>(value),
    );
  }
}

String _$unauthorizedHubHash() => r'dcc321854a3b7a6613c792fe47114d0952587b99';

@ProviderFor(apiClient)
final apiClientProvider = ApiClientProvider._();

final class ApiClientProvider
    extends $FunctionalProvider<ApiClient, ApiClient, ApiClient>
    with $Provider<ApiClient> {
  ApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'apiClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$apiClientHash();

  @$internal
  @override
  $ProviderElement<ApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ApiClient create(Ref ref) {
    return apiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApiClient>(value),
    );
  }
}

String _$apiClientHash() => r'1767150d36474b43bd715cb384613a2cc65119ee';
