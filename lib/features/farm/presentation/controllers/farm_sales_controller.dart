import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/farm_local_datasource.dart';
import '../../domain/entities/harvest_sale.dart';

class FarmSalesController extends StateNotifier<AsyncValue<List<HarvestSale>>> {
  FarmSalesController(this._datasource) : super(const AsyncValue.loading()) {
    load();
  }

  final FarmLocalDatasource _datasource;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_datasource.getHarvestSales);
  }

  Future<void> register({
    required int harvestId,
    int? customerId,
    required DateTime saleDate,
    required double quantity,
    required String unit,
    required double unitPrice,
    required String paymentMethod,
    String? notes,
  }) async {
    await _datasource.registerHarvestSale(
      harvestId: harvestId,
      customerId: customerId,
      saleDate: saleDate,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      paymentMethod: paymentMethod,
      notes: notes,
    );
    await load();
  }
}
