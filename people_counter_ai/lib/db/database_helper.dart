import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/people_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('people_counter.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE people_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        male INTEGER NOT NULL,
        female INTEGER NOT NULL,
        total INTEGER NOT NULL,
        enterCount INTEGER NOT NULL,
        exitCount INTEGER NOT NULL,
        insideCount INTEGER NOT NULL,
        location TEXT NOT NULL,
        session TEXT NOT NULL,
        dateTime TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _addColumnIfNotExists(
        db,
        'people_records',
        'enterCount',
        "INTEGER NOT NULL DEFAULT 0",
      );

      await _addColumnIfNotExists(
        db,
        'people_records',
        'exitCount',
        "INTEGER NOT NULL DEFAULT 0",
      );

      await _addColumnIfNotExists(
        db,
        'people_records',
        'insideCount',
        "INTEGER NOT NULL DEFAULT 0",
      );
    }
  }

  Future<void> _addColumnIfNotExists(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((item) => item['name'] == column);

    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }

  Future<int> insertRecord(PeopleRecord record) async {
    final db = await instance.database;
    return await db.insert('people_records', record.toMap());
  }

  Future<List<PeopleRecord>> getAllRecords() async {
    final db = await instance.database;

    final result = await db.query('people_records', orderBy: 'id DESC');

    return result.map((map) => PeopleRecord.fromMap(map)).toList();
  }

  Future<int> updateRecord(PeopleRecord record) async {
    final db = await instance.database;

    return await db.update(
      'people_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteRecord(int id) async {
    final db = await instance.database;

    return await db.delete('people_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllRecords() async {
    final db = await instance.database;
    return await db.delete('people_records');
  }
}
