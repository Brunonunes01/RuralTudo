import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  GetCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  Future<List<Category>> call() => _repository.getAll();
}
