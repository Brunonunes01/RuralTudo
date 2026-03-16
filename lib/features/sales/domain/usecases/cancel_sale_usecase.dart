import '../repositories/sales_repository.dart';

class CancelSaleUseCase {
  CancelSaleUseCase(this._repository);

  final SalesRepository _repository;

  Future<void> call(int saleId) => _repository.cancelSale(saleId);
}
