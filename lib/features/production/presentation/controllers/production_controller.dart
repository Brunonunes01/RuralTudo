import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/production_record.dart';
import '../../domain/usecases/get_production_records_usecase.dart';
import '../../domain/usecases/register_production_usecase.dart';

class ProductionController extends StateNotifier<AsyncValue<List<ProductionRecord>>> {
  ProductionController(this._getRecords, this._registerProduction)
      : super(const AsyncValue.loading()) {
    load();
  }

  final GetProductionRecordsUseCase _getRecords;
  final RegisterProductionUseCase _registerProduction;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_getRecords.call);
  }

  Future<void> register({
    required int productId,
    required String productionType,
    required double quantity,
    double? estimatedCost,
    String? notes,
    DateTime? date,
  }) async {
    await _registerProduction(
      productId: productId,
      productionType: productionType,
      quantity: quantity,
      estimatedCost: estimatedCost,
      notes: notes,
      date: date ?? DateTime.now(),
    );
    await load();
  }
}
