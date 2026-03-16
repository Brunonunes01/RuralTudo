import '../../../../core/database/database_service.dart';
import '../../domain/entities/report_summary.dart';

class ReportsLocalDatasource {
  ReportsLocalDatasource(this._databaseService);

  final DatabaseService _databaseService;

  Future<ReportSummary> getSummary({required DateTime start, required DateTime end}) async {
    final db = await _databaseService.database;
    final startIso = start.toIso8601String();
    final endIso = end.toIso8601String();

    final salesRows = await db.rawQuery(
      "SELECT COALESCE(SUM(total_amount), 0) AS total FROM sales WHERE status = 'completed' AND sale_date BETWEEN ? AND ?",
      [startIso, endIso],
    );
    final totalSales = (salesRows.first['total'] as num).toDouble();

    final expensesRows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM expenses WHERE date BETWEEN ? AND ?',
      [startIso, endIso],
    );
    final totalExpenses = (expensesRows.first['total'] as num).toDouble();

    final topProductsRows = await db.rawQuery('''
      SELECT p.name, SUM(si.quantity) AS qty
      FROM sale_items si
      INNER JOIN sales s ON s.id = si.sale_id
      INNER JOIN products p ON p.id = si.product_id
      WHERE s.status = 'completed' AND s.sale_date BETWEEN ? AND ?
      GROUP BY p.id
      ORDER BY qty DESC
      LIMIT 5
    ''', [startIso, endIso]);

    final lowStockRows = await db.rawQuery(
      'SELECT name, stock_quantity, min_stock FROM products WHERE stock_quantity <= min_stock ORDER BY stock_quantity ASC LIMIT 10',
    );

    final productionRows = await db.rawQuery(
      'SELECT COALESCE(SUM(quantity), 0) AS total FROM productions WHERE date BETWEEN ? AND ?',
      [startIso, endIso],
    );

    final salesByCategoryRows = await db.rawQuery('''
      SELECT c.name AS category_name, COALESCE(SUM(si.subtotal), 0) AS total
      FROM sale_items si
      INNER JOIN sales s ON s.id = si.sale_id
      INNER JOIN products p ON p.id = si.product_id
      INNER JOIN categories c ON c.id = p.category_id
      WHERE s.status = 'completed' AND s.sale_date BETWEEN ? AND ?
      GROUP BY c.id
      ORDER BY total DESC
    ''', [startIso, endIso]);

    return ReportSummary(
      totalSales: totalSales,
      totalExpenses: totalExpenses,
      estimatedProfit: totalSales - totalExpenses,
      topProducts: topProductsRows.map((e) => '${e['name']} (${(e['qty'] as num).toStringAsFixed(2)})').toList(),
      lowStockProducts: lowStockRows
          .map((e) => '${e['name']} (${(e['stock_quantity'] as num).toStringAsFixed(2)}/${(e['min_stock'] as num).toStringAsFixed(2)})')
          .toList(),
      totalProduction: (productionRows.first['total'] as num).toDouble(),
      salesByCategory: salesByCategoryRows
          .map((e) => '${e['category_name']}: ${(e['total'] as num).toStringAsFixed(2)}')
          .toList(),
    );
  }
}
