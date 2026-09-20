// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_gyms_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myGyms)
final myGymsProvider = MyGymsProvider._();

final class MyGymsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GymMembership>>,
          List<GymMembership>,
          FutureOr<List<GymMembership>>
        >
    with
        $FutureModifier<List<GymMembership>>,
        $FutureProvider<List<GymMembership>> {
  MyGymsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myGymsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myGymsHash();

  @$internal
  @override
  $FutureProviderElement<List<GymMembership>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GymMembership>> create(Ref ref) {
    return myGyms(ref);
  }
}

String _$myGymsHash() => r'44bdd21af5270221b341a52d1d2f7c2ef58a7512';

@ProviderFor(pendingGyms)
final pendingGymsProvider = PendingGymsProvider._();

final class PendingGymsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GymMembership>>,
          List<GymMembership>,
          FutureOr<List<GymMembership>>
        >
    with
        $FutureModifier<List<GymMembership>>,
        $FutureProvider<List<GymMembership>> {
  PendingGymsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingGymsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingGymsHash();

  @$internal
  @override
  $FutureProviderElement<List<GymMembership>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GymMembership>> create(Ref ref) {
    return pendingGyms(ref);
  }
}

String _$pendingGymsHash() => r'374a7d53716387f05ad40493be79ff644f3a3be0';
