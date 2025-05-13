import 'package:flutter/material.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  // Selected customer for detail view
  Map<String, dynamic>? _selectedCustomer;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer List (Left Section)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header and Add Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Customer List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showAddCustomerDialog();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Customer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Search Box
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, code or country',
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
                const SizedBox(height: 16),
                
                // Customer Table
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
                              const Text(
                                'Customers',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.filter_list),
                                onPressed: () {
                                  // Show filter options
                                },
                                tooltip: 'Filter',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Table
                          Expanded(
                            child: ListView.separated(
                              itemCount: _dummyCustomers.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final customer = _dummyCustomers[index];
                                final isSelected = _selectedCustomer != null && 
                                    _selectedCustomer!['code'] == customer['code'];
                                
                                return ListTile(
                                  selected: isSelected,
                                  selectedTileColor: Colors.blue[50],
                                  leading: CircleAvatar(
                                    backgroundColor: isSelected 
                                        ? const Color(0xFF1A237E) 
                                        : Colors.grey[400],
                                    child: Text(
                                      customer['name'].toString().substring(0, 1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(customer['name'].toString()),
                                  subtitle: Text('${customer['country']} | ${customer['tell']}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () {
                                          // Edit customer
                                          _showEditCustomerDialog(customer);
                                        },
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          // Delete customer
                                          _showDeleteConfirmDialog(customer);
                                        },
                                        tooltip: 'Delete',
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedCustomer = customer;
                                    });
                                  },
                                );
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
          ),
          const SizedBox(width: 16),
          
          // Customer Details (Right Section)
          Expanded(
            flex: 2,
            child: _selectedCustomer != null
                ? _buildCustomerDetailView(_selectedCustomer!)
                : _buildCustomerEmptyView(),
          ),
        ],
      ),
    );
  }
  
  // Empty view when no customer is selected
  Widget _buildCustomerEmptyView() {
    return Card(
      elevation: 1,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Select a customer to view details',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Customer detail view
  Widget _buildCustomerDetailView(Map<String, dynamic> customer) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Profile Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF1A237E),
                  child: Text(
                    customer['name'].toString().substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer['name'].toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Code: ${customer['code']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_business),
                  onPressed: () {
                    _showAddMachineDialog(customer);
                  },
                  tooltip: 'Add Machinery',
                ),
              ],
            ),
            const Divider(height: 32),
            
            // Customer Details
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tab Bar
                    const TabBar(
                      tabs: [
                        Tab(text: 'Contact Info'),
                        Tab(text: 'Machines'),
                      ],
                      labelColor: Color(0xFF1A237E),
                      indicatorColor: Color(0xFF1A237E),
                      unselectedLabelColor: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    
                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Contact Info Tab
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Country', customer['country']),
                                _buildInfoRow('Destination', customer['destination']),
                                _buildInfoRow('Telephone', customer['tell']),
                                _buildInfoRow('Fax', customer['fax']),
                                _buildInfoRow('Address', customer['address']),
                                const SizedBox(height: 16),
                                if (customer['geo'] != null) ...[
                                  const Text(
                                    'Geo Coordinates',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.map, size: 32),
                                          const SizedBox(height: 8),
                                          Text(customer['geo'].toString()),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          // Machines Tab
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: customer['machines'] != null && 
                                    (customer['machines'] as List).isNotEmpty
                                    ? ListView.builder(
                                        itemCount: (customer['machines'] as List).length,
                                        itemBuilder: (context, index) {
                                          final machine = (customer['machines'] as List)[index];
                                          return Card(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            child: ListTile(
                                              title: Text(machine['name']),
                                              subtitle: Text('Serial: ${machine['serial']} | Year: ${machine['year']}'),
                                              trailing: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'AMC Expiry: ${machine['amcExpiry']}',
                                                    style: TextStyle(
                                                      color: machine['amcStatus'] == 'Active' 
                                                          ? Colors.green 
                                                          : Colors.red,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text('Visits: ${machine['visits']}'),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.settings,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'No machines added yet',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                _showAddMachineDialog(customer);
                                              },
                                              icon: const Icon(Icons.add),
                                              label: const Text('Add Machine'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF1A237E),
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ],
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
    );
  }
  
  // Helper method to build info rows
  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value?.toString() ?? 'N/A',
            style: TextStyle(
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
  
  // Dialog to add a new customer
  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Customer'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500, // Dialog width
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Code and Name in one row
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Code',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Country and Destination in one row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Country',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Destination',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Telephone and Fax in one row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Telephone',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Fax',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Address
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  // Geo coordinates
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            border: OutlineInputBorder(),
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add customer logic
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Customer'),
            ),
          ],
        );
      },
    );
  }
  
  // Dialog to edit an existing customer
  void _showEditCustomerDialog(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Customer'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500, // Dialog width
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Code and Name in one row
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          initialValue: customer['code'].toString(),
                          decoration: const InputDecoration(
                            labelText: 'Code',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true, // Code should not be editable
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          initialValue: customer['name'].toString(),
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Country and Destination in one row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: customer['country'].toString(),
                          decoration: const InputDecoration(
                            labelText: 'Country',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: customer['destination'].toString(),
                          decoration: const InputDecoration(
                            labelText: 'Destination',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Telephone and Fax in one row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: customer['tell'].toString(),
                          decoration: const InputDecoration(
                            labelText: 'Telephone',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: customer['fax'].toString(),
                          decoration: const InputDecoration(
                            labelText: 'Fax',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Address
                  TextFormField(
                    initialValue: customer['address'].toString(),
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  // Geo coordinates
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: customer['geo']?.toString().split(',')[0] ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: customer['geo']?.toString().split(',')[1] ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            border: OutlineInputBorder(),
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Update customer logic
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
  
  // Confirmation dialog to delete a customer
  void _showDeleteConfirmDialog(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: Text(
            'Are you sure you want to delete "${customer['name']}"? This action cannot be undone.',
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
                // Delete customer logic
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
  
  // Dialog to add a new machine to a customer
  void _showAddMachineDialog(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Machine for ${customer['name']}'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500, // Dialog width
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Machine selection
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Machine',
                      border: OutlineInputBorder(),
                    ),
                    items: _dummyMachineTypes
                        .map((machine) => DropdownMenuItem(
                              value: machine,
                              child: Text(machine),
                            ))
                        .toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  
                  // Serial Number
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Serial Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Quantity and Year
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Year',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Invoice Date
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Invoice Date',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () {
                          // Show date picker
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Price in different currencies
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
                            labelText: 'INR',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'JPY',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'USD',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // AMC Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (value) {},
                      ),
                      const Text('Create AMC Contract for this machine'),
                    ],
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
                // Add machine logic
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Machine'),
            ),
          ],
        );
      },
    );
  }
}

// Dummy Data for Customers
final List<Map<String, dynamic>> _dummyCustomers = [
  {
    'code': 'C001',
    'name': 'Royal Jewellers',
    'country': 'India',
    'destination': 'Mumbai',
    'tell': '+91-22-12345678',
    'fax': '+91-22-87654321',
    'address': '123 Diamond Market, Zaveri Bazaar, Mumbai, Maharashtra 400003',
    'geo': '19.2307,72.8567',
    'machines': [
      {
        'name': 'Casting Machine X1',
        'serial': 'CM001-2023',
        'quantity': 1,
        'year': '2023',
        'amcExpiry': '15 Dec 2025',
        'amcStatus': 'Active',
        'visits': '2/4 completed',
      },
      {
        'name': 'Polisher P200',
        'serial': 'P200-567',
        'quantity': 2,
        'year': '2024',
        'amcExpiry': '20 Jul 2025',
        'amcStatus': 'Active',
        'visits': '1/4 completed',
      },
    ],
  },
  {
    'code': 'C002',
    'name': 'Star Jewellery',
    'country': 'India',
    'destination': 'Delhi',
    'tell': '+91-11-23456789',
    'fax': '+91-11-98765432',
    'address': '456 Gold Market, Chandni Chowk, New Delhi 110006',
    'geo': '28.6517,77.2282',
    'machines': [
      {
        'name': 'Wax Injector W50',
        'serial': 'W50-789',
        'quantity': 1,
        'year': '2022',
        'amcExpiry': '05 Jan 2025',
        'amcStatus': 'Expired',
        'visits': '4/4 completed',
      },
    ],
  },
  {
    'code': 'C003',
    'name': 'Elegant Designs',
    'country': 'United Arab Emirates',
    'destination': 'Dubai',
    'tell': '+971-4-1234567',
    'fax': '+971-4-7654321',
    'address': '789 Gold Souk, Deira, Dubai, UAE',
    'geo': '25.2697,55.3093',
    'machines': [
      {
        'name': 'Laser Welder LW-20',
        'serial': 'LW20-456',
        'quantity': 1,
        'year': '2024',
        'amcExpiry': '12 Mar 2026',
        'amcStatus': 'Active',
        'visits': '0/4 completed',
      },
      {
        'name': 'Casting Machine X1',
        'serial': 'CM001-2024',
        'quantity': 1,
        'year': '2024',
        'amcExpiry': '12 Mar 2026',
        'amcStatus': 'Active',
        'visits': '0/4 completed',
      },
    ],
  },
  {
    'code': 'C004',
    'name': 'Modern Creations',
    'country': 'India',
    'destination': 'Jaipur',
    'tell': '+91-141-9876543',
    'fax': '+91-141-3456789',
    'address': '101 Jewel Street, Johari Bazaar, Jaipur, Rajasthan 302003',
    'geo': '26.9239,75.8267',
    'machines': [],
  },
  {
    'code': 'C005',
    'name': 'Classic Jewellers',
    'country': 'Thailand',
    'destination': 'Bangkok',
    'tell': '+66-2-1234567',
    'fax': '+66-2-7654321',
    'address': '555 Jewelry Trade Center, Silom, Bangkok 10500',
    'geo': '13.7308,100.5241',
    'machines': [
      {
        'name': 'Polisher P200',
        'serial': 'P200-123',
        'quantity': 3,
        'year': '2022',
        'amcExpiry': '20 May 2025',
        'amcStatus': 'Active',
        'visits': '3/4 completed',
      },
    ],
  },
];

// Dummy machine types for dropdown
final List<String> _dummyMachineTypes = [
  'Casting Machine X1',
  'Polisher P200',
  'Wax Injector W50',
  'Laser Welder LW-20',
];