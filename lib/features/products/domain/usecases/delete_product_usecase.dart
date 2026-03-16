import '../repositories/product_repository.dart';

class DeleteProductUseCase {
  DeleteProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}
