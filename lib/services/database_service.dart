import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer.dart';
import '../models/machine.dart';
import '../models/stock_master.dart';
import '../models/spare_part.dart';
import '../models/amc_schedule.dart';
import '../models/import.dart';
import '../models/inventory_item.dart';

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
        // Customers Table
        await db.execute('''
          CREATE TABLE customers (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            city TEXT,
            state TEXT,
            country TEXT,
            email TEXT,
            contact_prn_1 TEXT,
            contact_prn_2 TEXT,
            address TEXT,
            tel_no TEXT,
            fax TEXT,
            geo_coord TEXT
          )
        ''');
        // Stock Master Table
        await db.execute('''
          CREATE TABLE stock_master (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            part_code TEXT UNIQUE NOT NULL,
            type TEXT CHECK(type IN ('machine', 'part')) NOT NULL,
            price_usd REAL,
            price_jpy REAL,
            price_inr REAL,
            stock_count INTEGER DEFAULT 0,
            threshold INTEGER DEFAULT 0
          )
        ''');
        // Machines Table
        await db.execute('''
          CREATE TABLE machines (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            customer_id INTEGER REFERENCES customers(id),
            serial_no TEXT UNIQUE,
            purchase_date DATE,
            price_usd REAL,
            price_jpy REAL,
            price_inr REAL,
            seller TEXT,
            amc_start_month DATE,
            amc_expire_month DATE,
            total_visits INTEGER DEFAULT 0,
            pending_visits INTEGER DEFAULT 0
          )
        ''');
        // Spare Parts Table
        await db.execute('''
          CREATE TABLE spare_parts (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            customer_id INTEGER REFERENCES customers(id),
            quantity INTEGER NOT NULL,
            purchase_date DATE,
            price_usd REAL,
            price_jpy REAL,
            price_inr REAL,
            invoice TEXT,
            seller TEXT
          )
        ''');
        // AMC Schedule Table
        await db.execute('''
          CREATE TABLE amc_schedule (
            id INTEGER PRIMARY KEY,
            machine_id INTEGER REFERENCES machines(id),
            due_date DATE,
            maintenance_type TEXT,
            status TEXT CHECK(status IN ('pending', 'completed')) DEFAULT 'pending',
            issue TEXT,
            fix TEXT,
            cost REAL
          )
        ''');
        // Imports Table
        await db.execute('''
          CREATE TABLE imports (
            id INTEGER PRIMARY KEY,
            part_code TEXT NOT NULL REFERENCES stock_master(part_code),
            name TEXT NOT NULL,
            type TEXT CHECK(type IN ('machine', 'part')) NOT NULL,
            customer_id INTEGER REFERENCES customers(id),
            quantity INTEGER NOT NULL,
            import_date DATE,
            price_usd REAL,
            price_jpy REAL,
            price_inr REAL,
            serial_no TEXT,
            invoice TEXT,
            status TEXT CHECK(status IN ('pending', 'delivered')) NOT NULL
          )
        ''');
        // Triggers
        await db.execute('''
          CREATE TRIGGER update_stock_on_import
          AFTER UPDATE ON imports
          FOR EACH ROW
          WHEN NEW.status = 'delivered' AND 
               (SELECT name FROM customers WHERE id = NEW.customer_id) LIKE '%YFE%'
          BEGIN
            UPDATE stock_master
            SET stock_count = stock_count + NEW.quantity
            WHERE part_code = NEW.part_code;
          END
        ''');
        await db.execute('''
          CREATE TRIGGER reduce_stock_on_machine_insert
          AFTER INSERT ON machines
          FOR EACH ROW
          WHEN NEW.seller = 'YFE'
          BEGIN
            UPDATE stock_master
            SET stock_count = stock_count - 1
            WHERE part_code = (SELECT part_code FROM stock_master WHERE name = NEW.name AND type = 'machine');
          END
        ''');
        await db.execute('''
          CREATE TRIGGER reduce_stock_on_spare_insert
          AFTER INSERT ON spare_parts
          FOR EACH ROW
          WHEN NEW.seller = 'YFE'
          BEGIN
            UPDATE stock_master
            SET stock_count = stock_count - NEW.quantity
            WHERE part_code = (SELECT part_code FROM stock_master WHERE name = NEW.name AND type = 'part');
          END
        ''');
      },
    );
  }

  // Customers CRUD
  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final maps = await db.query('customers');
    return maps.map((map) => Customer.fromMap(map)).toList();
  }
  Future<Customer?> getCustomer(int id) async {
    final db = await database;
    final maps = await db.query('customers', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }
  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update('customers', customer.toMap(), where: 'id = ?', whereArgs: [customer.id]);
  }
  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  // Stock Master CRUD
  Future<int> insertStockMaster(StockMaster stockMaster) async {
    final db = await database;
    return await db.insert('stock_master', stockMaster.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<StockMaster>> getStockMasters() async {
    final db = await database;
    final maps = await db.query('stock_master');
    return maps.map((map) => StockMaster.fromMap(map)).toList();
  }
  Future<List<StockMaster>> getStockMastersByType(String type) async {
    final db = await database;
    final maps = await db.query('stock_master', where: 'type = ?', whereArgs: [type]);
    return maps.map((map) => StockMaster.fromMap(map)).toList();
  }
  Future<StockMaster?> getStockMaster(int id) async {
    final db = await database;
    final maps = await db.query('stock_master', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return StockMaster.fromMap(maps.first);
    }
    return null;
  }
  Future<StockMaster?> getStockMasterByPartCode(String partCode) async {
    final db = await database;
    final maps = await db.query('stock_master', where: 'part_code = ?', whereArgs: [partCode]);
    if (maps.isNotEmpty) {
      return StockMaster.fromMap(maps.first);
    }
    return null;
  }
  Future<int> updateStockMaster(StockMaster stockMaster) async {
    final db = await database;
    return await db.update('stock_master', stockMaster.toMap(), where: 'id = ?', whereArgs: [stockMaster.id]);
  }
  Future<int> deleteStockMaster(int id) async {
    final db = await database;
    return await db.delete('stock_master', where: 'id = ?', whereArgs: [id]);
  }

  // Machines CRUD
  Future<int> insertMachine(Machine machine) async {
    final db = await database;
    return await db.insert('machines', machine.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<Machine>> getMachines() async {
    final db = await database;
    final maps = await db.query('machines');
    return maps.map((map) => Machine.fromMap(map)).toList();
  }
  Future<List<Machine>> getMachinesByCustomer(int customerId) async {
    final db = await database;
    final maps = await db.query('machines', where: 'customer_id = ?', whereArgs: [customerId]);
    return maps.map((map) => Machine.fromMap(map)).toList();
  }
  Future<Machine?> getMachine(int id) async {
    final db = await database;
    final maps = await db.query('machines', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Machine.fromMap(maps.first);
    }
    return null;
  }
  Future<int> updateMachine(Machine machine) async {
    final db = await database;
    return await db.update('machines', machine.toMap(), where: 'id = ?', whereArgs: [machine.id]);
  }
  Future<int> deleteMachine(int id) async {
    final db = await database;
    return await db.delete('machines', where: 'id = ?', whereArgs: [id]);
  }

  // Spare Parts CRUD
  Future<int> insertSparePart(SparePart sparePart) async {
    final db = await database;
    return await db.insert('spare_parts', sparePart.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<SparePart>> getSpareParts() async {
    final db = await database;
    final maps = await db.query('spare_parts');
    return maps.map((map) => SparePart.fromMap(map)).toList();
  }
  Future<List<SparePart>> getSparePartsByCustomer(int customerId) async {
    final db = await database;
    final maps = await db.query('spare_parts', where: 'customer_id = ?', whereArgs: [customerId]);
    return maps.map((map) => SparePart.fromMap(map)).toList();
  }
  Future<SparePart?> getSparePart(int id) async {
    final db = await database;
    final maps = await db.query('spare_parts', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return SparePart.fromMap(maps.first);
    }
    return null;
  }
  Future<int> updateSparePart(SparePart sparePart) async {
    final db = await database;
    return await db.update('spare_parts', sparePart.toMap(), where: 'id = ?', whereArgs: [sparePart.id]);
  }
  Future<int> deleteSparePart(int id) async {
    final db = await database;
    return await db.delete('spare_parts', where: 'id = ?', whereArgs: [id]);
  }

  // AMC Schedule CRUD
  Future<int> insertAMCSchedule(AMCSchedule amcSchedule) async {
    final db = await database;
    return await db.insert('amc_schedule', amcSchedule.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<AMCSchedule>> getAMCSchedules() async {
    final db = await database;
    final maps = await db.query('amc_schedule');
    return maps.map((map) => AMCSchedule.fromMap(map)).toList();
  }
  Future<List<AMCSchedule>> getAMCSchedulesByMachine(int machineId) async {
    final db = await database;
    final maps = await db.query('amc_schedule', where: 'machine_id = ?', whereArgs: [machineId]);
    return maps.map((map) => AMCSchedule.fromMap(map)).toList();
  }
  Future<List<AMCSchedule>> getPendingAMCSchedules() async {
    final db = await database;
    final maps = await db.query('amc_schedule', where: 'status = ?', whereArgs: ['pending']);
    return maps.map((map) => AMCSchedule.fromMap(map)).toList();
  }
  Future<AMCSchedule?> getAMCSchedule(int id) async {
    final db = await database;
    final maps = await db.query('amc_schedule', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return AMCSchedule.fromMap(maps.first);
    }
    return null;
  }
  Future<int> updateAMCSchedule(AMCSchedule amcSchedule) async {
    final db = await database;
    return await db.update('amc_schedule', amcSchedule.toMap(), where: 'id = ?', whereArgs: [amcSchedule.id]);
  }
  Future<int> deleteAMCSchedule(int id) async {
    final db = await database;
    return await db.delete('amc_schedule', where: 'id = ?', whereArgs: [id]);
  }

  // Imports CRUD
  Future<int> insertImport(Import importObj) async {
    final db = await database;
    return await db.insert('imports', importObj.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<List<Import>> getImports() async {
    final db = await database;
    final maps = await db.query('imports');
    return maps.map((map) => Import.fromMap(map)).toList();
  }
  Future<List<Import>> getImportsByStatus(String status) async {
    final db = await database;
    final maps = await db.query('imports', where: 'status = ?', whereArgs: [status]);
    return maps.map((map) => Import.fromMap(map)).toList();
  }
  Future<List<Import>> getImportsByCustomer(int customerId) async {
    final db = await database;
    final maps = await db.query('imports', where: 'customer_id = ?', whereArgs: [customerId]);
    return maps.map((map) => Import.fromMap(map)).toList();
  }
  Future<Import?> getImport(int id) async {
    final db = await database;
    final maps = await db.query('imports', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Import.fromMap(maps.first);
    }
    return null;
  }
  Future<int> updateImport(Import importObj) async {
    final db = await database;
    return await db.update('imports', importObj.toMap(), where: 'id = ?', whereArgs: [importObj.id]);
  }
  Future<int> deleteImport(int id) async {
    final db = await database;
    return await db.delete('imports', where: 'id = ?', whereArgs: [id]);
  }

  // Dashboard helpers
  Future<int> getTotalMachinesInStock() async {
    final db = await database;
    final result = await db.rawQuery("SELECT SUM(stock_count) as total FROM stock_master WHERE type = 'machine'");
    return result.first['total'] != null ? result.first['total'] as int : 0;
  }

  Future<Map<String, dynamic>> getDashboardSummary() async {
    final db = await database;
    final machines = await db.rawQuery("SELECT SUM(stock_count) as total FROM stock_master WHERE type = 'machine'");
    final parts = await db.rawQuery("SELECT SUM(stock_count) as total FROM stock_master WHERE type = 'part'");
    final sales = await db.rawQuery("SELECT SUM(price_inr) as total FROM machines WHERE purchase_date IS NOT NULL AND strftime('%Y', purchase_date) = strftime('%Y', 'now')");
    final pendingImports = await db.rawQuery("SELECT COUNT(*) as total FROM imports WHERE status = 'pending'");
    final arrivingThisWeek = await db.rawQuery("SELECT COUNT(*) as total FROM imports WHERE status = 'pending' AND import_date IS NOT NULL AND date(import_date) <= date('now', '+7 days')");
    return {
      'machinesInStock': machines.first['total'] ?? 0,
      'sparePartsInStock': parts.first['total'] ?? 0,
      'totalSales': sales.first['total'] ?? 0,
      'pendingImports': pendingImports.first['total'] ?? 0,
      'arrivingThisWeek': arrivingThisWeek.first['total'] ?? 0,
      'salesPercentChange': 0 // Placeholder
    };
  }

  Future<List<Map<String, dynamic>>> getAMCVisitsDueToday() async {
    final db = await database;
    final today = DateTime.now();
    final todayStr = "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final result = await db.rawQuery('''
      SELECT amc_schedule.*, machines.name as machine, customers.name as customer
      FROM amc_schedule
      JOIN machines ON amc_schedule.machine_id = machines.id
      JOIN customers ON machines.customer_id = customers.id
      WHERE amc_schedule.due_date = ? AND amc_schedule.status = 'pending'
    ''', [todayStr]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getImportOrderStatusForDashboard(int limit) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT * FROM imports ORDER BY import_date DESC LIMIT ?
    ''', [limit]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getInventoryItemsForDashboard(String type, int limit) async {
    final db = await database;
    final dbType = type.toLowerCase() == 'machine' ? 'machine' : 'part';
    final result = await db.rawQuery('''
      SELECT name, stock_count as stock FROM stock_master WHERE type = ? ORDER BY stock_count DESC LIMIT ?
    ''', [dbType, limit]);
    return result;
  }

  // Inventory CRUD and thresholds
  Future<List<InventoryItem>> getInventoryItems() async {
    final db = await database;
    final maps = await db.query('stock_master');
    return maps.map((map) => InventoryItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] == 'machine' ? 'Machine' : 'Spare Part',
      quantity: (map['stock_count'] as int?) ?? 0,
      unitPrice: (map['price_inr'] is int)
          ? (map['price_inr'] as int).toDouble()
          : (map['price_inr'] is double)
              ? map['price_inr'] as double
              : 0.0,
      lastUpdated: DateTime.now(), // No last updated in schema, so use now
      notes: '', // No notes/specs in schema
    )).toList();
  }

  Future<void> insertInventoryItem(InventoryItem item) async {
    final db = await database;
    await db.insert('stock_master', {
      'name': item.name,
      'part_code': item.name.toLowerCase().replaceAll(' ', '_'),
      'type': item.type == 'Machine' ? 'machine' : 'part',
      'price_inr': item.unitPrice,
      'stock_count': item.quantity,
      'price_usd': 0,
      'price_jpy': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    final db = await database;
    await db.update('stock_master', {
      'name': item.name,
      'type': item.type == 'Machine' ? 'machine' : 'part',
      'price_inr': item.unitPrice,
      'stock_count': item.quantity,
    }, where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteInventoryItem(int id) async {
    final db = await database;
    await db.delete('stock_master', where: 'id = ?', whereArgs: [id]);
  }
}
