// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memberList)
final memberListProvider = MemberListFamily._();

final class MemberListProvider
    extends
        $FunctionalProvider<
          AsyncValue<MemberListPage>,
          MemberListPage,
          FutureOr<MemberListPage>
        >
    with $FutureModifier<MemberListPage>, $FutureProvider<MemberListPage> {
  MemberListProvider._({
    required MemberListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'memberListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberListHash();

  @override
  String toString() {
    return r'memberListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MemberListPage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MemberListPage> create(Ref ref) {
    final argument = this.argument as String;
    return memberList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberListHash() => r'964de59d9aee25b2a578f1ee8b86d26a462d0bd1';

final class MemberListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MemberListPage>, String> {
  MemberListFamily._()
    : super(
        retry: null,
        name: r'memberListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MemberListProvider call(String search) =>
      MemberListProvider._(argument: search, from: this);

  @override
  String toString() => r'memberListProvider';
}

@ProviderFor(memberDetail)
final memberDetailProvider = MemberDetailFamily._();

final class MemberDetailProvider
    extends $FunctionalProvider<AsyncValue<Member>, Member, FutureOr<Member>>
    with $FutureModifier<Member>, $FutureProvider<Member> {
  MemberDetailProvider._({
    required MemberDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'memberDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberDetailHash();

  @override
  String toString() {
    return r'memberDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Member> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Member> create(Ref ref) {
    final argument = this.argument as int;
    return memberDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberDetailHash() => r'bad83882495120fd68568854a277dc1cb342707d';

final class MemberDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Member>, int> {
  MemberDetailFamily._()
    : super(
        retry: null,
        name: r'memberDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MemberDetailProvider call(int id) =>
      MemberDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'memberDetailProvider';
}

@ProviderFor(memberPayments)
final memberPaymentsProvider = MemberPaymentsFamily._();

final class MemberPaymentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MemberPayment>>,
          List<MemberPayment>,
          FutureOr<List<MemberPayment>>
        >
    with
        $FutureModifier<List<MemberPayment>>,
        $FutureProvider<List<MemberPayment>> {
  MemberPaymentsProvider._({
    required MemberPaymentsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'memberPaymentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberPaymentsHash();

  @override
  String toString() {
    return r'memberPaymentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<MemberPayment>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MemberPayment>> create(Ref ref) {
    final argument = this.argument as int;
    return memberPayments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberPaymentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberPaymentsHash() => r'7a3ffe566770011ae2c234a8b8f91baa6effdb78';

final class MemberPaymentsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<MemberPayment>>, int> {
  MemberPaymentsFamily._()
    : super(
        retry: null,
        name: r'memberPaymentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MemberPaymentsProvider call(int id) =>
      MemberPaymentsProvider._(argument: id, from: this);

  @override
  String toString() => r'memberPaymentsProvider';
}
