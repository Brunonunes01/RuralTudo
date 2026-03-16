import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._datasource);

  final CategoryLocalDatasource _datasource;

  @override
  Future<void> delete(int id) => _datasource.delete(id);

  @override
  Future<List<Category>> getAll() => _datasource.getAll();

  @override
  Future<void> upsert(Category category) {
    return _datasource.upsert(CategoryModel.fromEntity(category));
  }
}
