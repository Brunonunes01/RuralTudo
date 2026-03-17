import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'schema/app_schema.dart';

class DatabaseService {
  DatabaseService();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), AppSchema.databaseName);
    return openDatabase(
      path,
      version: AppSchema.databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        for (final sql in AppSchema.createStatements) {
          await db.execute(sql);
        }
        await _seedModuleSettings(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          for (final sql in AppSchema.migrationToV2Statements) {
            await db.execute(sql);
          }
          await _seedModuleSettings(db);
        }
        if (oldVersion < 3) {
          for (final sql in AppSchema.migrationToV3Statements) {
            try {
              await db.execute(sql);
            } on DatabaseException catch (e) {
              if (!e.toString().contains('duplicate column name')) {
                rethrow;
              }
            }
          }
        }
      },
    );
  }

  Future<void> _seedModuleSettings(Database db) async {
    const modules = <String>[
      'areas',
      'plantings',
      'management',
      'harvests',
      'sales',
      'expenses',
      'results',
      'customers',
      'orders',
      'woodworking',
    ];
    final now = DateTime.now().toIso8601String();
    for (final module in modules) {
      await db.insert('modules_settings', {
        'module_key': module,
        'is_active': module == 'woodworking' ? 0 : 1,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await db.insert('app_settings', {
      'profile_mode': 'agriculture',
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
}
