import '../../../../core/database/database_service.dart';
import '../models/category_model.dart';

class CategoryLocalDatasource {
  CategoryLocalDatasource(this._databaseService);

  final DatabaseService _databaseService;

  Future<List<CategoryModel>> getAll() async {
    final db = await _databaseService.database;
    final rows = await db.query('categories', orderBy: 'name ASC');
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<void> upsert(CategoryModel model) async {
    final db = await _databaseService.database;
    final map = model.toMap()..remove('id');
    if (model.id == null) {
      await db.insert('categories', map);
      return;
    }
    await db.update('categories', map, where: 'id = ?', whereArgs: [model.id]);
  }

  Future<void> delete(int id) async {
    final db = await _databaseService.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
