import 'package:flutter/material.dart';
import '../widgets/data_table_widget.dart';
import '../services/database_service.dart';
import '../models/import.dart';
import '../models/customer.dart';
import 'package:intl/intl.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();
  
  bool _isLoading = true;
  List<Import> _pendingImports = [];
  List<Import> _completedImports = [];
  List<Customer> _customers = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final allImports = await _databaseService.getImports();
      _pendingImports = allImports.where((order) => 
        order.status == 'pending').toList();
      _completedImports = allImports.where((order) => 
        order.status == 'delivered').toList();
      
      _customers = await _databaseService.getCustomers();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shop Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showNewImportDialog(),
                icon: const Icon(Icons.add),
                label: const Text('New Import Order'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF1A237E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Tabs for different shop sections
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Import Requests'),
              Tab(text: 'Import History'),
              Tab(text: 'Request Process'),
            ],
            labelColor: const Color(0xFF1A237E),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF1A237E),
          ),
          
          const SizedBox(height: 16),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Import Requests Tab
                _buildImportRequestsTab(),
                
                // Import History Tab
                _buildImportHistoryTab(),
                
                // Request Process Tab
                _buildRequestProcessTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Import Requests Tab
  Widget _buildImportRequestsTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Import Requests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filter'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                      label: const Text('Search'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Import Requests Table
            Expanded(
              child: _pendingImports.isEmpty
                ? const Center(child: Text('No pending import requests'))
                : DataTableWidget(
                  columns: const [
                    'ID',
                    'Date',
                    'Item Name',
                    'Quantity',
                    'Status',
                    'Actions',
                  ],
                  rows: _pendingImports.map((request) {
                    final formattedDate = request.importDate != null 
                        ? DateFormat('dd-MMM-yyyy').format(request.importDate!)
                        : 'N/A';
                    return {
                      'ID': request.id.toString(),
                      'Date': formattedDate,
                      'Item Name': request.name,
                      'Quantity': request.quantity.toString(),
                      'Status': request.status,
                      'Actions': request, // Pass the whole request for actions
                    };
                  }).toList(),
                  onEdit: (row) => _showEditRequestDialog(row['Actions'] as Import),
                  onDelete: null,
                ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Import History Tab
  Widget _buildImportHistoryTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Import History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filter'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download),
                      label: const Text('Export'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Import History Table
            Expanded(
              child: _completedImports.isEmpty
                ? const Center(child: Text('No import history available'))
                : DataTableWidget(
                  columns: const [
                    'ID',
                    'Date',
                    'Item Name',
                    'Customer',
                    'Invoice',
                    'Price (₹)',
                    'Status',
                  ],
                  rows: _completedImports.map((item) {
                    final formattedDate = item.importDate != null
                        ? DateFormat('dd-MMM-yyyy').format(item.importDate!)
                        : 'N/A';
                    return {
                      'ID': item.id.toString(),
                      'Date': formattedDate,
                      'Item Name': item.name,
                      'Customer': item.customerName ?? 'N/A',
                      'Invoice': item.invoice ?? 'N/A',
                      'Price (₹)': NumberFormat.currency(symbol: '₹', decimalDigits: 0)
                          .format(item.priceInr ?? 0),
                      'Status': item.status,
                    };
                  }).toList(),
                  onEdit: null,
                  onDelete: null,
                ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Request Process Tab
  Widget _buildRequestProcessTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request Process Workflow',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Request Process Steps
            Expanded(
              child: Row(
                children: [
                  _buildProcessStep(
                    icon: Icons.assignment,
                    title: '1. Create Request',
                    description: 'Create a new import request with item details, quantity, and customer information.',
                    color: Colors.blue,
                  ),
                  _buildArrow(),
                  _buildProcessStep(
                    icon: Icons.inventory_2,
                    title: '2. Process Order',
                    description: 'YNC processes the order and provides invoice details and expected shipping dates.',
                    color: Colors.orange,
                  ),
                  _buildArrow(),
                  _buildProcessStep(
                    icon: Icons.local_shipping,
                    title: '3. Shipping',
                    description: 'Order is shipped and tracking information is updated in the system.',
                    color: Colors.purple,
                  ),
                  _buildArrow(),
                  _buildProcessStep(
                    icon: Icons.check_circle,
                    title: '4. Delivery',
                    description: 'Order is received and marked as delivered. Inventory is automatically updated.',
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Recent Workflow Updates
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Workflow Updates',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Timeline entries
                  _buildTimelineEntry(
                    time: '10:30 AM, Today',
                    event: 'Casting Machine X2 marked as Delivered',
                    user: 'Ramesh Kumar',
                  ),
                  _buildTimelineEntry(
                    time: '09:15 AM, Today',
                    event: 'New import request created for Wax Injector Parts',
                    user: 'Suresh Singh',
                  ),
                  _buildTimelineEntry(
                    time: '04:45 PM, Yesterday',
                    event: 'Updated shipping status for Polisher Parts',
                    user: 'Aarti Sharma',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to build process steps
  Widget _buildProcessStep({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to build arrows between process steps
  Widget _buildArrow() {
    return const SizedBox(
      width: 40,
      child: Icon(
        Icons.arrow_forward,
        color: Colors.grey,
      ),
    );
  }
  
  // Helper method to build timeline entries
  Widget _buildTimelineEntry({
    required String time,
    required String event,
    required String user,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 5, right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· $user',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event,
                  style: const TextStyle(fontSize: 14),
                ),
                const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Dialog to create a new import order
  void _showNewImportDialog() {
    final DateTime now = DateTime.now();
    final TextEditingController dateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(now));
    String? selectedCustomerName;
    String itemName = '';
    String partCode = '';
    String type = 'machine';
    String serialNo = '';
    String invoice = '';
    int quantity = 1;
    double priceInr = 0;
    double priceJpy = 0;
    double priceUsd = 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Import Order'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Part Code',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => partCode = value,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Serial No.',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => serialNo = value,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => itemName = value,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  value: type,
                  items: const [
                    DropdownMenuItem(
                      value: 'machine',
                      child: Text('Machine'),
                    ),
                    DropdownMenuItem(
                      value: 'part',
                      child: Text('Part'),
                    ),
                  ],
                  onChanged: (value) => type = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Customer Name',
                    border: OutlineInputBorder(),
                  ),
                  items: _customers.map((customer) {
                    return DropdownMenuItem<String>(
                      value: customer.name,
                      child: Text(customer.name),
                    );
                  }).toList(),
                  onChanged: (value) => selectedCustomerName = value,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Invoice',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => invoice = value,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Import Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: '1',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => quantity = int.tryParse(value) ?? 1,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'JPY (¥)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_yen),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => priceJpy = double.tryParse(value) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'INR (₹)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => priceInr = double.tryParse(value) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'USD (\$)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => priceUsd = double.tryParse(value) ?? 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Find customer ID
              int? customerId;
              if (selectedCustomerName != null) {
                final customer = _customers.firstWhere(
                  (c) => c.name == selectedCustomerName,
                  orElse: () => Customer(name: selectedCustomerName!),
                );
                
                customerId = customer.id;
              }
              
              // Create new import order
              final newImport = Import(
                partCode: partCode,
                name: itemName,
                type: type,
                customerId: customerId,
                quantity: quantity,
                importDate: DateTime.tryParse(dateController.text) ?? now,
                priceInr: priceInr,
                priceJpy: priceJpy,
                priceUsd: priceUsd,
                serialNo: serialNo.isNotEmpty ? serialNo : null,
                invoice: invoice.isNotEmpty ? invoice : null,
                status: 'pending',
                customerName: selectedCustomerName,
              );
              
              await _databaseService.insertImport(newImport);
              _loadData(); // Reload data
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF1A237E),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  // Dialog to edit an existing request
  void _showEditRequestDialog(Import order) {
    final TextEditingController itemNameController = TextEditingController(text: order.name);
    final TextEditingController partCodeController = TextEditingController(text: order.partCode);
    final TextEditingController quantityController = TextEditingController(text: order.quantity.toString());
    final TextEditingController serialNoController = TextEditingController(text: order.serialNo ?? '');
    final TextEditingController invoiceController = TextEditingController(text: order.invoice ?? '');
    String status = order.status.toLowerCase();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Import Request'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: partCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Part Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: itemNameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: serialNoController,
                  decoration: const InputDecoration(
                    labelText: 'Serial Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: invoiceController,
                  decoration: const InputDecoration(
                    labelText: 'Invoice',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  value: status,
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'pending',
                      child: Text('Pending'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'delivered',
                      child: Text('Delivered'),
                    ),
                  ],
                  onChanged: (value) => status = value!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Update the order
              final updatedOrder = order.copyWith(
                name: itemNameController.text,
                partCode: partCodeController.text,
                quantity: int.tryParse(quantityController.text) ?? order.quantity,
                serialNo: serialNoController.text.isNotEmpty ? serialNoController.text : null,
                invoice: invoiceController.text.isNotEmpty ? invoiceController.text : null,
                status: status,
              );
              
              await _databaseService.updateImport(updatedOrder);
              _loadData(); // Reload data
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF1A237E),
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
  
  // Dialog to update the status of a request
  void _showUpdateStatusDialog(Import order) {
    String currentStatus = order.status;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Item: ${order.name}'),
              const SizedBox(height: 16),
              const Text('Current Status:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: {
                    'pending': Colors.orange,
                    'processing': Colors.amber,
                    'shipped': Colors.blue,
                    'delivered': Colors.green,
                  }[currentStatus.toLowerCase()]?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  currentStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: {
                      'pending': Colors.orange,
                      'processing': Colors.amber,
                      'shipped': Colors.blue,
                      'delivered': Colors.green,
                    }[currentStatus.toLowerCase()] ?? Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Update to:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                value: currentStatus.toLowerCase(),
                items: ['pending', 'processing', 'shipped', 'delivered'].map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status.substring(0, 1).toUpperCase() + status.substring(1)),
                  );
                }).toList(),
                onChanged: (value) => currentStatus = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Comments (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Update the order status
              final updatedOrder = order.copyWith(status: currentStatus);
              await _databaseService.updateImport(updatedOrder);
              _loadData(); // Reload data
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF1A237E),
            ),
            child: const Text('Update Status'),
          ),
        ],
      ),
    );
  }
}