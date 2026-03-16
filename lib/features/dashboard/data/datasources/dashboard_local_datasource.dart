import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_service.dart';
import '../../domain/entities/dashboard_summary.dart';

class DashboardLocalDatasource {
  DashboardLocalDatasource(this._databaseService);

  final DatabaseService _databaseService;

  Future<DashboardSummary> getSummary() async {
    final db = await _databaseService.database;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
    final monthStart = DateTime(now.year, now.month).toIso8601String();

    final soldToday = Sqflite.firstIntValue(await db.rawQuery(
          "SELECT COALESCE(SUM(total_amount), 0) FROM sales WHERE status = 'completed' AND sale_date >= ?",
          [todayStart],
        )) ??
        0;

    final soldMonth = Sqflite.firstIntValue(await db.rawQuery(
          "SELECT COALESCE(SUM(total_amount), 0) FROM sales WHERE status = 'completed' AND sale_date >= ?",
          [monthStart],
        )) ??
        0;

    final expensesMonth = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COALESCE(SUM(amount), 0) FROM expenses WHERE date >= ?',
          [monthStart],
        )) ??
        0;

    final lowStockCount = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM products WHERE stock_quantity <= min_stock AND is_active = 1',
        )) ??
        0;

    final pendingOrders = Sqflite.firstIntValue(await db.rawQuery(
          "SELECT COUNT(*) FROM orders WHERE status IN ('pending', 'inProduction', 'ready')",
        )) ??
        0;

    final totalProducts = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products')) ?? 0;

    final soldMonthDouble = soldMonth.toDouble();
    final expensesMonthDouble = expensesMonth.toDouble();

    return DashboardSummary(
      soldToday: soldToday.toDouble(),
      soldMonth: soldMonthDouble,
      expensesMonth: expensesMonthDouble,
      estimatedProfit: soldMonthDouble - expensesMonthDouble,
      lowStockCount: lowStockCount,
      pendingOrders: pendingOrders,
      totalProducts: totalProducts,
    );
  }
}
