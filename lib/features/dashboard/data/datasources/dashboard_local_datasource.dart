import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_service.dart';
import '../../domain/entities/dashboard_summary.dart';

class DashboardLocalDatasource {
  DashboardLocalDatasource(this._databaseService);

  final DatabaseService _databaseService;

  Future<DashboardSummary> getSummary() async {
    final db = await _databaseService.database;
    final now = DateTime.now();
    final thirtyDaysAgo = now
        .subtract(const Duration(days: 30))
        .toIso8601String();
    final monthStart = DateTime(now.year, now.month).toIso8601String();

    final plantingsInProgress =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM plantings WHERE status IN ('planted','growing')",
          ),
        ) ??
        0;
    final plantingsReadyToHarvest =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM plantings WHERE status = 'ready_to_harvest'",
          ),
        ) ??
        0;
    final recentHarvests =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM harvests WHERE harvest_date >= ?',
            [thirtyDaysAgo],
          ),
        ) ??
        0;
    final recentSales =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM harvest_sales WHERE sale_date >= ?',
            [thirtyDaysAgo],
          ),
        ) ??
        0;
    final recentExpenses =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM farm_expenses WHERE date >= ?',
            [thirtyDaysAgo],
          ),
        ) ??
        0;

    final availableFromRecentHarvests =
        (await db.rawQuery(
              '''
      SELECT COALESCE(SUM(h.quantity - IFNULL(s.sold, 0)), 0) AS available
      FROM harvests h
      LEFT JOIN (
        SELECT harvest_id, SUM(quantity) AS sold
        FROM harvest_sales
        GROUP BY harvest_id
      ) s ON s.harvest_id = h.id
      WHERE h.harvest_date >= ?
    ''',
              [thirtyDaysAgo],
            )).first['available']
            as num? ??
        0;

    final salesAmount =
        (await db.rawQuery(
              'SELECT COALESCE(SUM(total_amount), 0) AS total FROM harvest_sales WHERE sale_date >= ?',
              [monthStart],
            )).first['total']
            as num? ??
        0;

    final expensesAmount =
        (await db.rawQuery(
              'SELECT COALESCE(SUM(amount), 0) AS total FROM farm_expenses WHERE date >= ?',
              [monthStart],
            )).first['total']
            as num? ??
        0;

    return DashboardSummary(
      plantingsInProgress: plantingsInProgress,
      plantingsReadyToHarvest: plantingsReadyToHarvest,
      recentHarvests: recentHarvests,
      recentSales: recentSales,
      recentExpenses: recentExpenses,
      availableFromRecentHarvests: availableFromRecentHarvests.toDouble(),
      estimatedProfitPeriod: salesAmount.toDouble() - expensesAmount.toDouble(),
    );
  }
}
