import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/customer.dart';
import '../models/machine.dart';
import 'package:intl/intl.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  
  // Customer data
  List<Customer> _customers = [];
  List<Machine> _machines = [];
  Map<int, List<Machine>> _customerMachines = {};
  
  // Selected customer for detail view
  Customer? _selectedCustomer;
  String _searchQuery = '';
  
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
      // Load customers
      _customers = await _databaseService.getCustomers();
      
      // Load machines
      _machines = await _databaseService.getMachines();
      
      // Group machines by customer
      _customerMachines = {};
      for (final machine in _machines) {
        final key = machine.customerId ?? 0;
        if (!_customerMachines.containsKey(key)) {
          _customerMachines[key] = [];
        }
        _customerMachines[key]!.add(machine);
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading customer data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  List<Customer> get _filteredCustomers {
    if (_searchQuery.isEmpty) {
      return _customers;
    }
    final query = _searchQuery.toLowerCase();
    return _customers.where((customer) {
      return customer.name.toLowerCase().contains(query) ||
             (customer.country ?? '').toLowerCase().contains(query) ||
             (customer.city ?? '').toLowerCase().contains(query);
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
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
                    setState(() {
                      _searchQuery = value;
                    });
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
                              Text(
                                'Customers (${_filteredCustomers.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: _loadData,
                                tooltip: 'Refresh',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Table
                          Expanded(
                            child: _filteredCustomers.isEmpty
                                ? const Center(child: Text('No customers found'))
                                : ListView.separated(
                                    itemCount: _filteredCustomers.length,
                                    separatorBuilder: (context, index) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final customer = _filteredCustomers[index];
                                      final isSelected = _selectedCustomer != null && 
                                          _selectedCustomer!.id == customer.id;
                                      
                                      return ListTile(
                                        selected: isSelected,
                                        selectedTileColor: Colors.blue[50],
                                        leading: CircleAvatar(
                                          backgroundColor: isSelected 
                                              ? const Color(0xFF1A237E) 
                                              : Colors.grey[400],
                                          child: Text(
                                            customer.name.substring(0, 1),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(customer.name),
                                        subtitle: Text('${customer.country ?? ''} | ${customer.telNo ?? ''}'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blue),
                                              onPressed: () {
                                                _showEditCustomerDialog(customer);
                                              },
                                              tooltip: 'Edit',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () {
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
  Widget _buildCustomerDetailView(Customer customer) {
    // Get machines for this customer
    final customerMachines = _customerMachines[customer.id] ?? [];
    
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
                    customer.name.substring(0, 1),
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
                        customer.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Code: ${customer.id ?? ''}',
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
                                _buildInfoRow('Country', customer.country ?? ''),
                                _buildInfoRow('City', customer.city ?? ''),
                                _buildInfoRow('State', customer.state ?? ''),
                                _buildInfoRow('Email', customer.email ?? ''),
                                _buildInfoRow('Contact 1', customer.contactPrn1 ?? ''),
                                _buildInfoRow('Contact 2', customer.contactPrn2 ?? ''),
                                _buildInfoRow('Telephone', customer.telNo ?? ''),
                                _buildInfoRow('Fax', customer.fax ?? ''),
                                _buildInfoRow('Address', customer.address ?? ''),
                                if ((customer.geoCoord ?? '').isNotEmpty) ...[
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
                                          Text(customer.geoCoord ?? ''),
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
                                child: customerMachines.isNotEmpty
                                    ? ListView.builder(
                                        itemCount: customerMachines.length,
                                        itemBuilder: (context, index) {
                                          final machine = customerMachines[index];
                                          // Format AMC expiry date
                                          final amcExpiry = machine.amcExpireMonth != null
                                              ? DateFormat('dd MMM yyyy').format(machine.amcExpireMonth!)
                                              : 'No AMC';
                                          final bool isAmcActive = machine.amcExpireMonth != null &&
                                              machine.amcExpireMonth!.isAfter(DateTime.now());
                                          final String visits = '${machine.totalVisits - machine.pendingVisits}/${machine.totalVisits}';
                                          return Card(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            child: ListTile(
                                              title: Text(machine.name),
                                              subtitle: Text('Serial: ${machine.serialNo ?? ''} | Purchased: ${machine.purchaseDate != null ? DateFormat('yyyy').format(machine.purchaseDate!) : ''}'),
                                              trailing: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'AMC Expiry: $amcExpiry',
                                                    style: TextStyle(
                                                      color: isAmcActive
                                                          ? Colors.green 
                                                          : Colors.red,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text('Visits: $visits'),
                                                ],
                                              ),
                                              onTap: () {
                                                _showMachineDetailsDialog(machine);
                                              },
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
  Widget _buildInfoRow(String label, String value) {
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
            value.isNotEmpty ? value : 'N/A',
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
    // Controllers
    final TextEditingController nameController = TextEditingController();
    final TextEditingController countryController = TextEditingController();
    final TextEditingController cityController = TextEditingController();
    final TextEditingController stateController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController contactPrn1Controller = TextEditingController();
    final TextEditingController contactPrn2Controller = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController latController = TextEditingController();
    final TextEditingController lngController = TextEditingController();
    
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
                  // Name
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Country and City in one row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: countryController,
                          decoration: const InputDecoration(
                            labelText: 'Country',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: cityController,
                          decoration: const InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // State and Email in one row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: stateController,
                          decoration: const InputDecoration(
                            labelText: 'State',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Contact Person 1 and 2 in one row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: contactPrn1Controller,
                          decoration: const InputDecoration(
                            labelText: 'Contact Person 1',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: contactPrn2Controller,
                          decoration: const InputDecoration(
                            labelText: 'Contact Person 2',
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
                          controller: latController,
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
                          controller: lngController,
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Address
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
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
              onPressed: () async {
                // Create geo coordinate string if both lat and lng are provided
                String geo = '';
                if (latController.text.isNotEmpty && lngController.text.isNotEmpty) {
                  geo = '${latController.text},${lngController.text}';
                }
                
                // Create new customer
                final newCustomer = Customer(
                  id: 0, // Database will assign ID
                  name: nameController.text,
                  country: countryController.text,
                  city: cityController.text,
                  state: stateController.text,
                  email: emailController.text,
                  contactPrn1: contactPrn1Controller.text,
                  contactPrn2: contactPrn2Controller.text,
                  address: addressController.text,
                  geoCoord: geo,
                );
                
                await _databaseService.insertCustomer(newCustomer);
                _loadData(); // Reload data
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
  void _showEditCustomerDialog(Customer customer) {
    // Controllers
    final TextEditingController nameController = TextEditingController(text: customer.name);
    final TextEditingController countryController = TextEditingController(text: customer.country);
    final TextEditingController cityController = TextEditingController(text: customer.city);
    final TextEditingController stateController = TextEditingController(text: customer.state);
    final TextEditingController emailController = TextEditingController(text: customer.email);
    final TextEditingController contactPrn1Controller = TextEditingController(text: customer.contactPrn1);
    final TextEditingController contactPrn2Controller = TextEditingController(text: customer.contactPrn2);
    final TextEditingController addressController = TextEditingController(text: customer.address);
    
    // Split geo coordinates
    String lat = '';
    String lng = '';
    if (customer.geoCoord != null && customer.geoCoord!.isNotEmpty) {
      final parts = customer.geoCoord!.split(',');
      if (parts.length == 2) {
        lat = parts[0];
        lng = parts[1];
      }
    }
    
    final TextEditingController latController = TextEditingController(text: lat);
    final TextEditingController lngController = TextEditingController(text: lng);
    
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
                  // Name
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Country and City in one row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: countryController,
                          decoration: const InputDecoration(
                            labelText: 'Country',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: cityController,
                          decoration: const InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // State and Email in one row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: stateController,
                          decoration: const InputDecoration(
                            labelText: 'State',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Contact Person 1 and 2 in one row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: contactPrn1Controller,
                          decoration: const InputDecoration(
                            labelText: 'Contact Person 1',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: contactPrn2Controller,
                          decoration: const InputDecoration(
                            labelText: 'Contact Person 2',
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
                          controller: latController,
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
                          controller: lngController,
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Address
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
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
              onPressed: () async {
                // Create geo coordinate string if both lat and lng are provided
                String geo = '';
                if (latController.text.isNotEmpty && lngController.text.isNotEmpty) {
                  geo = '${latController.text},${lngController.text}';
                }
                
                // Update customer
                final updatedCustomer = Customer(
                  id: customer.id,
                  name: nameController.text,
                  country: countryController.text,
                  city: cityController.text,
                  state: stateController.text,
                  email: emailController.text,
                  contactPrn1: contactPrn1Controller.text,
                  contactPrn2: contactPrn2Controller.text,
                  address: addressController.text,
                  geoCoord: geo,
                );
                
                await _databaseService.updateCustomer(updatedCustomer);
                _loadData(); // Reload data
                
                // Update selected customer if that was the one edited
                if (_selectedCustomer != null && _selectedCustomer!.id == customer.id) {
                  setState(() {
                    _selectedCustomer = updatedCustomer;
                  });
                }
                
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
  void _showDeleteConfirmDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: Text(
            'Are you sure you want to delete "${customer.name}"? This action cannot be undone.',
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
                // Check if customer has machines
                final hasMachines = _customerMachines.containsKey(customer.id) && 
                    _customerMachines[customer.id]!.isNotEmpty;
                
                if (hasMachines) {
                  // Show warning about machines
                  Navigator.pop(context);
                  _showDeleteWithMachinesWarning(customer);
                } else {
                  // Delete customer directly
                  await _databaseService.deleteCustomer(customer.id!);
                  
                  // Clear selected customer if that was the one deleted
                  if (_selectedCustomer != null && _selectedCustomer!.id == customer.id) {
                    setState(() {
                      _selectedCustomer = null;
                    });
                  }
                  
                  _loadData(); // Reload data
                  Navigator.pop(context);
                }
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
  
  // Warning about deleting a customer with machines
  void _showDeleteWithMachinesWarning(Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning: Customer Has Machines'),
          content: const Text(
            'This customer has machines associated with them. Deleting the customer will also delete all associated machine records. Are you sure you want to proceed?',
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
                // Delete customer (will cascade to delete machines)
                await _databaseService.deleteCustomer(customer.id!);
                
                // Clear selected customer if that was the one deleted
                if (_selectedCustomer != null && _selectedCustomer!.id == customer.id) {
                  setState(() {
                    _selectedCustomer = null;
                  });
                }
                
                _loadData(); // Reload data
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Everything'),
            ),
          ],
        );
      },
    );
  }
  
  // Dialog to add a new machine to a customer
  void _showAddMachineDialog(Customer customer) {
    // Get list of machine types from inventory
    final machineTypes = _machines
        .map((m) => m.name)
        .toSet()
        .toList();
    
    if (machineTypes.isEmpty) {
      machineTypes.addAll(['Casting Machine X1', 'Polisher P200', 'Wax Injector W50', 'Laser Welder LW-20']);
    }
    
    String selectedMachineType = machineTypes.first;
    final TextEditingController serialController = TextEditingController();
    final TextEditingController inrController = TextEditingController();
    final TextEditingController jpyController = TextEditingController();
    final TextEditingController usdController = TextEditingController();
    
    bool createAmc = false;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Machine for ${customer.name}'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500, // Dialog width
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Machine selection
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Machine Type',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedMachineType,
                        items: machineTypes.map((machine) {
                          return DropdownMenuItem<String>(
                            value: machine,
                            child: Text(machine),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedMachineType = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Serial Number
                      TextFormField(
                        controller: serialController,
                        decoration: const InputDecoration(
                          labelText: 'Serial Number',
                          border: OutlineInputBorder(),
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
                              controller: inrController,
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
                              controller: jpyController,
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
                              controller: usdController,
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
                      const SizedBox(height: 16),
                      
                      // AMC Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: createAmc,
                            activeColor: const Color(0xFF1A237E),
                            onChanged: (value) {
                              setState(() {
                                createAmc = value ?? false;
                              });
                            },
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
                  onPressed: () async {
                    // Parse values
                    final priceInr = double.tryParse(inrController.text) ?? 0;
                    final priceJpy = double.tryParse(jpyController.text) ?? 0;
                    final priceUsd = double.tryParse(usdController.text) ?? 0;
                    
                    // Create new machine
                    final newMachine = Machine(
                      id: 0, // Database will assign ID
                      name: selectedMachineType,
                      serialNo: serialController.text,
                      customerId: customer.id ?? 0, // Ensure non-null
                      customerName: customer.name,
                      purchaseDate: DateTime.now(),
                      priceInr: priceInr,
                      priceJpy: priceJpy,
                      priceUsd: priceUsd,
                      amcExpireMonth: createAmc ? DateTime.now().add(const Duration(days: 365)) : null,
                      totalVisits: createAmc ? 4 : 0,
                      pendingVisits: createAmc ? 4 : 0,
                    );
                    
                    await _databaseService.insertMachine(newMachine);
                    _loadData(); // Reload data
                    Navigator.pop(context);
                    
                    // If AMC was created, show a confirmation
                    if (createAmc) {
                      _showAmcConfirmation(newMachine);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Machine'),
                ),
              ],
            );
          }
        );
      },
    );
  }
  
  // Display machine details and allow editing
  void _showMachineDetailsDialog(Machine machine) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(machine.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Serial Number', machine.serialNo ?? ''),
              _buildInfoRow('Purchased Date', machine.purchaseDate != null ? DateFormat('dd MMM yyyy').format(machine.purchaseDate!) : 'N/A'),
              
              const Divider(height: 24),
              
              // AMC information
              const Text(
                'AMC Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              _buildInfoRow('AMC Expiry', 
                machine.amcExpireMonth != null ? DateFormat('dd MMM yyyy').format(machine.amcExpireMonth!) : 'No AMC'),
                  
              _buildInfoRow('Total Visits', machine.totalVisits.toString()),
              _buildInfoRow('Pending Visits', machine.pendingVisits.toString()),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            if (machine.amcExpireMonth == null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showCreateAmcDialog(machine);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create AMC'),
              ),
            if (machine.amcExpireMonth != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showAmcDetailsDialog(machine);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Manage AMC'),
              ),
          ],
        );
      },
    );
  }
  
  // Show AMC confirmation after creation
  void _showAmcConfirmation(Machine machine) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AMC Created Successfully'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'An AMC contract has been created for ${machine.name}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Expiry Date: ${DateFormat('dd MMM yyyy').format(machine.amcExpireMonth!)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '4 service visits have been scheduled.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
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
                Navigator.pop(context);
                _showAmcDetailsDialog(machine);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text('View Details'),
            ),
          ],
        );
      },
    );
  }
  
  // Show dialog to create a new AMC for a machine
  void _showCreateAmcDialog(Machine machine) {
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
              title: Text('Create AMC for ${machine.name}'),
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
                    final updatedMachine = Machine(
                      id: machine.id,
                      name: machine.name,
                      serialNo: machine.serialNo, // Updated field name
                      customerId: machine.customerId,
                      customerName: machine.customerName,
                      purchaseDate: machine.purchaseDate, // Updated field name
                      priceInr: machine.priceInr,
                      priceJpy: machine.priceJpy,
                      priceUsd: machine.priceUsd,
                      seller: machine.seller,
                      amcStartMonth: startDate, // Set start date
                      amcExpireMonth: expiryDate, // Updated field name
                      totalVisits: visits, // Set number of visits
                      pendingVisits: visits, // Initially all visits are pending
                    );
                    
                    await _databaseService.updateMachine(updatedMachine);
                    _loadData(); // Reload data
                    Navigator.pop(context);
                    _showAmcConfirmation(updatedMachine);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create AMC'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  // Show AMC details and management options
  void _showAmcDetailsDialog(Machine machine) {
    final int visitsCompleted = machine.totalVisits - machine.pendingVisits;
    final int totalVisits = machine.totalVisits;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Determine if AMC is active
            final bool isAmcActive = _isAmcActive(machine);
            
            // Calculate days remaining
            final int daysRemaining = machine.amcExpireMonth != null
                ? machine.amcExpireMonth!.difference(DateTime.now()).inDays
                : 0;
            
            return AlertDialog(
              title: Text('AMC for ${machine.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // AMC Status Card
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
                                  isAmcActive 
                                    ? 'Expires in $daysRemaining days' 
                                    : 'Expired on ${DateFormat('dd MMM yyyy').format(machine.amcExpireMonth!)}',
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Visit tracking
                  const Text(
                    'Service Visits',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Visit progress indicator
                  LinearProgressIndicator(
                    value: totalVisits > 0
                      ? visitsCompleted / totalVisits
                      : 0,
                    backgroundColor: Colors.grey[200],
                    color: const Color(0xFF1A237E),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$visitsCompleted of $totalVisits visits completed',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  
                  // Update visits buttons
                  if (isAmcActive) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: visitsCompleted < totalVisits
                            ? () async {
                                final newPendingVisits = machine.pendingVisits - 1;
                                // Update machine
                                final updatedMachine = machine.copyWith(
                                  pendingVisits: newPendingVisits,
                                );
                                await _databaseService.updateMachine(updatedMachine);
                                _loadData(); // Reload data
                                Navigator.pop(context);
                              }
                            : null,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Visit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
                if (!isAmcActive)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showCreateAmcDialog(machine);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Renew AMC'),
                  ),
                if (isAmcActive)
                  ElevatedButton(
                    onPressed: () {
                      // Extend AMC logic
                      Navigator.pop(context);
                      _showExtendAmcDialog(machine, _selectedCustomer!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Extend AMC'),
                  ),
              ],
            );
          },
        );
      },
    );
  }
  
  // Dialog to extend an existing AMC
  void _showExtendAmcDialog(Machine machine, Customer customer) {
    final currentExpiry = machine.amcExpireMonth ?? DateTime.now();  // Use amcExpireMonth instead of amcExpiry
    final TextEditingController durationController = TextEditingController(text: '12');
    bool addVisits = true;
    int additionalVisits = 4;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Extend AMC for ${machine.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Expiry: ${DateFormat('dd MMM yyyy').format(currentExpiry)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Duration
                  TextFormField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Additional months',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  
                  // Add visits
                  Row(
                    children: [
                      Checkbox(
                        value: addVisits,
                        activeColor: const Color(0xFF1A237E),
                        onChanged: (value) {
                          setState(() {
                            addVisits = value ?? false;
                          });
                        },
                      ),
                      const Text('Add service visits'),
                    ],
                  ),
                  
                  if (addVisits) ...[
                    const SizedBox(height: 8),
                    // Additional visits
                    Slider(
                      value: additionalVisits.toDouble(),
                      min: 1,
                      max: 12,
                      divisions: 11,
                      label: additionalVisits.toString(),
                      activeColor: const Color(0xFF1A237E),
                      onChanged: (value) {
                        setState(() {
                          additionalVisits = value.round();
                        });
                      },
                    ),
                    Text(
                      'Add $additionalVisits visit${additionalVisits > 1 ? 's' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
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
                    final duration = int.tryParse(durationController.text) ?? 12;
                    
                    // Calculate new expiry date
                    final newExpiryDate = DateTime(
                      currentExpiry.year,
                      currentExpiry.month + duration,
                      currentExpiry.day,
                    );
                    
                    // Calculate new total visits
                    final currentVisits = machine.totalVisits;  // Use totalVisits directly instead of parsing from string
                    final newTotalVisits = addVisits 
                      ? currentVisits + additionalVisits
                      : currentVisits;
                    
                    // Update the machine with extended AMC details
                    final updatedMachine = Machine(
                      id: machine.id,
                      name: machine.name,
                      serialNo: machine.serialNo,  // Changed from serialNumber to serialNo
                      customerId: machine.customerId,
                      customerName: customer.name,
                      purchaseDate: machine.purchaseDate,  // Use purchaseDate instead of invoiceDate
                      priceInr: machine.priceInr,
                      priceJpy: machine.priceJpy,
                      priceUsd: machine.priceUsd,
                      seller: machine.seller,
                      amcStartMonth: machine.amcStartMonth,  // Preserve the start month
                      amcExpireMonth: newExpiryDate,  // Use amcExpireMonth instead of amcExpiryDate
                      totalVisits: newTotalVisits,
                      pendingVisits: addVisits ? machine.pendingVisits + additionalVisits : machine.pendingVisits,
                    );
                    
                    await _databaseService.updateMachine(updatedMachine);
                    _loadData(); // Reload data
                    Navigator.pop(context);
                    
                    // Show confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('AMC extended to ${DateFormat('dd MMM yyyy').format(newExpiryDate)}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Extend AMC'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  // Helper to check if machine has active AMC
  bool _isAmcActive(Machine machine) {
    return machine.amcExpireMonth != null && 
        machine.amcExpireMonth!.isAfter(DateTime.now());
  }
}