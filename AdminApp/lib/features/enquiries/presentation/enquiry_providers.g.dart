// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enquiry_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(enquiryList)
final enquiryListProvider = EnquiryListProvider._();

final class EnquiryListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Enquiry>>,
          List<Enquiry>,
          FutureOr<List<Enquiry>>
        >
    with $FutureModifier<List<Enquiry>>, $FutureProvider<List<Enquiry>> {
  EnquiryListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'enquiryListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$enquiryListHash();

  @$internal
  @override
  $FutureProviderElement<List<Enquiry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Enquiry>> create(Ref ref) {
    return enquiryList(ref);
  }
}

String _$enquiryListHash() => r'0bdab0778ca68e2fb769f6599f7c008beb982f03';

@ProviderFor(conversionStats)
final conversionStatsProvider = ConversionStatsProvider._();

final class ConversionStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ConversionStats>,
          ConversionStats,
          FutureOr<ConversionStats>
        >
    with $FutureModifier<ConversionStats>, $FutureProvider<ConversionStats> {
  ConversionStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversionStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversionStatsHash();

  @$internal
  @override
  $FutureProviderElement<ConversionStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ConversionStats> create(Ref ref) {
    return conversionStats(ref);
  }
}

String _$conversionStatsHash() => r'bfd9dbf63591218aada9193e51163501a99c5b2d';
