import 'package:flutter/material.dart';

class DataTableWidget extends StatefulWidget {
  final List<String> columns;
  final List<Map<String, dynamic>> rows;
  final void Function(Map<String, dynamic>)? onEdit;
  final void Function(Map<String, dynamic>)? onDelete;
  final int? initialSortColumnIndex;
  final bool initialSortAscending;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.rows,
    this.onEdit,
    this.onDelete,
    this.initialSortColumnIndex,
    this.initialSortAscending = true,
  });

  @override
  State<DataTableWidget> createState() => _DataTableWidgetState();
}

class _DataTableWidgetState extends State<DataTableWidget> {
  late List<Map<String, dynamic>> _filteredRows;
  late int? _sortColumnIndex;
  late bool _sortAscending;
  int _rowsPerPage = 10;
  int _currentPage = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredRows = List.from(widget.rows);
    _sortColumnIndex = widget.initialSortColumnIndex;
    _sortAscending = widget.initialSortAscending;
    
    if (_sortColumnIndex != null) {
      _sortData();
    }
  }

  @override
  void didUpdateWidget(DataTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rows != widget.rows) {
      setState(() {
        _filteredRows = _applySearch(widget.rows);
        if (_sortColumnIndex != null) {
          _sortData();
        }
      });
    }
  }

  void _sortData() {
    if (_sortColumnIndex != null) {
      final columnName = widget.columns[_sortColumnIndex!];
      _filteredRows.sort((a, b) {
        final aValue = a[columnName];
        final bValue = b[columnName];
        
        if (aValue == null && bValue == null) {
          return 0;
        } else if (aValue == null) {
          return _sortAscending ? -1 : 1;
        } else if (bValue == null) {
          return _sortAscending ? 1 : -1;
        }
        
        int comparison;
        if (aValue is num && bValue is num) {
          comparison = aValue.compareTo(bValue);
        } else {
          comparison = aValue.toString().compareTo(bValue.toString());
        }
        
        return _sortAscending ? comparison : -comparison;
      });
    }
  }

  List<Map<String, dynamic>> _applySearch(List<Map<String, dynamic>> data) {
    if (_searchQuery.isEmpty) {
      return data;
    }
    
    final query = _searchQuery.toLowerCase();
    return data.where((row) {
      return row.values.any((value) => 
          value.toString().toLowerCase().contains(query));
    }).toList();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _filteredRows = _applySearch(widget.rows);
      if (_sortColumnIndex != null) {
        _sortData();
      }
      // Reset to first page when searching
      _currentPage = 0;
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _sortData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate pagination
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage > _filteredRows.length)
        ? _filteredRows.length
        : startIndex + _rowsPerPage;
    
    final displayedRows = (startIndex < _filteredRows.length)
        ? _filteredRows.sublist(startIndex, endIndex)
        : [];
    
    final totalPages = (_filteredRows.length / _rowsPerPage).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Box
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
            ),
            onChanged: _onSearch,
          ),
        ),
        
        // Table
        Expanded(
          child: Card(
            elevation: 1.0,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                  dataRowMaxHeight: 60,
                  columns: _buildColumns(),
                  rows: _buildRows(displayedRows.cast<Map<String, dynamic>>()),
                ),
              ),
            ),
          ),
        ),
        
        // Pagination Controls
        if (_filteredRows.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${startIndex + 1} to $endIndex of ${_filteredRows.length} entries',
                  style: const TextStyle(color: Colors.grey),
                ),
                Row(
                  children: [
                    // First Page
                    IconButton(
                      icon: const Icon(Icons.first_page),
                      onPressed: _currentPage > 0 
                          ? () => setState(() => _currentPage = 0)
                          : null,
                      tooltip: 'First Page',
                    ),
                    // Previous Page
                    IconButton(
                      icon: const Icon(Icons.navigate_before),
                      onPressed: _currentPage > 0 
                          ? () => setState(() => _currentPage--)
                          : null,
                      tooltip: 'Previous Page',
                    ),
                    // Page Indicator
                    Text(
                      'Page ${_currentPage + 1} of $totalPages',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // Next Page
                    IconButton(
                      icon: const Icon(Icons.navigate_next),
                      onPressed: _currentPage < totalPages - 1 
                          ? () => setState(() => _currentPage++)
                          : null,
                      tooltip: 'Next Page',
                    ),
                    // Last Page
                    IconButton(
                      icon: const Icon(Icons.last_page),
                      onPressed: _currentPage < totalPages - 1 
                          ? () => setState(() => _currentPage = totalPages - 1)
                          : null,
                      tooltip: 'Last Page',
                    ),
                    // Rows Per Page Selector
                    const SizedBox(width: 16),
                    DropdownButton<int>(
                      value: _rowsPerPage,
                      items: [10, 25, 50, 100].map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value rows'),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _rowsPerPage = newValue;
                            _currentPage = 0; // Reset to first page
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<DataColumn> _buildColumns() {
    return widget.columns.asMap().entries.map((entry) {
      final index = entry.key;
      final column = entry.value;
      
      return DataColumn(
        label: Text(
          column,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onSort: (columnIndex, ascending) {
          _onSort(columnIndex, ascending);
        },
      );
    }).toList();
  }

  List<DataRow> _buildRows(List<Map<String, dynamic>> rows) {
    return rows.map((rowData) {
      return DataRow(
        cells: _buildCells(rowData),
      );
    }).toList();
  }

  List<DataCell> _buildCells(Map<String, dynamic> rowData) {
    final cells = widget.columns.map((column) {
      var cellValue = rowData[column];
      
      // Handle Actions column
      if (column == 'Actions' && (widget.onEdit != null || widget.onDelete != null)) {
        return DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => widget.onEdit!(rowData),
                  tooltip: 'Edit',
                ),
              if (widget.onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => widget.onDelete!(rowData),
                  tooltip: 'Delete',
                ),
            ],
          ),
        );
      }
      
      // For all other columns
      return DataCell(
        cellValue == null 
            ? const Text('—', style: TextStyle(color: Colors.grey))
            : Text(cellValue.toString()),
      );
    }).toList();
    
    return cells;
  }
}