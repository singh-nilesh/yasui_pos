class AMCSchedule {
  final int? id;
  final int machineId;
  final DateTime? dueDate;
  final String? maintenanceType;
  final String status; // 'pending' or 'completed'
  final String? issue;
  final String? fix;
  final double? cost;
  
  // Denormalized for convenience
  final String? machineName;
  final String? customerName;

  AMCSchedule({
    this.id,
    required this.machineId,
    this.dueDate,
    this.maintenanceType,
    this.status = 'pending',
    this.issue,
    this.fix,
    this.cost,
    this.machineName,
    this.customerName,
  });

  factory AMCSchedule.fromMap(Map<String, dynamic> map) {
    return AMCSchedule(
      id: map['id'],
      machineId: map['machine_id'],
      dueDate: map['due_date'] != null 
          ? DateTime.parse(map['due_date']) 
          : null,
      maintenanceType: map['maintenance_type'],
      status: map['status'] ?? 'pending',
      issue: map['issue'],
      fix: map['fix'],
      cost: map['cost'],
      machineName: map['machine_name'],
      customerName: map['customer_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'machine_id': machineId,
      'due_date': dueDate?.toIso8601String(),
      'maintenance_type': maintenanceType,
      'status': status,
      'issue': issue,
      'fix': fix,
      'cost': cost,
    };
  }

  AMCSchedule copyWith({
    int? id,
    int? machineId,
    DateTime? dueDate,
    String? maintenanceType,
    String? status,
    String? issue,
    String? fix,
    double? cost,
    String? machineName,
    String? customerName,
  }) {
    return AMCSchedule(
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      dueDate: dueDate ?? this.dueDate,
      maintenanceType: maintenanceType ?? this.maintenanceType,
      status: status ?? this.status,
      issue: issue ?? this.issue,
      fix: fix ?? this.fix,
      cost: cost ?? this.cost,
      machineName: machineName ?? this.machineName,
      customerName: customerName ?? this.customerName,
    );
  }
}