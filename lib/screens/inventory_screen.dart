import 'package:flutter/material.dart';
import '../widgets/data_table_widget.dart';
import '../services/database_service.dart';
import '../models/inventory_item.dart';
import 'package:intl/intl.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  
  // Selected filter
  String _selectedFilter = 'All Items';
  final List<String> _filterOptions = [
    'All Items',
    'Low Stock',
    'Recently Updated',
    'Machines Only',
    'Spare Parts Only'
  ];
  
  // Inventory data
  List<InventoryItem> _allInventoryItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  
  @override
  void initState() {
    super.initState();
    _loadInventoryData();
  }
  
  Future<void> _loadInventoryData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load inventory items
      _allInventoryItems = await _databaseService.getInventoryItems();
      
      // Apply default filter (All Items)
      _applyFilter(_selectedFilter);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading inventory data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _applyFilter(String filter) {
    // Convert inventory items to the format expected by the DataTableWidget
    List<Map<String, dynamic>> items = _allInventoryItems.map((item) {
      final formattedDate = DateFormat('dd MMM yyyy').format(item.lastUpdated);
      
      final formattedPrice = NumberFormat.currency(
        symbol: '₹',
        decimalDigits: 0
      ).format(item.unitPrice);
      
      return {
        'id': item.id,
        'Name': item.name,
        'Type': item.type,
        'Quantity': item.quantity.toString(),
        'Unit Price': formattedPrice,
        'Last Updated': formattedDate,
        'Notes': item.notes,
        'Threshold': item.threshold?.toString() ?? 'N/A', // Add threshold
      };
    }).toList();
    
    setState(() {
      _selectedFilter = filter;
      
      switch (filter) {
        case 'All Items':
          _filteredItems = items;
          break;
        case 'Low Stock':
          _filteredItems = items.where((item) {
            final itemName = item['Name'].toString();
            final quantity = int.parse(item['Quantity'].toString());
            final threshold = int.tryParse(item['Threshold'].toString()) ?? 5; // Default threshold
            return quantity < threshold;
          }).toList();
          break;
        case 'Recently Updated':
          _filteredItems = [...items];
          _filteredItems.sort((a, b) {
            final aDate = a['Last Updated'].toString();
            final bDate = b['Last Updated'].toString();
            return bDate.compareTo(aDate); // Sort descending
          });
          _filteredItems = _filteredItems.take(5).toList(); // Take top 5
          break;
        case 'Machines Only':
          _filteredItems = items
              .where((item) => item['Type'] == 'Machine')
              .toList();
          break;
        case 'Spare Parts Only':
          _filteredItems = items
              .where((item) => item['Type'] == 'Spare Part')
              .toList();
          break;
      }
    });
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
                    if (value.isEmpty) {
                      _applyFilter(_selectedFilter);
                      return;
                    }
                    
                    final lowerCaseQuery = value.toLowerCase();
                    setState(() {
                      _filteredItems = _filteredItems.where((item) {
                        final name = item['Name'].toString().toLowerCase();
                        final type = item['Type'].toString().toLowerCase();
                        return name.contains(lowerCaseQuery) || 
                               type.contains(lowerCaseQuery);
                      }).toList();
                    });
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
                            _loadInventoryData();
                          },
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Table
                    Expanded(
                      child: _filteredItems.isEmpty
                        ? const Center(child: Text('No items found'))
                        : DataTableWidget(
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
                            // Find the inventory item from the original data
                            final id = row['id'];
                            final inventoryItem = _allInventoryItems.firstWhere(
                              (item) => item.id == id, 
                              orElse: () => InventoryItem(
                                id: 0, 
                                name: '', 
                                type: '',
                                quantity: 0, 
                                unitPrice: 0, 
                                lastUpdated: DateTime.now(), 
                                notes: ''
                              )
                            );
                            _showEditItemDialog(inventoryItem);
                          },
                          onDelete: (row) {
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
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController unitPriceController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    final TextEditingController thresholdController = TextEditingController(text: '5');
    String type = 'Spare Part';
    
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
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Type dropdown
                  StatefulBuilder(
                    builder: (context, setState) {
                      return DropdownButtonFormField<String>(
                        value: type,
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
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              type = value;
                            });
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Quantity field
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Price field
                  TextFormField(
                    controller: unitPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Unit Price (₹)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Notes/Specs field
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes/Specifications',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Threshold field
                  TextFormField(
                    controller: thresholdController,
                    decoration: const InputDecoration(
                      labelText: 'Threshold',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
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
              onPressed: () async {
                // Add item logic
                final newItem = InventoryItem(
                  id: 0,
                  name: nameController.text,
                  type: type,
                  quantity: int.tryParse(quantityController.text) ?? 0,
                  unitPrice: double.tryParse(unitPriceController.text) ?? 0,
                  lastUpdated: DateTime.now(),
                  notes: notesController.text,
                  threshold: int.tryParse(thresholdController.text) ?? 5, // Add threshold
                );
                
                await _databaseService.insertInventoryItem(newItem);
                
                _loadInventoryData(); // Reload data
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
  void _showEditItemDialog(InventoryItem item) {
    final TextEditingController nameController = TextEditingController(text: item.name);
    final TextEditingController quantityController = TextEditingController(text: item.quantity.toString());
    final TextEditingController unitPriceController = TextEditingController(text: item.unitPrice.toString());
    final TextEditingController notesController = TextEditingController(text: item.notes);
    final TextEditingController thresholdController = TextEditingController(text: item.threshold?.toString() ?? '5');
    String type = item.type;
    
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
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Type dropdown
                  StatefulBuilder(
                    builder: (context, setState) {
                      return DropdownButtonFormField<String>(
                        value: type,
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
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              type = value;
                            });
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Quantity field
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Price field
                  TextFormField(
                    controller: unitPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Unit Price (₹)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Notes/Specs field
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes/Specifications',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Threshold field
                  TextFormField(
                    controller: thresholdController,
                    decoration: const InputDecoration(
                      labelText: 'Threshold',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
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
              onPressed: () async {
                // Update item logic
                final updatedItem = InventoryItem(
                  id: item.id,
                  name: nameController.text,
                  type: type,
                  quantity: int.tryParse(quantityController.text) ?? 0,
                  unitPrice: double.tryParse(unitPriceController.text) ?? 0,
                  lastUpdated: DateTime.now(),
                  notes: notesController.text,
                  threshold: int.tryParse(thresholdController.text) ?? 5, // Update threshold
                );
                
                await _databaseService.updateInventoryItem(updatedItem);
                _loadInventoryData(); // Reload data
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
              onPressed: () async {
                // Delete item logic
                await _databaseService.deleteInventoryItem(item['id']);
                _loadInventoryData(); // Reload data
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
    final lowStockItems = _filteredItems
        .where((item) {
          final itemName = item['Name'].toString();
          final quantity = int.parse(item['Quantity'].toString());
          final threshold = int.tryParse(item['Threshold'].toString()) ?? 5; // Default threshold
          return quantity < threshold;
        })
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
                      final threshold = int.tryParse(item['Threshold'].toString()) ?? 5;
                      
                      return ListTile(
                        title: Text(item['Name'].toString()),
                        subtitle: Text(
                          'Type: ${item['Type']} | Current Quantity: ${item['Quantity']} | Threshold: $threshold',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Find the inventory item and show edit dialog
                            final id = item['id'];
                            final inventoryItem = _allInventoryItems.firstWhere(
                              (i) => i.id == id,
                              orElse: () => InventoryItem(
                                id: 0, 
                                name: '', 
                                type: '',
                                quantity: 0, 
                                unitPrice: 0, 
                                lastUpdated: DateTime.now(),
                                notes: ''
                              )
                            );
                            _showEditItemDialog(inventoryItem);
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
          ],
        );
      },
    );
  }
}