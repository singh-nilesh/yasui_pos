import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import 'inventory_screen.dart';
import 'shop_screen.dart';
import 'amc_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  
  // Dashboard data
  Map<String, dynamic> _summaryData = {};
  List<Map<String, dynamic>> _amcVisitsDue = [];
  List<Map<String, dynamic>> _pendingImports = [];
  List<Map<String, dynamic>> _machineInventory = [];
  List<Map<String, dynamic>> _sparePartsInventory = [];
  List<Map<String, dynamic>> _expiringContracts = [];
  List<Map<String, dynamic>> _monthlySalesData = [];

  // Currency selection
  String _selectedCurrency = 'INR (₹)';
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Fetch dashboard summary stats
      _summaryData = await _databaseService.getDashboardSummary();
      
      // Fetch AMC visits due today
      _amcVisitsDue = await _databaseService.getAMCVisitsDueToday();
      
      // Fetch pending imports
      final imports = await _databaseService.getImportsByStatus('pending');
      _pendingImports = imports.map((import) => import.toMap()).toList();
      
      // Fetch top inventory items
      _machineInventory = await _databaseService.getInventoryItemsForDashboard('machine', 5);
      _sparePartsInventory = await _databaseService.getInventoryItemsForDashboard('part', 5);
      
      // TODO: Load monthly sales data for chart
      _monthlySalesData = _generateDummySalesData(); // Placeholder until real implementation
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Helper method to generate dummy sales data for the chart
  List<Map<String, dynamic>> _generateDummySalesData() {
    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();
    
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthName = DateFormat('MMM').format(month);
      
      data.add({
        'month': monthName,
        'sales': (50000 + (i * 10000) + (1000 * i * i)).toDouble(),
      });
    }
    
    return data;
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Stats Cards Row
          _buildStatsCards(),
          
          const SizedBox(height: 24),
          
          // Monthly Sales and AMC Reminders Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monthly Sales Chart
              Expanded(
                flex: 3,
                child: _buildMonthlySalesCard(),
              ),
              
              const SizedBox(width: 16),
              
              // AMC Reminders
              Expanded(
                flex: 2,
                child: _buildRemindersCard(),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Import Status Section
          _buildImportStatusCard(),
          
          const SizedBox(height: 24),
          
          // Inventory Overview
          _buildInventoryOverviewCard(),
        ],
      ),
    );
  }
  
  // Stats Cards Row
  Widget _buildStatsCards() {
    final currencyFormatter = NumberFormat.currency(
      symbol: '₹', 
      decimalDigits: 2,
      locale: 'en_IN',
    );
    
    return Row(
      children: [
        // Machines in Stock
        Expanded(
          child: _buildStatCard(
            icon: Icons.precision_manufacturing,
            iconColor: Colors.indigo,
            title: 'Machines in Stock',
            value: _summaryData['machinesInStock']?.toString() ?? '0',
            trend: '+3 since last month',
            bgColor: Colors.indigo.withOpacity(0.1),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Spare Parts in Stock
        Expanded(
          child: _buildStatCard(
            icon: Icons.settings,
            iconColor: Colors.blue,
            title: 'Spare Parts in Stock',
            value: _summaryData['sparePartsInStock']?.toString() ?? '0',
            trend: '-52 since last month',
            bgColor: Colors.blue.withOpacity(0.1),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Total Sales
        Expanded(
          child: _buildStatCard(
            icon: Icons.attach_money,
            iconColor: Colors.green,
            title: 'Total Sales (2025)',
            value: currencyFormatter.format(_summaryData['totalSales'] ?? 0),
            trend: '+0% compared to 2024',
            bgColor: Colors.green.withOpacity(0.1),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Pending Imports
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_shipping,
            iconColor: Colors.orange,
            title: 'Pending Imports',
            value: _summaryData['pendingImports']?.toString() ?? '0',
            trend: '${_summaryData['arrivingThisWeek'] ?? 0} arriving this week',
            bgColor: Colors.orange.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
  
  // Individual stat card
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String trend,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Trend
          Text(
            trend,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  // Monthly Sales Chart Card
  Widget _buildMonthlySalesCard() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with currency selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Sales (2025)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedCurrency,
                  items: ['INR (₹)', 'USD (\$)', 'JPY (¥)']
                      .map((currency) => DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCurrency = value;
                      });
                    }
                  },
                  underline: Container(),
                  icon: const Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Chart placeholder
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _monthlySalesData.map((data) {
                  // Calculate height based on sales amount
                  final maxSales = _monthlySalesData
                      .map((d) => d['sales'] as double)
                      .reduce((a, b) => a > b ? a : b);
                  
                  final normalizedHeight = (data['sales'] as double) / maxSales * 160;
                  
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 30,
                        height: normalizedHeight.toDouble(),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['month'] as String,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Chart label
            Center(
              child: Text(
                'Monthly Sales Chart',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // AMC Reminders Card
  Widget _buildRemindersCard() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with view all button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AMC Reminders',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to AMC screen
                    // You would implement navigation here
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Due Today Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Due Today',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // AMC Visits Due Today
                  _amcVisitsDue.isEmpty
                      ? const Text('No visits due today')
                      : Column(
                          children: _amcVisitsDue.map((visit) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                visit['machine'] as String? ?? '',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                'Customer: ${visit['customer'] as String? ?? ''}',
                              ),
                              leading: const CircleAvatar(
                                backgroundColor: Colors.deepOrange,
                                child: Icon(
                                  Icons.timer,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Import Status Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Import Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Import Status List
                  _pendingImports.isEmpty
                      ? const Text('No pending import orders')
                      : Column(
                          children: _pendingImports.take(3).map((order) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                order['name'] as String? ?? '',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                'Status: ${order['status'] as String? ?? ''}',
                              ),
                              trailing: Text(
                                DateFormat('dd MMM').format(
                                  DateTime.tryParse(
                                      order['import_date'] as String? ?? '') ??
                                      DateTime.now(),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Import Status Card
  Widget _buildImportStatusCard() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with view all button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Import Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to Shop screen
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Import Orders List
            _pendingImports.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No pending import orders'),
                    ),
                  )
                : Column(
                    children: _pendingImports.take(5).map((order) {
                      return ListTile(
                        title: Text(
                          order['name'] as String? ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'Quantity: ${order['quantity']} · Customer: ${order['customer_name'] ?? 'N/A'}',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (order['status'] == 'pending')
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            order['status'] as String? ?? '',
                            style: TextStyle(
                              color: (order['status'] == 'pending')
                                  ? Colors.orange
                                  : Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
  
  // Inventory Overview Card
  Widget _buildInventoryOverviewCard() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with view all button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Inventory Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to Inventory screen
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Tabs for Machines and Spare Parts
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // Tab Bar
                  const TabBar(
                    tabs: [
                      Tab(text: 'Machines'),
                      Tab(text: 'Spare Parts'),
                    ],
                    labelColor: Color(0xFF1A237E),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFF1A237E),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tab Content
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      children: [
                        // Machines Tab
                        _buildInventoryList(_machineInventory),
                        
                        // Spare Parts Tab
                        _buildInventoryList(_sparePartsInventory),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Inventory List helper
  Widget _buildInventoryList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No items available'),
      );
    }
    
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(
            item['name'] as String? ?? '',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: Text(
            'Stock: ${item['stock']}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        );
      },
    );
  }
}
