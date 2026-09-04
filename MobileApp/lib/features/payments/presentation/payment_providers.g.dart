// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myPayments)
final myPaymentsProvider = MyPaymentsProvider._();

final class MyPaymentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentRecord>>,
          List<PaymentRecord>,
          FutureOr<List<PaymentRecord>>
        >
    with
        $FutureModifier<List<PaymentRecord>>,
        $FutureProvider<List<PaymentRecord>> {
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
  $FutureProviderElement<List<PaymentRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentRecord>> create(Ref ref) {
    return myPayments(ref);
  }
}

String _$myPaymentsHash() => r'e571c46125f76b89550ea0e015e4bf721c273b0f';
