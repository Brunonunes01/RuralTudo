import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getAll();
  Future<List<Product>> getLowStock();
  Future<Product?> getById(int id);
  Future<void> upsert(Product product);
  Future<void> delete(int id);
  Future<void> updateStock(int productId, double newQuantity);
}
