// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_portal_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memberPortalRepository)
final memberPortalRepositoryProvider = MemberPortalRepositoryProvider._();

final class MemberPortalRepositoryProvider
    extends
        $FunctionalProvider<
          MemberPortalRepository,
          MemberPortalRepository,
          MemberPortalRepository
        >
    with $Provider<MemberPortalRepository> {
  MemberPortalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memberPortalRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memberPortalRepositoryHash();

  @$internal
  @override
  $ProviderElement<MemberPortalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MemberPortalRepository create(Ref ref) {
    return memberPortalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemberPortalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemberPortalRepository>(value),
    );
  }
}

String _$memberPortalRepositoryHash() =>
    r'c777b58e4d0aaaa23ef0369b6f48af3d49cfd39c';

@ProviderFor(myProfile)
final myProfileProvider = MyProfileProvider._();

final class MyProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<MemberProfile>,
          MemberProfile,
          FutureOr<MemberProfile>
        >
    with $FutureModifier<MemberProfile>, $FutureProvider<MemberProfile> {
  MyProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myProfileHash();

  @$internal
  @override
  $FutureProviderElement<MemberProfile> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MemberProfile> create(Ref ref) {
    return myProfile(ref);
  }
}

String _$myProfileHash() => r'a2abfc5e13e45e3765a4b05d1b781bf724a135b2';

@ProviderFor(myMembership)
final myMembershipProvider = MyMembershipProvider._();

final class MyMembershipProvider
    extends
        $FunctionalProvider<
          AsyncValue<MembershipDetails>,
          MembershipDetails,
          FutureOr<MembershipDetails>
        >
    with
        $FutureModifier<MembershipDetails>,
        $FutureProvider<MembershipDetails> {
  MyMembershipProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myMembershipProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myMembershipHash();

  @$internal
  @override
  $FutureProviderElement<MembershipDetails> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MembershipDetails> create(Ref ref) {
    return myMembership(ref);
  }
}

String _$myMembershipHash() => r'82ce30ad6efe57f7013809eb95bb838e90cca63d';

@ProviderFor(myQrCode)
final myQrCodeProvider = MyQrCodeProvider._();

final class MyQrCodeProvider
    extends
        $FunctionalProvider<
          AsyncValue<MemberQrCode>,
          MemberQrCode,
          FutureOr<MemberQrCode>
        >
    with $FutureModifier<MemberQrCode>, $FutureProvider<MemberQrCode> {
  MyQrCodeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myQrCodeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myQrCodeHash();

  @$internal
  @override
  $FutureProviderElement<MemberQrCode> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MemberQrCode> create(Ref ref) {
    return myQrCode(ref);
  }
}

String _$myQrCodeHash() => r'7263ab806d1d099dbaba32eae9fee2df3c51a714';

@ProviderFor(myAttendance)
final myAttendanceProvider = MyAttendanceProvider._();

final class MyAttendanceProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MemberAttendanceRecord>>,
          List<MemberAttendanceRecord>,
          FutureOr<List<MemberAttendanceRecord>>
        >
    with
        $FutureModifier<List<MemberAttendanceRecord>>,
        $FutureProvider<List<MemberAttendanceRecord>> {
  MyAttendanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myAttendanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myAttendanceHash();

  @$internal
  @override
  $FutureProviderElement<List<MemberAttendanceRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MemberAttendanceRecord>> create(Ref ref) {
    return myAttendance(ref);
  }
}

String _$myAttendanceHash() => r'a2b1f513b6f570eb32575fdc258758843b9d99cb';

@ProviderFor(myPayments)
final myPaymentsProvider = MyPaymentsProvider._();

final class MyPaymentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MemberPaymentRecord>>,
          List<MemberPaymentRecord>,
          FutureOr<List<MemberPaymentRecord>>
        >
    with
        $FutureModifier<List<MemberPaymentRecord>>,
        $FutureProvider<List<MemberPaymentRecord>> {
  MyPaymentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myPaymentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myPaymentsHash();

  @$internal
  @override
  $FutureProviderElement<List<MemberPaymentRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MemberPaymentRecord>> create(Ref ref) {
    return myPayments(ref);
  }
}

String _$myPaymentsHash() => r'1b47aaabc66523a5c417e2fc1dc6c3941561fd4b';

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

String _$myNotificationsHash() => r'6d4fa400e28b705cbe38b36510c0243e2f405c89';

@ProviderFor(myWorkoutPlans)
final myWorkoutPlansProvider = MyWorkoutPlansProvider._();

final class MyWorkoutPlansProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PortalWorkoutPlan>>,
          List<PortalWorkoutPlan>,
          FutureOr<List<PortalWorkoutPlan>>
        >
    with
        $FutureModifier<List<PortalWorkoutPlan>>,
        $FutureProvider<List<PortalWorkoutPlan>> {
  MyWorkoutPlansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myWorkoutPlansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myWorkoutPlansHash();

  @$internal
  @override
  $FutureProviderElement<List<PortalWorkoutPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PortalWorkoutPlan>> create(Ref ref) {
    return myWorkoutPlans(ref);
  }
}

String _$myWorkoutPlansHash() => r'245a8bc006074818e60a8a965150c3fe941226f5';

@ProviderFor(myDietPlans)
final myDietPlansProvider = MyDietPlansProvider._();

final class MyDietPlansProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PortalDietPlan>>,
          List<PortalDietPlan>,
          FutureOr<List<PortalDietPlan>>
        >
    with
        $FutureModifier<List<PortalDietPlan>>,
        $FutureProvider<List<PortalDietPlan>> {
  MyDietPlansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myDietPlansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myDietPlansHash();

  @$internal
  @override
  $FutureProviderElement<List<PortalDietPlan>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PortalDietPlan>> create(Ref ref) {
    return myDietPlans(ref);
  }
}

String _$myDietPlansHash() => r'ca6027494c626108c5dc2b69d523abe8df013724';

@ProviderFor(myProgress)
final myProgressProvider = MyProgressProvider._();

final class MyProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<PortalProgress>,
          PortalProgress,
          FutureOr<PortalProgress>
        >
    with $FutureModifier<PortalProgress>, $FutureProvider<PortalProgress> {
  MyProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myProgressHash();

  @$internal
  @override
  $FutureProviderElement<PortalProgress> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PortalProgress> create(Ref ref) {
    return myProgress(ref);
  }
}

String _$myProgressHash() => r'14674c24eead8e6b10dee5167c4bdc6ccecb9856';
