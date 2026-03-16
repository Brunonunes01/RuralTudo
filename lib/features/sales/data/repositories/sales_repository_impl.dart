import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_local_datasource.dart';
import '../models/sale_item_model.dart';

class SalesRepositoryImpl implements SalesRepository {
  SalesRepositoryImpl(this._datasource);

  final SalesLocalDatasource _datasource;

  @override
  Future<void> cancelSale(int saleId) => _datasource.cancelSale(saleId);

  @override
  Future<List<Sale>> getAll() => _datasource.getAll();

  @override
  Future<void> registerSale({
    int? customerId,
    required DateTime saleDate,
    required String paymentMethod,
    String? notes,
    required List<SaleItem> items,
  }) {
    return _datasource.registerSale(
      customerId: customerId,
      saleDate: saleDate,
      paymentMethod: paymentMethod,
      notes: notes,
      items: items
          .map(
            (item) => SaleItemModel(
              productId: item.productId,
              productName: item.productName,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
            ),
          )
          .toList(),
    );
  }
}
