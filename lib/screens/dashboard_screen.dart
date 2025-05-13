import 'package:flutter/material.dart';
import '../widgets/info_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: InfoCard(
                    title: 'Total Machines in Stock',
                    value: '45',
                    icon: Icons.precision_manufacturing,
                    iconColor: Colors.indigo,
                    subtitle: '+3 since last month',
                    onTap: () {},
                    width: 180, // Set a fixed width to prevent overflow
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InfoCard(
                    title: 'Spare Parts in Stock',
                    value: '1,248',
                    icon: Icons.settings,
                    iconColor: Colors.blue,
                    subtitle: '-52 since last month',
                    onTap: () {},
                    width: 180, // Set a fixed width to prevent overflow
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InfoCard(
                    title: 'Total Sales (2025)',
                    value: '₹12.4M',
                    icon: Icons.attach_money,
                    iconColor: Colors.green,
                    subtitle: '+18% compared to 2024',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InfoCard(
                    title: 'Pending Import Orders',
                    value: '8',
                    icon: Icons.local_shipping,
                    iconColor: Colors.orange,
                    subtitle: '3 arriving this week',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Main Content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - Charts and Inventory
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Monthly Sales Chart
                      SizedBox(
                        height: 220,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Monthly Sales (2025)',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    DropdownButton<String>(
                                      value: 'INR',
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'INR',
                                          child: Text('INR (₹)'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'JPY',
                                          child: Text('JPY (¥)'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'USD',
                                          child: Text('USD (\$)'),
                                        ),
                                      ],
                                      onChanged: (value) {},
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Placeholder for chart
                                Expanded(
                                  child: Center(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.bar_chart,
                                            size: 64,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Monthly Sales Chart',
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Inventory Overview
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Inventory Overview',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      size: 18,
                                    ),
                                    label: const Text('View All'),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Tabs for Machines/Spare Parts
                              const DefaultTabController(
                                length: 2,
                                child: Column(
                                  children: [
                                    TabBar(
                                      tabs: [
                                        Tab(text: 'Machines'),
                                        Tab(text: 'Spare Parts'),
                                      ],
                                      labelColor: Color(0xFF1A237E),
                                      unselectedLabelColor: Colors.grey,
                                      indicatorColor: Color(0xFF1A237E),
                                    ),
                                    SizedBox(height: 8),
                                    SizedBox(
                                      height: 48 * 4.0, // 4 items max height, adjust as needed
                                      child: TabBarView(
                                        children: [
                                          _MachinesInventoryTab(),
                                          _SparePartsInventoryTab(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right Column - Reminders and Quick Actions
                Expanded(
                  child: Column(
                    children: [
                      // AMC Reminders
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'AMC Reminders',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      size: 18,
                                    ),
                                    label: const Text('View All'),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              const Divider(),
                              // Only show Due Today
                              const Text(
                                'Due Today',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 8),
                              for (var i = 0; i < _todayVisits.length; i++) ...[
                                _buildVisitTile(_todayVisits[i]),
                                if (i < _todayVisits.length - 1)
                                  const Divider(height: 8),
                              ],
                              if (_todayVisits.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('No visits due today'),
                                ),
                              // Removed upcoming visits section
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Import Status
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Import Status',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      size: 18,
                                    ),
                                    label: const Text('View All'),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              const Divider(),
                              // List of import orders
                              for (var i = 0; i < _importOrders.length; i++) ...[
                                _buildImportTile(_importOrders[i]),
                                if (i < _importOrders.length - 1)
                                  const Divider(height: 8),
                              ],
                              if (_importOrders.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('No pending import orders'),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to build visit reminder tiles
  Widget _buildVisitTile(Map<String, dynamic> visit) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.blue[50],
        child: const Icon(
          Icons.calendar_today,
          color: Colors.blue,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Text(
            visit['customer'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: visit['date'] == 'Today' ? Colors.red[50] : Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              visit['date'],
              style: TextStyle(
                fontSize: 12,
                color: visit['date'] == 'Today' ? Colors.red : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(visit['machine']),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
  
  // Helper method to build import status tiles
  Widget _buildImportTile(Map<String, dynamic> order) {
    final statusColors = {
      'Shipped': Colors.blue,
      'Processing': Colors.orange,
      'Delivered': Colors.green,
      'Pending': Colors.grey,
    };
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        order['name'],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(order['details']),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColors[order['status']]!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              order['status'],
              style: TextStyle(
                fontSize: 12,
                color: statusColors[order['status']],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order['date'],
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      onTap: () {},
    );
  }
}

// Tab content for Machines inventory
class _MachinesInventoryTab extends StatelessWidget {
  const _MachinesInventoryTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _machinesInventory.length,
      itemBuilder: (context, index) {
        final machine = _machinesInventory[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  machine['name'],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'In Stock: ${machine['stock']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: LinearProgressIndicator(
                  value: machine['stock'] / 10, // Max stock assumed to be 10
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    machine['stock'] < 3 ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Tab content for Spare Parts inventory
class _SparePartsInventoryTab extends StatelessWidget {
  const _SparePartsInventoryTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _sparePartsInventory.length,
      itemBuilder: (context, index) {
        final part = _sparePartsInventory[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  part['name'],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'In Stock: ${part['stock']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: LinearProgressIndicator(
                  value: part['stock'] / 50, // Max stock assumed to be 50
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    part['stock'] < 10 ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Dummy Data
final List<Map<String, dynamic>> _todayVisits = [
  {
    'customer': 'Royal Jewellers',
    'machine': 'Casting Machine X1',
    'date': 'Today',
    'time': '10:00 AM',
  },
  {
    'customer': 'Elegant Designs',
    'machine': 'Laser Welder LW-20',
    'date': 'Today',
    'time': '2:30 PM',
  },
];

final List<Map<String, dynamic>> _importOrders = [
  {
    'name': 'Casting Machine X2',
    'details': 'Order #I2025-42 - YNC Invoice: JP24891',
    'status': 'Shipped',
    'date': 'Expected: May 20, 2025',
  },
  {
    'name': 'Polisher Parts (x15)',
    'details': 'Order #I2025-39 - YNC Invoice: JP24873',
    'status': 'Processing',
    'date': 'Ordered: May 5, 2025',
  },
  {
    'name': 'Wax Injector W60',
    'details': 'Order #I2025-36 - YNC Invoice: JP24812',
    'status': 'Delivered',
    'date': 'Arrived: May 8, 2025',
  },
];

final List<Map<String, dynamic>> _machinesInventory = [
  {'name': 'Casting Machine X1', 'stock': 5},
  {'name': 'Polisher P200', 'stock': 3},
  {'name': 'Wax Injector W50', 'stock': 2},
  {'name': 'Laser Welder LW-20', 'stock': 1},
];

final List<Map<String, dynamic>> _sparePartsInventory = [
  {'name': 'Casting Flask 100mm', 'stock': 24},
  {'name': 'Polisher Disc P120', 'stock': 45},
  {'name': 'Wax Nozzle 0.8mm', 'stock': 8},
  {'name': 'Laser Lens 50mm', 'stock': 5},
  {'name': 'Vacuum Pump Filter', 'stock': 12},
];