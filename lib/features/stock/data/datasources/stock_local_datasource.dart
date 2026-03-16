import '../../../../core/database/database_service.dart';
import '../models/stock_movement_model.dart';

class StockLocalDatasource {
  StockLocalDatasource(this._databaseService);

  final DatabaseService _databaseService;

  Future<List<StockMovementModel>> getMovements() async {
    final db = await _databaseService.database;
    final rows = await db.rawQuery('''
      SELECT sm.id, sm.product_id, p.name as product_name, sm.movement_type, sm.origin, sm.quantity, sm.date, sm.notes
      FROM stock_movements sm
      INNER JOIN products p ON p.id = sm.product_id
      ORDER BY sm.date DESC, sm.id DESC
    ''');
    return rows.map(StockMovementModel.fromMap).toList();
  }
}
