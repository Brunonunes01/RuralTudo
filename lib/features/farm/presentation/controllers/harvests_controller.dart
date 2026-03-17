import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/farm_local_datasource.dart';
import '../../domain/entities/harvest.dart';

class HarvestsController extends StateNotifier<AsyncValue<List<Harvest>>> {
  HarvestsController(this._datasource) : super(const AsyncValue.loading()) {
    load();
  }

  final FarmLocalDatasource _datasource;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_datasource.getHarvests);
  }

  Future<void> register({
    required int plantingId,
    required DateTime harvestDate,
    required double quantity,
    required String unit,
    double? lossQuantity,
    String? notes,
  }) async {
    await _datasource.registerHarvest(
      plantingId: plantingId,
      harvestDate: harvestDate,
      quantity: quantity,
      unit: unit,
      lossQuantity: lossQuantity,
      notes: notes,
    );
    await load();
  }
}
