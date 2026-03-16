import '../entities/stock_movement.dart';

abstract class StockRepository {
  Future<List<StockMovement>> getMovements();
}
