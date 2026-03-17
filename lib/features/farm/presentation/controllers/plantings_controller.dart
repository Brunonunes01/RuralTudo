import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/farm_local_datasource.dart';
import '../../domain/entities/planting.dart';

class PlantingsController extends StateNotifier<AsyncValue<List<Planting>>> {
  PlantingsController(this._datasource) : super(const AsyncValue.loading()) {
    load();
  }

  final FarmLocalDatasource _datasource;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_datasource.getPlantings);
  }

  Future<void> save({
    int? id,
    required int areaId,
    required String cropName,
    String? variety,
    required DateTime plantingDate,
    DateTime? expectedHarvestDate,
    int? cycleDays,
    double? plantedQuantity,
    String? plantedUnit,
    required double initialCost,
    String? notes,
    required String status,
  }) async {
    await _datasource.upsertPlanting(
      id: id,
      areaId: areaId,
      cropName: cropName,
      variety: variety,
      plantingDate: plantingDate,
      expectedHarvestDate: expectedHarvestDate,
      cycleDays: cycleDays,
      plantedQuantity: plantedQuantity,
      plantedUnit: plantedUnit,
      initialCost: initialCost,
      notes: notes,
      status: status,
    );
    await load();
  }
}
