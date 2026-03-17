import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/farm_local_datasource.dart';
import '../../domain/entities/farm_area.dart';

class AreasController extends StateNotifier<AsyncValue<List<FarmArea>>> {
  AreasController(this._datasource) : super(const AsyncValue.loading()) {
    load();
  }

  final FarmLocalDatasource _datasource;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_datasource.getAreas);
  }

  Future<void> save(FarmArea area) async {
    await _datasource.upsertArea(area);
    await load();
  }
}
