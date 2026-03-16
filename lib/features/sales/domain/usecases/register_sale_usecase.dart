import '../entities/sale_item.dart';
import '../repositories/sales_repository.dart';

class RegisterSaleUseCase {
  RegisterSaleUseCase(this._repository);

  final SalesRepository _repository;

  Future<void> call({
    int? customerId,
    required DateTime saleDate,
    required String paymentMethod,
    String? notes,
    required List<SaleItem> items,
  }) {
    return _repository.registerSale(
      customerId: customerId,
      saleDate: saleDate,
      paymentMethod: paymentMethod,
      notes: notes,
      items: items,
    );
  }
}
