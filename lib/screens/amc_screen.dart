import 'package:flutter/material.dart';
import '../widgets/data_table_widget.dart';

class AMCScreen extends StatefulWidget {
  const AMCScreen({super.key});

  @override
  State<AMCScreen> createState() => _AMCScreenState();
}

class _AMCScreenState extends State<AMCScreen> {
  // Selected date for calendar view
  DateTime _selectedDate = DateTime.now();
  
  // Selected view (calendar or table)
  String _selectedView = 'Calendar';
  
  // Filter for table view
  String _selectedFilter = 'All';
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AMC Management',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // View Toggle
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: 'Calendar',
                          label: Text('Calendar View'),
                          icon: Icon(Icons.calendar_month),
                        ),
                        ButtonSegment<String>(
                          value: 'Table',
                          label: Text('Table View'),
                          icon: Icon(Icons.view_list),
                        ),
                      ],
                      selected: {_selectedView},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _selectedView = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    // Quick action buttons
                    ElevatedButton.icon(
                      onPressed: () {
                        _showNewAMCDialog();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('New AMC Contract'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showEmergencyVisitDialog();
                      },
                      icon: const Icon(Icons.emergency),
                      label: const Text('Emergency Visit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Main content based on selected view
            Expanded(
              child: _selectedView == 'Calendar' 
                  ? _buildCalendarView() 
                  : _buildTableView(),
            ),
          ],
        ),
      ),
    );
  }
  
  // Calendar View
  Widget _buildCalendarView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendar
        Expanded(
          flex: 3,
          child: Card(
            elevation: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month Navigation
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month - 1,
                              _selectedDate.day,
                            );
                          });
                        },
                        tooltip: 'Previous Month',
                      ),
                      Text(
                        '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month + 1,
                              _selectedDate.day,
                            );
                          });
                        },
                        tooltip: 'Next Month',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0),
                
                // Calendar Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: 7 + _getDaysInMonth(_selectedDate.year, _selectedDate.month),
                    itemBuilder: (context, index) {
                      // First row is weekdays
                      if (index < 7) {
                        return _buildWeekdayCell(index);
                      }
                      
                      // Calendar days
                      final dayNumber = index - 6; // Adjusted for weekday row
                      final date = DateTime(_selectedDate.year, _selectedDate.month, dayNumber);
                      
                      // Check if this date has AMC visits
                      final visitsCount = _getAMCVisitsForDate(date);
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: _selectedDate.day == dayNumber
                                ? Colors.blue[50]
                                : DateTime.now().year == date.year &&
                                  DateTime.now().month == date.month &&
                                  DateTime.now().day == date.day
                                    ? Colors.amber[50]
                                    : null,
                            border: Border.all(
                              color: _selectedDate.day == dayNumber
                                  ? Colors.blue
                                  : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    dayNumber.toString(),
                                    style: TextStyle(
                                      fontWeight: _selectedDate.day == dayNumber
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              if (visitsCount > 0)
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: _getVisitStatusColor(visitsCount),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      visitsCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Selected Day Details
        Expanded(
          flex: 2,
          child: Card(
            elevation: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Row(
                    children: [
                      Icon(
                        Icons.event,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Visits for ${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildVisitsForSelectedDate(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // Table View
  Widget _buildTableView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter by status
        Row(
          children: [
            const Text(
              'Filter by Status:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            ChoiceChip(
              label: const Text('All'),
              selected: _selectedFilter == 'All',
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = 'All';
                  });
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Active'),
              selected: _selectedFilter == 'Active',
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = 'Active';
                  });
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Expired'),
              selected: _selectedFilter == 'Expired',
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = 'Expired';
                  });
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Expiring Soon'),
              selected: _selectedFilter == 'Expiring Soon',
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = 'Expiring Soon';
                  });
                }
              },
            ),
            const Spacer(),
            // Search box
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Search contracts',
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
          ],
        ),
        const SizedBox(height: 16),
        
        // AMC Contracts Table
        Expanded(
          child: DataTableWidget(
            columns: const [
              'Contract ID',
              'Customer',
              'Machine',
              'Start Date',
              'End Date',
              'Status',
              'Last Visit',
              'Next Visit',
              'Actions',
            ],
            rows: _getFilteredAMCContracts(),
            onEdit: (row) {
              // Edit AMC contract
              _showEditAMCDialog(row);
            },
            onDelete: null, // No delete option for AMC
          ),
        ),
      ],
    );
  }
  
  // Helper method to build weekday header cells
  Widget _buildWeekdayCell(int index) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        weekdays[index],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  // Helper method to get AMC visits for a specific date
  int _getAMCVisitsForDate(DateTime date) {
    // Format the date for comparison in MM/DD/YYYY format
    final dateString = '${date.month}/${date.day}/${date.year}';
    
    // Count visits scheduled for this date
    return _dummyAMCVisits
        .where((visit) => visit['date'] == dateString)
        .length;
  }
  
  // Helper method to build visits list for selected date
  Widget _buildVisitsForSelectedDate() {
    // Format the date for comparison in MM/DD/YYYY format
    final dateString = '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}';
    
    // Filter visits for the selected date
    final visits = _dummyAMCVisits
        .where((visit) => visit['date'] == dateString)
        .toList();
    
    if (visits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No AMC visits scheduled for this date',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _showScheduleVisitDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Schedule Visit'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: visits.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final visit = visits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              visit['customer'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Machine: ${visit['machine']}'),
                Text('Time: ${visit['time']}'),
                Text('Engineer: ${visit['engineer']}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _getStatusChip(visit['status']),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    _showVisitActionMenu(context, visit);
                  },
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
  
  // Helper method to display a visit status chip
  Widget _getStatusChip(String status) {
    Color chipColor;
    Icon? chipIcon;
    
    switch (status) {
      case 'Scheduled':
        chipColor = Colors.blue;
        chipIcon = const Icon(Icons.event, color: Colors.white, size: 16);
        break;
      case 'Completed':
        chipColor = Colors.green;
        chipIcon = const Icon(Icons.check_circle, color: Colors.white, size: 16);
        break;
      case 'Cancelled':
        chipColor = Colors.red;
        chipIcon = const Icon(Icons.cancel, color: Colors.white, size: 16);
        break;
      case 'In Progress':
        chipColor = Colors.orange;
        chipIcon = const Icon(Icons.timelapse, color: Colors.white, size: 16);
        break;
      default:
        chipColor = Colors.grey;
        chipIcon = null;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chipIcon != null) ...[
            chipIcon,
            const SizedBox(width: 4),
          ],
          Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to show visit action menu
  void _showVisitActionMenu(BuildContext context, Map<String, dynamic> visit) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Visit'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditVisitDialog(visit);
                },
              ),
              if (visit['status'] == 'Scheduled') ...[
                ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: const Text('Mark as Completed'),
                  onTap: () {
                    Navigator.pop(context);
                    // Mark as completed logic
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Cancel Visit'),
                  onTap: () {
                    Navigator.pop(context);
                    // Cancel visit logic
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.content_paste),
                title: const Text('View Report'),
                onTap: () {
                  Navigator.pop(context);
                  // View report logic
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Contact Customer'),
                onTap: () {
                  Navigator.pop(context);
                  // Contact customer logic
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Helper method to get filtered AMC contracts based on selected filter
  List<Map<String, dynamic>> _getFilteredAMCContracts() {
    switch (_selectedFilter) {
      case 'Active':
        return _dummyAMCContracts
            .where((contract) => contract['Status'] == 'Active')
            .toList();
      case 'Expired':
        return _dummyAMCContracts
            .where((contract) => contract['Status'] == 'Expired')
            .toList();
      case 'Expiring Soon':
        return _dummyAMCContracts
            .where((contract) => contract['Status'] == 'Expiring Soon')
            .toList();
      default:
        return [..._dummyAMCContracts];
    }
  }
  
  // Helper method to get the color for visit count indicator on calendar
  Color _getVisitStatusColor(int count) {
    if (count >= 3) {
      return Colors.red;
    } else if (count == 2) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }
  
  // Helper method to get month name from month number
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
  
  // Helper method to get days in a month
  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
  
  // Dialog to create new AMC contract
  void _showNewAMCDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New AMC Contract'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Customer dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Customer',
                      border: OutlineInputBorder(),
                    ),
                    items: _dummyCustomerNames
                        .map((name) => DropdownMenuItem<String>(
                              value: name,
                              child: Text(name),
                            ))
                        .toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  
                  // Machine dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Machine',
                      border: OutlineInputBorder(),
                    ),
                    items: _dummyMachineNames
                        .map((name) => DropdownMenuItem<String>(
                              value: name,
                              child: Text(name),
                            ))
                        .toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  
                  // Contract period
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () {
                                // Show date picker
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () {
                                // Show date picker
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Contract value
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Contract Value (₹)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  
                  // Visit frequency
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Visit Frequency',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: '3',
                        child: Text('Quarterly (4 visits/year)'),
                      ),
                      DropdownMenuItem(
                        value: '6',
                        child: Text('Bi-annually (2 visits/year)'),
                      ),
                      DropdownMenuItem(
                        value: '12',
                        child: Text('Annually (1 visit/year)'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Notes',
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
                // Create AMC logic
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Create Contract'),
            ),
          ],
        );
      },
    );
  }
  
  // Dialog to edit AMC contract
  void _showEditAMCDialog(Map<String, dynamic> contract) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit AMC Contract ${contract['Contract ID']}'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Customer dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Customer',
                      border: OutlineInputBorder(),
                    ),
                    value: contract['Customer'],
                    items: _dummyCustomerNames
                        .map((name) => DropdownMenuItem<String>(
                              value: name,
                              child: Text(name),
                            ))
                        .toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  
                  // Machine dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Machine',
                      border: OutlineInputBorder(),
                    ),
                    value: contract['Machine'],
                    items: _dummyMachineNames
                        .map((name) => DropdownMenuItem<String>(
                              value: name,
                              child: Text(name),
                            ))
                        .toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  
                  // Contract period
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: contract['Start Date'],
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () {
                                // Show date picker
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: contract['End Date'],
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () {
                                // Show date picker
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes
                  TextFormField(
                    initialValue: contract['Notes'] ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Notes',
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
                // Update AMC logic
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Update Contract'),
            ),
          ],
        );
      },
    );
  }
  
  // Dialog to edit a visit
  void _showEditVisitDialog(Map<String, dynamic> visit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Visit'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Date and Time
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: visit['date'],
                          decoration: InputDecoration(
                            labelText: 'Date',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () {
                                // Show date picker
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: visit['time'],
                          decoration: InputDecoration(
                            labelText: 'Time',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.access_time),
                              onPressed: () {
                                // Show time picker
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Engineer assigned
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Engineer',
                      border: OutlineInputBorder(),
                    ),
                    value: visit['engineer'],
                    items: _dummyEngineers
                        .map((name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ))
                        .toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  
                  // Status
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    value: visit['status'],
                    items: const [
                      DropdownMenuItem(
                        value: 'Scheduled',
                        child: Text('Scheduled'),
                      ),
                      DropdownMenuItem(
                        value: 'In Progress',
                        child: Text('In Progress'),
                      ),
                      DropdownMenuItem(
                        value: 'Completed',
                        child: Text('Completed'),
                      ),
                      DropdownMenuItem(
                        value: 'Cancelled',
                        child: Text('Cancelled'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes
                  TextFormField(
                    initialValue: visit['notes'] ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Notes',
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
                // Update visit logic
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Update Visit'),
            ),
          ],
        );
      },
    );
  }
  
  // Dialog to schedule a new visit
  void _showScheduleVisitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Schedule Visit'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // AMC Contract dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'AMC Contract',
                      border: OutlineInputBorder(),
                    ),
                    items: _dummyAMCContracts
                        .where((contract) => contract['Status'] == 'Active')
                        .map((contract) => DropdownMenuItem<String>(
                              value: contract['Contract ID'],
                              child: Text(
                                '${contract['Contract ID']} - ${contract['Customer']} (${contract['Machine']})',
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  
                  // Date and Time
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue:
                              '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                          decoration: InputDecoration(
                            labelText: 'Date',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () {
                                // Show date picker
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Time',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.access_time),
                              onPressed: () {
                                // Show time picker
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Engineer assigned
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Engineer',
                      border: OutlineInputBorder(),
                    ),
                    items: _dummyEngineers
                        .map((name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ))
                        .toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Notes',
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
                // Schedule visit logic
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Schedule Visit'),
            ),
          ],
        );
      },
    );
  }
  
  // Dialog for emergency visit
  void _showEmergencyVisitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              const Text('Schedule Emergency Visit'),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Customer dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Customer',
                      border: OutlineInputBorder(),
                    ),
                    items: _dummyCustomerNames
                        .map((name) => DropdownMenuItem<String>(
                              value: name,
                              child: Text(name),
                            ))
                        .toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  
                  // Machine dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Machine',
                      border: OutlineInputBorder(),
                    ),
                    items: _dummyMachineNames
                        .map((name) => DropdownMenuItem<String>(
                              value: name,
                              child: Text(name),
                            ))
                        .toList(),
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  
                  // Issue description
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Issue Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  // Priority level
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Priority Level',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'High',
                        child: Text('High - Same Day'),
                      ),
                      DropdownMenuItem(
                        value: 'Medium',
                        child: Text('Medium - Within 48 hours'),
                      ),
                      DropdownMenuItem(
                        value: 'Low',
                        child: Text('Low - Within a week'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 16),
                  
                  // Date and Time
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Preferred Date',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () {
                                // Show date picker
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Preferred Time',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.access_time),
                              onPressed: () {
                                // Show time picker
                              },
                            ),
                          ),
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
                // Schedule emergency visit logic
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Schedule Emergency Visit'),
            ),
          ],
        );
      },
    );
  }
}

// Dummy Data for AMC Screen
final List<Map<String, dynamic>> _dummyAMCContracts = [
  {
    'Contract ID': 'AMC001',
    'Customer': 'Royal Jewellers',
    'Machine': 'Casting Machine X1',
    'Start Date': '15 May 2024',
    'End Date': '14 May 2025',
    'Status': 'Active',
    'Last Visit': '15 Mar 2025',
    'Next Visit': '15 Jul 2025',
    'Notes': 'Quarterly maintenance contract',
  },
  {
    'Contract ID': 'AMC002',
    'Customer': 'Royal Jewellers',
    'Machine': 'Polisher P200',
    'Start Date': '20 Jul 2024',
    'End Date': '19 Jul 2025',
    'Status': 'Active',
    'Last Visit': '20 Mar 2025',
    'Next Visit': '20 May 2025',
    'Notes': 'Bi-monthly maintenance contract',
  },
  {
    'Contract ID': 'AMC003',
    'Customer': 'Star Jewellery',
    'Machine': 'Wax Injector W50',
    'Start Date': '05 Jan 2024',
    'End Date': '04 Jan 2025',
    'Status': 'Expired',
    'Last Visit': '05 Oct 2024',
    'Next Visit': 'N/A',
    'Notes': 'Contract renewal pending',
  },
  {
    'Contract ID': 'AMC004',
    'Customer': 'Elegant Designs',
    'Machine': 'Laser Welder LW-20',
    'Start Date': '12 Mar 2025',
    'End Date': '11 Mar 2026',
    'Status': 'Active',
    'Last Visit': 'N/A',
    'Next Visit': '12 Jun 2025',
    'Notes': 'First visit scheduled',
  },
  {
    'Contract ID': 'AMC005',
    'Customer': 'Elegant Designs',
    'Machine': 'Casting Machine X1',
    'Start Date': '12 Mar 2025',
    'End Date': '11 Mar 2026',
    'Status': 'Active',
    'Last Visit': 'N/A',
    'Next Visit': '12 Jun 2025',
    'Notes': 'First visit scheduled',
  },
  {
    'Contract ID': 'AMC006',
    'Customer': 'Classic Jewellers',
    'Machine': 'Polisher P200',
    'Start Date': '20 May 2024',
    'End Date': '19 May 2025',
    'Status': 'Expiring Soon',
    'Last Visit': '20 Feb 2025',
    'Next Visit': '20 May 2025',
    'Notes': 'Final visit due before renewal',
  },
];

final List<Map<String, dynamic>> _dummyAMCVisits = [
  {
    'id': 'V001',
    'contractId': 'AMC001',
    'customer': 'Royal Jewellers',
    'machine': 'Casting Machine X1',
    'date': '5/14/2025',
    'time': '10:00 AM',
    'engineer': 'Rahul Sharma',
    'status': 'Scheduled',
    'notes': 'Regular quarterly maintenance',
  },
  {
    'id': 'V002',
    'contractId': 'AMC002',
    'customer': 'Royal Jewellers',
    'machine': 'Polisher P200',
    'date': '5/15/2025',
    'time': '2:00 PM',
    'engineer': 'Rahul Sharma',
    'status': 'Scheduled',
    'notes': 'Check motor and bearings',
  },
  {
    'id': 'V003',
    'contractId': 'AMC006',
    'customer': 'Classic Jewellers',
    'machine': 'Polisher P200',
    'date': '5/20/2025',
    'time': '11:00 AM',
    'engineer': 'Amit Patel',
    'status': 'Scheduled',
    'notes': 'Final visit before contract renewal',
  },
  {
    'id': 'V004',
    'contractId': 'AMC004',
    'customer': 'Elegant Designs',
    'machine': 'Laser Welder LW-20',
    'date': '5/13/2025',
    'time': '9:30 AM',
    'engineer': 'Priya Verma',
    'status': 'In Progress',
    'notes': 'Emergency visit for calibration issue',
  },
  {
    'id': 'V005',
    'contractId': 'AMC005',
    'customer': 'Elegant Designs',
    'machine': 'Casting Machine X1',
    'date': '5/13/2025',
    'time': '1:30 PM',
    'engineer': 'Priya Verma',
    'status': 'Scheduled',
    'notes': 'Check heating elements and pressure system',
  },
];

// Dummy data for dropdowns
final List<String> _dummyCustomerNames = [
  'Royal Jewellers',
  'Star Jewellery',
  'Elegant Designs',
  'Modern Creations',
  'Classic Jewellers',
];

final List<String> _dummyMachineNames = [
  'Casting Machine X1',
  'Polisher P200',
  'Wax Injector W50',
  'Laser Welder LW-20',
];

final List<String> _dummyEngineers = [
  'Rahul Sharma',
  'Amit Patel',
  'Priya Verma',
  'Sunil Kumar',
];