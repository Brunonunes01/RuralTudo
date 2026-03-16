import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._datasource);

  final ProductLocalDatasource _datasource;

  @override
  Future<void> delete(int id) => _datasource.delete(id);

  @override
  Future<List<Product>> getAll() => _datasource.getAll();

  @override
  Future<Product?> getById(int id) => _datasource.getById(id);

  @override
  Future<List<Product>> getLowStock() => _datasource.getLowStock();

  @override
  Future<void> upsert(Product product) => _datasource.upsert(ProductModel.fromEntity(product));

  @override
  Future<void> updateStock(int productId, double newQuantity) {
    return _datasource.updateStock(productId, newQuantity);
  }
}
