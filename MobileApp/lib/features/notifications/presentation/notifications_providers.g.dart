// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myNotifications)
final myNotificationsProvider = MyNotificationsProvider._();

final class MyNotificationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MemberNotification>>,
          List<MemberNotification>,
          FutureOr<List<MemberNotification>>
        >
    with
        $FutureModifier<List<MemberNotification>>,
        $FutureProvider<List<MemberNotification>> {
  MyNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myNotificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myNotificationsHash();

  @$internal
  @override
  $FutureProviderElement<List<MemberNotification>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MemberNotification>> create(Ref ref) {
    return myNotifications(ref);
  }
}

String _$myNotificationsHash() => r'4857b8aa44045fb5ca9d66bd1019e62b12c34b84';
