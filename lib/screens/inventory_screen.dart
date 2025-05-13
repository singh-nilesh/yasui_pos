import 'package:flutter/material.dart';
import '../widgets/data_table_widget.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // Selected filter
  String _selectedFilter = 'All Items';
  List<String> _filterOptions = [
    'All Items',
    'Low Stock',
    'Recently Updated',
    'Machines Only',
    'Spare Parts Only'
  ];
  
  // Filtered data
  List<Map<String, dynamic>> _filteredItems = [];
  
  @override
  void initState() {
    super.initState();
    // Initialize with all items
    _filteredItems = [..._dummyInventory];
  }
  
  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      
      switch (filter) {
        case 'All Items':
          _filteredItems = [..._dummyInventory];
          break;
        case 'Low Stock':
          _filteredItems = _dummyInventory
              .where((item) => int.parse(item['Quantity'].toString()) < 5)
              .toList();
          break;
        case 'Recently Updated':
          // In a real app, you would filter by date
          _filteredItems = [..._dummyInventory].take(3).toList();
          break;
        case 'Machines Only':
          _filteredItems = _dummyInventory
              .where((item) => item['Type'] == 'Machine')
              .toList();
          break;
        case 'Spare Parts Only':
          _filteredItems = _dummyInventory
              .where((item) => item['Type'] == 'Spare Part')
              .toList();
          break;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header and Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Inventory Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // Low Stock Alert button
                  OutlinedButton.icon(
                    onPressed: () {
                      _showLowStockAlertDialog();
                    },
                    icon: const Icon(Icons.warning, color: Colors.orange),
                    label: const Text(
                      'Low Stock Alerts',
                      style: TextStyle(color: Colors.orange),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Add new item button
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddItemDialog();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Search and Filter Section
          Row(
            children: [
              // Search Box
              Expanded(
                flex: 3,
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or type',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (value) {
                    // Implement search functionality
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Filter Dropdown
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.filter_list),
                    items: _filterOptions
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _applyFilter(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Inventory Table
          Expanded(
            child: Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Table Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${_filteredItems.length} items',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            _applyFilter('All Items');
                          },
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Table
                    Expanded(
                      child: DataTableWidget(
                        columns: const [
                          'Name',
                          'Type',
                          'Quantity',
                          'Unit Price',
                          'Last Updated',
                          'Actions'
                        ],
                        rows: _filteredItems,
                        onEdit: (row) {
                          // Edit item logic
                          _showEditItemDialog(row);
                        },
                        onDelete: (row) {
                          // Delete item logic
                          _showDeleteConfirmDialog(row);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Dialog to add a new item
  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Item'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500, // Dialog width
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name field
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Type dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Machine',
                        child: Text('Machine'),
                      ),
                      DropdownMenuItem(
                        value: 'Spare Part',
                        child: Text('Spare Part'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  // Quantity field
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Price field
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Unit Price (₹)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Notes/Specs field
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Notes/Specifications',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
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
              onPressed: () {
                // Add item logic
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Item'),
            ),
          ],
        );
      },
    );
  }
  
  // Dialog to edit an existing item
  void _showEditItemDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500, // Dialog width
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name field
                  TextFormField(
                    initialValue: item['Name'].toString(),
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Type dropdown
                  DropdownButtonFormField<String>(
                    value: item['Type'].toString(),
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Machine',
                        child: Text('Machine'),
                      ),
                      DropdownMenuItem(
                        value: 'Spare Part',
                        child: Text('Spare Part'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  // Quantity field
                  TextFormField(
                    initialValue: item['Quantity'].toString(),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Price field
                  TextFormField(
                    initialValue: item['Unit Price'].toString().replaceAll('₹', ''),
                    decoration: const InputDecoration(
                      labelText: 'Unit Price (₹)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Notes/Specs field
                  TextFormField(
                    initialValue: item['Notes'] ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Notes/Specifications',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
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
              onPressed: () {
                // Update item logic
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
  
  // Confirmation dialog to delete an item
  void _showDeleteConfirmDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text(
            'Are you sure you want to delete "${item['Name']}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Delete item logic
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
  
  // Dialog for low stock alerts
  void _showLowStockAlertDialog() {
    final lowStockItems = _dummyInventory
        .where((item) => int.parse(item['Quantity'].toString()) < 5)
        .toList();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('Low Stock Alerts'),
            ],
          ),
          content: SizedBox(
            width: 600,
            height: 300,
            child: lowStockItems.isEmpty
                ? const Center(
                    child: Text('No low stock items found.'),
                  )
                : ListView.builder(
                    itemCount: lowStockItems.length,
                    itemBuilder: (context, index) {
                      final item = lowStockItems[index];
                      return ListTile(
                        title: Text(item['Name'].toString()),
                        subtitle: Text(
                          'Type: ${item['Type']} | Current Quantity: ${item['Quantity']}',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // Order more logic
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Order More'),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                // Configure threshold logic
                _showThresholdSettingsDialog();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Configure Thresholds'),
            ),
          ],
        );
      },
    );
  }
  
  // Dialog to configure thresholds
  void _showThresholdSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Low Stock Thresholds'),
          content: SizedBox(
            width: 500,
            height: 300,
            child: ListView.builder(
              itemCount: _dummyThresholds.length,
              itemBuilder: (context, index) {
                final threshold = _dummyThresholds[index];
                return ListTile(
                  title: Text(threshold['itemName'].toString()),
                  subtitle: Text('Current Threshold: ${threshold['threshold']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Edit threshold logic
                        },
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Delete threshold logic
                        },
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add new threshold logic
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add New Threshold'),
            ),
          ],
        );
      },
    );
  }
}

// Dummy Data for Inventory
final List<Map<String, dynamic>> _dummyInventory = [
  {
    'Name': 'Casting Machine X1',
    'Type': 'Machine',
    'Quantity': '3',
    'Unit Price': '₹180,000',
    'Last Updated': '10 May 2025',
    'Notes': 'Advanced casting machine for jewelry production'
  },
  {
    'Name': 'Polisher P200',
    'Type': 'Machine',
    'Quantity': '5',
    'Unit Price': '₹85,000',
    'Last Updated': '08 May 2025',
    'Notes': 'High-speed polishing machine'
  },
  {
    'Name': 'Wax Injector W50',
    'Type': 'Machine',
    'Quantity': '2',
    'Unit Price': '₹120,000',
    'Last Updated': '05 May 2025',
    'Notes': 'Digital wax injector for precision molds'
  },
  {
    'Name': 'Laser Welder LW-20',
    'Type': 'Machine',
    'Quantity': '1',
    'Unit Price': '₹250,000',
    'Last Updated': '01 May 2025',
    'Notes': 'High-precision laser welder for fine jewelry'
  },
  {
    'Name': 'Heating Element',
    'Type': 'Spare Part',
    'Quantity': '15',
    'Unit Price': '₹5,000',
    'Last Updated': '12 May 2025',
    'Notes': 'Compatible with Casting Machine X1'
  },
  {
    'Name': 'Control Board',
    'Type': 'Spare Part',
    'Quantity': '8',
    'Unit Price': '₹12,000',
    'Last Updated': '11 May 2025',
    'Notes': 'Digital control board for multiple machines'
  },
  {
    'Name': 'Pressure Valve',
    'Type': 'Spare Part',
    'Quantity': '20',
    'Unit Price': '₹3,500',
    'Last Updated': '09 May 2025',
    'Notes': 'Industrial-grade pressure valve'
  },
  {
    'Name': 'Motor Assembly',
    'Type': 'Spare Part',
    'Quantity': '5',
    'Unit Price': '₹18,000',
    'Last Updated': '07 May 2025',
    'Notes': 'For Polisher P200 machines'
  },
  {
    'Name': 'Wax Nozzle',
    'Type': 'Spare Part',
    'Quantity': '30',
    'Unit Price': '₹1,200',
    'Last Updated': '06 May 2025',
    'Notes': 'Precision nozzles for Wax Injector W50'
  },
  {
    'Name': 'Laser Tube',
    'Type': 'Spare Part',
    'Quantity': '3',
    'Unit Price': '₹40,000',
    'Last Updated': '03 May 2025',
    'Notes': 'Replacement tube for Laser Welder LW-20'
  },
];

// Dummy thresholds for low stock alerts
final List<Map<String, dynamic>> _dummyThresholds = [
  {'itemName': 'Casting Machine X1', 'threshold': 2},
  {'itemName': 'Polisher P200', 'threshold': 3},
  {'itemName': 'Wax Injector W50', 'threshold': 2},
  {'itemName': 'Laser Welder LW-20', 'threshold': 1},
  {'itemName': 'Heating Element', 'threshold': 5},
  {'itemName': 'Control Board', 'threshold': 3},
  {'itemName': 'Motor Assembly', 'threshold': 5},
  {'itemName': 'Laser Tube', 'threshold': 2},
];