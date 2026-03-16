import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/stock_movement.dart';
import '../../domain/usecases/get_stock_movements_usecase.dart';

class StockController extends StateNotifier<AsyncValue<List<StockMovement>>> {
  StockController(this._getMovements) : super(const AsyncValue.loading()) {
    load();
  }

  final GetStockMovementsUseCase _getMovements;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_getMovements.call);
  }
}
