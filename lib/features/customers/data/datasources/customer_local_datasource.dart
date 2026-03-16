import '../../../../core/database/database_service.dart';
import '../models/customer_model.dart';

class CustomerLocalDatasource {
  CustomerLocalDatasource(this._databaseService);

  final DatabaseService _databaseService;

  Future<List<CustomerModel>> getAll() async {
    final db = await _databaseService.database;
    final rows = await db.query('customers', orderBy: 'name ASC');
    return rows.map(CustomerModel.fromMap).toList();
  }

  Future<void> upsert(CustomerModel customer) async {
    final db = await _databaseService.database;
    final map = customer.toMap()..remove('id');
    if (customer.id == null) {
      await db.insert('customers', map);
      return;
    }
    await db.update('customers', map, where: 'id = ?', whereArgs: [customer.id]);
  }

  Future<void> delete(int id) async {
    final db = await _databaseService.database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }
}
