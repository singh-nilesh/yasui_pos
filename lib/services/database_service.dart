import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'yasui_pos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE customers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT,
            name TEXT,
            country TEXT,
            destination TEXT,
            tell TEXT,
            fax TEXT,
            address TEXT,
            geo TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final maps = await db.query('customers');
    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update('customers', customer.toMap(), where: 'id = ?', whereArgs: [customer.id]);
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }
}
