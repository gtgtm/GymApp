// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchRepository)
final searchRepositoryProvider = SearchRepositoryProvider._();

final class SearchRepositoryProvider
    extends
        $FunctionalProvider<
          SearchRepository,
          SearchRepository,
          SearchRepository
        >
    with $Provider<SearchRepository> {
  SearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchRepositoryHash();

  @$internal
  @override
  $ProviderElement<SearchRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchRepository create(Ref ref) {
    return searchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchRepository>(value),
    );
  }
}

String _$searchRepositoryHash() => r'e63d4bfc7e51c852e085a1a354779913a2ae207c';

@ProviderFor(globalSearch)
final globalSearchProvider = GlobalSearchFamily._();

final class GlobalSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<GlobalSearchResults>,
          GlobalSearchResults,
          FutureOr<GlobalSearchResults>
        >
    with
        $FutureModifier<GlobalSearchResults>,
        $FutureProvider<GlobalSearchResults> {
  GlobalSearchProvider._({
    required GlobalSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'globalSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$globalSearchHash();

  @override
  String toString() {
    return r'globalSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<GlobalSearchResults> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GlobalSearchResults> create(Ref ref) {
    final argument = this.argument as String;
    return globalSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GlobalSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$globalSearchHash() => r'06225a6790214dc48d63e2adc51c05a9a5dcc145';

final class GlobalSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<GlobalSearchResults>, String> {
  GlobalSearchFamily._()
    : super(
        retry: null,
        name: r'globalSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GlobalSearchProvider call(String query) =>
      GlobalSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'globalSearchProvider';
}
