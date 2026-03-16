import '../entities/product.dart';
import '../repositories/product_repository.dart';

class UpsertProductUseCase {
  UpsertProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<void> call(Product product) => _repository.upsert(product);
}
