import '../entities/sale.dart';
import '../entities/sale_item.dart';

abstract class SalesRepository {
  Future<List<Sale>> getAll();
  Future<void> registerSale({
    int? customerId,
    required DateTime saleDate,
    required String paymentMethod,
    String? notes,
    required List<SaleItem> items,
  });
  Future<void> cancelSale(int saleId);
}
