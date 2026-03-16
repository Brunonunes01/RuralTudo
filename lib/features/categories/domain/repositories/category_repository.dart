import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAll();
  Future<void> upsert(Category category);
  Future<void> delete(int id);
}
