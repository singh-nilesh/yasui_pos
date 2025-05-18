import '../models/customer.dart';
import '../models/machine.dart';
import '../models/stock_master.dart';
import '../models/spare_part.dart';
import '../models/import.dart';
import '../models/amc_schedule.dart';
import 'database_service.dart';

class DataSeederService {
  final DatabaseService _databaseService = DatabaseService();
  
  // Main method to seed all data
  Future<void> seedAllData() async {
    await seedCustomers();
    await seedStockMaster();
    await seedMachines();
    await seedSpareParts();
    await seedImports();
    await seedAMCSchedules();
  }
  
  // Seed customer data
  Future<void> seedCustomers() async {
    try {
      final customers = [
        Customer(
          name: 'YFE India',
          city: 'Mumbai',
          state: 'Maharashtra',
          country: 'India',
          email: 'contact@yfe.com',
          contactPrn1: 'John Doe',
          contactPrn2: 'Jane Smith',
          address: '123 Main Street, Mumbai',
          telNo: '+91-22-1234-5678',
          fax: '+91-22-1234-5679',
          geoCoord: '19.0760,72.8777',
        ),
        Customer(
          name: 'Tokyo Jewelry Co.',
          city: 'Tokyo',
          state: null,
          country: 'Japan',
          email: 'info@tokyojewelry.com',
          contactPrn1: 'Takeshi Yamamoto',
          contactPrn2: null,
          address: '1-2-3 Chiyoda, Tokyo',
          telNo: '+81-3-1234-5678',
          fax: '+81-3-1234-5679',
          geoCoord: '35.6812,139.7671',
        ),
        Customer(
          name: 'Mumbai Jewels',
          city: 'Mumbai',
          state: 'Maharashtra',
          country: 'India',
          email: 'contact@mumbaijewels.com',
          contactPrn1: 'Raj Patel',
          contactPrn2: 'Priya Shah',
          address: '123 Marine Drive, Mumbai',
          telNo: '+91-22-2345-6789',
          fax: '+91-22-2345-6780',
          geoCoord: '19.0760,72.8777',
        ),
        Customer(
          name: 'Dubai Gold',
          city: 'Dubai',
          state: 'Dubai',
          country: 'UAE',
          email: 'info@dubaigold.ae',
          contactPrn1: 'Mohammed Al Fasi',
          contactPrn2: null,
          address: 'Gold Souk, Dubai',
          telNo: '+971-4-1234-5678',
          fax: '+971-4-1234-5679',
          geoCoord: '25.2697,55.3094',
        ),
        Customer(
          name: 'New York Diamonds',
          city: 'New York',
          state: 'NY',
          country: 'USA',
          email: 'sales@nydimonds.com',
          contactPrn1: 'David Cohen',
          contactPrn2: 'Sarah Miller',
          address: '47th Street Diamond District, New York',
          telNo: '+1-212-1234-5678',
          fax: '+1-212-1234-5679',
          geoCoord: '40.7580,-73.9855',
        ),
      ];
      
      for (var customer in customers) {
        await _databaseService.insertCustomer(customer);
      }
      
      print('Customers seeded successfully');
    } catch (e) {
      print('Error seeding customers: $e');
    }
  }
  
  // Seed stock master data
  Future<void> seedStockMaster() async {
    try {
      final stockItems = [
        StockMaster(
          name: 'Casting Machine X1',
          partCode: 'CM-X1',
          type: 'machine',
          priceUsd: 3500.0,
          priceJpy: 540000.0,
          priceInr: 285000.0,
          stockCount: 5,
          threshold: 2,
        ),
        StockMaster(
          name: 'Polisher P200',
          partCode: 'PP-200',
          type: 'machine',
          priceUsd: 2200.0,
          priceJpy: 340000.0,
          priceInr: 180000.0,
          stockCount: 3,
          threshold: 2,
        ),
        StockMaster(
          name: 'Wax Injector W50',
          partCode: 'WI-50',
          type: 'machine',
          priceUsd: 1850.0,
          priceJpy: 285000.0,
          priceInr: 150000.0,
          stockCount: 4,
          threshold: 2,
        ),
        StockMaster(
          name: 'Laser Welder LW-20',
          partCode: 'LW-20',
          type: 'machine',
          priceUsd: 3900.0,
          priceJpy: 605000.0,
          priceInr: 320000.0,
          stockCount: 2,
          threshold: 2,
        ),
        StockMaster(
          name: 'Heating Element HE-100',
          partCode: 'HE-100',
          type: 'part',
          priceUsd: 60.0,
          priceJpy: 9000.0,
          priceInr: 5000.0,
          stockCount: 25,
          threshold: 5,
        ),
        StockMaster(
          name: 'Vacuum Pump VP-200',
          partCode: 'VP-200',
          type: 'part',
          priceUsd: 100.0,
          priceJpy: 15000.0,
          priceInr: 8500.0,
          stockCount: 15,
          threshold: 5,
        ),
        StockMaster(
          name: 'Polishing Wheel PW-50',
          partCode: 'PW-50',
          type: 'part',
          priceUsd: 15.0,
          priceJpy: 2200.0,
          priceInr: 1200.0,
          stockCount: 40,
          threshold: 5,
        ),
        StockMaster(
          name: 'Wax Nozzle WN-10',
          partCode: 'WN-10',
          type: 'part',
          priceUsd: 10.0,
          priceJpy: 1500.0,
          priceInr: 850.0,
          stockCount: 30,
          threshold: 5,
        ),
        StockMaster(
          name: 'Laser Lens LL-25',
          partCode: 'LL-25',
          type: 'part',
          priceUsd: 180.0,
          priceJpy: 28000.0,
          priceInr: 15000.0,
          stockCount: 12,
          threshold: 5,
        ),
        StockMaster(
          name: 'Control Board CB-X1',
          partCode: 'CB-X1',
          type: 'part',
          priceUsd: 220.0,
          priceJpy: 34000.0,
          priceInr: 18000.0,
          stockCount: 8,
          threshold: 5,
        ),
      ];
      
      for (var item in stockItems) {
        await _databaseService.insertStockMaster(item);
      }
      
      print('Stock master items seeded successfully');
    } catch (e) {
      print('Error seeding stock master: $e');
    }
  }
  
  // Seed machine data
  Future<void> seedMachines() async {
    try {
      // Get customer IDs for reference
      final customers = await _databaseService.getCustomers();
      if (customers.isEmpty) {
        print('No customers found, seeding machines skipped');
        return;
      }
      
      // Sample machines with customer assignments
      final machines = [
        {
          'name': 'Casting Machine X1',
          'serialNo': 'CM-X1-001',
          'customerName': 'Tokyo Jewelry Co.',
          'purchaseDate': '2022-03-15',
          'priceInr': 285000.0,
          'priceJpy': 540000.0,
          'priceUsd': 3500.0,
          'seller': 'YFE',
          'amcStartMonth': '2022-04-01',
          'amcExpireMonth': '2023-03-31',
        },
        {
          'name': 'Polisher P200',
          'serialNo': 'PP-200-002',
          'customerName': 'Mumbai Jewels',
          'purchaseDate': '2023-01-10',
          'priceInr': 180000.0,
          'priceJpy': 340000.0,
          'priceUsd': 2200.0,
          'seller': 'YFE',
          'amcStartMonth': '2023-02-01',
          'amcExpireMonth': '2024-01-31',
        },
        {
          'name': 'Wax Injector W50',
          'serialNo': 'WI-50-003',
          'customerName': 'Dubai Gold',
          'purchaseDate': '2022-08-05',
          'priceInr': 150000.0,
          'priceJpy': 285000.0,
          'priceUsd': 1850.0,
          'seller': 'YFE',
          'amcStartMonth': null,
          'amcExpireMonth': null,
        },
        {
          'name': 'Laser Welder LW-20',
          'serialNo': 'LW-20-004',
          'customerName': 'New York Diamonds',
          'purchaseDate': '2023-05-20',
          'priceInr': 320000.0,
          'priceJpy': 605000.0,
          'priceUsd': 3900.0,
          'seller': 'YFE',
          'amcStartMonth': '2023-06-01',
          'amcExpireMonth': '2024-05-31',
        },
        {
          'name': 'Casting Machine X1',
          'serialNo': 'CM-X1-005',
          'customerName': 'YFE India', // Stock machine
          'purchaseDate': '2021-11-12',
          'priceInr': 275000.0,
          'priceJpy': 520000.0,
          'priceUsd': 3350.0,
          'seller': 'Factory',
          'amcStartMonth': null,
          'amcExpireMonth': null,
        },
      ];
      
      for (var machineData in machines) {
        // Find matching customer
        final customer = customers.firstWhere(
          (c) => c.name == machineData['customerName'],
          orElse: () => customers.first, // Default to first customer if not found
        );
        
        final machine = Machine(
          name: machineData['name'] as String,
          customerId: customer.id,
          serialNo: machineData['serialNo'] as String,
          purchaseDate: machineData['purchaseDate'] != null 
              ? DateTime.parse(machineData['purchaseDate'] as String)
              : null,
          priceInr: machineData['priceInr'] as double,
          priceJpy: machineData['priceJpy'] as double,
          priceUsd: machineData['priceUsd'] as double,
          seller: machineData['seller'] as String,
          amcStartMonth: machineData['amcStartMonth'] != null 
              ? DateTime.parse(machineData['amcStartMonth'] as String)
              : null,
          amcExpireMonth: machineData['amcExpireMonth'] != null 
              ? DateTime.parse(machineData['amcExpireMonth'] as String)
              : null,
          totalVisits: machineData['amcStartMonth'] != null ? 4 : 0, 
          pendingVisits: machineData['amcStartMonth'] != null ? 1 : 0,
          customerName: customer.name,
        );
        
        await _databaseService.insertMachine(machine);
      }
      
      print('Machines seeded successfully');
    } catch (e) {
      print('Error seeding machines: $e');
    }
  }
  
  // Seed spare parts data
  Future<void> seedSpareParts() async {
    try {
      // Get customer IDs for reference
      final customers = await _databaseService.getCustomers();
      if (customers.isEmpty) {
        print('No customers found, seeding spare parts skipped');
        return;
      }
      
      // Sample spare parts with customer assignments
      final spareParts = [
        {
          'name': 'Heating Element HE-100',
          'customerName': 'Tokyo Jewelry Co.',
          'quantity': 2,
          'purchaseDate': '2022-04-10',
          'priceInr': 5000.0,
          'priceJpy': 9000.0,
          'priceUsd': 60.0,
          'invoice': 'INV-HE-001',
          'seller': 'YFE',
        },
        {
          'name': 'Vacuum Pump VP-200',
          'customerName': 'Mumbai Jewels',
          'quantity': 1,
          'purchaseDate': '2023-02-15',
          'priceInr': 8500.0,
          'priceJpy': 15000.0,
          'priceUsd': 100.0,
          'invoice': 'INV-VP-002',
          'seller': 'YFE',
        },
        {
          'name': 'Control Board CB-X1',
          'customerName': 'Dubai Gold',
          'quantity': 1,
          'purchaseDate': '2022-09-25',
          'priceInr': 18000.0,
          'priceJpy': 34000.0,
          'priceUsd': 220.0,
          'invoice': 'INV-CB-003',
          'seller': 'YFE',
        },
        {
          'name': 'Laser Lens LL-25',
          'customerName': 'New York Diamonds',
          'quantity': 2,
          'purchaseDate': '2023-06-05',
          'priceInr': 15000.0,
          'priceJpy': 28000.0,
          'priceUsd': 180.0,
          'invoice': 'INV-LL-004',
          'seller': 'YFE',
        },
        {
          'name': 'Wax Nozzle WN-10',
          'customerName': 'YFE India', // Stock spare part
          'quantity': 10,
          'purchaseDate': '2023-01-20',
          'priceInr': 8500.0,
          'priceJpy': 15000.0,
          'priceUsd': 100.0,
          'invoice': 'INV-WN-005',
          'seller': 'Factory',
        },
      ];
      
      for (var partData in spareParts) {
        // Find matching customer
        final customer = customers.firstWhere(
          (c) => c.name == partData['customerName'],
          orElse: () => customers.first,
        );
        
        final sparePart = SparePart(
          name: partData['name'] as String,
          customerId: customer.id,
          quantity: partData['quantity'] as int,
          purchaseDate: partData['purchaseDate'] != null
              ? DateTime.parse(partData['purchaseDate'] as String)
              : null,
          priceInr: partData['priceInr'] as double,
          priceJpy: partData['priceJpy'] as double,
          priceUsd: partData['priceUsd'] as double,
          invoice: partData['invoice'] as String,
          seller: partData['seller'] as String,
          customerName: customer.name,
        );
        
        await _databaseService.insertSparePart(sparePart);
      }
      
      print('Spare parts seeded successfully');
    } catch (e) {
      print('Error seeding spare parts: $e');
    }
  }
  
  // Seed import data
  Future<void> seedImports() async {
    try {
      // Get customer IDs for reference
      final customers = await _databaseService.getCustomers();
      if (customers.isEmpty) {
        print('No customers found, seeding imports skipped');
        return;
      }
      
      // Get stock master for reference
      final stockMasters = await _databaseService.getStockMasters();
      if (stockMasters.isEmpty) {
        print('No stock masters found, seeding imports skipped');
        return;
      }
      
      // Sample imports data
      final imports = [
        {
          'partCodePrefix': 'CM-X1',
          'customerName': 'YFE India',
          'quantity': 2,
          'importDate': '2023-05-20',
          'priceInr': 275000.0,
          'priceJpy': 520000.0,
          'priceUsd': 3350.0,
          'serialNo': 'CM-X1-IMP-001',
          'invoice': 'YNC-2023-001',
          'status': 'delivered',
          'type': 'machine',
        },
        {
          'partCodePrefix': 'PP-200',
          'customerName': 'Tokyo Jewelry Co.',
          'quantity': 1,
          'importDate': '2023-06-15',
          'priceInr': 180000.0,
          'priceJpy': 340000.0,
          'priceUsd': 2200.0,
          'serialNo': 'PP-200-IMP-002',
          'invoice': 'YNC-2023-002',
          'status': 'pending',
          'type': 'machine',
        },
        {
          'partCodePrefix': 'HE-100',
          'customerName': 'YFE India',
          'quantity': 10,
          'importDate': '2023-07-05',
          'priceInr': 50000.0,
          'priceJpy': 90000.0,
          'priceUsd': 600.0,
          'serialNo': null,
          'invoice': 'YNC-2023-003',
          'status': 'delivered',
          'type': 'part',
        },
        {
          'partCodePrefix': 'VP-200',
          'customerName': 'Mumbai Jewels',
          'quantity': 1,
          'importDate': '2023-07-20',
          'priceInr': 8500.0,
          'priceJpy': 15000.0,
          'priceUsd': 100.0,
          'serialNo': null,
          'invoice': 'YNC-2023-004',
          'status': 'pending',
          'type': 'part',
        },
        {
          'partCodePrefix': 'LW-20',
          'customerName': 'Dubai Gold',
          'quantity': 1,
          'importDate': '2023-08-10',
          'priceInr': 320000.0,
          'priceJpy': 605000.0,
          'priceUsd': 3900.0,
          'serialNo': 'LW-20-IMP-003',
          'invoice': 'YNC-2023-005',
          'status': 'pending',
          'type': 'machine',
        },
      ];
      
      for (var importData in imports) {
        // Find matching customer
        final customer = customers.firstWhere(
          (c) => c.name == importData['customerName'],
          orElse: () => customers.first,
        );
        
        // Find matching stock master item
        final stockItem = stockMasters.firstWhere(
          (s) => s.partCode == importData['partCodePrefix'] && s.type == importData['type'],
          orElse: () => stockMasters.first,
        );
        
        final importItem = Import(
          partCode: stockItem.partCode,
          name: stockItem.name,
          type: importData['type'] as String,
          customerId: customer.id,
          quantity: importData['quantity'] as int,
          importDate: importData['importDate'] != null
              ? DateTime.parse(importData['importDate'] as String)
              : null,
          priceInr: importData['priceInr'] as double,
          priceJpy: importData['priceJpy'] as double,
          priceUsd: importData['priceUsd'] as double,
          serialNo: importData['serialNo'] as String?,
          invoice: importData['invoice'] as String,
          status: importData['status'] as String,
          customerName: customer.name,
        );
        
        await _databaseService.insertImport(importItem);
      }
      
      print('Imports seeded successfully');
    } catch (e) {
      print('Error seeding imports: $e');
    }
  }
  
  // Seed AMC schedule data
  Future<void> seedAMCSchedules() async {
    try {
      // Get machines for reference
      final machines = await _databaseService.getMachines();
      if (machines.isEmpty) {
        print('No machines found, seeding AMC schedules skipped');
        return;
      }
      
      // Only create AMC schedules for machines with AMC start/end dates
      final machinesWithAMC = machines.where((m) => m.amcStartMonth != null && m.amcExpireMonth != null).toList();
      
      for (var machine in machinesWithAMC) {
        // Create 4 quarterly AMC visits for each machine with AMC
        for (var i = 0; i < 4; i++) {
          final dueDate = DateTime(
            machine.amcStartMonth!.year,
            machine.amcStartMonth!.month + (i * 3),
            machine.amcStartMonth!.day,
          );
          
          // Only add if the due date is before AMC expiry
          if (dueDate.isBefore(machine.amcExpireMonth!)) {
            final now = DateTime.now();
            
            // Determine status based on due date
            final status = dueDate.isBefore(now) ? 'completed' : 'pending';
            
            final amcSchedule = AMCSchedule(
              machineId: machine.id!,
              dueDate: dueDate,
              maintenanceType: 'Quarterly Maintenance',
              status: status,
              issue: status == 'completed' ? 'Regular maintenance' : null,
              fix: status == 'completed' ? 'Performed standard maintenance procedures' : null,
              cost: status == 'completed' ? 5000.0 : null,
              machineName: machine.name,
              customerName: machine.customerName,
            );
            
            await _databaseService.insertAMCSchedule(amcSchedule);
          }
        }
      }
      
      print('AMC schedules seeded successfully');
    } catch (e) {
      print('Error seeding AMC schedules: $e');
    }
  }
}