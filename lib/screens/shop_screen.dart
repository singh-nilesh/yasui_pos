import 'package:flutter/material.dart';
import '../widgets/data_table_widget.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: DataTableWidget(
                columns: const [
                  'ID',
                  'Date',
                  'Item Name',
                  'Quantity',
                  'Status',
                  'Actions',
                ],
                rows: _importRequests.map((request) {
                  final statusColor = {
                    'Pending': Colors.orange,
                    'Processing': Colors.amber,
                    'Shipped': Colors.blue,
                    'Delivered': Colors.green,
                  }[request['status']] ?? Colors.grey;
                  
                  return {
                    'ID': request['id'],
                    'Date': request['date'],
                    'Item Name': request['itemName'],
                    'Quantity': request['quantity'],
                    'Status': request['status'],
                    'Actions': request, // Pass the whole request for actions
                  };
                }).toList(),
                onEdit: (row) => _showEditRequestDialog(row),
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
              child: DataTableWidget(
                columns: const [
                  'ID',
                  'Date',
                  'Item Name',
                  'Customer',
                  'YNC Invoice',
                  'Price (₹)',
                  'Status',
                ],
                rows: _importHistory.map((item) {
                  final statusColor = {
                    'Delivered': Colors.green,
                    'Completed': Colors.purple,
                    'Canceled': Colors.red,
                  }[item['status']] ?? Colors.grey;
                  return {
                    'ID': item['id'],
                    'Date': item['date'],
                    'Item Name': item['itemName'],
                    'Customer': item['customer'],
                    'YNC Invoice': item['invoice'],
                    'Price (₹)': '₹${item['price']}',
                    'Status': item['status'],
                  };
                }).toList(),
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
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Serial No.',
                          border: OutlineInputBorder(),
                        ),
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
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Customer Name',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Royal Jewellers',
                    'Elegant Designs',
                    'Star Jewellery',
                    'Classic Jewellers',
                    'Modern Creations',
                  ].map((customer) {
                    return DropdownMenuItem<String>(
                      value: customer,
                      child: Text(customer),
                    );
                  }).toList(),
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: '2025',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'YNC Invoice',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Invoice Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
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
            onPressed: () {
              // Save new import order logic would go here
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
  void _showEditRequestDialog(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Import Request'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                initialValue: request['itemName'],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                initialValue: request['quantity'].toString(),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                value: request['status'],
                items: ['Pending', 'Shipped', 'Delivered'].map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {},
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
            onPressed: () {
              // Save edited request logic would go here
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
  void _showUpdateStatusDialog(Map<String, dynamic> request) {
    String currentStatus = request['status'];
    
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
              Text('Item: ${request['itemName']}'),
              const SizedBox(height: 16),
              const Text('Current Status:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: {
                    'Pending': Colors.orange,
                    'Shipped': Colors.blue,
                    'Delivered': Colors.green,
                  }[currentStatus]!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  currentStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: {
                      'Pending': Colors.orange,
                      'Shipped': Colors.blue,
                      'Delivered': Colors.green,
                    }[currentStatus],
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
                value: currentStatus,
                items: ['Pending', 'Shipped', 'Delivered'].map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  currentStatus = value!;
                },
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
            onPressed: () {
              // Update status logic would go here
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

// Dummy data for import requests
final List<Map<String, dynamic>> _importRequests = [
  {
    'id': 'IR-2025-042',
    'date': '10-May-2025',
    'itemName': 'Casting Machine X2',
    'quantity': 1,
    'status': 'Shipped',
  },
  {
    'id': 'IR-2025-041',
    'date': '08-May-2025',
    'itemName': 'Polisher Parts',
    'quantity': 15,
    'status': 'Processing',
  },
  {
    'id': 'IR-2025-040',
    'date': '05-May-2025',
    'itemName': 'Laser Welder Parts',
    'quantity': 8,
    'status': 'Pending',
  },
  {
    'id': 'IR-2025-039',
    'date': '01-May-2025',
    'itemName': 'Wax Injector W60',
    'quantity': 2,
    'status': 'Delivered',
  },
  {
    'id': 'IR-2025-038',
    'date': '28-Apr-2025',
    'itemName': 'Vacuum Pump Filter',
    'quantity': 20,
    'status': 'Delivered',
  },
];

// Dummy data for import history
final List<Map<String, dynamic>> _importHistory = [
  {
    'id': 'IR-2025-039',
    'date': '01-May-2025',
    'itemName': 'Wax Injector W60',
    'customer': 'Royal Jewellers',
    'invoice': 'JP24812',
    'price': '280,000',
    'status': 'Delivered',
  },
  {
    'id': 'IR-2025-038',
    'date': '28-Apr-2025',
    'itemName': 'Vacuum Pump Filter',
    'customer': 'Elegant Designs',
    'invoice': 'JP24798',
    'price': '45,000',
    'status': 'Delivered',
  },
  {
    'id': 'IR-2025-037',
    'date': '25-Apr-2025',
    'itemName': 'Polisher P200',
    'customer': 'Star Jewellery',
    'invoice': 'JP24781',
    'price': '320,000',
    'status': 'Delivered',
  },
  {
    'id': 'IR-2025-036',
    'date': '20-Apr-2025',
    'itemName': 'Casting Flask 100mm',
    'customer': 'Modern Creations',
    'invoice': 'JP24766',
    'price': '15,000',
    'status': 'Completed',
  },
  {
    'id': 'IR-2025-035',
    'date': '18-Apr-2025',
    'itemName': 'Laser Lens 50mm',
    'customer': 'Classic Jewellers',
    'invoice': 'JP24754',
    'price': '85,000',
    'status': 'Completed',
  },
  {
    'id': 'IR-2025-034',
    'date': '15-Apr-2025',
    'itemName': 'Wax Nozzle 0.8mm (Pack of 10)',
    'customer': 'Elegant Designs',
    'invoice': 'JP24742',
    'price': '12,000',
    'status': 'Completed',
  },
];