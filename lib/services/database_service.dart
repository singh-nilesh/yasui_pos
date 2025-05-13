import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer.dart';
import '../models/machine.dart';
import '../models/amc.dart';
import '../models/amc_visit.dart';
import '../models/inventory_item.dart';
import '../models/import_order.dart';

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
        // Customers table
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
        
        // Machines table
        await db.execute('''
          CREATE TABLE machines(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            serial_number TEXT,
            quantity INTEGER,
            year INTEGER,
            invoice_date TEXT,
            price_inr REAL,
            price_jpy REAL,
            price_usd REAL,
            customer_id INTEGER,
            customer_name TEXT,
            amc_expiry_date TEXT,
            amc_status TEXT,
            visits_completed TEXT,
            FOREIGN KEY(customer_id) REFERENCES customers(id)
          )
        ''');
        
        // AMC contracts table
        await db.execute('''
          CREATE TABLE amc_contracts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            contract_id TEXT UNIQUE,
            customer_id INTEGER,
            customer_name TEXT,
            machine_id INTEGER,
            machine_name TEXT,
            start_date TEXT,
            end_date TEXT,
            status TEXT,
            last_visit_date TEXT,
            next_visit_date TEXT,
            contract_value REAL,
            visit_frequency INTEGER,
            notes TEXT,
            FOREIGN KEY(customer_id) REFERENCES customers(id),
            FOREIGN KEY(machine_id) REFERENCES machines(id)
          )
        ''');
        
        // AMC visits table
        await db.execute('''
          CREATE TABLE amc_visits(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            visit_id TEXT UNIQUE,
            amc_id INTEGER,
            amc_contract_id TEXT,
            customer_id INTEGER,
            customer_name TEXT,
            machine_id INTEGER,
            machine_name TEXT,
            visit_date TEXT,
            visit_time TEXT,
            engineer_id TEXT,
            engineer_name TEXT,
            status TEXT,
            notes TEXT,
            is_emergency INTEGER,
            FOREIGN KEY(amc_id) REFERENCES amc_contracts(id),
            FOREIGN KEY(customer_id) REFERENCES customers(id),
            FOREIGN KEY(machine_id) REFERENCES machines(id)
          )
        ''');
        
        // Inventory items table
        await db.execute('''
          CREATE TABLE inventory_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            type TEXT,
            quantity INTEGER,
            unit_price REAL,
            last_updated TEXT,
            notes TEXT
          )
        ''');
        
        // Inventory thresholds table
        await db.execute('''
          CREATE TABLE inventory_thresholds(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_name TEXT UNIQUE,
            threshold INTEGER
          )
        ''');
        
        // Import orders table
        await db.execute('''
          CREATE TABLE import_orders(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id TEXT UNIQUE,
            date TEXT,
            part_code TEXT,
            item_name TEXT,
            serial_number TEXT,
            quantity INTEGER,
            customer_id INTEGER,
            customer_name TEXT,
            year INTEGER,
            ync_invoice TEXT,
            invoice_date TEXT,
            price_inr REAL,
            price_jpy REAL,
            price_usd REAL,
            status TEXT,
            FOREIGN KEY(customer_id) REFERENCES customers(id)
          )
        ''');
        
        // Engineers table
        await db.execute('''
          CREATE TABLE engineers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
        ''');
        
        // Insert some default engineers
        await db.execute('''
          INSERT INTO engineers (name) VALUES 
          ('Rahul Sharma'), 
          ('Amit Patel'), 
          ('Priya Verma'), 
          ('Sunil Kumar')
        ''');
      },
    );
  }

  // Customer CRUD operations
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

  // Machine CRUD operations
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

  // AMC CRUD operations
  Future<int> insertAMC(AMC amc) async {
    final db = await database;
    return await db.insert('amc_contracts', amc.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AMC>> getAMCs() async {
    final db = await database;
    final maps = await db.query('amc_contracts');
    return maps.map((map) => AMC.fromMap(map)).toList();
  }

  Future<List<AMC>> getActiveAMCs() async {
    final db = await database;
    final maps = await db.query('amc_contracts', where: 'status = ?', whereArgs: ['Active']);
    return maps.map((map) => AMC.fromMap(map)).toList();
  }

  Future<List<AMC>> getExpiringAMCs() async {
    // Get AMCs expiring within 30 days
    final now = DateTime.now();
    final thirtyDaysLater = now.add(const Duration(days: 30));
    
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT * FROM amc_contracts WHERE status = ? AND date(end_date) BETWEEN date(?) AND date(?)',
      ['Active', now.toIso8601String(), thirtyDaysLater.toIso8601String()]
    );
    return maps.map((map) => AMC.fromMap(map)).toList();
  }

  Future<AMC?> getAMC(int id) async {
    final db = await database;
    final maps = await db.query('amc_contracts', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return AMC.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateAMC(AMC amc) async {
    final db = await database;
    return await db.update('amc_contracts', amc.toMap(), where: 'id = ?', whereArgs: [amc.id]);
  }

  Future<int> deleteAMC(int id) async {
    final db = await database;
    return await db.delete('amc_contracts', where: 'id = ?', whereArgs: [id]);
  }

  // AMC Visit CRUD operations
  Future<int> insertAMCVisit(AMCVisit visit) async {
    final db = await database;
    return await db.insert('amc_visits', visit.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AMCVisit>> getAMCVisits() async {
    final db = await database;
    final maps = await db.query('amc_visits');
    return maps.map((map) => AMCVisit.fromMap(map)).toList();
  }

  Future<List<AMCVisit>> getAMCVisitsByDate(DateTime date) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0];
    final maps = await db.query(
      'amc_visits',
      where: 'visit_date LIKE ?',
      whereArgs: ['$dateString%']
    );
    return maps.map((map) => AMCVisit.fromMap(map)).toList();
  }

  Future<List<AMCVisit>> getAMCVisitsByContract(int amcId) async {
    final db = await database;
    final maps = await db.query('amc_visits', where: 'amc_id = ?', whereArgs: [amcId]);
    return maps.map((map) => AMCVisit.fromMap(map)).toList();
  }

  Future<AMCVisit?> getAMCVisit(int id) async {
    final db = await database;
    final maps = await db.query('amc_visits', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return AMCVisit.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateAMCVisit(AMCVisit visit) async {
    final db = await database;
    return await db.update('amc_visits', visit.toMap(), where: 'id = ?', whereArgs: [visit.id]);
  }

  Future<int> deleteAMCVisit(int id) async {
    final db = await database;
    return await db.delete('amc_visits', where: 'id = ?', whereArgs: [id]);
  }

  // Inventory Item CRUD operations
  Future<int> insertInventoryItem(InventoryItem item) async {
    final db = await database;
    return await db.insert('inventory_items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<InventoryItem>> getInventoryItems() async {
    final db = await database;
    final maps = await db.query('inventory_items');
    return maps.map((map) => InventoryItem.fromMap(map)).toList();
  }

  Future<List<InventoryItem>> getInventoryItemsByType(String type) async {
    final db = await database;
    final maps = await db.query('inventory_items', where: 'type = ?', whereArgs: [type]);
    return maps.map((map) => InventoryItem.fromMap(map)).toList();
  }

  Future<List<InventoryItem>> getLowStockItems() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT i.* FROM inventory_items i
      JOIN inventory_thresholds t ON i.name = t.item_name
      WHERE i.quantity <= t.threshold
    ''');
    return maps.map((map) => InventoryItem.fromMap(map)).toList();
  }

  Future<InventoryItem?> getInventoryItem(int id) async {
    final db = await database;
    final maps = await db.query('inventory_items', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return InventoryItem.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateInventoryItem(InventoryItem item) async {
    final db = await database;
    return await db.update('inventory_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> deleteInventoryItem(int id) async {
    final db = await database;
    return await db.delete('inventory_items', where: 'id = ?', whereArgs: [id]);
  }

  // Inventory Threshold operations
  Future<int> setInventoryThreshold(String itemName, int threshold) async {
    final db = await database;
    return await db.insert(
      'inventory_thresholds',
      {'item_name': itemName, 'threshold': threshold},
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<Map<String, int>> getInventoryThresholds() async {
    final db = await database;
    final maps = await db.query('inventory_thresholds');
    return Map.fromEntries(
      maps.map((map) => MapEntry(map['item_name'] as String, map['threshold'] as int))
    );
  }

  Future<int> deleteInventoryThreshold(String itemName) async {
    final db = await database;
    return await db.delete('inventory_thresholds', where: 'item_name = ?', whereArgs: [itemName]);
  }

  // Import Order CRUD operations
  Future<int> insertImportOrder(ImportOrder order) async {
    final db = await database;
    return await db.insert('import_orders', order.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ImportOrder>> getImportOrders() async {
    final db = await database;
    final maps = await db.query('import_orders');
    return maps.map((map) => ImportOrder.fromMap(map)).toList();
  }

  Future<List<ImportOrder>> getImportOrdersByStatus(String status) async {
    final db = await database;
    final maps = await db.query('import_orders', where: 'status = ?', whereArgs: [status]);
    return maps.map((map) => ImportOrder.fromMap(map)).toList();
  }

  Future<ImportOrder?> getImportOrder(int id) async {
    final db = await database;
    final maps = await db.query('import_orders', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return ImportOrder.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateImportOrder(ImportOrder order) async {
    final db = await database;
    return await db.update('import_orders', order.toMap(), where: 'id = ?', whereArgs: [order.id]);
  }

  Future<int> deleteImportOrder(int id) async {
    final db = await database;
    return await db.delete('import_orders', where: 'id = ?', whereArgs: [id]);
  }

  // Engineer operations
  Future<List<String>> getEngineers() async {
    final db = await database;
    final maps = await db.query('engineers');
    return maps.map((map) => map['name'] as String).toList();
  }

  Future<int> addEngineer(String name) async {
    final db = await database;
    return await db.insert('engineers', {'name': name});
  }
}
