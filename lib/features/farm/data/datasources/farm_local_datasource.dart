import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_service.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/farm_area.dart';
import '../../domain/entities/farm_expense.dart';
import '../../domain/entities/harvest.dart';
import '../../domain/entities/harvest_sale.dart';
import '../../domain/entities/modules_config.dart';
import '../../domain/entities/planting.dart';

class FarmLocalDatasource {
  FarmLocalDatasource(this._databaseService);

  final DatabaseService _databaseService;

  Future<List<FarmArea>> getAreas() async {
    final db = await _databaseService.database;
    final rows = await db.query('areas', orderBy: 'is_active DESC, name ASC');
    return rows
        .map(
          (e) => FarmArea(
            id: e['id'] as int,
            name: e['name'] as String,
            description: e['description'] as String?,
            areaSize: (e['area_size'] as num?)?.toDouble(),
            areaUnit: e['area_unit'] as String?,
            notes: e['notes'] as String?,
            isActive: (e['is_active'] as int) == 1,
          ),
        )
        .toList();
  }

  Future<void> upsertArea(FarmArea area) async {
    final db = await _databaseService.database;
    final now = DateTime.now().toIso8601String();
    final map = {
      'name': area.name,
      'description': area.description,
      'area_size': area.areaSize,
      'area_unit': area.areaUnit,
      'notes': area.notes,
      'is_active': area.isActive ? 1 : 0,
      'updated_at': now,
    };

    if (area.id == null) {
      await db.insert('areas', {...map, 'created_at': now});
      return;
    }

    await db.update('areas', map, where: 'id = ?', whereArgs: [area.id]);
  }

  Future<List<Planting>> getPlantings() async {
    final db = await _databaseService.database;
    final rows = await db.rawQuery('''
      SELECT p.id, p.area_id, a.name AS area_name, p.crop_name, p.variety, p.planting_date,
             p.expected_harvest_date, p.cycle_days, p.planted_quantity, p.planted_unit,
             p.initial_cost, p.notes, p.status
      FROM plantings p
      INNER JOIN areas a ON a.id = p.area_id
      ORDER BY p.planting_date DESC, p.id DESC
    ''');

    return rows
        .map(
          (e) => Planting(
            id: e['id'] as int,
            areaId: e['area_id'] as int,
            areaName: e['area_name'] as String,
            cropName: e['crop_name'] as String,
            variety: e['variety'] as String?,
            plantingDate: DateTime.parse(e['planting_date'] as String),
            expectedHarvestDate: (e['expected_harvest_date'] as String?) == null
                ? null
                : DateTime.parse(e['expected_harvest_date'] as String),
            cycleDays: e['cycle_days'] as int?,
            plantedQuantity: (e['planted_quantity'] as num?)?.toDouble(),
            plantedUnit: e['planted_unit'] as String?,
            initialCost: (e['initial_cost'] as num).toDouble(),
            notes: e['notes'] as String?,
            status: e['status'] as String,
          ),
        )
        .toList();
  }

  Future<void> upsertPlanting({
    int? id,
    required int areaId,
    required String cropName,
    String? variety,
    required DateTime plantingDate,
    DateTime? expectedHarvestDate,
    int? cycleDays,
    double? plantedQuantity,
    String? plantedUnit,
    required double initialCost,
    String? notes,
    required String status,
  }) async {
    final db = await _databaseService.database;
    final now = DateTime.now().toIso8601String();
    final map = {
      'area_id': areaId,
      'crop_name': cropName,
      'variety': variety,
      'planting_date': plantingDate.toIso8601String(),
      'expected_harvest_date': expectedHarvestDate?.toIso8601String(),
      'cycle_days': cycleDays,
      'planted_quantity': plantedQuantity,
      'planted_unit': plantedUnit,
      'initial_cost': initialCost,
      'notes': notes,
      'status': status,
      'updated_at': now,
    };

    if (id == null) {
      await db.insert('plantings', {...map, 'created_at': now});
      return;
    }

    await db.update('plantings', map, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Harvest>> getHarvests() async {
    final db = await _databaseService.database;
    final rows = await db.rawQuery('''
      SELECT h.id, h.planting_id, p.crop_name, a.name AS area_name, h.harvest_date,
             h.quantity, h.unit, h.loss_quantity, h.notes,
             COALESCE((SELECT SUM(s.quantity) FROM harvest_sales s WHERE s.harvest_id = h.id), 0) AS sold_quantity
      FROM harvests h
      INNER JOIN plantings p ON p.id = h.planting_id
      INNER JOIN areas a ON a.id = p.area_id
      ORDER BY h.harvest_date DESC, h.id DESC
    ''');

    return rows
        .map(
          (e) => Harvest(
            id: e['id'] as int,
            plantingId: e['planting_id'] as int,
            cropName: e['crop_name'] as String,
            areaName: e['area_name'] as String,
            harvestDate: DateTime.parse(e['harvest_date'] as String),
            quantity: (e['quantity'] as num).toDouble(),
            unit: e['unit'] as String,
            lossQuantity: (e['loss_quantity'] as num?)?.toDouble(),
            notes: e['notes'] as String?,
            soldQuantity: (e['sold_quantity'] as num).toDouble(),
          ),
        )
        .toList();
  }

  Future<void> registerHarvest({
    required int plantingId,
    required DateTime harvestDate,
    required double quantity,
    required String unit,
    double? lossQuantity,
    String? notes,
  }) async {
    final db = await _databaseService.database;
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.insert('harvests', {
        'planting_id': plantingId,
        'harvest_date': harvestDate.toIso8601String(),
        'quantity': quantity,
        'unit': unit,
        'loss_quantity': lossQuantity,
        'notes': notes,
        'created_at': now,
      });

      await txn.update(
        'plantings',
        {'status': 'harvested', 'updated_at': now},
        where: 'id = ?',
        whereArgs: [plantingId],
      );
    });
  }

  Future<List<HarvestSale>> getHarvestSales() async {
    final db = await _databaseService.database;
    final rows = await db.rawQuery('''
      SELECT s.id, s.harvest_id, p.crop_name, c.name AS customer_name, s.sale_date,
             s.quantity, s.unit, s.unit_price, s.total_amount, s.payment_method, s.notes
      FROM harvest_sales s
      INNER JOIN harvests h ON h.id = s.harvest_id
      INNER JOIN plantings p ON p.id = h.planting_id
      LEFT JOIN customers c ON c.id = s.customer_id
      ORDER BY s.sale_date DESC, s.id DESC
    ''');

    return rows
        .map(
          (e) => HarvestSale(
            id: e['id'] as int,
            harvestId: e['harvest_id'] as int,
            cropName: e['crop_name'] as String,
            customerName: e['customer_name'] as String?,
            saleDate: DateTime.parse(e['sale_date'] as String),
            quantity: (e['quantity'] as num).toDouble(),
            unit: e['unit'] as String,
            unitPrice: (e['unit_price'] as num).toDouble(),
            totalAmount: (e['total_amount'] as num).toDouble(),
            paymentMethod: e['payment_method'] as String,
            notes: e['notes'] as String?,
          ),
        )
        .toList();
  }

  Future<void> registerHarvestSale({
    required int harvestId,
    int? customerId,
    required DateTime saleDate,
    required double quantity,
    required String unit,
    required double unitPrice,
    required String paymentMethod,
    String? notes,
  }) async {
    final db = await _databaseService.database;
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      final harvestRows = await txn.query(
        'harvests',
        where: 'id = ?',
        whereArgs: [harvestId],
        limit: 1,
      );
      if (harvestRows.isEmpty) {
        throw AppException('Colheita não encontrada.');
      }
      final harvest = harvestRows.first;
      final harvestQuantity = (harvest['quantity'] as num).toDouble();
      final harvestUnit = harvest['unit'] as String;

      final soldRows = await txn.rawQuery(
        'SELECT COALESCE(SUM(quantity), 0) AS sold FROM harvest_sales WHERE harvest_id = ?',
        [harvestId],
      );
      final sold = (soldRows.first['sold'] as num).toDouble();
      final available = harvestQuantity - sold;

      if (unit != harvestUnit) {
        throw AppException('Use a mesma unidade da colheita ($harvestUnit).');
      }
      if (quantity > available) {
        throw AppException(
          'Venda maior que o saldo disponível. Saldo atual: ${available.toStringAsFixed(2)} $harvestUnit',
        );
      }

      final totalAmount = quantity * unitPrice;
      await txn.insert('harvest_sales', {
        'harvest_id': harvestId,
        'customer_id': customerId,
        'sale_date': saleDate.toIso8601String(),
        'quantity': quantity,
        'unit': unit,
        'unit_price': unitPrice,
        'total_amount': totalAmount,
        'payment_method': paymentMethod,
        'notes': notes,
        'created_at': now,
      });
    });
  }

  Future<List<FarmExpense>> getFarmExpenses() async {
    final db = await _databaseService.database;
    final rows = await db.rawQuery('''
      SELECT e.id, e.planting_id, e.category, e.description, e.amount, e.date, e.notes,
             CASE WHEN p.id IS NOT NULL THEN p.crop_name || ' - ' || a.name ELSE NULL END AS planting_label
      FROM farm_expenses e
      LEFT JOIN plantings p ON p.id = e.planting_id
      LEFT JOIN areas a ON a.id = p.area_id
      ORDER BY e.date DESC, e.id DESC
    ''');

    return rows
        .map(
          (e) => FarmExpense(
            id: e['id'] as int,
            plantingId: e['planting_id'] as int?,
            plantingLabel: e['planting_label'] as String?,
            category: e['category'] as String,
            description: e['description'] as String,
            amount: (e['amount'] as num).toDouble(),
            date: DateTime.parse(e['date'] as String),
            notes: e['notes'] as String?,
          ),
        )
        .toList();
  }

  Future<void> upsertFarmExpense({
    int? id,
    int? plantingId,
    required String category,
    required String description,
    required double amount,
    required DateTime date,
    String? notes,
  }) async {
    final db = await _databaseService.database;
    final now = DateTime.now().toIso8601String();
    final map = {
      'planting_id': plantingId,
      'category': category,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
    };

    if (id == null) {
      await db.insert('farm_expenses', {...map, 'created_at': now});
      return;
    }

    await db.update('farm_expenses', map, where: 'id = ?', whereArgs: [id]);
  }

  Future<ModulesConfig> getModulesConfig() async {
    final db = await _databaseService.database;
    final appRow = await db.query('app_settings', orderBy: 'id ASC', limit: 1);
    final profileMode = appRow.isEmpty
        ? 'agriculture'
        : (appRow.first['profile_mode'] as String? ?? 'agriculture');

    final rows = await db.query('modules_settings');
    final activeModules = <String, bool>{};
    for (final row in rows) {
      activeModules[row['module_key'] as String] =
          (row['is_active'] as int) == 1;
    }

    return ModulesConfig(
      profileMode: profileMode,
      activeModules: activeModules,
    );
  }

  Future<void> setProfileMode(String profileMode) async {
    final db = await _databaseService.database;
    final now = DateTime.now().toIso8601String();
    await db.update('app_settings', {
      'profile_mode': profileMode,
      'updated_at': now,
    }, where: 'id = 1');

    if (profileMode == 'agriculture') {
      await _setModules(db, {
        'areas': true,
        'plantings': true,
        'management': true,
        'harvests': true,
        'sales': true,
        'expenses': true,
        'results': true,
        'customers': true,
        'orders': false,
        'woodworking': false,
      });
    }

    if (profileMode == 'woodworking') {
      await _setModules(db, {
        'areas': false,
        'plantings': false,
        'management': false,
        'harvests': false,
        'sales': false,
        'expenses': true,
        'results': false,
        'customers': true,
        'orders': true,
        'woodworking': true,
      });
    }

    if (profileMode == 'both') {
      await _setModules(db, {
        'areas': true,
        'plantings': true,
        'management': true,
        'harvests': true,
        'sales': true,
        'expenses': true,
        'results': true,
        'customers': true,
        'orders': true,
        'woodworking': true,
      });
    }
  }

  Future<void> setModuleActive({
    required String moduleKey,
    required bool isActive,
  }) async {
    final db = await _databaseService.database;
    await db.update(
      'modules_settings',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'module_key = ?',
      whereArgs: [moduleKey],
    );
  }

  Future<void> _setModules(Database db, Map<String, bool> modules) async {
    final now = DateTime.now().toIso8601String();
    for (final entry in modules.entries) {
      await db.update(
        'modules_settings',
        {'is_active': entry.value ? 1 : 0, 'updated_at': now},
        where: 'module_key = ?',
        whereArgs: [entry.key],
      );
    }
  }
}
