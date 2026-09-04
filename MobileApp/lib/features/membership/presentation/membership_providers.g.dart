// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memberProfile)
final memberProfileProvider = MemberProfileProvider._();

final class MemberProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<MemberProfile>,
          MemberProfile,
          FutureOr<MemberProfile>
        >
    with $FutureModifier<MemberProfile>, $FutureProvider<MemberProfile> {
  MemberProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberProfileHash();

  @$internal
  @override
  $FutureProviderElement<MemberProfile> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MemberProfile> create(Ref ref) {
    return memberProfile(ref);
  }
}

String _$memberProfileHash() => r'97a52ce18e6cac451b3170bd4815c905e6f7b46b';

@ProviderFor(membershipDetails)
final membershipDetailsProvider = MembershipDetailsProvider._();

final class MembershipDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<MembershipDetails>,
          MembershipDetails,
          FutureOr<MembershipDetails>
        >
    with
        $FutureModifier<MembershipDetails>,
        $FutureProvider<MembershipDetails> {
  MembershipDetailsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membershipDetailsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membershipDetailsHash();

  @$internal
  @override
  $FutureProviderElement<MembershipDetails> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MembershipDetails> create(Ref ref) {
    return membershipDetails(ref);
  }
}

String _$membershipDetailsHash() => r'7456f522f1d33be918ae891dee1c9374d80d42b9';

@ProviderFor(memberQrCode)
final memberQrCodeProvider = MemberQrCodeProvider._();

final class MemberQrCodeProvider
    extends
        $FunctionalProvider<
          AsyncValue<({String memberCode, String qrToken})>,
          ({String memberCode, String qrToken}),
          FutureOr<({String memberCode, String qrToken})>
        >
    with
        $FutureModifier<({String memberCode, String qrToken})>,
        $FutureProvider<({String memberCode, String qrToken})> {
  MemberQrCodeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberQrCodeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberQrCodeHash();

  @$internal
  @override
  $FutureProviderElement<({String memberCode, String qrToken})> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<({String memberCode, String qrToken})> create(Ref ref) {
    return memberQrCode(ref);
  }
}

String _$memberQrCodeHash() => r'b2ac62ed38281731c0cf1a4a31ee49cc89d9d606';
