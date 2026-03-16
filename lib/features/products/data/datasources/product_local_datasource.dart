import '../../../../core/database/database_service.dart';
import '../models/product_model.dart';

class ProductLocalDatasource {
  ProductLocalDatasource(this._databaseService);

  final DatabaseService _databaseService;

  Future<List<ProductModel>> getAll() async {
    final db = await _databaseService.database;
    final rows = await db.query('products', orderBy: 'name ASC');
    return rows.map(ProductModel.fromMap).toList();
  }

  Future<List<ProductModel>> getLowStock() async {
    final db = await _databaseService.database;
    final rows = await db.rawQuery(
      'SELECT * FROM products WHERE stock_quantity <= min_stock AND is_active = 1 ORDER BY stock_quantity ASC',
    );
    return rows.map(ProductModel.fromMap).toList();
  }

  Future<ProductModel?> getById(int id) async {
    final db = await _databaseService.database;
    final rows = await db.query('products', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return ProductModel.fromMap(rows.first);
  }

  Future<void> upsert(ProductModel model) async {
    final db = await _databaseService.database;
    final map = model.toMap()..remove('id');
    if (model.id == null) {
      await db.insert('products', map);
      return;
    }
    await db.update('products', map, where: 'id = ?', whereArgs: [model.id]);
  }

  Future<void> delete(int id) async {
    final db = await _databaseService.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateStock(int productId, double newQuantity) async {
    final db = await _databaseService.database;
    await db.update(
      'products',
      {
        'stock_quantity': newQuantity,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
  }
}
