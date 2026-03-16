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
      },
    );
  }
}
