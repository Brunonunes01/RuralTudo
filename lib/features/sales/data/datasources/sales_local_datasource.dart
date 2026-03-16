import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_service.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/inventory_service.dart';
import '../models/sale_item_model.dart';
import '../models/sale_model.dart';

class SalesLocalDatasource {
  SalesLocalDatasource(this._databaseService, this._inventoryService);

  final DatabaseService _databaseService;
  final InventoryService _inventoryService;

  Future<List<SaleModel>> getAll() async {
    final db = await _databaseService.database;
    final salesRows = await db.rawQuery('''
      SELECT s.id, s.customer_id, c.name as customer_name, s.sale_date, s.total_amount,
             s.payment_method, s.status, s.notes
      FROM sales s
      LEFT JOIN customers c ON c.id = s.customer_id
      ORDER BY s.sale_date DESC, s.id DESC
    ''');

    final result = <SaleModel>[];
    for (final row in salesRows) {
      final items = await _getItemsBySaleId(db, row['id'] as int);
      result.add(SaleModel.fromMap(row, items));
    }
    return result;
  }

  Future<List<SaleItemModel>> _getItemsBySaleId(Database db, int saleId) async {
    final rows = await db.rawQuery('''
      SELECT si.product_id, p.name as product_name, si.quantity, si.unit_price
      FROM sale_items si
      INNER JOIN products p ON p.id = si.product_id
      WHERE si.sale_id = ?
    ''', [saleId]);
    return rows.map(SaleItemModel.fromMap).toList();
  }

  Future<void> registerSale({
    int? customerId,
    required DateTime saleDate,
    required String paymentMethod,
    String? notes,
    required List<SaleItemModel> items,
  }) async {
    if (items.isEmpty) {
      throw AppException('Venda precisa ter ao menos um item');
    }

    final db = await _databaseService.database;
    await db.transaction((txn) async {
      for (final item in items) {
        final currentStock = await _inventoryService.getCurrentStock(txn, item.productId);
        if (currentStock < item.quantity) {
          throw AppException('Estoque insuficiente para ${item.productName}');
        }
      }

      final total = items.fold<double>(0, (sum, item) => sum + item.subtotal);

      final saleId = await txn.insert('sales', {
        'customer_id': customerId,
        'sale_date': saleDate.toIso8601String(),
        'total_amount': total,
        'payment_method': paymentMethod,
        'status': 'completed',
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      });

      for (final item in items) {
        await txn.insert('sale_items', {
          'sale_id': saleId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'subtotal': item.subtotal,
          'created_at': DateTime.now().toIso8601String(),
        });

        await _inventoryService.decreaseStock(
          db: txn,
          productId: item.productId,
          quantity: item.quantity,
          origin: 'sale',
          date: saleDate.toIso8601String(),
          referenceId: saleId,
          notes: 'Venda #$saleId',
        );
      }
    });
  }

  Future<void> cancelSale(int saleId) async {
    final db = await _databaseService.database;
    await db.transaction((txn) async {
      final sales = await txn.query('sales', where: 'id = ?', whereArgs: [saleId], limit: 1);
      if (sales.isEmpty) {
        throw AppException('Venda nao encontrada');
      }

      if ((sales.first['status'] as String) == 'canceled') {
        return;
      }

      final items = await txn.query('sale_items', where: 'sale_id = ?', whereArgs: [saleId]);
      for (final item in items) {
        await _inventoryService.increaseStock(
          db: txn,
          productId: item['product_id'] as int,
          quantity: (item['quantity'] as num).toDouble(),
          origin: 'sale_cancel',
          date: DateTime.now().toIso8601String(),
          referenceId: saleId,
          notes: 'Cancelamento da venda #$saleId',
        );
      }

      await txn.update('sales', {'status': 'canceled'}, where: 'id = ?', whereArgs: [saleId]);
    });
  }
}
