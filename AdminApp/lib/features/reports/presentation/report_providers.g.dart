// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reportRepository)
final reportRepositoryProvider = ReportRepositoryProvider._();

final class ReportRepositoryProvider
    extends
        $FunctionalProvider<
          ReportRepository,
          ReportRepository,
          ReportRepository
        >
    with $Provider<ReportRepository> {
  ReportRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReportRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReportRepository create(Ref ref) {
    return reportRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportRepository>(value),
    );
  }
}

String _$reportRepositoryHash() => r'87f98fa44929635eda2fbf21fcab608c44df15c8';

@ProviderFor(financialSummary)
final financialSummaryProvider = FinancialSummaryFamily._();

final class FinancialSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<FinancialSummary>,
          FinancialSummary,
          FutureOr<FinancialSummary>
        >
    with $FutureModifier<FinancialSummary>, $FutureProvider<FinancialSummary> {
  FinancialSummaryProvider._({
    required FinancialSummaryFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'financialSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$financialSummaryHash();

  @override
  String toString() {
    return r'financialSummaryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<FinancialSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FinancialSummary> create(Ref ref) {
    final argument = this.argument as (String, String);
    return financialSummary(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is FinancialSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$financialSummaryHash() => r'198784f3120794eee6c5144f92822ec5a18d2f7d';

final class FinancialSummaryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<FinancialSummary>,
          (String, String)
        > {
  FinancialSummaryFamily._()
    : super(
        retry: null,
        name: r'financialSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FinancialSummaryProvider call(String from, String to) =>
      FinancialSummaryProvider._(argument: (from, to), from: this);

  @override
  String toString() => r'financialSummaryProvider';
}
