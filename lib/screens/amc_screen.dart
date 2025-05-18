import 'package:flutter/material.dart';
import '../models/amc_schedule.dart'; // Ensure AMCSchedule is imported
import '../models/customer.dart';
import '../models/machine.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class AMCScreen extends StatefulWidget {
  const AMCScreen({super.key});

  @override
  State<AMCScreen> createState() => _AMCScreenState();
}

class _AMCScreenState extends State<AMCScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  
  // AMC data
  List<Machine> _machines = [];
  List<Customer> _customers = [];
  String _searchQuery = '';
  String _selectedFilter = 'All';
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load all machines
      final allMachines = await _databaseService.getMachines();
      // Only keep machines with AMC (amcExpireMonth is not null)
      _machines = allMachines.where((m) => m.amcExpireMonth != null).toList();
      // Load customers for reference
      _customers = await _databaseService.getCustomers();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading AMC data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Filter machines based on search and status filter
  List<Machine> get _filteredMachines {
    List<Machine> result = _machines;
    
    // Apply status filter
    if (_selectedFilter == 'Active') {
      result = result.where((machine) => 
        machine.amcExpireMonth != null && 
        machine.amcExpireMonth!.isAfter(DateTime.now())
      ).toList();
    } else if (_selectedFilter == 'Expired') {
      result = result.where((machine) => 
        machine.amcExpireMonth != null && 
        machine.amcExpireMonth!.isBefore(DateTime.now())
      ).toList();
    }
    
    // Apply search filter if there's a query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((machine) {
        // Get customer name
        final customer = _customers.firstWhere(
          (c) => c.id == machine.customerId,
          orElse: () => Customer(
            name: 'Unknown',
            city: '',
            country: '',
            telNo: '',
          ),
        );
        
        return machine.name.toLowerCase().contains(query) ||
               (machine.serialNo?.toLowerCase().contains(query) ?? false) ||
               customer.name.toLowerCase().contains(query) ||
               (customer.country?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    
    return result;
  }
  
  // Get customer by ID
  Customer _getCustomer(int? customerId) {
    if (customerId == null) {
      return Customer(
        name: 'Unknown',
      );
    }
    
    return _customers.firstWhere(
      (customer) => customer.id == customerId,
      orElse: () => Customer(
        name: 'Unknown',
      ),
    );
  }

  // Get completed visits count
  int _getVisitsCompleted(Machine machine) {
    return machine.totalVisits - machine.pendingVisits;
  }

  // Get total visits count
  int _getTotalVisits(Machine machine) {
    return machine.totalVisits;
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and refresh button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Annual Maintenance Contracts',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Filters and search
          Row(
            children: [
              // Status filter
              Expanded(
                flex: 1,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'All',
                      label: Text('All'),
                    ),
                    ButtonSegment<String>(
                      value: 'Active',
                      label: Text('Active'),
                    ),
                    ButtonSegment<String>(
                      value: 'Expired',
                      label: Text('Expired'),
                    ),
                  ],
                  selected: {_selectedFilter},
                  onSelectionChanged: (Set<String> selection) {
                    setState(() {
                      _selectedFilter = selection.first;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Search
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Search by machine name, serial number, or customer',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // AMC data
          Expanded(
            child: _filteredMachines.isEmpty 
              ? _buildEmptyView()
              : _buildAmcTable(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_late,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
              ? 'No AMCs match your filters'
              : 'No AMCs found in the system',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          if (_searchQuery.isNotEmpty || _selectedFilter != 'All') ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedFilter = 'All';
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildAmcTable() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AMCs (${_filteredMachines.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Filter: $_selectedFilter',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Machine')),
                      DataColumn(label: Text('Serial Number')),
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Location')),
                      DataColumn(label: Text('AMC Status')),
                      DataColumn(label: Text('Expiry Date')),
                      DataColumn(label: Text('Visits')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: _filteredMachines.map((machine) {
                      final customer = _getCustomer(machine.customerId);
                      
                      // Determine AMC status
                      final bool isAmcActive = machine.amcExpireMonth != null && 
                          machine.amcExpireMonth!.isAfter(DateTime.now());
                      
                      // Format expiry date
                      final String expiryDate = machine.amcExpireMonth != null
                          ? DateFormat('dd MMM yyyy').format(machine.amcExpireMonth!)
                          : 'N/A';
                          
                      // Calculate days remaining or days expired
                      final int daysRemaining = machine.amcExpireMonth != null
                          ? machine.amcExpireMonth!.difference(DateTime.now()).inDays
                          : 0;
                          
                      // Format visits
                      final visitsCompleted = _getVisitsCompleted(machine);
                      final totalVisits = _getTotalVisits(machine);
                      final String visits = '$visitsCompleted/$totalVisits';
                      
                      return DataRow(
                        cells: [
                          DataCell(Text(machine.name)),
                          DataCell(Text(machine.serialNo ?? 'N/A')),
                          DataCell(Text(customer.name)),
                          DataCell(Text(customer.country ?? 'N/A')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isAmcActive
                                    ? Colors.green[100]
                                    : Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isAmcActive ? 'Active' : 'Expired',
                                style: TextStyle(
                                  color: isAmcActive
                                      ? Colors.green[800]
                                      : Colors.red[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(expiryDate),
                                Text(
                                  isAmcActive
                                      ? '$daysRemaining days remaining'
                                      : '${-daysRemaining} days expired',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isAmcActive
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                if (totalVisits > 0) ...[
                                  SizedBox(
                                    width: 50,
                                    child: LinearProgressIndicator(
                                      value: totalVisits > 0
                                          ? visitsCompleted / totalVisits
                                          : 0,
                                      backgroundColor: Colors.grey[200],
                                      color: const Color(0xFF1A237E),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(visits),
                              ],
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                if (isAmcActive)
                                  IconButton(
                                    icon: const Icon(Icons.add_task, color: Colors.blue),
                                    onPressed: () {
                                      _showAddVisitDialog(machine);
                                    },
                                    tooltip: 'Add Visit',
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.preview, color: Colors.green),
                                  onPressed: () {
                                    _showAmcDetailsDialog(machine, customer);
                                  },
                                  tooltip: 'View Details',
                                ),
                                if (!isAmcActive)
                                  IconButton(
                                    icon: const Icon(Icons.refresh, color: Colors.orange),
                                    onPressed: () {
                                      _showRenewAmcDialog(machine);
                                    },
                                    tooltip: 'Renew AMC',
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAddVisitDialog(Machine machine) {
    final TextEditingController dateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final TextEditingController issueController = TextEditingController();
    final TextEditingController fixController = TextEditingController();
    final TextEditingController costController = TextEditingController();
    final String maintenanceType = 'Regular Maintenance';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Service Visit for ${machine.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Visit information
                TextFormField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Visit Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 7)),
                        );
                        if (picked != null) {
                          dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Issue 
                TextFormField(
                  controller: issueController,
                  decoration: const InputDecoration(
                    labelText: 'Issue Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Fix
                TextFormField(
                  controller: fixController,
                  decoration: const InputDecoration(
                    labelText: 'Fix Applied',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Cost
                TextFormField(
                  controller: costController,
                  decoration: const InputDecoration(
                    labelText: 'Cost (if any)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                
                // Current status
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.blue[800],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Completed Visits: ${machine.totalVisits - machine.pendingVisits}/${machine.totalVisits}',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Create AMC schedule
                final visitDate = DateTime.tryParse(dateController.text) ?? DateTime.now();
                final cost = double.tryParse(costController.text) ?? 0.0;
                
                // Create AMC schedule entry
                final amcSchedule = AMCSchedule(
                  machineId: machine.id!,
                  dueDate: visitDate,
                  maintenanceType: maintenanceType,
                  status: 'completed',
                  issue: issueController.text,
                  fix: fixController.text,
                  cost: cost,
                  machineName: machine.name,
                  customerName: machine.customerName,
                );
                
                // Update machine visit counter
                final updatedMachine = machine.copyWith(
                  totalVisits: machine.totalVisits,
                  pendingVisits: machine.pendingVisits > 0 ? machine.pendingVisits - 1 : 0,
                );
                
                // Save to database
                await _databaseService.insertAMCSchedule(amcSchedule);
                await _databaseService.updateMachine(updatedMachine);
                
                _loadData(); // Refresh data
                Navigator.pop(context);
                
                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Service visit added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Visit'),
            ),
          ],
        );
      },
    );
  }
  
  void _showAmcDetailsDialog(Machine machine, Customer customer) async {
    // Load all AMC schedules for this machine
    final List<AMCSchedule> schedules = await _databaseService.getAMCSchedulesByMachine(machine.id!);
    
    // Determine AMC status
    final bool isAmcActive = machine.amcExpireMonth != null && 
        machine.amcExpireMonth!.isAfter(DateTime.now());
    
    // Calculate days remaining or days expired
    final int daysRemaining = machine.amcExpireMonth != null
        ? machine.amcExpireMonth!.difference(DateTime.now()).inDays
        : 0;
        
    final String daysText = isAmcActive
        ? '$daysRemaining days remaining'
        : '${-daysRemaining} days expired';
        
    // Get completed and pending visits count
    final completedVisits = schedules.where((s) => s.status == 'completed').length;
    final totalVisits = machine.totalVisits;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with machine and customer info
                Row(
                  children: [
                    // Machine icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A237E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Machine and customer details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            machine.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'S/N: ${machine.serialNo ?? "N/A"}',
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Customer: ${customer.name}',
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'Location: ${customer.country ?? "N/A"}',
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                
                // AMC Status card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isAmcActive ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isAmcActive ? Icons.check_circle : Icons.error,
                        color: isAmcActive ? Colors.green : Colors.red,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAmcActive ? 'Active' : 'Expired',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isAmcActive ? Colors.green : Colors.red,
                              ),
                            ),
                            if (machine.amcExpireMonth != null)
                              Text(
                                'Expires on ${DateFormat('dd MMM yyyy').format(machine.amcExpireMonth!)}',
                              ),
                            Text(daysText),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Visit Progress
                Text(
                  'Service Visits: $completedVisits/$totalVisits',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: totalVisits > 0 ? completedVisits / totalVisits : 0,
                  backgroundColor: Colors.grey[200],
                  color: const Color(0xFF1A237E),
                ),
                const SizedBox(height: 16),
                
                // Visit History
                const Text(
                  'Visit History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Visit list
                SizedBox(
                  height: 200,
                  child: schedules.isEmpty
                      ? Center(
                          child: Text(
                            'No service visits recorded',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: schedules.length,
                          itemBuilder: (context, index) {
                            final schedule = schedules[index];
                            return ListTile(
                              leading: const Icon(Icons.engineering),
                              title: Text(
                                'Visit on ${schedule.dueDate != null ? DateFormat('dd MMM yyyy').format(schedule.dueDate!) : "N/A"}',
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Status: ${schedule.status}'),
                                  if (schedule.issue != null && schedule.issue!.isNotEmpty)
                                    Text('Issue: ${schedule.issue}'),
                                  if (schedule.fix != null && schedule.fix!.isNotEmpty)
                                    Text('Fix: ${schedule.fix}'),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                
                // Action buttons
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    ),
                    if (isAmcActive)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddVisitDialog(machine);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Visit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    if (!isAmcActive)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showRenewAmcDialog(machine);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Renew AMC'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _showRenewAmcDialog(Machine machine) {
    final TextEditingController startDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final TextEditingController durationController = TextEditingController(text: '12');
    int visits = 4;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Renew AMC for ${machine.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Start date
                  TextFormField(
                    controller: startDateController,
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Duration
                  TextFormField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (months)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  
                  // Visits
                  const Text('Number of Visits:'),
                  Slider(
                    value: visits.toDouble(),
                    min: 1,
                    max: 12,
                    divisions: 11,
                    label: visits.toString(),
                    activeColor: const Color(0xFF1A237E),
                    onChanged: (value) {
                      setState(() {
                        visits = value.round();
                      });
                    },
                  ),
                  Text(
                    '$visits visit${visits > 1 ? 's' : ''} per contract',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Parse values
                    final startDate = DateTime.tryParse(startDateController.text) ?? DateTime.now();
                    final duration = int.tryParse(durationController.text) ?? 12;
                    
                    // Calculate expiry date
                    final expiryDate = DateTime(
                      startDate.year,
                      startDate.month + duration,
                      startDate.day,
                    );
                    
                    // Update the machine with AMC details
                    final updatedMachine = machine.copyWith(
                      amcStartMonth: startDate,
                      amcExpireMonth: expiryDate,
                      totalVisits: visits,
                      pendingVisits: visits,
                    );
                    
                    await _databaseService.updateMachine(updatedMachine);
                    
                    // Create AMC Schedule entries for the new visits
                    for (int i = 0; i < visits; i++) {
                      final dueDate = DateTime(
                        startDate.year,
                        startDate.month + ((i * duration) ~/ visits),
                        startDate.day,
                      );
                      
                      final amcSchedule = AMCSchedule(
                        machineId: machine.id!,
                        dueDate: dueDate,
                        maintenanceType: 'Quarterly Maintenance',
                        status: 'pending',
                        machineName: machine.name,
                        customerName: machine.customerName,
                      );
                      
                      await _databaseService.insertAMCSchedule(amcSchedule);
                    }
                    
                    _loadData(); // Reload data
                    Navigator.pop(context);
                    
                    // Show confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('AMC renewed successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Renew AMC'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}