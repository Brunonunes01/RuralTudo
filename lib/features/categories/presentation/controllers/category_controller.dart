import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/upsert_category_usecase.dart';

class CategoryController extends StateNotifier<AsyncValue<List<Category>>> {
  CategoryController(
    this._getCategories,
    this._upsertCategory,
    this._deleteCategory,
  ) : super(const AsyncValue.loading()) {
    load();
  }

  final GetCategoriesUseCase _getCategories;
  final UpsertCategoryUseCase _upsertCategory;
  final DeleteCategoryUseCase _deleteCategory;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_getCategories.call);
  }

  Future<void> save({int? id, required String name, String? description}) async {
    await _upsertCategory(
      Category(
        id: id,
        name: name,
        description: (description == null || description.isEmpty) ? null : description,
        createdAt: DateTime.now(),
      ),
    );
    await load();
  }

  Future<void> remove(int id) async {
    await _deleteCategory(id);
    await load();
  }
}
