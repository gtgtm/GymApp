// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myAttendanceHistory)
final myAttendanceHistoryProvider = MyAttendanceHistoryProvider._();

final class MyAttendanceHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AttendanceRecord>>,
          List<AttendanceRecord>,
          FutureOr<List<AttendanceRecord>>
        >
    with
        $FutureModifier<List<AttendanceRecord>>,
        $FutureProvider<List<AttendanceRecord>> {
  MyAttendanceHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myAttendanceHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myAttendanceHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<AttendanceRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AttendanceRecord>> create(Ref ref) {
    return myAttendanceHistory(ref);
  }
}

String _$myAttendanceHistoryHash() =>
    r'ec88d0574755fd03141b50391f7cae9169c1f5db';
