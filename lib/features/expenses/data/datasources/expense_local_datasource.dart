import '../../../../core/database/database_service.dart';
import '../models/expense_model.dart';

class ExpenseLocalDatasource {
  ExpenseLocalDatasource(this._databaseService);

  final DatabaseService _databaseService;

  Future<List<ExpenseModel>> getAll() async {
    final db = await _databaseService.database;
    final rows = await db.query('expenses', orderBy: 'date DESC');
    return rows.map(ExpenseModel.fromMap).toList();
  }

  Future<void> upsert(ExpenseModel expense) async {
    final db = await _databaseService.database;
    final map = expense.toMap()..remove('id');
    if (expense.id == null) {
      await db.insert('expenses', map);
      return;
    }
    await db.update('expenses', map, where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<void> delete(int id) async {
    final db = await _databaseService.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
