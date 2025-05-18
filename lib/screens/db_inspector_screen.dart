import 'package:flutter/material.dart';
import '../services/database_service.dart';

class DBInspectorScreen extends StatefulWidget {
  const DBInspectorScreen({super.key});

  @override
  State<DBInspectorScreen> createState() => _DBInspectorScreenState();
}

class _DBInspectorScreenState extends State<DBInspectorScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  List<String> _tables = [];
  String? _selectedTable;
  List<Map<String, dynamic>> _records = [];
  List<String> _columns = [];

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = await _databaseService.database;
      // Get all tables in the database
      final tableList = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'");
      
      setState(() {
        _tables = tableList.map((item) => item['name'] as String).toList();
        _isLoading = false;
      });
      
      // Select the first table by default
      if (_tables.isNotEmpty) {
        await _selectTable(_tables.first);
      }
    } catch (e) {
      print('Error loading tables: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectTable(String tableName) async {
    setState(() {
      _isLoading = true;
      _selectedTable = tableName;
    });

    try {
      final db = await _databaseService.database;
      
      // Get table schema to determine columns
      final tableInfo = await db.rawQuery('PRAGMA table_info($tableName)');
      final columns = tableInfo.map((col) => col['name'] as String).toList();
      
      // Get all records from the selected table
      final records = await db.query(tableName);
      
      setState(() {
        _columns = columns;
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading records: $e');
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Database Inspector',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadTables,
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Table selection dropdown
          Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTable,
                isExpanded: true,
                hint: const Text('Select a table'),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _selectTable(newValue);
                  }
                },
                items: _tables.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Table data
          Expanded(
            child: _selectedTable == null || _columns.isEmpty
              ? const Center(child: Text('No table selected or table is empty'))
              : Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_selectedTable (${_records.length} records)',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 12,
                                headingRowColor: WidgetStateProperty.all(
                                  Colors.grey[200],
                                ),
                                columns: _columns
                                    .map(
                                      (col) => DataColumn(
                                        label: Text(
                                          col,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                rows: _records.map((record) {
                                  return DataRow(
                                    cells: _columns.map((col) {
                                      final value = record[col]?.toString() ?? 'null';
                                      return DataCell(
                                        Tooltip(
                                          message: value,
                                          child: Text(
                                            value,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                }).toList(),
                              ),
                            ),
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
}