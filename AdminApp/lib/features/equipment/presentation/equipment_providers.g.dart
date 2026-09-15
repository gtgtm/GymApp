// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(equipmentList)
final equipmentListProvider = EquipmentListProvider._();

final class EquipmentListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Equipment>>,
          List<Equipment>,
          FutureOr<List<Equipment>>
        >
    with $FutureModifier<List<Equipment>>, $FutureProvider<List<Equipment>> {
  EquipmentListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'equipmentListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$equipmentListHash();

  @$internal
  @override
  $FutureProviderElement<List<Equipment>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Equipment>> create(Ref ref) {
    return equipmentList(ref);
  }
}

String _$equipmentListHash() => r'4ed22ea8cc845e94c5d6c92c56c91d80673a0ea9';

@ProviderFor(maintenanceDueList)
final maintenanceDueListProvider = MaintenanceDueListProvider._();

final class MaintenanceDueListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Equipment>>,
          List<Equipment>,
          FutureOr<List<Equipment>>
        >
    with $FutureModifier<List<Equipment>>, $FutureProvider<List<Equipment>> {
  MaintenanceDueListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'maintenanceDueListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$maintenanceDueListHash();

  @$internal
  @override
  $FutureProviderElement<List<Equipment>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Equipment>> create(Ref ref) {
    return maintenanceDueList(ref);
  }
}

String _$maintenanceDueListHash() =>
    r'c92f01fa802216dd6fb34db78b3e871b91cbbb58';
