import 'package:sqflite/sqflite.dart';

import '../errors/app_exception.dart';

class InventoryService {
  Future<double> getCurrentStock(DatabaseExecutor db, int productId) async {
    final rows = await db.query('products', columns: ['stock_quantity'], where: 'id = ?', whereArgs: [productId], limit: 1);
    if (rows.isEmpty) {
      throw AppException('Produto nao encontrado: $productId');
    }
    return (rows.first['stock_quantity'] as num).toDouble();
  }

  Future<void> increaseStock({
    required DatabaseExecutor db,
    required int productId,
    required double quantity,
    required String origin,
    required String date,
    int? referenceId,
    String? notes,
  }) async {
    final current = await getCurrentStock(db, productId);
    final updated = current + quantity;

    await db.update(
      'products',
      {'stock_quantity': updated, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [productId],
    );

    await _recordMovement(
      db: db,
      productId: productId,
      movementType: 'entry',
      origin: origin,
      quantity: quantity,
      date: date,
      referenceId: referenceId,
      notes: notes,
    );
  }

  Future<void> decreaseStock({
    required DatabaseExecutor db,
    required int productId,
    required double quantity,
    required String origin,
    required String date,
    int? referenceId,
    String? notes,
  }) async {
    final current = await getCurrentStock(db, productId);
    if (current < quantity) {
      throw AppException('Estoque insuficiente para o produto $productId');
    }
    final updated = current - quantity;

    await db.update(
      'products',
      {'stock_quantity': updated, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [productId],
    );

    await _recordMovement(
      db: db,
      productId: productId,
      movementType: 'exit',
      origin: origin,
      quantity: quantity,
      date: date,
      referenceId: referenceId,
      notes: notes,
    );
  }

  Future<void> adjustStock({
    required DatabaseExecutor db,
    required int productId,
    required double quantity,
    required String date,
    String? notes,
  }) async {
    await db.update(
      'products',
      {'stock_quantity': quantity, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [productId],
    );

    await _recordMovement(
      db: db,
      productId: productId,
      movementType: 'adjustment',
      origin: 'manual_adjustment',
      quantity: quantity,
      date: date,
      notes: notes,
    );
  }

  Future<void> _recordMovement({
    required DatabaseExecutor db,
    required int productId,
    required String movementType,
    required String origin,
    required double quantity,
    required String date,
    int? referenceId,
    String? notes,
  }) async {
    await db.insert('stock_movements', {
      'product_id': productId,
      'movement_type': movementType,
      'origin': origin,
      'quantity': quantity,
      'date': date,
      'notes': notes,
      'reference_id': referenceId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
