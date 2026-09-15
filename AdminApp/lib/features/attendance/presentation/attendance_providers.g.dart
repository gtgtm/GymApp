// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(todaysAttendance)
final todaysAttendanceProvider = TodaysAttendanceProvider._();

final class TodaysAttendanceProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AttendanceEntry>>,
          List<AttendanceEntry>,
          FutureOr<List<AttendanceEntry>>
        >
    with
        $FutureModifier<List<AttendanceEntry>>,
        $FutureProvider<List<AttendanceEntry>> {
  TodaysAttendanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todaysAttendanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todaysAttendanceHash();

  @$internal
  @override
  $FutureProviderElement<List<AttendanceEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AttendanceEntry>> create(Ref ref) {
    return todaysAttendance(ref);
  }
}

String _$todaysAttendanceHash() => r'98e7d631defd22711dc3f0c888583c7d6d3bb396';
