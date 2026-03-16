import '../../domain/entities/production_record.dart';
import '../../domain/repositories/production_repository.dart';
import '../datasources/production_local_datasource.dart';

class ProductionRepositoryImpl implements ProductionRepository {
  ProductionRepositoryImpl(this._datasource);

  final ProductionLocalDatasource _datasource;

  @override
  Future<List<ProductionRecord>> getAll() => _datasource.getAll();

  @override
  Future<void> register({
    required int productId,
    required String productionType,
    required double quantity,
    double? estimatedCost,
    String? notes,
    required DateTime date,
  }) {
    return _datasource.register(
      productId: productId,
      productionType: productionType,
      quantity: quantity,
      estimatedCost: estimatedCost,
      notes: notes,
      date: date,
    );
  }
}
