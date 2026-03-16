import '../entities/stock_movement.dart';
import '../repositories/stock_repository.dart';

class GetStockMovementsUseCase {
  GetStockMovementsUseCase(this._repository);

  final StockRepository _repository;

  Future<List<StockMovement>> call() => _repository.getMovements();
}
