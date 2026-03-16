import '../../../../core/database/database_service.dart';
import '../../../../core/services/inventory_service.dart';
import '../models/production_record_model.dart';

class ProductionLocalDatasource {
  ProductionLocalDatasource(this._databaseService, this._inventoryService);

  final DatabaseService _databaseService;
  final InventoryService _inventoryService;

  Future<List<ProductionRecordModel>> getAll() async {
    final db = await _databaseService.database;
    final rows = await db.rawQuery('''
      SELECT pr.id, pr.product_id, p.name as product_name, pr.production_type, pr.quantity,
             pr.estimated_cost, pr.date, pr.notes, pr.created_at
      FROM productions pr
      INNER JOIN products p ON p.id = pr.product_id
      ORDER BY pr.date DESC, pr.id DESC
    ''');
    return rows.map(ProductionRecordModel.fromMap).toList();
  }

  Future<void> register({
    required int productId,
    required String productionType,
    required double quantity,
    double? estimatedCost,
    String? notes,
    required DateTime date,
  }) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      final productionId = await txn.insert('productions', {
        'product_id': productId,
        'production_type': productionType,
        'quantity': quantity,
        'estimated_cost': estimatedCost,
        'date': date.toIso8601String(),
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      });

      await _inventoryService.increaseStock(
        db: txn,
        productId: productId,
        quantity: quantity,
        origin: 'production',
        date: date.toIso8601String(),
        referenceId: productionId,
        notes: notes,
      );
    });
  }
}
