import '../entities/production_record.dart';
import '../repositories/production_repository.dart';

class GetProductionRecordsUseCase {
  GetProductionRecordsUseCase(this._repository);

  final ProductionRepository _repository;

  Future<List<ProductionRecord>> call() => _repository.getAll();
}
