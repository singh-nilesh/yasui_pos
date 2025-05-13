class AMC {
  final int? id;
  final String contractId;
  final int customerId;
  final String customerName; // Denormalized for convenience
  final int machineId;
  final String machineName; // Denormalized for convenience
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'Active', 'Expired', 'Expiring Soon'
  final DateTime? lastVisitDate;
  final DateTime? nextVisitDate;
  final double contractValue;
  final int visitFrequency; // In months (e.g., 3 for quarterly)
  final String notes;

  const AMC({
    this.id,
    required this.contractId,
    required this.customerId,
    required this.customerName,
    required this.machineId,
    required this.machineName,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.lastVisitDate,
    this.nextVisitDate,
    required this.contractValue,
    required this.visitFrequency,
    this.notes = '',
  });

  factory AMC.fromMap(Map<String, dynamic> map) {
    return AMC(
      id: map['id'],
      contractId: map['contract_id'],
      customerId: map['customer_id'],
      customerName: map['customer_name'],
      machineId: map['machine_id'],
      machineName: map['machine_name'],
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      status: map['status'],
      lastVisitDate: map['last_visit_date'] != null 
          ? DateTime.parse(map['last_visit_date']) 
          : null,
      nextVisitDate: map['next_visit_date'] != null 
          ? DateTime.parse(map['next_visit_date']) 
          : null,
      contractValue: map['contract_value'],
      visitFrequency: map['visit_frequency'],
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contract_id': contractId,
      'customer_id': customerId,
      'customer_name': customerName,
      'machine_id': machineId,
      'machine_name': machineName,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'last_visit_date': lastVisitDate?.toIso8601String(),
      'next_visit_date': nextVisitDate?.toIso8601String(),
      'contract_value': contractValue,
      'visit_frequency': visitFrequency,
      'notes': notes,
    };
  }

  AMC copyWith({
    int? id,
    String? contractId,
    int? customerId,
    String? customerName,
    int? machineId,
    String? machineName,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? lastVisitDate,
    DateTime? nextVisitDate,
    double? contractValue,
    int? visitFrequency,
    String? notes,
  }) {
    return AMC(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      machineId: machineId ?? this.machineId,
      machineName: machineName ?? this.machineName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      nextVisitDate: nextVisitDate ?? this.nextVisitDate,
      contractValue: contractValue ?? this.contractValue,
      visitFrequency: visitFrequency ?? this.visitFrequency,
      notes: notes ?? this.notes,
    );
  }
}