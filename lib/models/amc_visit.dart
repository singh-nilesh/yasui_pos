class AMCVisit {
  final int? id;
  final String visitId;
  final int amcId;
  final String amcContractId; // Denormalized for convenience
  final int customerId;
  final String customerName; // Denormalized for convenience
  final int machineId;
  final String machineName; // Denormalized for convenience
  final DateTime visitDate;
  final String visitTime;
  final String engineerId;
  final String engineerName; // Denormalized for convenience
  final String status; // 'Scheduled', 'Completed', 'In Progress', 'Cancelled'
  final String notes;
  final bool isEmergency;

  const AMCVisit({
    this.id,
    required this.visitId,
    required this.amcId,
    required this.amcContractId,
    required this.customerId,
    required this.customerName,
    required this.machineId,
    required this.machineName,
    required this.visitDate,
    required this.visitTime,
    required this.engineerId,
    required this.engineerName,
    required this.status,
    this.notes = '',
    this.isEmergency = false,
  });

  factory AMCVisit.fromMap(Map<String, dynamic> map) {
    return AMCVisit(
      id: map['id'],
      visitId: map['visit_id'],
      amcId: map['amc_id'],
      amcContractId: map['amc_contract_id'],
      customerId: map['customer_id'],
      customerName: map['customer_name'],
      machineId: map['machine_id'],
      machineName: map['machine_name'],
      visitDate: DateTime.parse(map['visit_date']),
      visitTime: map['visit_time'],
      engineerId: map['engineer_id'],
      engineerName: map['engineer_name'],
      status: map['status'],
      notes: map['notes'] ?? '',
      isEmergency: map['is_emergency'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'visit_id': visitId,
      'amc_id': amcId,
      'amc_contract_id': amcContractId,
      'customer_id': customerId,
      'customer_name': customerName,
      'machine_id': machineId,
      'machine_name': machineName,
      'visit_date': visitDate.toIso8601String(),
      'visit_time': visitTime,
      'engineer_id': engineerId,
      'engineer_name': engineerName,
      'status': status,
      'notes': notes,
      'is_emergency': isEmergency ? 1 : 0,
    };
  }

  AMCVisit copyWith({
    int? id,
    String? visitId,
    int? amcId,
    String? amcContractId,
    int? customerId,
    String? customerName,
    int? machineId,
    String? machineName,
    DateTime? visitDate,
    String? visitTime,
    String? engineerId,
    String? engineerName,
    String? status,
    String? notes,
    bool? isEmergency,
  }) {
    return AMCVisit(
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      amcId: amcId ?? this.amcId,
      amcContractId: amcContractId ?? this.amcContractId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      machineId: machineId ?? this.machineId,
      machineName: machineName ?? this.machineName,
      visitDate: visitDate ?? this.visitDate,
      visitTime: visitTime ?? this.visitTime,
      engineerId: engineerId ?? this.engineerId,
      engineerName: engineerName ?? this.engineerName,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      isEmergency: isEmergency ?? this.isEmergency,
    );
  }
}