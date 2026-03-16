import '../entities/sale.dart';
import '../repositories/sales_repository.dart';

class GetSalesUseCase {
  GetSalesUseCase(this._repository);

  final SalesRepository _repository;

  Future<List<Sale>> call() => _repository.getAll();
}
