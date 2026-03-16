import '../../domain/entities/stock_movement.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_local_datasource.dart';

class StockRepositoryImpl implements StockRepository {
  StockRepositoryImpl(this._datasource);

  final StockLocalDatasource _datasource;

  @override
  Future<List<StockMovement>> getMovements() => _datasource.getMovements();
}
