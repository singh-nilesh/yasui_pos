class Import {
  final int? id;
  final String partCode;
  final String name;
  final String type;  // 'machine' or 'part'
  final int? customerId;
  final int quantity;
  final DateTime? importDate;
  final double? priceUsd;
  final double? priceJpy;
  final double? priceInr;
  final String? serialNo;
  final String? invoice;
  final String status;  // 'pending' or 'delivered'
  
  // Denormalized for convenience
  final String? customerName;

  Import({
    this.id,
    required this.partCode,
    required this.name,
    required this.type,
    this.customerId,
    required this.quantity,
    this.importDate,
    this.priceUsd,
    this.priceJpy,
    this.priceInr,
    this.serialNo,
    this.invoice,
    required this.status,
    this.customerName,
  });

  factory Import.fromMap(Map<String, dynamic> map) {
    return Import(
      id: map['id'],
      partCode: map['part_code'],
      name: map['name'],
      type: map['type'],
      customerId: map['customer_id'],
      quantity: map['quantity'],
      importDate: map['import_date'] != null 
          ? DateTime.parse(map['import_date']) 
          : null,
      priceUsd: map['price_usd'],
      priceJpy: map['price_jpy'],
      priceInr: map['price_inr'],
      serialNo: map['serial_no'],
      invoice: map['invoice'],
      status: map['status'] ?? 'pending',
      customerName: map['customer_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'part_code': partCode,
      'name': name,
      'type': type,
      'customer_id': customerId,
      'quantity': quantity,
      'import_date': importDate?.toIso8601String(),
      'price_usd': priceUsd,
      'price_jpy': priceJpy,
      'price_inr': priceInr,
      'serial_no': serialNo,
      'invoice': invoice,
      'status': status,
    };
  }

  Import copyWith({
    int? id,
    String? partCode,
    String? name,
    String? type,
    int? customerId,
    int? quantity,
    DateTime? importDate,
    double? priceUsd,
    double? priceJpy,
    double? priceInr,
    String? serialNo,
    String? invoice,
    String? status,
    String? customerName,
  }) {
    return Import(
      id: id ?? this.id,
      partCode: partCode ?? this.partCode,
      name: name ?? this.name,
      type: type ?? this.type,
      customerId: customerId ?? this.customerId,
      quantity: quantity ?? this.quantity,
      importDate: importDate ?? this.importDate,
      priceUsd: priceUsd ?? this.priceUsd,
      priceJpy: priceJpy ?? this.priceJpy,
      priceInr: priceInr ?? this.priceInr,
      serialNo: serialNo ?? this.serialNo,
      invoice: invoice ?? this.invoice,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
    );
  }
}