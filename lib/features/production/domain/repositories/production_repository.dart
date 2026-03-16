import '../entities/production_record.dart';

abstract class ProductionRepository {
  Future<List<ProductionRecord>> getAll();
  Future<void> register({
    required int productId,
    required String productionType,
    required double quantity,
    double? estimatedCost,
    String? notes,
    required DateTime date,
  });
}
