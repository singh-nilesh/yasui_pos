class Machine {
  final int? id;
  final String name;
  final String serialNumber;
  final int quantity;
  final int year;
  final DateTime invoiceDate;
  final double priceInr;
  final double priceJpy;
  final double priceUsd;
  final int customerId;
  final String customerName; // Denormalized for convenience
  final DateTime? amcExpiryDate;
  final String amcStatus; // 'Active', 'Expired', 'None'
  final String visitsCompleted;

  const Machine({
    this.id,
    required this.name,
    required this.serialNumber,
    required this.quantity,
    required this.year,
    required this.invoiceDate,
    required this.priceInr,
    required this.priceJpy,
    required this.priceUsd,
    required this.customerId,
    required this.customerName,
    this.amcExpiryDate,
    this.amcStatus = 'None',
    this.visitsCompleted = '0/0',
  });

  factory Machine.fromMap(Map<String, dynamic> map) {
    return Machine(
      id: map['id'],
      name: map['name'],
      serialNumber: map['serial_number'],
      quantity: map['quantity'],
      year: map['year'],
      invoiceDate: DateTime.parse(map['invoice_date']),
      priceInr: map['price_inr'],
      priceJpy: map['price_jpy'],
      priceUsd: map['price_usd'],
      customerId: map['customer_id'],
      customerName: map['customer_name'],
      amcExpiryDate: map['amc_expiry_date'] != null 
          ? DateTime.parse(map['amc_expiry_date']) 
          : null,
      amcStatus: map['amc_status'] ?? 'None',
      visitsCompleted: map['visits_completed'] ?? '0/0',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'serial_number': serialNumber,
      'quantity': quantity,
      'year': year,
      'invoice_date': invoiceDate.toIso8601String(),
      'price_inr': priceInr,
      'price_jpy': priceJpy,
      'price_usd': priceUsd,
      'customer_id': customerId,
      'customer_name': customerName,
      'amc_expiry_date': amcExpiryDate?.toIso8601String(),
      'amc_status': amcStatus,
      'visits_completed': visitsCompleted,
    };
  }

  Machine copyWith({
    int? id,
    String? name,
    String? serialNumber,
    int? quantity,
    int? year,
    DateTime? invoiceDate,
    double? priceInr,
    double? priceJpy,
    double? priceUsd,
    int? customerId,
    String? customerName,
    DateTime? amcExpiryDate,
    String? amcStatus,
    String? visitsCompleted,
  }) {
    return Machine(
      id: id ?? this.id,
      name: name ?? this.name,
      serialNumber: serialNumber ?? this.serialNumber,
      quantity: quantity ?? this.quantity,
      year: year ?? this.year,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      priceInr: priceInr ?? this.priceInr,
      priceJpy: priceJpy ?? this.priceJpy,
      priceUsd: priceUsd ?? this.priceUsd,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      amcExpiryDate: amcExpiryDate ?? this.amcExpiryDate,
      amcStatus: amcStatus ?? this.amcStatus,
      visitsCompleted: visitsCompleted ?? this.visitsCompleted,
    );
  }
}